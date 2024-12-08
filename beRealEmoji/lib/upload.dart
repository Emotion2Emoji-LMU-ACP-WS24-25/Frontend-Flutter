import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  Uint8List? _frontImageBytes; 
  Uint8List? _rearImageBytes;

  final ImagePicker _picker = ImagePicker();

//  Future<void> _pickFrontImage() async {
//    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//    if (pickedFile != null) {
//      setState(() async {
//        _frontImageBytes = await pickedFile.readAsBytes();
//      });
//    }
//  }

Future<void> _pickFrontImage() async {
  // Bild aus der Galerie auswählen (asynchron)
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  // Wenn ein Bild ausgewählt wurde, führe die asynchrone Operation (readAsBytes) außerhalb von setState aus
  if (pickedFile != null) {
    // Zuerst die asynchrone Arbeit ausführen
    final frontImageBytes = await pickedFile.readAsBytes();

    // Dann den Zustand aktualisieren, indem du setState aufrufst
    setState(() {
      _frontImageBytes = frontImageBytes;  // Hier wird nur der Zustand gesetzt
    });
  }
}


//  Future<void> _pickRearImage() async {
//    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//    if (pickedFile != null) {
//      setState(() async {
//        _rearImageBytes = await pickedFile.readAsBytes();
//      });
//    }
//  }

Future<void> _pickRearImage() async {
  // Zuerst die asynchrone Arbeit ausführen (Bild auswählen)
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  // Wenn ein Bild ausgewählt wurde, führe die asynchrone Operation readAsBytes() aus
  if (pickedFile != null) {
    // Asynchrone Arbeit ausführen und den Wert in eine Variable speichern
    final rearImageBytes = await pickedFile.readAsBytes();

    // Den Zustand mit setState() aktualisieren
    setState(() {
      _rearImageBytes = rearImageBytes; // Den Zustand mit den geladenen Bildbytes aktualisieren
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
                  if (_frontImageBytes != null)
                    Image.memory(
                      _frontImageBytes!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickRearImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    ),
                    child: const Text('Upload Back/Rear Image'),
                  ),
                  const SizedBox(height: 16),
                  if (_rearImageBytes != null)
                    Image.memory(
                      _rearImageBytes!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickRearImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    ),
                    child: const Text('Created BeReal Image'),
                  ),
                  const SizedBox(height: 16),
                  if (_rearImageBytes != null)
                    Stack(
                      children: [
                        Image.memory(
                          _rearImageBytes!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        if (_frontImageBytes != null)
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
                                child: Image.memory(
                                  _frontImageBytes!,
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
