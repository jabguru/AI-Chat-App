import 'package:ai_chat_app/features/chat/presentation/chat_screen.dart';
import 'package:ai_chat_app/features/auth/presentation/welcome.dart';
import 'package:ai_chat_app/shared/services/supabase_service.dart';
import 'package:ai_chat_app/core/theme/colors.dart';
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

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return ChatScreen();
        } else {
          return WelcomeScreen();
        }
      },
    );
  }
}
