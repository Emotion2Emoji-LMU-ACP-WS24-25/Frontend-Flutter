import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Post {
  final String id;
  final String user;
  final Uint8List userImage;
  Uint8List frontImage;
  Uint8List rearImage;
  Uint8List? emoji;
  String? selectedEmoji; 
  final String time;
  bool isFlipped;
  final Uint8List defaultFrontImage;
  final Uint8List defaultRearImage;
  final String caption;

  Post({
    required this.id,
    required this.user,
    required this.userImage,
    required this.frontImage,
    required this.rearImage,
    this.emoji,
    this.selectedEmoji,
    required this.time,
    this.isFlipped = false,
    required this.caption,
  }) : defaultFrontImage = frontImage, defaultRearImage = rearImage;

  // Methode, um ein Asset-Bild als Uint8List zu laden
  Future<Uint8List> loadAssetImage(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    return byteData.buffer.asUint8List();
  }

  // Methode, um ein Emoji von einem Backend-Server herunterzuladen
  Future<void> fetchEmoji() async {
    final url = Uri.parse("${dotenv.get('BACKEND_URL', fallback: "")}/download")
        .replace(
      queryParameters: {
        'id': id,
        'user': user,
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        emoji = response.bodyBytes;
      } else {
      }
    } catch (e) {
    }
  }

  void setSelectedEmoji(String emojiPath) {
    selectedEmoji = emojiPath;
  }
}
