import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/medicine_model.dart';
import 'medicine_detail_screen.dart';

class AdvancedImageSearchScreen extends StatefulWidget {
  final Function(String) toggleFavorite;
  final Set<String> favorites;

  const AdvancedImageSearchScreen({
    required this.toggleFavorite,
    required this.favorites,
    Key? key,
  }) : super(key: key);

  @override
  _AdvancedImageSearchScreenState createState() => _AdvancedImageSearchScreenState();
}

class _AdvancedImageSearchScreenState extends State<AdvancedImageSearchScreen> {
  File? _image;
  bool _isProcessing = false;
  List<Medicine> _foundMedicines = [];
  final ImagePicker _picker = ImagePicker();
  String _processingText = '';
  String _searchResult = 'قم بالتقاط صورة للدواء أو اختر من المعرض';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _copyTessDataToAppDir();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.storage].request();
  }

  Future<void> _copyTessDataToAppDir() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tessDir = Directory('${appDir.path}/tessdata');

      if (!await tessDir.exists()) {
        await tessDir.create(recursive: true);
      }

      final assets = [
        'assets/tessdata/ara.traineddata',
        'assets/tessdata/eng.traineddata',
      ];

      for (final asset in assets) {
        final data = await rootBundle.load(asset);
        final file = File('${tessDir.path}/${asset.split('/').last}');
        if (!await file.exists()) {
          await file.writeAsBytes(data.buffer.asUint8List());
        }
      }
    } catch (e) {
      print('Error copying tessdata: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _image = File(pickedFile.path);
          _isProcessing = true;
          _foundMedicines = [];
          _processingText = 'جاري معالجة الصورة...';
        });

        final ocrText = await _processImage(File(pickedFile.path));
        if (ocrText.isNotEmpty) {
          await _searchMedicines(ocrText);
        } else {
          setState(() {
            _searchResult = 'لم يتم التعرف على نص في الصورة';
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      _handleError(e);
      setState(() => _isProcessing = false);
    }
  }

  Future<String> _processImage(File image) async {
    try {
      // 1. استخراج النص باستخدام Tesseract
      final ocrText = await _extractTextWithOCR(image);
      if (ocrText.isNotEmpty) return ocrText;

      // 2. إذا فشل Tesseract، جرب ML Kit
      setState(() => _processingText = 'جاري المحاولة بطريقة أخرى...');
      final mlText = await _recognizeTextWithMLKit(image);

      return mlText.isNotEmpty ? mlText : '';
    } catch (e) {
      print('Image processing error: $e');
      return '';
    }
  }

  Future<String> _extractTextWithOCR(File image) async {
    try {
      if (!await image.exists()) return '';

      final processedImage = await _preprocessImageForOCR(image);
      final tessDataDir = '${await getApplicationDocumentsDirectory()}/tessdata';

      final result = await FlutterTesseractOcr.extractText(
        processedImage.path,
        language: 'ara+eng',
        args: {
          "psm": "6",
          "oem": "1",
          "preserve_interword_spaces": "1",
          "tessedit_char_whitelist": "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZأ-ي",
          "tessdata_dir": tessDataDir
        },
      );

      return result?.trim() ?? '';
    } catch (e) {
      print('OCR Error: $e');
      return '';
    }
  }

  Future<File> _preprocessImageForOCR(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final imageObj = img.decodeImage(bytes)!;

      // تحسين جودة الصورة
      final processedImage = img.copyResize(imageObj, width: 1200);
      img.grayscale(processedImage);
      img.adjustColor(processedImage, contrast: 1.5, brightness: 0.9);

      // حفظ الصورة المؤقتة
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(tempPath).writeAsBytes(img.encodePng(processedImage));

      return File(tempPath);
    } catch (e) {
      print('Image preprocessing error: $e');
      return image;
    }
  }

  Future<String> _recognizeTextWithMLKit(File image) async {
    try {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();
      return recognizedText.text;
    } catch (e) {
      print('ML Kit Error: $e');
      return '';
    }
  }

  Future<void> _searchMedicines(String text) async {
    if (text.isEmpty) {
      setState(() => _searchResult = 'لم يتم إدخال نص للبحث');
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _processingText = 'جاري البحث في قاعدة البيانات...';
      });

      final queries = [
        _firestore.collection('medicines')
            .where('keywords', arrayContains: text.toLowerCase()),

        _firestore.collection('medicines')
            .where('medicineName', isGreaterThanOrEqualTo: text.toLowerCase())
            .where('medicineName', isLessThan: text.toLowerCase() + 'z'),

        _firestore.collection('medicines')
            .where('scientificName', isGreaterThanOrEqualTo: text.toLowerCase())
            .where('scientificName', isLessThan: text.toLowerCase() + 'z')
      ];

      List<Medicine> results = [];

      for (final query in queries) {
        if (results.length >= 5) break;

        final snapshot = await query.limit(5 - results.length).get();
        final newResults = snapshot.docs
            .map((doc) => Medicine.fromFirestore(doc))
            .where((med) => !results.any((m) => m.id == med.id));

        results.addAll(newResults);
      }

      setState(() {
        _foundMedicines = results;
        _searchResult = results.isEmpty
            ? 'لم يتم العثور على أدوية مطابقة'
            : 'تم العثور على ${results.length} نتيجة';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _searchResult = 'حدث خطأ أثناء البحث: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  void _handleError(dynamic error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${error.toString()}')),
      );
    }
    print('Error: $error');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'البحث بالصورة',
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          children: [
            if (_image != null) _buildImagePreview(),
            Expanded(child: _buildContent()),
          ],
        ),
        if (_isProcessing) _buildProgressOverlay(),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(_image!, height: 200, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildContent() {
    if (_isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_processingText),
          ],
        ),
      );
    }

    return _foundMedicines.isEmpty
        ? _buildEmptyState()
        : _buildResultsList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            _image == null
                ? 'قم بالتقاط صورة للدواء أو اختر من المعرض'
                : _searchResult,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          if (_image != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showManualSearchDialog,
              child: const Text('ابحث يدويًا'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_searchResult, style: const TextStyle(fontSize: 16)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _foundMedicines.length,
            itemBuilder: (context, index) {
              final medicine = _foundMedicines[index];
              return _buildMedicineCard(medicine);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.medication, size: 40),
        title: Text(medicine.medicineName),
        subtitle: Text(medicine.scientificMaterial),
        trailing: IconButton(
          icon: Icon(
            widget.favorites.contains(medicine.id)
                ? Icons.favorite
                : Icons.favorite_border,
            color: Colors.red,
          ),
          onPressed: () => widget.toggleFavorite(medicine.id),
        ),
        onTap: () => _navigateToDetails(medicine),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'gallery',
          onPressed: () => _pickImage(ImageSource.gallery),
          tooltip: 'المعرض',
          child: const Icon(Icons.photo_library),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          heroTag: 'camera',
          onPressed: () => _pickImage(ImageSource.camera),
          child: const Icon(Icons.camera_alt),
          tooltip: 'الكاميرا',
        ),
      ],
    );
  }

  Widget _buildProgressOverlay() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _navigateToDetails(Medicine medicine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailsScreen(medicine: medicine),
      ),
    );
  }

  void _showManualSearchDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث اليدوي'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'أدخل اسم الدواء',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _searchMedicines(textController.text);
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعليمات البحث'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('• التقط صورة واضحة للدواء أو الوصفة الطبية'),
              SizedBox(height: 8),
              Text('• تأكد من إضاءة جيدة وعدم وجود ظلال'),
              SizedBox(height: 8),
              Text('• ركز على أسماء الأدوية أو الباركود'),
              SizedBox(height: 8),
              Text('• يمكنك البحث يدويًا إذا لم ينجح التعرف التلقائي'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

// class AdvancedImageSearchScreen extends StatefulWidget {
//   final Function(String) toggleFavorite;
//   final Set<String> favorites;
//
//   const AdvancedImageSearchScreen({
//     required this.toggleFavorite,
//     required this.favorites,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _AdvancedImageSearchScreenState createState() => _AdvancedImageSearchScreenState();
// }
//
// class _AdvancedImageSearchScreenState extends State<AdvancedImageSearchScreen> {
//   File? _image;
//   bool _isProcessing = false;
//   List<Medicine> _foundMedicines = [];
//   final _picker = ImagePicker();
//   String _processingText = '';
//   double _processingProgress = 0;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   String _searchResult = 'اضغط للبحث'; // القيمة الافتراضية
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//
//   }
//
//   Future<void> _requestPermissions() async {
//     await [Permission.camera, Permission.photos].request();
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//
//     try {
//
//       final pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1200,
//         maxHeight: 1200,
//         imageQuality: 85,
//       );
//
//       // if (pickedFile != null && mounted) {
//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//           _isProcessing = true;
//           _foundMedicines = [];
//           _processingText = 'جاري معالجة الصورة...';
//         });
//
//         final result = await _processImageAndConfirm(File(pickedFile.path));
//         if (result != null && result.isNotEmpty) {
//           setState(() => _processingText = '...جاري البحث عن الأدوية');
//           await _searchMedicines(result);
//         }
//       }
//     } catch (e) {
//       _handleError(e);
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }
//
//   Future<String?> _processImageAndConfirm(File image) async {
//     try {
//       // 1. تحسين الصورة
//       setState(() => _processingText = 'جاري تحسين جودة الصورة...');
//       final processedImage = await _preprocessImage(image);
//       _updateProgress(0.2);
//
//       // 2. استخراج النص
//       setState(() => _processingText = 'جاري استخراج النص من الصورة...');
//       final ocrText = await _extractTextWithOCR(processedImage);
//       final mlText = await _recognizeTextWithMLKit(processedImage);
//       _updateProgress(0.5);
//
//       // 3. تنظيف النص
//       final combinedText = _cleanSearchText('$ocrText $mlText');
//       if (combinedText.isEmpty) {
//         _showError('لم يتم العثور على نص قابل للقراءة');
//         return null;
//       }
//
//       final confirmedText = await showDialog<String>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('النص المستخرج من الصورة'),
//           content: SingleChildScrollView(
//             child: Text(combinedText),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إلغاء'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, combinedText),
//               child: Text('بحث'),
//             ),
//           ],
//         ),
//       );
//
//       // 4. عرض النص للمستخدم للتأكيد
//       return await _showTextConfirmationDialog(combinedText);
//       return confirmedText;
//     } catch (e) {
//       _handleError(e);
//       return null;
//     }
//   }
//
//   Future<String> _extractTextWithOCR(File image) async {
//     try {
//       // 1. معالجة مسبقة للصورة
//       final img.Image? decodedImage = img.decodeImage(await image.readAsBytes());
//       if (decodedImage == null) return '';
//
//       // 2. تحسين التباين والحدة
//       final processedImage = img.grayscale(decodedImage);
//       final tempFile = File('${(await getTemporaryDirectory()).path}/processed_${DateTime.now().millisecondsSinceEpoch}.png');
//       await tempFile.writeAsBytes(img.encodePng(processedImage));
//
//       // 3. استدعاء Tesseract مع معاملات محسنة
//       final result = await FlutterTesseractOcr.extractText(
//         tempFile.path,
//         language: 'ara+eng',
//         args: {
//           "psm": "11",  // أفضل للصور غير المنتظمة
//           "oem": "1",   // نمط LSTM فقط
//           "preserve_interword_spaces": "1",
//           "tessedit_char_whitelist": "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZأ-ي",
//           "tessdata_dir": "${await getApplicationDocumentsDirectory()}/tessdata/"
//         },
//       );
//
//       // 4. تنظيف الملف المؤقت
//       await tempFile.delete();
//
//       return result?.trim() ?? '';
//
//     } catch (e) {
//       // print('OCR Error: $e');
//       print('OCR Processing Error: $e');
//       return '';
//     }
//   }
//
//   Future<String> _recognizeTextWithMLKit(File image) async {
//     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//     final inputImage = InputImage.fromFilePath(image.path);
//     final recognizedText = await textRecognizer.processImage(inputImage);
//     textRecognizer.close();
//     return recognizedText.text;
//
//   }
//
//   Future<String?> _showTextConfirmationDialog(String text) async {
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('النص المستخرج من الصورة'),
//         content: SingleChildScrollView(
//           child: Text(text),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, text),
//             child: Text('بحث'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _searchMedicines(String query) async {
//     setState(() => _searchResult = 'جاري البحث...');
//     if (query.isEmpty) {
//       setState(() => _searchResult = 'لم يتم التعرف على نص');
//       return;
//     }
//
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('medicines')
//           .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
//           .limit(1)
//           .get();
//
//       setState(() {
//         _searchResult = snapshot.docs.isEmpty
//             ? 'الدواء غير موجود'
//             : 'تم العثور على: ${snapshot.docs.first['name']}';
//       });
//     } catch (e) {
//       setState(() => _searchResult = 'خطأ في البحث: ${e.toString()}');
//     }
//
//   }
//
//   Future<File> _preprocessImage(File image) async {
//     try {
//       final bytes = await image.readAsBytes();
//       final imageObj = img.decodeImage(bytes)!;
//
//       final adjustedImage = img.adjustColor(
//         imageObj,
//         contrast: 1.5,
//         brightness: 0.2,
//       );
//
//       final croppedImage = img.copyCrop(
//         adjustedImage,
//         x: (adjustedImage.width * 0.1).toInt(),
//         y: (adjustedImage.height * 0.1).toInt(),
//         width: (adjustedImage.width * 0.8).toInt(),
//         height: (adjustedImage.height * 0.8).toInt(),
//       );
//
//       final tempDir = await getTemporaryDirectory();
//       final path = '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       await File(path).writeAsBytes(img.encodeJpg(croppedImage));
//
//       return File(path);
//     } catch (e) {
//       print('Error preprocessing image: $e');
//       return image;
//     }
//   }
//
//   String _cleanSearchText(String text) {
//     return text
//         .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s]'), '')
//         .split(' ')
//         .where((word) => word.length > 2)
//         .join(' ')
//         .toLowerCase();
//   }
//
//   void _updateProgress(double progress) {
//     if (mounted) {
//       setState(() => _processingProgress = progress);
//     }
//   }
//
//   void _handleError(dynamic error) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('حدث خطأ: ${error.toString()}')),
//       );
//     }
//     print('Error: $error');
//   }
//
//   void _showPermissionError(String permission) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('تم رفض صلاحية $permission'),
//           action: SnackBarAction(
//             label: 'الإعدادات',
//             onPressed: openAppSettings,
//           ),
//         ),
//       );
//     }
//   }
//
//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('البحث المتقدم بالصورة'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.info_outline),
//             onPressed: _showHelpDialog,
//           ),
//         ],
//       ),
//       body: _buildBody(),
//       floatingActionButton: _buildFloatingButtons(),
//     );
//   }
//
//   Widget _buildBody() {
//     return Stack(
//       children: [
//         Column(
//           children: [
//             if (_image != null) _buildImagePreview(),
//             Expanded(child: _buildContent()),
//           ],
//         ),
//         if (_isProcessing) _buildProgressOverlay(),
//       ],
//     );
//   }
//
//   Widget _buildImagePreview() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Image.file(_image!, height: 200, fit: BoxFit.cover),
//       ),
//     );
//   }
//
//   Widget _buildContent() {
//     if (_isProcessing) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text(_processingText),
//           ],
//         ),
//       );
//     }
//
//     return _foundMedicines.isEmpty
//         ? _buildEmptyState()
//         : _buildResultsList();
//   }
//
//   Widget _buildResultsList() {
//     return ListView.builder(
//       padding: EdgeInsets.all(8),
//       itemCount: _foundMedicines.length,
//       itemBuilder: (context, index) {
//         final medicine = _foundMedicines[index];
//         return Card(
//           margin: EdgeInsets.symmetric(vertical: 4),
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: InkWell(
//             borderRadius: BorderRadius.circular(10),
//             onTap: () => _navigateToDetails(medicine),
//             child: Padding(
//               padding: EdgeInsets.all(12),
//               child: ListTile(
//                 leading: _buildMedicineImage(medicine),
//                 title: Text(
//                   medicine.medicineName,
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(medicine.scientificMaterial),
//                     if (medicine.barcode != null)
//                       Text('باركود: ${medicine.barcode}'),
//                     if (medicine.price > 0)
//                       Text('السعر: ${medicine.price} ريال'),
//                   ],
//                 ),
//                 trailing: _buildFavoriteIcon(medicine),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildMedicineImage(Medicine medicine) {
//     if (medicine.image != null && medicine.image!.isNotEmpty) {
//       return Image.network(
//         medicine.image!,
//         width: 50,
//         height: 50,
//         errorBuilder: (_, __, ___) => Icon(Icons.medication, size: 50),
//       );
//     }
//     return Icon(Icons.medication, size: 50);
//   }
//
//   Widget _buildFavoriteIcon(Medicine medicine) {
//     return IconButton(
//       icon: Icon(
//         widget.favorites.contains(medicine.id)
//             ? Icons.favorite
//             : Icons.favorite_border,
//         color: Colors.red,
//       ),
//       onPressed: () => widget.toggleFavorite(medicine.id),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
//           SizedBox(height: 16),
//           Text(
//             _image == null
//                 ? 'قم بتحميل صورة الدواء أو الوصفة الطبية'
//                 : 'لم يتم العثور على أدوية مطابقة',
//             style: TextStyle(fontSize: 16),
//           ),
//           Text(
//             _searchResult, // هذا ما يعرض النتيجة
//             style: TextStyle(fontSize: 20, color: Colors.blue),
//           ),
//           if (_image != null) ...[
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _showManualSearchDialog,
//               child: Text('ابحث يدويًا'),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFloatingButtons() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         FloatingActionButton(
//           heroTag: 'camera',
//           onPressed: () => _pickImage(ImageSource.camera),
//           child: Icon(Icons.camera_alt),
//           tooltip: 'التقاط صورة',
//         ),
//         SizedBox(height: 10),
//         FloatingActionButton(
//           heroTag: 'gallery',
//           onPressed: () => _pickImage(ImageSource.gallery),
//           child: Icon(Icons.photo_library),
//           tooltip: 'اختيار من المعرض',
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProgressOverlay() {
//     return Positioned(
//       bottom: 20,
//       left: 20,
//       right: 20,
//       child: LinearProgressIndicator(
//         value: _processingProgress,
//         backgroundColor: Colors.grey[200],
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//       ),
//     );
//   }
//
//   void _navigateToDetails(Medicine medicine) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MedicineDetailsScreen(medicine: medicine),
//       ),
//     );
//   }
//
//   void _showManualSearchDialog() {
//     final textController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('البحث اليدوي'),
//         content: TextField(
//           controller: textController,
//           decoration: InputDecoration(
//             hintText: 'أدخل اسم الدواء أو المادة الفعالة',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               setState(() => _isProcessing = true);
//               await _searchMedicines(textController.text);
//               setState(() => _isProcessing = false);
//             },
//             child: Text('بحث'),
//           ),
//           Text(
//             _searchResult, // هذا ما يعرض النتيجة
//             style: TextStyle(fontSize: 20, color: Colors.blue),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showHelpDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('كيفية الاستخدام'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('• التقط صورة واضحة للدواء أو الوصفة الطبية'),
//               SizedBox(height: 8),
//               Text('• تأكد من إضاءة جيدة وعدم وجود ظلال'),
//               SizedBox(height: 8),
//               Text('• ركز على أسماء الأدوية أو الباركود'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('حسناً'),
//           ),
//         ],
//       ),
//     );
//   }
// }
