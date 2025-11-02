import 'package:ai_chat_app/screens/chat_screen.dart';
import 'package:ai_chat_app/screens/welcome.dart';
import 'package:ai_chat_app/services/supabase_service.dart';
import 'package:ai_chat_app/theme/colors.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _supabase = SupabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _supabase.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          );
        }

        // Check if user is logged in
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // User is logged in, go to chat
          return ChatScreen();
        } else {
          // User is not logged in, show welcome
          return WelcomeScreen();
        }
      },
    );
  }
}
