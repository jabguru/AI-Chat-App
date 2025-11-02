import 'package:ai_chat_app/screens/welcome.dart';
import 'package:ai_chat_app/theme/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ai Chat App',
      theme: AppTheme.themeData,
      home: WelcomeScreen(),
    );
  }
}
