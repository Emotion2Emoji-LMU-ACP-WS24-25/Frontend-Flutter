import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für rootBundle

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Map<String, dynamic>> posts = [];

  // Funktion zum Laden der Bilddateien aus den Assets
  Future<Uint8List> _loadAssetImage(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    return byteData.buffer.asUint8List();
  }

  @override
  void initState() {
    super.initState();
    // Standard-Posts beim Start hinzufügen
    _loadDefaultPosts();
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
    final rearImages = [
      await _loadAssetImage('br1.jpg'),
      await _loadAssetImage('br2.jpg'),
      await _loadAssetImage('br3.jpg'),
      await _loadAssetImage('br4.jpg'),
      await _loadAssetImage('br5.jpg'),
    ];

    setState(() {
      for (int i = 0; i < rearImages.length; i++) {
        posts.add({
          'id': DateTime.now().toString(),
          'user': _generateRandomUsername(),
          'frontImage': null,
          'rearImage': rearImages[i],
          'time': _generateRandomTime(),
        });
      }
    });
  }

  void _addNewPost(Map<String, dynamic> newPost) {
    final postTime = DateTime.now();
    setState(() {
      posts.insert(0, {
        'id': newPost['id'],
        'user': 'Me',
        'frontImage': newPost['frontImage'],
        'rearImage': newPost['rearImage'],
        'time': _getTimeAgo(postTime),
      });
    });
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Column(
          children: [
            const Text(
              'Recent Posts',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Container(
                        width: 350,
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12.0)),
                              child: Image.memory(
                                post['rearImage'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 466,
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
                              bottom: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/upload');
          if (result != null && result is Map<String, dynamic> && mounted) {
            _addNewPost(result);
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        label: const Text('Upload BeReal'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
