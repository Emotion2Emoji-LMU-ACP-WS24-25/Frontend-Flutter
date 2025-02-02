import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'ProfileModel.dart'; 
import 'upload.dart'; 

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "Max Musterman";
  String bio = "Ich heiße zwar nicht Bob, aber bin trotzdem ein Baumeister.";
  List<String> reactions = [
    'assets/happy.png',
    'assets/surprised.png',
    'assets/neutral.png',
    'assets/sad.png',
    'assets/angry.png',
  ];

  List<String> reactionLabels = ["Happy", "Surprised", "Neutral", "Sad", "Angry"];
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'BeReal.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/maxmuster.jpg'),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: EdgeInsets.all(10),
              width: 400,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text("Name", style: TextStyle(color: Colors.grey)),
                  Text(
                    username,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            Container(
              padding: EdgeInsets.all(10),
              width: 400,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text("Bio", style: TextStyle(color: Colors.grey)),
                  Text(
                    bio,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Container(
                padding: EdgeInsets.all(10),
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      isExpanded ? "Click on an emoji to change it" : "Reactions",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(reactions.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => UploadPage()),
                                  );
                                  if (result != null) {
                                    Provider.of<ProfileModel>(context, listen: false)
                                        .setCustomReaction(index, result);
                                  }
                                },
                                child: Consumer<ProfileModel>(
                                  builder: (context, profileModel, child) {
                                    String emojiPath = profileModel.customReactions.containsKey(index)
                                        ? profileModel.customReactions[index]!
                                        : reactions[index];
                                    return Image.asset(emojiPath, width: 40, height: 40);
                                  },
                                ),
                              ),
                              if (isExpanded)
                                Text(
                                  reactionLabels[index],
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
