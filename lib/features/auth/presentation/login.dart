import 'package:ai_chat_app/core/theme/colors.dart';
import 'package:ai_chat_app/core/utils/extensions/context_extension.dart';
import 'package:ai_chat_app/core/utils/extensions/text_style_extension.dart';
import 'package:ai_chat_app/core/utils/validators.dart';
import 'package:ai_chat_app/core/widgets/app_scaffold.dart';
import 'package:ai_chat_app/core/widgets/button.dart';
import 'package:ai_chat_app/core/widgets/loading_provider.dart';
import 'package:ai_chat_app/core/widgets/password_field.dart';
import 'package:ai_chat_app/core/widgets/space.dart';
import 'package:ai_chat_app/core/widgets/textfield.dart';
import 'package:ai_chat_app/features/auth/presentation/create_account.dart';
import 'package:ai_chat_app/features/auth/providers/auth_provider.dart';
import 'package:ai_chat_app/features/chat/presentation/chat_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    ref.read(loadingProvider.notifier).show();

    try {
      await ref
          .read(authProvider.notifier)
          .signIn(_emailController.text.trim(), _passwordController.text);

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => ChatScreen()));
      }
    } catch (e) {
      if (mounted) {
        String error = 'An error occured';
        if (e is AuthApiException) {
          error = e.message;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed: $error',
              style: context.textTheme.bodyMedium.c(AppColors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      ref.read(loadingProvider.notifier).hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: context.bottomViewInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log In', style: context.textTheme.headlineMedium),
            VerticalSpacing(8.0),
            Text('Welcome back to chat GPT 👋'),
            VerticalSpacing(32.0),
            AppTextField(
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.emailValidator,
              controller: _emailController,
            ),
            VerticalSpacing(24.0),
            PasswordField(
              label: 'Password',
              controller: _passwordController,
              validator: Validators.emptyValidator,
            ),
            VerticalSpacing(20.0),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Forgot Password?',
                style: context.textTheme.bodyMedium.c(AppColors.textSecondary),
              ),
            ),
            VerticalSpacing(24.0),
            ListenableBuilder(
              listenable: Listenable.merge([
                _emailController,
                _passwordController,
              ]),
              builder: (context, child) {
                final isLoading = ref.watch(loadingProvider);
                return AppButton(
                  text: 'Log In',
                  isDisabled:
                      isLoading ||
                      Validators.emailValidator(_emailController.text) !=
                          null ||
                      Validators.emptyValidator(_passwordController.text) !=
                          null,
                  onTap: _handleLogin,
                );
              },
            ),
            VerticalSpacing(20.0),
            Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Don\'t have an account? '),
                    TextSpan(
                      text: 'Create account ',
                      style: TextStyle(color: AppColors.primary),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => CreateAccountScreen(),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
