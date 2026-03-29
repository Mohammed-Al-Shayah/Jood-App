import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/features/admin/presentation/widgets/admin_attraction_form_content.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/attractions/domain/entities/attraction_entity.dart';

class AdminAttractionFormScreen extends StatelessWidget {
  const AdminAttractionFormScreen({super.key, this.attraction});

  final AttractionEntity? attraction;

  @override
  Widget build(BuildContext context) {
    final isEdit = attraction != null;
    return AdminShell(
      title: isEdit ? 'Edit Attraction' : 'Create Attraction',
      body: AdminAttractionFormContent(
        attraction: attraction,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        onSubmit: (result) async {
          if (!context.mounted) return;
          Navigator.of(context).pop(result);
        },
      ),
    );
  }
}
