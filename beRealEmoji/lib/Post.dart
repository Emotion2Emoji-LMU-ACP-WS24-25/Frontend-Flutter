import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Post {
  String _id;
  String _user;
  String _time;
  Uint8List _userImage;
  Uint8List _frontImage;
  Uint8List _rearImage;
  Uint8List? _emoji; // Nullable field for e, required Uint8List userImagemoji

  Post({
    required String id,
    required String user,
    required Uint8List userImage,
    required Uint8List frontImage,
    required Uint8List rearImage,
    required String time,
    Uint8List? emoji,
  })  : _id = id,
        _user = user,
        _userImage = userImage,
        _frontImage = frontImage,
        _rearImage = rearImage,
        _time = time,
        _emoji = emoji;

  // Getters
  String get id => _id;
  String get user => _user;
  String get time => _time;
  Uint8List get userImage => _userImage;
  Uint8List get frontImage => _frontImage;
  Uint8List get rearImage => _rearImage;
  Uint8List? get emoji => _emoji;

  // Setters
  set id(String id) {
    _id = id;
  }

  set user(String user) {
    _user = user;
  }

  set time(String time) {
    _time = time;
  }

  set userImage(Uint8List userImage) {
    _userImage = userImage;
  }

  set frontImage(Uint8List frontImage) {
    _frontImage = frontImage;
  }

  set rearImage(Uint8List rearImage) {
    _rearImage = rearImage;
  }

  set emoji(Uint8List? emoji) {
    _emoji = emoji;
  }

  // Method to fetch emoji from server
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
        // Handle other status codes if necessary
      }
    } catch (e) {
      // Handle exceptions if necessary
    }
  }
}
