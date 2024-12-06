import 'package:flutter/material.dart';
import 'login.dart';
import 'feed.dart'; 
import 'upload.dart'; 
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/main': (context) => MainPage(),
        '/upload': (context) => const UploadPage(), // UploadPage hinzugefügt
      },
    );
  }
}
