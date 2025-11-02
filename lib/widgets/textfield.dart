import 'package:ai_chat_app/global/util/extensions/context_extension.dart';
import 'package:ai_chat_app/global/util/extensions/text_style_extension.dart';
import 'package:ai_chat_app/theme/colors.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    super.key,
  });
  final String label;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: context.textTheme.bodyLarge.c(AppColors.white),
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        suffixIcon: suffixIcon != null
            ? Row(mainAxisSize: MainAxisSize.min, children: [suffixIcon!])
            : null,
      ),
    );
  }
}
