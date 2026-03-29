import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/admin/presentation/widgets/admin_user_form_content.dart';
import 'package:jood/features/users/domain/entities/user_entity.dart';

class AdminUserFormScreen extends StatelessWidget {
  const AdminUserFormScreen({super.key, this.user});

  final UserEntity? user;

  @override
  Widget build(BuildContext context) {
    final isEdit = user != null;
    if (!isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showAppSnackBar(
          context,
          'User creation is disabled.',
          type: SnackBarType.info,
        );
        Navigator.of(context).pop();
      });
    }

    return AdminShell(
      title: isEdit ? 'Edit User' : 'Create User',
      body: AdminUserFormContent(
        user: user,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        onSubmit: (result) async {
          if (!context.mounted) return;
          Navigator.of(context).pop(result);
        },
      ),
    );
  }
}
