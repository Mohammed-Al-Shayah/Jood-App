import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.cardBackground,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const _AdminBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBackground extends StatelessWidget {
  const _AdminBackground();

  @override
  Widget build(BuildContext context) {
    return Container(color: AppColors.cardBackground);
  }
}
