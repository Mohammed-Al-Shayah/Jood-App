import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/features/admin/presentation/widgets/admin_offer_form_content.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';

class AdminOfferFormScreen extends StatelessWidget {
  const AdminOfferFormScreen({super.key, this.offer, this.initialCategory});

  final OfferEntity? offer;
  final String? initialCategory;

  @override
  Widget build(BuildContext context) {
    final content = AdminOfferFormContent(
      offer: offer,
      initialCategory: initialCategory,
      padding: EdgeInsets.fromLTRB(0, 6.h, 0, 24.h),
      onSubmit: (result) async {
        if (!context.mounted) return;
        Navigator.of(context).pop(result);
      },
    );

    final title = offer != null
        ? 'Edit Offer'
        : _titleForCategory(initialCategory);

    return AdminShell(title: title, body: content);
  }

  String _titleForCategory(String? category) {
    switch ((category ?? '').trim().toLowerCase()) {
      case 'buffet':
        return 'Create Buffet Offer';
      case 'set_menu':
        return 'Create Set Menu Offer';
      case 'attraction':
        return 'Create Attraction Offer';
      default:
        return 'Create Offer';
    }
  }
}
