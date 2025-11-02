import 'package:ai_chat_app/global/util/extensions/context_extension.dart';
import 'package:ai_chat_app/global/util/extensions/text_style_extension.dart';
import 'package:ai_chat_app/global/util/validators.dart';
import 'package:ai_chat_app/screens/create_account.dart';
import 'package:ai_chat_app/theme/colors.dart';
import 'package:ai_chat_app/widgets/app_scaffold.dart';
import 'package:ai_chat_app/widgets/button.dart';
import 'package:ai_chat_app/widgets/password_field.dart';
import 'package:ai_chat_app/widgets/space.dart';
import 'package:ai_chat_app/widgets/textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
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
                return AppButton(
                  text: 'Log In',
                  isDisabled:
                      Validators.emailValidator(_emailController.text) !=
                          null ||
                      Validators.emptyValidator(_passwordController.text) !=
                          null,
                  onTap: () {},
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
