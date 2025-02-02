import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:login/Post.dart';
import 'package:flutter/services.dart' show rootBundle;

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  Uint8List? _frontImageBytes;
  Uint8List? _rearImageBytes;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera([int cameraIndex = 0]) async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![cameraIndex], // Use the specified camera
      ResolutionPreset.high,
    );
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final XFile image = await _cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();
      setState(() {
        if (_isFrontCamera) {
          _frontImageBytes = imageBytes;
        } else {
          _rearImageBytes = imageBytes;
        }
      });
    }
  }

  Future<void> _captureBothImages() async {
    // Capture front camera image
    await _initializeCamera(1); // Assuming front camera is at index 1
    await _captureImage();

    _isFrontCamera = false;

    // Add a short delay
    await Future.delayed(const Duration(milliseconds: 2000));

    // Capture rear camera image
    await _initializeCamera(0); // Assuming rear camera is at index 0
    await _captureImage();

    _postBeReal();
  }

  void _rotateCamera() {
    if (_cameras != null && _cameras!.length > 1) {
      final currentIndex = _cameras!.indexOf(_cameraController!.description);
      final nextIndex = (currentIndex + 1) % _cameras!.length;
      _initializeCamera(nextIndex);
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFrontImage() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if (pickedFile != null) {
      final frontImageBytes = await pickedFile.readAsBytes();
      setState(() {
        _frontImageBytes = frontImageBytes;
      });
    }
  }

  Future<void> _pickRearImage() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      final rearImageBytes = await pickedFile.readAsBytes();
      setState(() {
        _rearImageBytes = rearImageBytes;
      });
    }
  }

  void _postBeReal() async {
    final ByteData data = await rootBundle.load('assets/default_user.jpeg');
    final Uint8List userImageBytes = data.buffer.asUint8List();
    if (_frontImageBytes != null && _rearImageBytes != null) {
      var jobId = await _uploadImages();
      final newPost = Post(
        id: jobId!, // Replace with actual jobId if available
        user: 'Demo@LMU',
        userImage:
            userImageBytes, // Replace with actual user image if available
        frontImage: _frontImageBytes!,
        rearImage: _rearImageBytes!,
        time:
            "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
        caption: '', // Replace with actual caption if available
      );
      Navigator.pop(context, newPost);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload both front and rear images')),
      );
    }
  }

  // Funktion zum Hochladen der Bilder an server
  Future<String?> _uploadImages() async {
    if (_frontImageBytes != null && _rearImageBytes != null) {
      // Erstellen eines Multipart-FormData Requests
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            "${dotenv.get('BACKEND_URL', fallback: "")}/daily_upload"), // URL des Express Servers
      );
      request.headers.addAll({
        'ngrok-skip-browser-warning': 'Servus',
      });

      // Füge die Bilder zum Request hinzu
      var frontImage = http.MultipartFile.fromBytes(
        'front', // Name des Form-Feldes im Express-Server
        _frontImageBytes!,
        contentType: MediaType('image', 'jpeg'), // MIME-Typ für Bilder
        filename: 'front_image.jpg',
      );

      var rearImage = http.MultipartFile.fromBytes(
        'back', // Name des Form-Feldes im Express-Server
        _rearImageBytes!,
        contentType: MediaType('image', 'jpeg'), // MIME-Typ für Bilder
        filename: 'rear_image.jpg',
      );

      // Füge das Frontbild und Rückbild zum Request hinzu
      request.files.add(frontImage);
      request.files.add(rearImage);

      // Füge zusätzliche Formulardaten hinzu
      request.fields['user'] = 'Demo@LMU'; // Benutzername als Form-Feld

      try {
        // Sende die Anfrage
        var response = await request.send();

        // Antwort verarbeiten
        if (response.statusCode == 200) {
          print('Bilder erfolgreich hochgeladen!');
          final responseData = await response.stream.bytesToString();
          final job_id = jsonDecode(responseData)['id'];
          print('Job ID: $job_id');
          return job_id;
        } else {
          print('Fehler beim Hochladen der Bilder: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fehler beim Hochladen')));
          return null;
        }
      } catch (e) {
        print('Fehler: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler beim Hochladen')));
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload both front and rear images')),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Page'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _captureBothImages,
                  child: const Icon(Icons.camera),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _rotateCamera,
                  child: const Icon(Icons.cameraswitch),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
