import 'package:ai_chat_app/core/utils/extensions/double_extension.dart';
import 'package:ai_chat_app/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

extension TextStyleX on TextStyle? {
  TextStyle? get w100 => this?.copyWith(fontWeight: FontWeight.w100);
  TextStyle? get w200 => this?.copyWith(fontWeight: FontWeight.w200);
  TextStyle? get w300 => this?.copyWith(fontWeight: FontWeight.w300);
  TextStyle? get w400 => this?.copyWith(fontWeight: FontWeight.w400);
  TextStyle? get w500 => this?.copyWith(fontWeight: FontWeight.w500);
  TextStyle? get w600 => this?.copyWith(fontWeight: FontWeight.w600);
  TextStyle? get w700 => this?.copyWith(fontWeight: FontWeight.w700);
  TextStyle? get w800 => this?.copyWith(fontWeight: FontWeight.w800);
  TextStyle? get w900 => this?.copyWith(fontWeight: FontWeight.w900);
  TextStyle? c(Color color) => this?.copyWith(color: color);
  TextStyle? ls(double spacing) =>
      this?.copyWith(letterSpacing: this?.fontSize?.percent(spacing));
  TextStyle? lh(double height) => this?.copyWith(height: height);
  TextStyle? size(double size) => this?.copyWith(fontSize: size);
  TextStyle? fontFamily(String fontFamily) =>
      this?.copyWith(fontFamily: fontFamily);
  TextStyle? get header => this?.copyWith(fontFamily: FontFamily.ranade);
}
