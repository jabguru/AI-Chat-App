import 'package:ai_chat_app/gen/assets.gen.dart';
import 'package:ai_chat_app/global/util/extensions/context_extension.dart';
import 'package:ai_chat_app/theme/colors.dart';
import 'package:ai_chat_app/widgets/button.dart';
import 'package:ai_chat_app/widgets/space.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: context.eqH(64.0),
              left: 0,
              right: 0,
              child: Assets.images.robotWelcome.image(
                height: context.eqH(334.0),
              ),
            ),
            Positioned(
              top: context.eqH(213.0),
              left: 0,
              right: 0,
              child: Assets.images.handsWelcome.image(
                // width: context.eqH(409.06),
                height: context.eqH(409.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      style: context.textTheme.headlineMedium,
                      children: [
                        TextSpan(
                          text: 'ChatGPT ',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        TextSpan(
                          text: '- Your AI\n Chat ',
                          style: TextStyle(color: AppColors.white),
                        ),
                        TextSpan(
                          text: 'Partner',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  VerticalSpacing(8.0),
                  Text(
                    "Unlock Infinite Conversations: ChatGPT,\nYour AI Companion!",
                    textAlign: TextAlign.center,
                  ),
                  VerticalSpacing(23.0),
                  AppButton(text: 'Log In'),
                  VerticalSpacing(16.0),
                  AppButton(text: 'Create Account', isOutline: true),
                  VerticalSpacing(12.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
