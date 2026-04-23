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

class AdminAdsScreen extends StatefulWidget {
  const AdminAdsScreen({super.key});

  @override
  State<AdminAdsScreen> createState() => _AdminAdsScreenState();
}

class _AdminAdsScreenState extends State<AdminAdsScreen> {
  final Set<String> _selectedAdIds = <String>{};

  bool get _selectionMode => _selectedAdIds.isNotEmpty;

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

  String _saveSuccessMessage(AdEntity ad) {
    return ad.id.trim().isEmpty
        ? 'Ad created successfully.'
        : 'Ad updated successfully.';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminAdsCubit>()..load(),
      child: BlocBuilder<AdminAdsCubit, AdminAdsState>(
        builder: (context, state) {
          final allAdsSelected =
              state.ads.isNotEmpty &&
              state.ads.every((ad) => _selectedAdIds.contains(ad.id));

          return AdminShell(
            title: _selectionMode ? 'Selected ${_selectedAdIds.length}' : 'Ads',
            actions: _selectionMode
                ? [
                    TextButton(
                      onPressed: state.ads.isEmpty
                          ? null
                          : () => _toggleSelectAll(state.ads),
                      child: Text(
                        allAdsSelected ? 'Deselect all' : 'Select all',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _confirmDeleteSelected(context),
                      icon: const Icon(Icons.delete_outline),
                    ),
                    IconButton(
                      onPressed: _clearSelection,
                      icon: const Icon(Icons.close),
                    ),
                  ]
                : null,
            floatingActionButton: _selectionMode
                ? null
                : FloatingActionButton(
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
                        _saveSuccessMessage(result as AdEntity),
                        type: SnackBarType.success,
                      );
                    },
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminAdsState state) {
    if (state.status == AdminAdsStatus.loading && state.ads.isEmpty) {
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
        final status = _statusFor(ad);
        return AdminListTile(
          leading: _AdIcon(color: status.color),
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
              '${_scheduleLabel(ad)} | ${ad.resolvedDisplaySeconds}s | ${status.label}',
              style: AppTextStyles.cardMeta,
            ),
          ],
          onTap: () async {
            if (_selectionMode) {
              _toggleSelection(ad);
              return;
            }

            final result = await Navigator.of(context).pushNamed(
              Routes.adminAdFormScreen,
              arguments: AdminAdFormArgs(
                ad: ad,
                onSubmit: (updated) => _submitFormResult(context, updated),
              ),
            );
            if (!context.mounted || result == null) return;
            showAppSnackBar(
              context,
              _saveSuccessMessage(result as AdEntity),
              type: SnackBarType.success,
            );
          },
          onLongPress: () => _toggleSelection(ad),
          onDelete: () => _confirmDelete(context, ad),
          isSelected: _selectedAdIds.contains(ad.id),
          selectionMode: _selectionMode,
        );
      },
    );
  }

  void _toggleSelection(AdEntity ad) {
    setState(() {
      if (_selectedAdIds.contains(ad.id)) {
        _selectedAdIds.remove(ad.id);
      } else {
        _selectedAdIds.add(ad.id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedAdIds.clear();
    });
  }

  void _toggleSelectAll(List<AdEntity> ads) {
    if (ads.isEmpty) return;

    setState(() {
      final allSelected = ads.every((ad) => _selectedAdIds.contains(ad.id));
      if (allSelected) {
        for (final ad in ads) {
          _selectedAdIds.remove(ad.id);
        }
      } else {
        for (final ad in ads) {
          _selectedAdIds.add(ad.id);
        }
      }
    });
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

  Future<void> _confirmDeleteSelected(BuildContext context) async {
    if (_selectedAdIds.isEmpty) return;

    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete ads',
      message: 'Delete ${_selectedAdIds.length} ads?',
    );
    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<AdminAdsCubit>();
    final ids = _selectedAdIds.toList(growable: false);
    _clearSelection();
    for (final id in ids) {
      await cubit.delete(id);
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

_AdStatus _statusFor(AdEntity ad) {
  final now = DateTime.now();
  if (!ad.isActive) {
    return const _AdStatus('Inactive', Color(0xFFF59E0B));
  }

  final start = ad.scheduleStartAt;
  final end = ad.scheduleEndAt;
  if (start != null && now.isBefore(start)) {
    return const _AdStatus('Scheduled', Color(0xFF2563EB));
  }
  if (end != null && now.isAfter(end)) {
    return const _AdStatus('Ended', Color(0xFF6B7280));
  }
  if (ad.canShowOnHomeSliderAt(now)) {
    return const _AdStatus('Active', Color(0xFF0E9F6E));
  }

  return const _AdStatus('Inactive', Color(0xFFF59E0B));
}

String _scheduleLabel(AdEntity ad) {
  final startDate = ad.startDate.trim().isNotEmpty
      ? ad.startDate.trim()
      : ad.targetOfferDate.trim();
  final endDate = ad.endDate.trim().isNotEmpty
      ? ad.endDate.trim()
      : ad.targetOfferDate.trim();
  final startTime = ad.startTime.trim().isEmpty ? '00:00' : ad.startTime.trim();
  final endTime = ad.endTime.trim().isEmpty ? '23:59' : ad.endTime.trim();
  return 'Schedule $startDate $startTime -> $endDate $endTime';
}

class _AdStatus {
  const _AdStatus(this.label, this.color);

  final String label;
  final Color color;
}

class _AdIcon extends StatelessWidget {
  const _AdIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(
        Icons.view_carousel_outlined,
        color: color,
      ),
    );
  }
}
