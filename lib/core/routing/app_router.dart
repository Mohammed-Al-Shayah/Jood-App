import 'package:flutter/material.dart';

import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/home/presentation/pages/onboarding_screen.dart';
import 'routes.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onboardingScreen:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );
      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );
    }
  }
}
