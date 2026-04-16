import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/cubit/admin_ads_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_ads_state.dart';
import 'package:jood/features/admin/presentation/widgets/admin_confirm_dialog.dart';
import 'package:jood/features/admin/presentation/widgets/admin_list_tile.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/ads/domain/entities/ad_entity.dart';

import 'admin_ad_form_screen.dart';

class AdminAdsScreen extends StatelessWidget {
  const AdminAdsScreen({super.key});

  Future<void> _submitFormResult(BuildContext context, AdEntity ad) async {
    final cubit = context.read<AdminAdsCubit>();
    if (ad.id.trim().isEmpty) {
      await cubit.create(ad);
    } else {
      await cubit.update(ad);
    }
    if (cubit.state.status == AdminAdsStatus.failure) {
      throw Exception(cubit.state.errorMessage ?? 'Failed to save ad.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminAdsCubit>()..load(),
      child: Builder(
        builder: (context) {
          return AdminShell(
            title: 'Ads',
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  Routes.adminAdFormScreen,
                  arguments: AdminAdFormArgs(
                    onSubmit: (ad) => _submitFormResult(context, ad),
                  ),
                );
                if (!context.mounted || result == null) return;
                showAppSnackBar(
                  context,
                  'Ad created successfully.',
                  type: SnackBarType.success,
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: BlocBuilder<AdminAdsCubit, AdminAdsState>(
              builder: (context, state) {
                if (state.status == AdminAdsStatus.loading &&
                    state.ads.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == AdminAdsStatus.failure) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        state.errorMessage ?? 'Failed to load ads.',
                        style: AppTextStyles.cardMeta,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (state.ads.isEmpty) {
                  return Center(
                    child: Text('No ads yet.', style: AppTextStyles.cardMeta),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(0, 8.h, 0, 84.h),
                  itemCount: state.ads.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final ad = state.ads[index];
                    return AdminListTile(
                      leading: _AdIcon(isActive: ad.isActive),
                      title: ad.title,
                      subtitles: [
                        SizedBox(height: 4.h),
                        Text(
                          '${_categoryLabel(ad.targetCategory)} | ${ad.targetVenueName}',
                          style: AppTextStyles.cardMeta,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          ad.targetOfferTitle,
                          style: AppTextStyles.cardMeta,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Date ${ad.targetOfferDate} | ${ad.resolvedDisplaySeconds}s',
                          style: AppTextStyles.cardMeta,
                        ),
                      ],
                      onTap: () async {
                        final result = await Navigator.of(context).pushNamed(
                          Routes.adminAdFormScreen,
                          arguments: AdminAdFormArgs(
                            ad: ad,
                            onSubmit: (updated) =>
                                _submitFormResult(context, updated),
                          ),
                        );
                        if (!context.mounted || result == null) return;
                        showAppSnackBar(
                          context,
                          'Ad updated successfully.',
                          type: SnackBarType.success,
                        );
                      },
                      onDelete: () => _confirmDelete(context, ad),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AdEntity ad) async {
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete ad',
      message: 'Delete ${ad.title}?',
    );
    if (confirmed == true && context.mounted) {
      await context.read<AdminAdsCubit>().delete(ad.id);
    }
  }

  String _categoryLabel(String value) {
    switch (value) {
      case 'buffet':
        return 'Buffet';
      case 'set_menu':
        return 'Set Menu';
      case 'combo':
        return 'Combo';
      case 'attraction':
        return 'Attraction';
      default:
        return value;
    }
  }
}

class _AdIcon extends StatelessWidget {
  const _AdIcon({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: (isActive ? AppColors.primary : Colors.orange).withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(
        Icons.view_carousel_outlined,
        color: isActive ? AppColors.primary : Colors.orange,
      ),
    );
  }
}
