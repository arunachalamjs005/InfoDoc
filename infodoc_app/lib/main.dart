import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const InfoDocApp());
}

class InfoDocApp extends StatelessWidget {
  const InfoDocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfoDoc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
