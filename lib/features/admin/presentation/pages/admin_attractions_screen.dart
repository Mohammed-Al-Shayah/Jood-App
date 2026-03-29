import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/admin/presentation/cubit/admin_attractions_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_attractions_state.dart';
import 'package:jood/features/admin/presentation/widgets/admin_confirm_dialog.dart';
import 'package:jood/features/admin/presentation/widgets/admin_list_tile.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/attractions/data/datasources/attraction_remote_data_source.dart';
import 'package:jood/features/attractions/data/repositories/attraction_repository_impl.dart';
import 'package:jood/features/attractions/domain/entities/attraction_entity.dart';
import 'package:jood/features/attractions/domain/usecases/create_attraction_usecase.dart';
import 'package:jood/features/attractions/domain/usecases/delete_attraction_usecase.dart';
import 'package:jood/features/attractions/domain/usecases/get_all_attractions_usecase.dart';
import 'package:jood/features/attractions/domain/usecases/update_attraction_usecase.dart';

class AdminAttractionsScreen extends StatelessWidget {
  const AdminAttractionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _resolveAdminAttractionsCubit()..load(),
      child: Builder(
        builder: (context) {
          return AdminShell(
            title: 'Attractions',
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  Routes.adminAttractionFormScreen,
                  arguments: const AdminAttractionFormArgs(),
                );
                if (result is AttractionEntity && context.mounted) {
                  context.read<AdminAttractionsCubit>().create(result);
                }
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: BlocBuilder<AdminAttractionsCubit, AdminAttractionsState>(
              builder: (context, state) {
                final isLoading =
                    state.status == AdminAttractionsStatus.loading;
                if (state.status == AdminAttractionsStatus.failure) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        state.errorMessage ?? 'Failed to load attractions.',
                        style: AppTextStyles.cardMeta,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final items = isLoading
                    ? _skeletonAttractions()
                    : state.attractions;
                if (!isLoading && items.isEmpty) {
                  return Center(
                    child: Text(
                      'No attractions yet.',
                      style: AppTextStyles.cardMeta,
                    ),
                  );
                }
                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(0, 12.h, 0, 80.h),
                    itemBuilder: (context, index) {
                      final attraction = items[index];
                      return AdminListTile(
                        leading: _AttractionThumb(
                          url: attraction.coverImageUrl,
                        ),
                        title: attraction.name,
                        subtitles: [
                          SizedBox(height: 4.h),
                          Text(
                            '${attraction.cityId} - ${attraction.area}',
                            style: AppTextStyles.cardMeta,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            attraction.isActive ? 'Active' : 'Inactive',
                            style: AppTextStyles.cardMeta.copyWith(
                              color: attraction.isActive
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                        onTap: isLoading
                            ? null
                            : () async {
                                final result = await Navigator.of(context)
                                    .pushNamed(
                                      Routes.adminAttractionFormScreen,
                                      arguments: AdminAttractionFormArgs(
                                        attraction: attraction,
                                      ),
                                    );
                                if (result is AttractionEntity &&
                                    context.mounted) {
                                  context.read<AdminAttractionsCubit>().update(
                                    result,
                                  );
                                }
                              },
                        onDelete: isLoading
                            ? null
                            : () => _confirmDelete(context, attraction),
                      );
                    },
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemCount: items.length,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AttractionEntity attraction,
  ) async {
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete attraction',
      message: 'Delete ${attraction.name}? This also removes related offers.',
    );
    if (confirmed == true && context.mounted) {
      context.read<AdminAttractionsCubit>().delete(attraction.id);
    }
  }
}

class _AttractionThumb extends StatelessWidget {
  const _AttractionThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(Icons.local_activity_outlined, color: AppColors.primary),
    );
    if (url.trim().isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Image.network(
        url,
        width: 44.w,
        height: 44.w,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

List<AttractionEntity> _skeletonAttractions() {
  return List.generate(
    6,
    (index) => AttractionEntity(
      id: 'skeleton-$index',
      name: 'Attraction name',
      cityId: 'City',
      area: 'Area',
      rating: 4.5,
      reviewsCount: 0,
      coverImageUrl: '',
      about: '',
      phone: '',
      address: '',
      highlights: const [],
      inclusions: const [],
      catalogDescription: '',
      catalogHighlights: const [],
      catalogIncluded: const [],
      packageOverview: const [],
      bookingNotes: const [],
      isActive: true,
      createdAt: DateTime(2000),
      badge: '',
      priceFrom: '',
      discount: '',
      slotsLeft: '',
    ),
  );
}

class AdminAttractionFormArgs {
  const AdminAttractionFormArgs({this.attraction});

  final AttractionEntity? attraction;
}

AdminAttractionsCubit _resolveAdminAttractionsCubit() {
  if (getIt.isRegistered<AdminAttractionsCubit>()) {
    return getIt<AdminAttractionsCubit>();
  }
  final remoteDataSource = AttractionRemoteDataSource(
    FirebaseFirestore.instance,
  );
  final repository = AttractionRepositoryImpl(remoteDataSource);
  return AdminAttractionsCubit(
    getAllAttractions: GetAllAttractionsUseCase(repository),
    createAttraction: CreateAttractionUseCase(repository),
    updateAttraction: UpdateAttractionUseCase(repository),
    deleteAttraction: DeleteAttractionUseCase(repository),
  );
}
