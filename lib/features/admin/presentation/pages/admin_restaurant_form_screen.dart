import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/features/admin/presentation/widgets/admin_restaurant_form_content.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';

class AdminRestaurantFormScreen extends StatelessWidget {
  const AdminRestaurantFormScreen({super.key, this.restaurant});

  final RestaurantEntity? restaurant;

  @override
  Widget build(BuildContext context) {
    final isEdit = restaurant != null;
    return AdminShell(
      title: isEdit ? 'Edit Restaurant' : 'Create Restaurant',
      body: AdminRestaurantFormContent(
        restaurant: restaurant,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        onSubmit: (result) async {
          if (!context.mounted) return;
          Navigator.of(context).pop(result);
        },
      ),
    );
  }
}
