import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; 
import 'login.dart';
import 'feed.dart';
import 'upload.dart';
import 'profile.dart';
import 'ProfileModel.dart'; 

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileModel(), // Provider für das Profilmodell
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/main': (context) => MainPage(),
          '/upload': (context) => const UploadPage(),
          '/profile': (context) => ProfilePage(),
        },
      ),
    );
  }
}
