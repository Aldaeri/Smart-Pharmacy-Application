import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:google_ml_kit/google_ml_kit.dart';


class ImageAnalysisOnly extends StatelessWidget {
  const ImageAnalysisOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تحليل الصور',
      home: const TextExtractionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TextExtractionPage extends StatefulWidget {
  const TextExtractionPage({super.key});

  @override
  State<TextExtractionPage> createState() => _TextExtractionPageState();
}

class _TextExtractionPageState extends State<TextExtractionPage> {
  File? _imageFile;
  final picker = ImagePicker();
  bool _isAnalyzing = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _analyzeImage(File(pickedFile.path));
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _analyzeImage(File(pickedFile.path));
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String extractedText = recognizedText.text;

      await textRecognizer.close();

      if (mounted) {
        _showExtractedTextDialog(context, extractedText);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحليل النص: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showExtractedTextDialog(BuildContext context, String text) {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد نص في الصورة.')),
      );
      Navigator.pop(context); // Close dialog
      Navigator.pop(context, ''); // Go back with empty string
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('النص المستخرج'),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, text); // Go back with extracted text
            },
            child: const Text('موافق'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل النص من الصورة'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : const Text('لم يتم اختيار صورة.'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('اختيار صورة (المعرض)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('التقاط صورة'),
            ),
            if (_isAnalyzing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}