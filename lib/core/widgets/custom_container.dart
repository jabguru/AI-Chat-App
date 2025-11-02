import 'package:ai_chat_app/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? color;
  final double? circularBorderRadius;
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? hPadding;
  final double? vPadding;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  const CustomContainer({
    super.key,
    this.height,
    this.width,
    this.color,
    this.circularBorderRadius,
    this.child,
    this.padding,
    this.margin,
    this.hPadding,
    this.vPadding,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            borderRadius ??
            (circularBorderRadius != null
                ? BorderRadius.circular(circularBorderRadius!)
                : null),
        border: border,
        boxShadow: boxShadow,
      ),
      height: height,
      width: width,
      padding:
          padding ??
          ((hPadding != null || vPadding != null)
              ? EdgeInsets.symmetric(
                  horizontal: hPadding ?? 0.0,
                  vertical: vPadding ?? 0.0,
                )
              : null),
      margin: margin,
      child: child,
    );
  }
}

class AnimatedCustomContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? color;
  final double? circularBorderRadius;
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? hPadding;
  final double? vPadding;
  final BorderRadius? borderRadius;
  final bool hasShadow;
  final bool hasBorder;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  const AnimatedCustomContainer({
    super.key,
    this.height,
    this.width,
    this.color,
    this.circularBorderRadius,
    this.child,
    this.padding,
    this.margin,
    this.hPadding,
    this.vPadding,
    this.borderRadius,
    this.hasShadow = false,
    this.hasBorder = false,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Durations.short4,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius:
            borderRadius ??
            (circularBorderRadius != null
                ? BorderRadius.circular(circularBorderRadius!)
                : null),
        boxShadow: boxShadow,
        border: border,
      ),
      height: height,
      width: width,
      padding:
          padding ??
          ((hPadding != null || vPadding != null)
              ? EdgeInsets.symmetric(
                  horizontal: hPadding ?? 0.0,
                  vertical: vPadding ?? 0.0,
                )
              : null),
      margin: margin,
      child: child,
    );
  }
}
