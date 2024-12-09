import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//neue importe für anbindung an express server
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';


class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  Uint8List? _frontImageBytes;
  Uint8List? _rearImageBytes;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFrontImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final frontImageBytes = await pickedFile.readAsBytes();
      setState(() {
        _frontImageBytes = frontImageBytes;
      });
    }
  }

  Future<void> _pickRearImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final rearImageBytes = await pickedFile.readAsBytes();
      setState(() {
        _rearImageBytes = rearImageBytes;
      });
    }
  }

  void _postBeReal() {
    if (_frontImageBytes != null && _rearImageBytes != null) {
      final newPost = {
        'frontImage': _frontImageBytes,
        'rearImage': _rearImageBytes,
      };
      Navigator.pop(context, newPost); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both front and rear images')),
      );
    }
  }

   // Funktion zum Hochladen der Bilder an den express server
  Future<void> _uploadImages() async {
    if (_frontImageBytes != null && _rearImageBytes != null) {
      try {
        // Erstelle Multipart-Anfrage
        var request = http.MultipartRequest('POST', Uri.parse('http://localhost:3000/daily_upload'));

        // Füge das Bild und den Benutzernamen als Formulardaten hinzu
        request.fields['user'] = 'user123';  // Beispielbenutzername, du kannst ihn nach Bedarf anpassen

        request.files.add(http.MultipartFile.fromBytes(
          'front', 
          _frontImageBytes!, 
          filename: 'front.jpg', 
          contentType: MediaType('image', 'jpeg'),
        ));

        request.files.add(http.MultipartFile.fromBytes(
          'back', 
          _rearImageBytes!, 
          filename: 'back.jpg', 
          contentType: MediaType('image', 'jpeg'),
        ));

        // Sende die Anfrage und empfange die Antwort
        var response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final jsonResponse = jsonDecode(responseData);
          print('Bilder erfolgreich hochgeladen: ${jsonResponse['message']}');
        } else {
          print('Fehler beim Hochladen der Bilder: ${response.statusCode}');
        }
      } catch (e) {
        print('Fehler beim Hochladen der Bilder: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both front and rear images')),
      );
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  if (_rearImageBytes != null)
                    Image.memory(
                      _rearImageBytes!,
                      height: 350, 
                      width: 250,  
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      height: 350,  
                      width: 250,   
                      color: Colors.grey[800],
                      child: const Center(
                        child: Text(
                          'Placeholder',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  if (_frontImageBytes != null)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _postBeReal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                ),
                child: const Text('Post BeReal'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _pickFrontImage,
                child: const Text('Upload Front Image'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickRearImage,
                child: const Text('Upload Rear Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
