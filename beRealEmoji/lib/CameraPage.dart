import 'package:flutter/material.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Page'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Camera Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
