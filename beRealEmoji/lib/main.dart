import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _frontImage;
  File? _rearImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFrontImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _frontImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickRearImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _rearImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Upload BeReal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Upload Front and Rear Images',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Front Image Upload Section
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickFrontImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    ),
                    child: const Text('Upload Front Image'),
                  ),
                  const SizedBox(height: 16),
                  if (_frontImage != null)
                    Image.file(
                      _frontImage!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              const SizedBox(height: 40),
              // Rear Image Upload Section
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickRearImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    ),
                    child: const Text('Upload Rear Image'),
                  ),
                  const SizedBox(height: 16),
                  if (_rearImage != null)
                    Stack(
                      children: [
                        Image.file(
                          _rearImage!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        if (_frontImage != null)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _frontImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}