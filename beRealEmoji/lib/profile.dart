
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
  import 'dart:convert'; 

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "Max Musterman";
  String bio = "Ich heiße zwar nicht Bob, aber bin trotzdem ein Baumeister.";

  List<dynamic> reactions = [
    'assets/happy.png',  
    'assets/surprised.png',
    'assets/neutral.png',
    'assets/sad.png',
    'assets/angry.png'
  ];

  List<String> reactionLabels = [
    "Happy",
    "Surprised",
    "Neutral",
    "Sad",
    "Angry"
  ];

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  

Future<void> _saveImage(int index, Uint8List byteData) async {
  final prefs = await SharedPreferences.getInstance();
  String base64Image = base64Encode(byteData); // Konvertiere in Base64
  prefs.setString('reaction_$index', base64Image);
}

Future<void> _loadImages() async {
  final prefs = await SharedPreferences.getInstance();
  bool updated = false;

  for (int i = 0; i < reactions.length; i++) {
    String? savedImage = prefs.getString('reaction_$i');
    if (savedImage != null && savedImage.isNotEmpty) {
      try {
        reactions[i] = base64Decode(savedImage);
        updated = true;
      } catch (e) {
        print("Fehler beim Laden des Bildes $i: $e");
      }
    }
  }

  if (updated) {
    setState(() {}); 
  }
}




  Future<void> _pickImage(int index) async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  
  if (pickedFile != null) {
    final byteData = await pickedFile.readAsBytes();

    setState(() {
      reactions[index] = byteData; 
    });

    _saveImage(index, byteData);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'BeReal. ',
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/maxmuster.jpg'),
              ),
              const SizedBox(height: 20),
              _buildInfoContainer("Name", username),
              const SizedBox(height: 10),
              _buildInfoContainer("Bio", bio),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: _buildReactionContainer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String title, String content) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 400,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey)),
          Text(
            content,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReactionContainer() {
    return Container(
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
                      onTap: () => _pickImage(index),
                      child: reactions[index] is Uint8List
  ? Image.memory(reactions[index], width: 40, height: 40)
  : Image.asset(reactions[index], width: 40, height: 40),

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
    );
  }
}
