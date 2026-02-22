import 'package:flutter/material.dart';

enum SnackBarType { success, error, info }

void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
  bool fromTop = false,
}) {
  final backgroundColor = switch (type) {
    SnackBarType.success => Colors.green,
    SnackBarType.error => Colors.red,
    SnackBarType.info => null,
  };

  final topPadding = MediaQuery.of(context).padding.top;
  final margin = fromTop
      ? EdgeInsets.fromLTRB(16, topPadding + 12, 16, 0)
      : const EdgeInsets.fromLTRB(16, 0, 16, 12);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: margin,
    ),
  );
}
