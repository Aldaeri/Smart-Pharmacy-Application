import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_pharmacy_app/constants/colors.dart';
import '../models/medicine_model.dart';
import 'medicine_detail_screen.dart';

class ImageSearchScreen extends StatefulWidget {
  final Function(String) toggleFavorite;
  final Set<String> favorites;

  const ImageSearchScreen({
    required this.toggleFavorite,
    required this.favorites,
    super.key,
  });

  @override
  _ImageSearchScreenState createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  File? _image;
  bool _isProcessing = false;
  List<Medicine> _foundMedicines = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isProcessing = true;
        _foundMedicines = [];
      });
      await _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;

    // محاولة التعرف على النص أولاً
    String extractedText = await _extractTextFromImage(_image!);

    // إذا لم يتم العثور على نص، جرب التعرف على الدواء مباشرة
    if (extractedText.isEmpty) {
      extractedText = await _recognizeDrugFromImage(_image!);
    }

    // البحث في قاعدة البيانات
    await _searchMedicines(extractedText);

    setState(() => _isProcessing = false);
  }

  Future<String> _extractTextFromImage(File image) async {
    try {
      return await FlutterTesseractOcr.extractText(
        image.path,
        args: {
          "psm": "4",
          "preserve_interword_spaces": "1",
        },
        language: 'ara+eng',
      );
    } catch (e) {
      print('Error in OCR: $e');
      return '';
    }
  }

  Future<String> _recognizeDrugFromImage(File image) async {
    // final visionImage = FirebaseVisionImage.fromFile(image);
    // final textRecognizer = FirebaseVision.instance.textRecognizer();
    // final visionText = await textRecognizer.processImage(visionImage);
    // textRecognizer.close();
    //
    // String recognizedText = '';
    // for (TextBlock block in visionText.blocks) {
    //   for (TextLine line in block.lines) {
    //     recognizedText += '${line.text} ';
    //   }
    // }
    // return recognizedText.trim();
    return '';
  }

  Future<void> _searchMedicines(String query) async {
    if (query.isEmpty) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('medicines')
        .where('keywords', arrayContains: query.toLowerCase())
        .limit(10)
        .get();

    setState(() {
      _foundMedicines = snapshot.docs
          .map((doc) => Medicine.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
            'البحث عن الأدوية بالصورة',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isProcessing
                ? Center(child: CircularProgressIndicator())
                : _image == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'قم بتحميل صورة الدواء أو الوصفة الطبية',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
                : _buildResultsView(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () => _pickImage(ImageSource.camera),
            tooltip: 'التقاط صورة',
            child: Icon(Icons.camera_alt),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () => _pickImage(ImageSource.gallery),
            tooltip: 'اختيار من المعرض',
            child: Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    if (_foundMedicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لم يتم العثور على أدوية مطابقة',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _foundMedicines.length,
      itemBuilder: (context, index) {
        final medicine = _foundMedicines[index];
        return ListTile(
          leading: medicine.image!.isNotEmpty
              ? Image.network(medicine.image!, width: 50, height: 50)
              : Icon(Icons.medication, size: 50),
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicineDetailsScreen(medicine: medicine),
              ),
            );
          },
        );
      },
    );
  }
}