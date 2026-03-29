import 'package:flutter/material.dart';

class AppKeyboardDismissRegion extends StatelessWidget {
  const AppKeyboardDismissRegion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!_shouldDismissOnScroll(notification)) {
          return false;
        }
        FocusManager.instance.primaryFocus?.unfocus();
        return false;
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        child: child,
      ),
    );
  }

  bool _shouldDismissOnScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      return notification.dragDetails != null;
    }
    if (notification is ScrollUpdateNotification) {
      return notification.dragDetails != null;
    }
    if (notification is OverscrollNotification) {
      return notification.dragDetails != null;
    }
    return false;
  }
}
