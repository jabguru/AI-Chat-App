import 'package:ai_chat_app/core/theme/colors.dart';
import 'package:ai_chat_app/core/utils/extensions/context_extension.dart';
import 'package:ai_chat_app/core/utils/extensions/text_style_extension.dart';
import 'package:ai_chat_app/core/utils/validators.dart';
import 'package:ai_chat_app/core/widgets/app_scaffold.dart';
import 'package:ai_chat_app/core/widgets/button.dart';
import 'package:ai_chat_app/core/widgets/checkbox.dart';
import 'package:ai_chat_app/core/widgets/loading_provider.dart';
import 'package:ai_chat_app/core/widgets/password_field.dart';
import 'package:ai_chat_app/core/widgets/space.dart';
import 'package:ai_chat_app/core/widgets/textfield.dart';
import 'package:ai_chat_app/features/auth/presentation/login.dart';
import 'package:ai_chat_app/features/auth/providers/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  bool _agreed = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    ref.read(loadingProvider.notifier).show();

    try {
      await ref
          .read(authProvider.notifier)
          .signUp(_emailController.text.trim(), _passwordController.text);

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created! Please check your email to verify your account before logging in.',
            ),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
              'Sign up failed: $error',
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
            Text(
              'Create your account',
              style: context.textTheme.headlineMedium,
            ),
            VerticalSpacing(8.0),
            Text(
              'To begin using the chat GPT, please create an account with your email address.',
            ),
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
              validator: Validators.passwordValidator,
            ),
            VerticalSpacing(20.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCheckbox(
                  value: _agreed,
                  onChanged: (value) => setState(() {
                    _agreed = value!;
                  }),
                ),
                HorizontalSpacing(10.0),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'By continuing you agree to the chat GPT ',
                        ),
                        TextSpan(
                          text: 'Term of Service ',
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                        TextSpan(text: 'and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                  text: 'Continue',
                  isDisabled:
                      isLoading ||
                      !_agreed ||
                      Validators.emailValidator(_emailController.text) !=
                          null ||
                      Validators.passwordValidator(_passwordController.text) !=
                          null,
                  onTap: _handleSignUp,
                );
              },
            ),
            VerticalSpacing(20.0),
            Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Log In ',
                      style: TextStyle(color: AppColors.primary),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => LoginScreen()),
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
