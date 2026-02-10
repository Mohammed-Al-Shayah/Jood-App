import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/admin/presentation/cubit/admin_offers_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_offers_state.dart';
import 'package:jood/features/admin/presentation/widgets/admin_confirm_dialog.dart';
import 'package:jood/features/admin/presentation/widgets/admin_list_tile.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';
import 'package:jood/features/restaurants/domain/usecases/get_all_restaurants_usecase.dart';

class AdminOffersScreen extends StatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen> {
  Map<String, String> _restaurantNames = const {};
  final Set<String> _expandedRestaurants = {};

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      final usecase = getIt<GetAllRestaurantsUseCase>();
      final restaurants = await usecase();
      if (!mounted) return;
      setState(() {
        _restaurantNames = {for (final r in restaurants) r.id: r.name};
      });
    } catch (_) {
      // Ignore; we'll fallback to restaurantId in the UI.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminOffersCubit>()..load(),
      child: Builder(
        builder: (context) {
          return AdminShell(
            title: 'Offers',
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  Routes.adminOfferFormScreen,
                  arguments: const AdminOfferFormArgs(),
                );
                if (!context.mounted) return;
                if (result is OfferEntity) {
                  context.read<AdminOffersCubit>().create(result);
                } else if (result is List<OfferEntity>) {
                  context.read<AdminOffersCubit>().createMany(result);
                }
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: BlocBuilder<AdminOffersCubit, AdminOffersState>(
              builder: (context, state) {
                final isLoading = state.status == AdminOffersStatus.loading;
                if (state.status == AdminOffersStatus.failure) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        state.errorMessage ?? 'Failed to load offers.',
                        style: AppTextStyles.cardMeta,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final items = isLoading ? _skeletonOffers() : state.offers;
                if (!isLoading && items.isEmpty) {
                  return Center(
                    child: Text(
                      'No offers yet.',
                      style: AppTextStyles.cardMeta,
                    ),
                  );
                }
                final groupedItems = _groupByRestaurant(
                  items,
                  _restaurantNames,
                );
                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(0, 12.h, 0, 80.h),
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      final group = groupedItems[index];
                      final isExpanded = _expandedRestaurants.contains(
                        group.restaurantId,
                      );
                      return ExpansionTile(
                        key: PageStorageKey(group.restaurantId),
                        initiallyExpanded: isExpanded,
                        tilePadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        title: Text(
                          group.restaurantName,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 14.sp,
                          ),
                        ),
                        onExpansionChanged: (expanded) {
                          setState(() {
                            if (expanded) {
                              _expandedRestaurants.add(group.restaurantId);
                            } else {
                              _expandedRestaurants.remove(group.restaurantId);
                            }
                          });
                        },
                        children: group.offers
                            .map(
                              (offer) => Padding(
                                padding: EdgeInsets.only(
                                  left: 6.w,
                                  right: 6.w,
                                  bottom: 12.h,
                                ),
                                child: AdminListTile(
                                  leading: _OfferIcon(),
                                  title: offer.title,
                                  subtitles: [
                                    SizedBox(height: 4.h),
                                    Text(
                                      offer.date,
                                      style: AppTextStyles.cardMeta,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '${offer.startTime} - ${offer.endTime}',
                                      style: AppTextStyles.cardMeta,
                                    ),
                                  ],
                                  onTap: isLoading
                                      ? null
                                      : () async {
                                          final result =
                                              await Navigator.of(
                                                context,
                                              ).pushNamed(
                                                Routes.adminOfferFormScreen,
                                                arguments: AdminOfferFormArgs(
                                                  offer: offer,
                                                ),
                                              );
                                          if (result is OfferEntity &&
                                              context.mounted) {
                                            context
                                                .read<AdminOffersCubit>()
                                                .update(result);
                                          }
                                        },
                                  onDelete: isLoading
                                      ? null
                                      : () => _confirmDelete(context, offer),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, OfferEntity offer) async {
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete offer',
      message: 'Delete ${offer.title}?',
    );
    if (confirmed == true && context.mounted) {
      context.read<AdminOffersCubit>().delete(offer.id);
    }
  }
}

class _OfferIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(Icons.local_offer_outlined, color: AppColors.primary),
    );
  }
}

class _OfferGroup {
  const _OfferGroup({
    required this.restaurantId,
    required this.restaurantName,
    required this.offers,
  });

  final String restaurantId;
  final String restaurantName;
  final List<OfferEntity> offers;
}

List<_OfferGroup> _groupByRestaurant(
  List<OfferEntity> items,
  Map<String, String> restaurantNames,
) {
  final groups = <String, List<OfferEntity>>{};
  for (final offer in items) {
    groups.putIfAbsent(offer.restaurantId, () => []).add(offer);
  }

  final result = <_OfferGroup>[];
  for (final entry in groups.entries) {
    final offers = entry.value
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        return a.startTime.compareTo(b.startTime);
      });

    final name = restaurantNames[entry.key] ?? entry.key;
    result.add(
      _OfferGroup(
        restaurantId: entry.key,
        restaurantName: name,
        offers: offers,
      ),
    );
  }

  result.sort((a, b) => a.restaurantName.compareTo(b.restaurantName));
  return result;
}

List<OfferEntity> _skeletonOffers() {
  final now = DateTime.now();
  return List.generate(
    6,
    (index) => OfferEntity(
      id: 'skeleton-$index',
      restaurantId: 'restaurant',
      date: '2026-02-07',
      startTime: '12:00',
      endTime: '14:00',
      currency: 'OMR',
      priceAdult: 0,
      priceAdultOriginal: 0,
      priceChild: 0,
      capacityAdult: 0,
      capacityChild: 0,
      bookedAdult: 0,
      bookedChild: 0,
      status: 'active',
      title: 'Offer title',
      entryConditions: const [],
      createdAt: now,
      updatedAt: now,
    ),
  );
}

class AdminOfferFormArgs {
  const AdminOfferFormArgs({this.offer});

  final OfferEntity? offer;
}
