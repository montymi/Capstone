import 'package:flutter/material.dart';
import '../models/station.dart';

class StationScreen extends StatelessWidget {
  final Station station;
  const StationScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(station.name),
        backgroundColor: Colors.black87,
      ),
      body: const Center(child: Text('Station Screen')),
    );
  }
}
