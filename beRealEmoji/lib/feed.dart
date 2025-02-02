import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für rootBundle
import 'package:provider/provider.dart';
import 'package:login/profile.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'Post.dart';
import 'ProfileModel.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Post> posts = [];
  int? selectedPostIndex;
  bool floatingBarVisible = false; 

  @override
  void initState() {
    super.initState();
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
    final emojis = [
      await _loadAssetImage('f0_emoji.jpg'),
      await _loadAssetImage('f1_emoji.jpg'),
      await _loadAssetImage('f2_emoji.jpg'),
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
    final captions = [
      '"Das Bayern-Spiel heute hat mich so traurig gemacht."',
      '"Heute gab es lecker Pizza, ich bin glücklich."',
      '"Ich bin sauer. Mein Icehockey-Team war heute so schlecht."',
    ];

    List<Post> newPosts = [];
    for (int i = 0; i < ids.length; i++) {
      newPosts.add(Post(
        id: ids[i],
        user: usernames[i],
        userImage: userImages[i],
        frontImage: frontImages[i],
        rearImage: rearImages[i],
        emoji: emojis[i],
        time: _generateRandomTime(),
        caption: captions[i], 
      ));
    }

    setState(() {
      posts.addAll(newPosts);
    });
  }

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
    }
  }

  void _flipImages(int index) {
    setState(() {
      final post = posts[index];
      post.isFlipped = !post.isFlipped;

      if (post.isFlipped) {
        post.frontImage = post.emoji!;
        post.rearImage = post.emoji!;
      } else {
        post.frontImage = post.defaultFrontImage;
        post.rearImage = post.defaultRearImage;
      }
    });
  }

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

  void _toggleReactionBar(int index) {
    setState(() {
      selectedPostIndex = selectedPostIndex == index ? null : index;
      floatingBarVisible = !floatingBarVisible; 
    });
  }

void _selectEmoji(int postIndex, String emojiPath) {
  setState(() {
    if (postIndex >= 0 && postIndex < posts.length) {
      posts[postIndex].selectedEmoji = emojiPath;
      floatingBarVisible = false;
      selectedPostIndex = null;
    }
  });
}




  Widget _buildFloatingBar() {
    return AnimatedOpacity(
      opacity: floatingBarVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Positioned(
        bottom: 20,
        left: 50,
        right: 50,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
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
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/maxmuster.jpg'),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: GestureDetector(
                      onTap: () => _flipImages(index),
                      child: Center(
                        child: Container(
                          width: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.3 * 255).toInt()),
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
                                      backgroundImage: MemoryImage(post.userImage),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                                      onPressed: () {},
                                    ),
                                    if (post.emoji != null)
                                      IconButton(
                                        icon: const Icon(Icons.ios_share, color: Colors.white),
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
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12.0),
                                    topRight: Radius.circular(12.0),
                                  ),
                                  child: Image.memory(
                                    post.rearImage,
                                    fit: BoxFit.cover,
                                    width: 400,
                                    height: 533,
                                  ),
                                ),
                                if (post.isFlipped) 
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Container(
                                      width: 100,
                                      height: 130,
                                      child: const ClipRRect(
                                      ),
                                    ),
                                  ),
                                if (!post.isFlipped)
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Container(
                                      width: 100,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black, width: 2),
                                        borderRadius: BorderRadius.circular(12),
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
                                if (selectedPostIndex == index)
                                  Positioned(
                                    bottom: 15,
                                    left: 80,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      width: 280,
                                      height: 40, 
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: List.generate(5, (index) {
                                          List<String> imagePaths = [
                                            'assets/happy.png',
                                            'assets/surprised.png',
                                            'assets/neutral.png',
                                            'assets/sad.png',
                                            'assets/angry.png',
                                          ];
                                          return GestureDetector(
                                            onTap: () async {
                                              _selectEmoji(selectedPostIndex!, imagePaths[index]);
                                            },
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: AssetImage(imagePaths[index]),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Image.asset(
                                          'assets/Comment.png',
                                          width: 30, 
                                          height: 30,
                                        ),
                                        onPressed: () {
                                        },
                                      ),
                                      IconButton(
                                        icon: Image.asset(
                                          'assets/ReactSmiley.png',
                                          width: 30, 
                                          height: 30,
                                        ),
                                        onPressed: () => _toggleReactionBar(index),
                                      ),
                                    ],
                                  ),
                                ),
                                if (post.selectedEmoji != null)
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: AssetImage(post.selectedEmoji!), 
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0.0),
                              child: Container(
                                width: 400, 
                                decoration: const BoxDecoration(
                                  color: Colors.white, 
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12.0), 
                                    bottomRight: Radius.circular(12.0),
                                  ),
                                ),
                                padding: const EdgeInsets.all(8.0), 
                                child: Text(
                                  post.caption,
                                  style: const TextStyle(
                                    color: Colors.black, 
                                    fontSize: 16.0,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildFloatingBar(), 
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
                child: Icon(Icons.camera_alt, color: Colors.white, size: 40),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
