import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';
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
  String caption;

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
  })  : defaultFrontImage = frontImage,
        defaultRearImage = rearImage;

  // Methode, um ein Asset-Bild als Uint8List zu laden
  Future<Uint8List> loadAssetImage(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    return byteData.buffer.asUint8List();
  }

  // Methode, um ein Emoji von einem Backend-Server herunterzuladen
  Future<String> fetchData() async {
    final url = Uri.parse("${dotenv.get('BACKEND_URL', fallback: "")}/download")
        .replace(
      queryParameters: {
        'id': id,
        'user': user,
      },
    );

    final url_caption =
        Uri.parse("${dotenv.get('BACKEND_URL', fallback: "")}/caption").replace(
      queryParameters: {
        'id': id,
        'user': user,
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        emoji = response.bodyBytes;
        final responseCaption = await http.get(url_caption);
        final body = json.decode(responseCaption.body);
        caption = body['caption'];
        print(caption);
        return 'successful';
      } else {
        return 'Still processing ...';
      }
    } catch (e) {
      return 'Error occurred while fetching emoji';
    }
  }

  void setSelectedEmoji(String emojiPath) {
    selectedEmoji = emojiPath;
  }
}
