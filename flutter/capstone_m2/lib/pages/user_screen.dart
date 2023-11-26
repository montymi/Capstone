import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M2Solar'),
        backgroundColor: Colors.black87,
      ),
      body: const Center(child: Text('User Screen')),
    );
  }
}
