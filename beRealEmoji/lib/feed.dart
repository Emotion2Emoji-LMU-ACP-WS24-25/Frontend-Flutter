import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für rootBundle
import 'package:login/profile.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'Post.dart';
import 'package:avatar_glow/avatar_glow.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Post> posts = [];
  int? selectedPostIndex;
  bool floatingBarVisible = false;
  bool _showOverlay = false;

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
    final times = [
      '12:04',
      '13:41',
      '15:55',
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
        time: times[i],
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
    } catch (e) {}
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

  void _showOverlayImage() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'BeReal.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.people, color: Colors.white),
          onPressed: () {
            // Add your onPressed code here!
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/maxmuster.jpg'),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProfilePage();
              }));
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
                  posts.sort((a, b) => b.time.compareTo(a.time));
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GestureDetector(
                      onDoubleTap: () => _showOverlayImage(),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width - 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
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
                                    if (post.emoji == null)
                                      IconButton(
                                        icon: const Icon(Icons.refresh_outlined,
                                            color: Colors.white),
                                        onPressed: () async {
                                          final result =
                                              await post.fetchEmoji();
                                          print(result);
                                        },
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
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                        bottomLeft: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0)),
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
                                      width: 110,
                                      height: 145,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.memory(
                                          post.frontImage,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (selectedPostIndex == index)
                                    Positioned(
                                      bottom: 140,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                20,
                                        height: 120,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
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
                                                _selectEmoji(selectedPostIndex!,
                                                    imagePaths[index]);
                                              },
                                              child: Container(
                                                width: 65,
                                                height: 65,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.black,
                                                    width:
                                                        3.0, // Adjust the width as needed
                                                  ),
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        imagePaths[index]),
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
                                        if (post.emoji != null)
                                          Positioned(
                                            top: 20,
                                            right: 20,
                                            child: AvatarGlow(
                                              glowRadiusFactor: 0.1,
                                              curve: Curves.fastOutSlowIn,
                                              glowColor: Colors.black,
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.touch_app_rounded,
                                                    color: Colors.grey,
                                                    size: 25),
                                                onPressed: () {},
                                              ),
                                            ),
                                          ),
                                        IconButton(
                                          icon: Image.asset(
                                            'assets/Comment.png',
                                            width: 25,
                                            height: 25,
                                          ),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: Image.asset(
                                            'assets/ReactSmiley.png',
                                            width: 25,
                                            height: 25,
                                          ),
                                          onPressed: () =>
                                              _toggleReactionBar(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (post.selectedEmoji != null)
                                    Positioned(
                                      bottom: 15,
                                      left: 15,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image:
                                                AssetImage(post.selectedEmoji!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_showOverlay && post.emoji != null)
                                    Positioned(
                                      top: 20,
                                      right: 20,
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: const Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Image.memory(
                                            post.emoji!,
                                            width: 140,
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                              SizedBox(
                                width: 400,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    post.caption,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11),
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
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          final newPost = await Navigator.pushNamed(context, '/upload');
          if (newPost != null && newPost is Post) {
            setState(() {
              posts.add(newPost);
            });
          }
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            color: Colors.white,
          ),
          child: const Stack(
            children: [
              Center(
                child: Icon(Icons.camera_alt_rounded,
                    color: Colors.black, size: 30),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
