import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_users_state.dart';
import 'package:jood/features/admin/presentation/widgets/admin_confirm_dialog.dart';
import 'package:jood/features/admin/presentation/widgets/admin_list_tile.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/users/domain/entities/user_entity.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminUsersCubit>()..load(),
      child: Builder(
        builder: (context) {
          return AdminShell(
            title: 'Users & Roles',
            body: BlocBuilder<AdminUsersCubit, AdminUsersState>(
              builder: (context, state) {
                final isLoading = state.status == AdminUsersStatus.loading;
                if (state.status == AdminUsersStatus.failure) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        state.errorMessage ?? 'Failed to load users.',
                        style: AppTextStyles.cardMeta,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final items = isLoading ? _skeletonUsers() : state.users;
                if (!isLoading && items.isEmpty) {
                  return Center(
                    child: Text('No users yet.', style: AppTextStyles.cardMeta),
                  );
                }
                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(0, 12.h, 0, 80.h),
                    itemBuilder: (context, index) {
                      final user = items[index];
                      return AdminListTile(
                        leading: _UserIcon(),
                        title: user.fullName,
                        subtitles: [
                          SizedBox(height: 4.h),
                          Text(user.email, style: AppTextStyles.cardMeta),
                          SizedBox(height: 4.h),
                          Text(
                            '${user.role}${_restaurantSuffix(user)}',
                            style: AppTextStyles.cardMeta,
                          ),
                        ],
                        onTap: isLoading
                            ? null
                            : () async {
                                final result =
                                    await Navigator.of(context).pushNamed(
                                  Routes.adminUserFormScreen,
                                  arguments: AdminUserFormArgs(user: user),
                                );
                                if (result is UserEntity && context.mounted) {
                                  context.read<AdminUsersCubit>().update(result);
                                }
                              },
                        onDelete: isLoading
                            ? null
                            : () => _confirmDelete(context, user),
                      );
                    },
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
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

  Future<void> _confirmDelete(BuildContext context, UserEntity user) async {
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete user',
      message: 'Delete ${user.fullName}?',
    );
    if (confirmed == true && context.mounted) {
      context.read<AdminUsersCubit>().delete(user.id);
    }
  }

  String _restaurantSuffix(UserEntity user) {
    final id = user.restaurantId;
    if (id == null || id.isEmpty) return '';
    return ' - $id';
  }
}

class _UserIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(Icons.person_outline, color: AppColors.primary),
    );
  }
}

List<UserEntity> _skeletonUsers() {
  return List.generate(
    6,
    (index) => UserEntity(
      id: 'skeleton-$index',
      fullName: 'User name',
      email: 'user@example.com',
      phone: '',
      country: '',
      city: '',
      role: 'staff',
      restaurantId: 'restaurant',
    ),
  );
}

class AdminUserFormArgs {
  const AdminUserFormArgs({this.user});

  final UserEntity? user;
}
