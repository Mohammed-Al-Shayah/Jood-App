import 'package:flutter/material.dart';

enum SnackBarType { success, error, info }

void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
}) {
  final backgroundColor = switch (type) {
    SnackBarType.success => Colors.green,
    SnackBarType.error => Colors.red,
    SnackBarType.info => null,
  };

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: backgroundColor),
  );
}
