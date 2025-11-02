import 'package:ai_chat_app/theme/colors.dart';
import 'package:ai_chat_app/widgets/custom_container.dart';
import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  const CustomCheckbox({super.key, this.value, this.onChanged});

  @override
  State<CustomCheckbox> createState() => CustomCheckboxState();
}

class CustomCheckboxState extends State<CustomCheckbox> {
  bool? isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isChecked = !isChecked!;
          widget.onChanged!(isChecked);
        });
      },
      child: AnimatedCustomContainer(
        width: 18.0,
        height: 18.0,
        color: isChecked! ? AppColors.primary : AppColors.white,
        circularBorderRadius: 4.0,
        border: isChecked!
            ? null
            : Border.all(color: AppColors.textColor, width: 1.0),
        child: isChecked!
            ? Icon(Icons.check, color: AppColors.white, size: 15.0)
            : null,
      ),
    );
  }
}

class CustomValueCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  const CustomValueCheckbox({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedCustomContainer(
      width: 18.0,
      height: 18.0,
      color: value ? AppColors.primary : AppColors.white,
      circularBorderRadius: 4.0,
      border: value ? null : Border.all(color: AppColors.textColor, width: 1.0),
      child: value
          ? Icon(Icons.check, color: AppColors.white, size: 15.0)
          : null,
    );
  }
}
