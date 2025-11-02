import 'package:flutter/material.dart';

class HorizontalSpacing extends StatelessWidget {
  const HorizontalSpacing(this.width, {super.key});
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}

class VerticalSpacing extends StatelessWidget {
  const VerticalSpacing(this.height, {super.key});
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

double eqH(BuildContext context, double height) {
  double heightInDesign = 852.0;
  double screenHeight = MediaQuery.sizeOf(context).height;
  return (height / heightInDesign) * screenHeight;
}

double eqW(BuildContext context, double width) {
  double widthInDesign = 393.0;
  double screenWidth = MediaQuery.sizeOf(context).width;
  return (width / widthInDesign) * screenWidth;
}
