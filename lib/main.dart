import 'package:ai_chat_app/screens/auth_wrapper.dart';
import 'package:ai_chat_app/screens/welcome.dart';
import 'package:ai_chat_app/screens/chat_screen.dart';
import 'package:ai_chat_app/services/supabase_service.dart';
import 'package:ai_chat_app/theme/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
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
      home: AuthWrapper(),
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/chat': (context) => ChatScreen(),
      },
    );
  }
}
