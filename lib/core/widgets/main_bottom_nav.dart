import 'package:flutter/material.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      selectedLabelStyle: AppTextStyles.cardMeta,
      unselectedLabelStyle: AppTextStyles.cardMeta,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          label: AppStrings.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined),
          label: AppStrings.orders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          label: AppStrings.profile,
        ),
      ],
    );
  }
}
