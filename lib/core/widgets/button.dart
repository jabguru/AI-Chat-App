import 'package:ai_chat_app/core/utils/extensions/context_extension.dart';
import 'package:ai_chat_app/core/utils/extensions/text_style_extension.dart';
import 'package:ai_chat_app/core/theme/colors.dart';
import 'package:ai_chat_app/core/widgets/custom_container.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    this.onTap,
    this.isOutline = false,
    this.isDisabled = false,
    super.key,
  });
  final String text;
  final VoidCallback? onTap;
  final bool isOutline;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: isDisabled ? 0.2 : 1.0,
        child: CustomContainer(
          color: isOutline ? Colors.transparent : AppColors.primary,
          vPadding: 14.0,
          hPadding: 24.0,
          width: double.infinity,
          circularBorderRadius: 15.0,
          border: isOutline ? Border.all(color: AppColors.primary) : null,
          child: Center(
            child: Text(
              text,
              style: context.textTheme.bodyLarge.header.w700.c(
                isOutline ? AppColors.primary : AppColors.background,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
