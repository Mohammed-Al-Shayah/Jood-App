import 'package:flutter/material.dart';

import '../../../../core/theming/app_colors.dart';
import 'home_tab.dart';

export 'home_tab.dart' show HomeTab;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: HomeTab(),
    );
  }
}
