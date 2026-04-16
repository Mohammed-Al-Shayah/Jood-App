import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/cubit/admin_ads_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_ads_state.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_inline_form_view.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_metric_card.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_panel.dart';
import 'package:jood/features/admin/presentation/widgets/admin_ad_form_content.dart';
import 'package:jood/features/admin/presentation/widgets/admin_confirm_dialog.dart';
import 'package:jood/features/ads/domain/entities/ad_entity.dart';

class AdminWebAdsPage extends StatefulWidget {
  const AdminWebAdsPage({super.key});

  @override
  State<AdminWebAdsPage> createState() => _AdminWebAdsPageState();
}

class _AdminWebAdsPageState extends State<AdminWebAdsPage> {
  late final AdminAdsCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  _AdsView _view = _AdsView.list;
  AdEntity? _selectedAd;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AdminAdsCubit>()..load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _cubit.close();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _openCreateForm() {
    setState(() {
      _view = _AdsView.create;
      _selectedAd = null;
    });
  }

  void _openEditForm(AdEntity ad) {
    setState(() {
      _view = _AdsView.edit;
      _selectedAd = ad;
    });
  }

  void _closeForm() {
    setState(() {
      _view = _AdsView.list;
      _selectedAd = null;
    });
  }

  Future<void> _submitForm(AdEntity ad) async {
    if (_view == _AdsView.edit) {
      await _cubit.update(ad);
    } else {
      await _cubit.create(ad);
    }
    if (!mounted) return;
    if (_cubit.state.status == AdminAdsStatus.failure) {
      showAppSnackBar(
        context,
        _cubit.state.errorMessage ?? 'Failed to save ad.',
        type: SnackBarType.error,
      );
      return;
    }
    showAppSnackBar(
      context,
      _view == _AdsView.edit
          ? 'Ad updated successfully.'
          : 'Ad created successfully.',
      type: SnackBarType.success,
    );
    _closeForm();
  }

  Future<void> _confirmDelete(AdEntity ad) async {
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete ad',
      message: 'Delete ${ad.title}?',
    );
    if (confirmed != true) return;
    await _cubit.delete(ad.id);
  }

  List<AdEntity> _filteredAds(List<AdEntity> ads) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return ads;
    return ads.where((ad) {
      final haystack = [
        ad.title,
        ad.targetVenueName,
        ad.targetOfferTitle,
        ad.targetCategory,
        ad.targetOfferDate,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AdminAdsCubit, AdminAdsState>(
        builder: (context, state) {
          if (_view != _AdsView.list) {
            final isEdit = _view == _AdsView.edit;
            return AdminWebInlineFormView(
              title: isEdit ? 'Edit ad' : 'Create ad',
              subtitle:
                  'Choose the category, venue, and offer the ad should open from the home slider.',
              onBack: _closeForm,
              backTooltip: 'Back to ads',
              child: AdminAdFormContent(
                ad: _selectedAd,
                padding: EdgeInsets.all(20.w),
                onSubmit: _submitForm,
              ),
            );
          }

          final filteredAds = _filteredAds(state.ads);
          final activeCount = state.ads.where((ad) => ad.isActive).length;
          final uniqueVenues = state.ads
              .map((ad) => ad.targetVenueId)
              .where((id) => id.trim().isNotEmpty)
              .toSet()
              .length;

          return ListView(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 16.w;
                  final columns = constraints.maxWidth >= 1000
                      ? 3
                      : constraints.maxWidth >= 680
                      ? 2
                      : 1;
                  final cardWidth = columns == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - (spacing * (columns - 1))) /
                            columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: 16.h,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: AdminWebMetricCard(
                          title: 'All ads',
                          value: '${state.ads.length}',
                          icon: Icons.view_carousel_outlined,
                          iconColor: AppColors.primary,
                          caption: 'Configured slider ads',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: AdminWebMetricCard(
                          title: 'Active ads',
                          value: '$activeCount',
                          icon: Icons.check_circle_outline,
                          iconColor: const Color(0xFF0E9F6E),
                          caption: 'Visible on the home slider',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: AdminWebMetricCard(
                          title: 'Target venues',
                          value: '$uniqueVenues',
                          icon: Icons.storefront_outlined,
                          iconColor: const Color(0xFF2563EB),
                          caption: 'Unique venues linked to ads',
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20.h),
              AdminWebPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final searchField = TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                'Search by ad title, venue, offer, or date',
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: const Color(0xFFF6F7FB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                        final actions = Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                await _cubit.load();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Refresh'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _openCreateForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Add ad'),
                            ),
                          ],
                        );
                        if (constraints.maxWidth < 980) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              searchField,
                              SizedBox(height: 12.h),
                              actions,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: searchField),
                            SizedBox(width: 12.w),
                            actions,
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 18.h),
                    if (state.status == AdminAdsStatus.loading &&
                        state.ads.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (state.status == AdminAdsStatus.failure)
                      _AdsPanelMessage(
                        message: state.errorMessage ?? 'Failed to load ads.',
                        isError: true,
                      )
                    else if (filteredAds.isEmpty)
                      const _AdsPanelMessage(
                        message: 'No ads match the current search.',
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 22.w,
                          headingRowHeight: 48.h,
                          dataRowMinHeight: 70.h,
                          dataRowMaxHeight: 88.h,
                          columns: const [
                            DataColumn(label: Text('Ad')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Venue')),
                            DataColumn(label: Text('Offer')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Duration')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: filteredAds.map((ad) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 220.w,
                                    child: Text(
                                      ad.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(_categoryLabel(ad.targetCategory))),
                                DataCell(
                                  SizedBox(
                                    width: 180.w,
                                    child: Text(
                                      ad.targetVenueName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 260.w,
                                    child: Text(
                                      ad.targetOfferTitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(ad.targetOfferDate)),
                                DataCell(Text('${ad.resolvedDisplaySeconds}s')),
                                DataCell(
                                  _AdsStatusPill(
                                    label: ad.isActive ? 'Active' : 'Inactive',
                                    color: ad.isActive
                                        ? const Color(0xFF0E9F6E)
                                        : const Color(0xFFF59E0B),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _openEditForm(ad),
                                        tooltip: 'Edit',
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        onPressed: () => _confirmDelete(ad),
                                        tooltip: 'Delete',
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(growable: false),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
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

enum _AdsView { list, create, edit }

class _AdsStatusPill extends StatelessWidget {
  const _AdsStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.cardMeta.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdsPanelMessage extends StatelessWidget {
  const _AdsPanelMessage({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.cardMeta.copyWith(
            color: isError ? const Color(0xFFC62828) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
