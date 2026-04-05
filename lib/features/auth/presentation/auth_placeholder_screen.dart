import 'package:flutter/material.dart';
import 'package:jood/core/utils/app_strings.dart';

class AuthPlaceholderScreen extends StatelessWidget {
  const AuthPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(AppStrings.authPlaceholder)));
  }
}
