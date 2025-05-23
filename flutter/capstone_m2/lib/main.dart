import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'M2Solar',
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}
