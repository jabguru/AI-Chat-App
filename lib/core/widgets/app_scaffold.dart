import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.appBar,
    this.hasPadding = true,
    this.resizeToAvoidBottomInset,
    this.padding,
    this.backgroundColor,
    super.key,
  });
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool hasPadding;
  final bool? resizeToAvoidBottomInset;
  final double? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: appBar,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Padding(
          padding: hasPadding
              ? EdgeInsets.symmetric(horizontal: padding ?? 20.0)
              : EdgeInsets.zero,
          child: body,
        ),
      ),
    );
  }
}
