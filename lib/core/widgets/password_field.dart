import 'package:ai_chat_app/core/widgets/textfield.dart';
import 'package:ai_chat_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.label,
    this.controller,
    this.onChanged,
    this.validator,
    super.key,
  });
  final String label;
  final TextEditingController? controller;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      suffixIcon: GestureDetector(
        onTap: () => setState(() {
          _obscureText = !_obscureText;
        }),
        child: _obscureText
            ? Assets.images.icons.passwordOn.svg()
            : Assets.images.icons.passwordOff.svg(),
      ),
    );
  }
}
