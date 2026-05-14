import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_users_state.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_inline_form_view.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_metric_card.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_panel.dart';
import 'package:jood/features/admin/presentation/widgets/admin_confirm_dialog.dart';
import 'package:jood/features/admin/presentation/widgets/admin_user_form_content.dart';
import 'package:jood/features/users/domain/entities/user_entity.dart';

class AdminWebUsersPage extends StatefulWidget {
  const AdminWebUsersPage({super.key});

  @override
  State<AdminWebUsersPage> createState() => _AdminWebUsersPageState();
}

class _AdminWebUsersPageState extends State<AdminWebUsersPage> {
  late final AdminUsersCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedUserIds = <String>{};
  String _roleFilter = 'all';
  _UsersView _view = _UsersView.list;
  UserEntity? _selectedUser;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AdminUsersCubit>()..load();
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

  void _openEditForm(UserEntity user) {
    setState(() {
      _view = _UsersView.edit;
      _selectedUser = user;
    });
  }

  Future<void> _confirmDelete(UserEntity user) async {
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete user',
      message: 'Delete ${user.fullName}?',
    );
    if (confirmed != true) return;
    await _cubit.delete(user.id);
    if (!mounted) return;
    setState(() {
      _selectedUserIds.remove(user.id);
    });
  }

  void _toggleUserSelection(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedUserIds.add(id);
      } else {
        _selectedUserIds.remove(id);
      }
    });
  }

  void _toggleSelectAllUsers(List<UserEntity> items) {
    final ids = items.map((item) => item.id).toList(growable: false);
    final allSelected =
        ids.isNotEmpty && ids.every((id) => _selectedUserIds.contains(id));
    setState(() {
      if (allSelected) {
        _selectedUserIds.removeAll(ids);
      } else {
        _selectedUserIds.addAll(ids);
      }
    });
  }

  Future<void> _confirmDeleteSelectedUsers(List<UserEntity> items) async {
    final selectedIds = items
        .map((item) => item.id)
        .where(_selectedUserIds.contains)
        .toList(growable: false);
    if (selectedIds.isEmpty) return;
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete users',
      message: 'Delete ${selectedIds.length} selected users?',
    );
    if (confirmed != true) return;
    for (final id in selectedIds) {
      await _cubit.delete(id);
    }
    if (!mounted) return;
    setState(() {
      _selectedUserIds.removeAll(selectedIds);
    });
  }

  void _closeForm() {
    setState(() {
      _view = _UsersView.list;
      _selectedUser = null;
    });
  }

  Future<void> _submitForm(UserEntity user) async {
    await _cubit.update(user);
    if (!mounted) return;
    if (_cubit.state.status == AdminUsersStatus.failure) {
      showAppSnackBar(
        context,
        _cubit.state.errorMessage ?? 'Failed to save user.',
        type: SnackBarType.error,
      );
      return;
    }
    showAppSnackBar(
      context,
      'User updated successfully.',
      type: SnackBarType.success,
    );
    _closeForm();
  }

  List<UserEntity> _applyFilters(List<UserEntity> items) {
    final query = _searchController.text.trim().toLowerCase();
    return items
        .where((user) {
          final role = user.role.trim().toLowerCase();
          if (_roleFilter != 'all' && role != _roleFilter) {
            return false;
          }
          if (query.isEmpty) return true;
          final haystack = [
            user.fullName,
            user.email,
            user.phone,
            user.country,
            user.city,
            user.role,
            user.restaurantId ?? '',
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AdminUsersCubit, AdminUsersState>(
        builder: (context, state) {
          if (_view == _UsersView.edit && _selectedUser != null) {
            return AdminWebInlineFormView(
              title: 'Edit user',
              subtitle: 'Update account details and return to the users list.',
              onBack: _closeForm,
              backTooltip: 'Back to users',
              child: AdminUserFormContent(
                user: _selectedUser,
                padding: EdgeInsets.all(20.w),
                onSubmit: _submitForm,
              ),
            );
          }

          final filteredItems = _applyFilters(state.users);
          _selectedUserIds.removeWhere(
            (id) => !state.users.any((item) => item.id == id),
          );
          final selectedInViewCount = filteredItems
              .where((item) => _selectedUserIds.contains(item.id))
              .length;
          final allFilteredSelected =
              filteredItems.isNotEmpty &&
              selectedInViewCount == filteredItems.length;
          final adminCount = state.users
              .where((user) => user.role.trim().toLowerCase() == 'admin')
              .length;
          final verifiedCount = state.users
              .where((user) => user.emailVerified)
              .length;

          return ListView(
            padding: EdgeInsets.zero,
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
                          title: 'Total users',
                          value: '${state.users.length}',
                          icon: Icons.people_outline,
                          iconColor: AppColors.primary,
                          caption: 'All profiles in the platform',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: AdminWebMetricCard(
                          title: 'Admins',
                          value: '$adminCount',
                          icon: Icons.admin_panel_settings_outlined,
                          iconColor: const Color(0xFF2563EB),
                          caption: 'Users with dashboard access',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: AdminWebMetricCard(
                          title: 'Verified email',
                          value: '$verifiedCount',
                          icon: Icons.verified_outlined,
                          iconColor: const Color(0xFF0E9F6E),
                          caption: 'Accounts with verified email state',
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
                        final searchField = _SearchField(
                          controller: _searchController,
                          hintText:
                              'Search by name, email, phone, role, or restaurant',
                        );
                        final actions = Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _cubit.load,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Refresh'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _toggleSelectAllUsers(filteredItems),
                              icon: Icon(
                                allFilteredSelected
                                    ? Icons.deselect_outlined
                                    : Icons.select_all_rounded,
                              ),
                              label: Text(
                                allFilteredSelected
                                    ? 'Deselect all'
                                    : 'Select all',
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: selectedInViewCount > 0
                                  ? () => _confirmDeleteSelectedUsers(
                                      filteredItems,
                                    )
                                  : null,
                              icon: const Icon(Icons.delete_sweep_outlined),
                              label: const Text('Delete selected'),
                            ),
                          ],
                        );
                        if (constraints.maxWidth < 1180) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              searchField,
                              SizedBox(height: 12.h),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: actions,
                              ),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: searchField),
                            SizedBox(width: 12.w),
                            Flexible(
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: actions,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 14.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _FilterChip(
                          label: 'All roles',
                          selected: _roleFilter == 'all',
                          onTap: () => setState(() => _roleFilter = 'all'),
                        ),
                        ..._roleOptions(state.users).map(
                          (role) => _FilterChip(
                            label: _titleCase(role),
                            selected: _roleFilter == role,
                            onTap: () => setState(() => _roleFilter = role),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    if (state.status == AdminUsersStatus.loading &&
                        state.users.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (state.status == AdminUsersStatus.failure)
                      _PanelMessage(
                        message: state.errorMessage ?? 'Failed to load users.',
                        isError: true,
                      )
                    else if (filteredItems.isEmpty)
                      const _PanelMessage(
                        message: 'No users match the current filters.',
                      )
                    else
                      _UsersTable(
                        items: filteredItems,
                        onEdit: _openEditForm,
                        onDelete: _confirmDelete,
                        selectedIds: _selectedUserIds,
                        onSelectionChanged: _toggleUserSelection,
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

  List<String> _roleOptions(List<UserEntity> users) {
    final values =
        users
            .map((user) => user.role.trim().toLowerCase())
            .where((role) => role.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return values;
  }
}

enum _UsersView { list, edit }

class _UsersTable extends StatelessWidget {
  const _UsersTable({
    required this.items,
    required this.onEdit,
    required this.onDelete,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final List<UserEntity> items;
  final ValueChanged<UserEntity> onEdit;
  final ValueChanged<UserEntity> onDelete;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columnSpacing: 22.w,
        headingRowHeight: 48.h,
        dataRowMinHeight: 68.h,
        dataRowMaxHeight: 78.h,
        columns: [
          DataColumn(
            label: SizedBox(
              width: 28.w,
              child: const Icon(Icons.check_box_outline_blank, size: 18),
            ),
          ),
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Restaurant')),
          DataColumn(label: Text('Actions')),
        ],
        rows: items
            .map((user) {
              final isSelected = selectedIds.contains(user.id);
              return DataRow(
                selected: isSelected,
                cells: [
                  DataCell(
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) =>
                          onSelectionChanged(user.id, value ?? false),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 220.w,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.14,
                            ),
                            child: Text(
                              _initials(user.fullName),
                              style: AppTextStyles.cardMeta.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  user.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.cardMeta,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 220.w,
                      child: Text(
                        user.email,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(user.phone.trim().isEmpty ? '-' : user.phone)),
                  DataCell(
                    Text(
                      '${user.country}${user.city.trim().isEmpty ? '' : ' - ${user.city}'}',
                    ),
                  ),
                  DataCell(
                    _StatusPill(
                      label: _titleCase(user.role),
                      color: user.role.trim().toLowerCase() == 'admin'
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF0E9F6E),
                    ),
                  ),
                  DataCell(
                    Text(
                      user.restaurantId?.trim().isNotEmpty == true
                          ? user.restaurantId!
                          : '-',
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => onEdit(user),
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => onDelete(user),
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.22),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.16),
      labelStyle: AppTextStyles.cardMeta.copyWith(
        color: selected ? AppColors.primaryDark : AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.18)
            : const Color(0xFFE5EAF1),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

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

class _PanelMessage extends StatelessWidget {
  const _PanelMessage({required this.message, this.isError = false});

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

String _titleCase(String value) {
  final words = value
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return '-';
  return words
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _initials(String text) {
  final parts = text
      .trim()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty || parts.first.isEmpty) return 'US';
  if (parts.length == 1) {
    final word = parts.first;
    return word.length >= 2
        ? word.substring(0, 2).toUpperCase()
        : word.substring(0, 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
