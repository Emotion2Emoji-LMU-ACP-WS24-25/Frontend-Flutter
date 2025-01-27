import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für rootBundle
import 'post.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Post> posts = [];
  bool _showCircles = false;

  @override
  void initState() {
    super.initState();
    // Standard-Posts beim Start hinzufügen
    _loadDefaultPosts();
  }

  Future<void> _loadDefaultPosts() async {
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
    final userImages = [
      await _loadAssetImage('maxmuster.jpg'),
      await _loadAssetImage('maxmuster.jpg'),
      await _loadAssetImage('maxmuster.jpg'),
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

    List<Post> newPosts = [];
    for (int i = 0; i < ids.length; i++) {
      newPosts.add(Post(
        id: ids[i],
        user: usernames[i],
        userImage: userImages[i],
        frontImage: frontImages[i],
        rearImage: rearImages[i],
        time: _generateRandomTime(),
      ));
    }

    setState(() {
      posts.addAll(newPosts);
    });
  }

  // Funktion zum Laden der Bilddateien aus den Assets
  Future<Uint8List> _loadAssetImage(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    return byteData.buffer.asUint8List();
  }

  Future<void> _shareEmoji(Uint8List emoji) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/emoji.png').create();
      await file.writeAsBytes(emoji);

      final xFile = XFile(file.path);
      Share.shareXFiles([xFile]);
    } catch (e) {
      //Error handling
    }
  }

  void _toggleCircles() {
    setState(() {
      _showCircles = !_showCircles;
    });
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

  // void _addPost(String id, String user, Uint8List userImage,
  //     Uint8List frontImage, Uint8List rearImage, String time) {
  //   posts.add(Post(
  //     id: id,
  //     user: user,
  //     userImage: userImage,
  //     frontImage: frontImage,
  //     rearImage: rearImage,
  //     time: time,
  //   ));
  // }

  // TODO Flip Card to show emoji (with animation)

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
            onPressed: () {
              for (var post in posts) {
                post.fetchEmoji().then((_) {
                  setState(() {});
                });
              }
            },
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/maxmuster.jpg'),
            ),
            onPressed: () {
              // Add your onPressed code here!
            },
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
                              color:
                                  Colors.black.withAlpha((0.3 * 255).toInt()),
                              blurRadius: 8.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20.0,
                                    backgroundImage:
                                        MemoryImage(post.userImage),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.user,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        post.time,
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
                                  if (post.emoji != null)
                                    IconButton(
                                      icon: const Icon(Icons.ios_share,
                                          color: Colors.white),
                                      onPressed: () {
                                        _shareEmoji(post.emoji!);
                                      },
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
                                    post.rearImage,
                                    fit: BoxFit.cover,
                                    width: 400,
                                    height: 533,
                                  ),
                                ),
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
                                        post.frontImage,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                if (post.emoji != null)
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: GestureDetector(
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.memory(post.emoji!,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 80,
                                  right: 0,
                                  child: TextButton(
                                    onPressed: () {
                                      _toggleCircles();
                                    },
                                    child: const Text(
                                      '😀',
                                      style: TextStyle(fontSize: 40),
                                    ),
                                  ),
                                ),
                                if (_showCircles)
                                  Positioned(
                                    bottom: 16,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        final emojis = [
                                          '😍',
                                          '😡',
                                          '😲',
                                          '🤢',
                                          '😢'
                                        ];
                                        final images = [
                                          'assets/emoji.jpg',
                                          'assets/emoji.jpg',
                                          'assets/emoji.jpg',
                                          'assets/emoji.jpg',
                                          'assets/emoji.jpg'
                                        ];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 2),
                                                ),
                                                child: ClipOval(
                                                  child: Image.asset(
                                                    images[index],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: -4,
                                                right: -4,
                                                child: Text(
                                                  emojis[index],
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
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
          if (result != null && result is Map<String, dynamic> && mounted) {}
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
