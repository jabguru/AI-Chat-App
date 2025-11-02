import 'package:ai_chat_app/widgets/space.dart' as space;
import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.of(this).size;
  double eqH(double height) => space.eqH(this, height);
  double eqW(double width) => space.eqW(this, width);
  double get bottomViewInset => MediaQuery.of(this).viewInsets.bottom;
  double get fullBottomSheetHeight => screenSize.height * 0.8;
}
