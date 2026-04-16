import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/features/admin/presentation/widgets/admin_ad_form_content.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/ads/domain/entities/ad_entity.dart';

class AdminAdFormScreen extends StatelessWidget {
  const AdminAdFormScreen({super.key, this.ad, this.onSubmit});

  final AdEntity? ad;
  final Future<void> Function(AdEntity ad)? onSubmit;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: ad == null ? 'Create Ad' : 'Edit Ad',
      body: AdminAdFormContent(
        ad: ad,
        padding: EdgeInsets.fromLTRB(0, 6.h, 0, 24.h),
        onSubmit: (result) async {
          final submit = onSubmit;
          if (submit != null) {
            await submit(result);
          }
          if (!context.mounted) return;
          Navigator.of(context).pop(result);
        },
      ),
    );
  }
}

class AdminAdFormArgs {
  const AdminAdFormArgs({this.ad, this.onSubmit});

  final AdEntity? ad;
  final Future<void> Function(AdEntity ad)? onSubmit;
}
