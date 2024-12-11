import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für rootBundle
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Map<String, dynamic>> posts = [];
  bool _isButtonDisabled = false;

  // Funktion zum Laden der Bilddateien aus den Assets
  Future<Uint8List> _loadAssetImage(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List?> _fetchImage(String postId, String user) async {
    final url = Uri.parse("${dotenv.get('BACKEND_URL', fallback: "")}/download")
        .replace(
      queryParameters: {
        'id': postId,
        'user': user,
      },
    );

    int attempts = 0;
    const maxAttempts = 8;
    const delayDuration = Duration(seconds: 15);

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(url);

        if (response.statusCode == 422) {
          return await _getFallbackImage();
        }

        if (response.statusCode == 200) {
          return response.bodyBytes;
        } else {
          print('Attempt ${attempts + 1}: ${response.statusCode}');
        }
      } catch (e) {
        print('Network error on attempt ${attempts + 1}: $e');
        return await _getFallbackImage();
      }

      attempts++;
      if (attempts < maxAttempts) {
        await Future.delayed(delayDuration);
      }
    }
    print(
        'Failed to download image after $attempts attempts. Returning fallback image.');
    return await _getFallbackImage();
  }

  Future<Uint8List> _getFallbackImage() async {
    return (await rootBundle.load('assets/maxmuster.jpg')).buffer.asUint8List();
  }

  @override
  void initState() {
    super.initState();
    // Standard-Posts beim Start hinzufügen
    //_loadDefaultPosts();
  }

  // Zufällige Benutzernamen erstellen
  String _generateRandomUsername() {
    const names = [
      'Alice',
      'Bob',
      'Charlie',
      'David',
      'Eve',
      'Frank',
      'Grace',
      'Hannah',
      'Ivy',
      'Jack'
    ];
    final random = Random();
    return names[random.nextInt(names.length)];
  }

  // Zufällige Zeitstempel generieren
  String _generateRandomTime() {
    final random = Random();
    final now = DateTime.now();
    final randomMinutes = random.nextInt(60); // Zufällige Minuten
    final randomHours = random.nextInt(24); // Zufällige Stunden
    final randomDays = random.nextInt(7); // Zufällige Tage

    final randomTime = now.subtract(Duration(
      days: randomDays,
      hours: randomHours,
      minutes: randomMinutes,
    ));

    return _getTimeAgo(randomTime);
  }

  String _getTimeAgo(DateTime postTime) {
    final now = DateTime.now();
    final difference = now.difference(postTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Future<void> _loadDefaultPosts() async {
    _isButtonDisabled = true;

    final rearImages = [
      await _loadAssetImage('b0.jpg'),
      await _loadAssetImage('b1.jpg'),
      await _loadAssetImage('b2.jpg'),
    ];
    final frontImages = [
      await _loadAssetImage('f0.jpg'),
      await _loadAssetImage('f1.jpg'),
      await _loadAssetImage('f2.jpg'),
    ];
    final usernames = [
      'BayernFan1900',
      'Maggus',
      'Emanuel',
    ];
    final ids = [
      '675955c6b174d862f28b31d0',
      '6758c6475d9247cd8202c99f',
      '67595d32b174d862f28b31ee',
    ];

    setState(() {
      for (int i = 0; i < rearImages.length; i++) {
        posts.add({
          'id': ids[i],
          'user': usernames[i],
          'frontImage': frontImages[i],
          'rearImage': rearImages[i],
          'time': _generateRandomTime(),
        });
      }
    });
  }

  void _addNewPost(Map<String, dynamic> newPost) async {
    final postTime = DateTime.now();
    setState(() {
      posts.insert(0, {
        'id': newPost['id'],
        'user': newPost['user'],
        'frontImage': newPost['frontImage'],
        'rearImage': newPost['rearImage'],
        'time': _getTimeAgo(postTime),
      });
    });
  }

  void _showFullScreenImage(BuildContext context, Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Close dialog on tap
          child: Image.memory(
            imageData,
            fit: BoxFit.contain,
            width: 400,
            height: 400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'BeReal.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sync),
            color: Colors.white,
            onPressed: _isButtonDisabled ? null : _loadDefaultPosts,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Center(
                      child: Container(
                        width: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              // Header bar with user info
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 20.0,
                                    backgroundImage: AssetImage(
                                        'assets/maxmuster.jpg'), // User avatar from assets
                                  ),
                                  const SizedBox(width: 12.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post['user'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        post['time'],
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.more_horiz,
                                        color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0)),
                                  child: Image.memory(
                                    post['rearImage'],
                                    fit: BoxFit.cover,
                                    width: 400,
                                    height: 533,
                                  ),
                                ),
                                if (post['frontImage'] != null)
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Container(
                                      width: 100,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          post['frontImage'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: GestureDetector(
                                    onTap: () async {
// Fetch the full-size image data
                                      final fullImage = await _fetchImage(
                                          post['id'], post['user']);
                                      if (fullImage != null) {
                                        _showFullScreenImage(
                                            context, fullImage);
                                      }
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: FutureBuilder<Uint8List?>(
                                          future: _fetchImage(
                                              post['id'], post['user']),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                    ConnectionState.waiting ||
                                                snapshot.data == null) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasData) {
                                              return Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          final result = await Navigator.pushNamed(context, '/upload');
          if (result != null && result is Map<String, dynamic> && mounted) {
            _addNewPost(result);
          }
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            color: Colors.transparent,
          ),
          child: const Stack(
            children: [
              Center(
                child: Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
