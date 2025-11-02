import 'package:ai_chat_app/global/util/extensions/context_extension.dart';
import 'package:ai_chat_app/global/util/validators.dart';
import 'package:ai_chat_app/screens/login.dart';
import 'package:ai_chat_app/theme/colors.dart';
import 'package:ai_chat_app/widgets/app_scaffold.dart';
import 'package:ai_chat_app/widgets/button.dart';
import 'package:ai_chat_app/widgets/checkbox.dart';
import 'package:ai_chat_app/widgets/password_field.dart';
import 'package:ai_chat_app/widgets/space.dart';
import 'package:ai_chat_app/widgets/textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _agreed = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
                return AppButton(
                  text: 'Continue',
                  isDisabled:
                      !_agreed ||
                      Validators.emailValidator(_emailController.text) !=
                          null ||
                      Validators.passwordValidator(_passwordController.text) !=
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
