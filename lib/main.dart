import 'package:ai_chat_app/core/theme/theme.dart';
import 'package:ai_chat_app/core/widgets/loading_overlay.dart';
import 'package:ai_chat_app/features/auth/presentation/auth_wrapper.dart';
import 'package:ai_chat_app/shared/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ai Chat App',
      theme: AppTheme.themeData,
      home: LoadingOverlay(child: AuthWrapper()),
    );
  }
}
