import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/features/admin/presentation/widgets/admin_input_decoration.dart';
import 'package:jood/features/admin/presentation/widgets/admin_section_card.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';
import 'package:jood/features/restaurants/domain/usecases/get_all_restaurants_usecase.dart';
import 'package:jood/features/users/domain/entities/user_entity.dart';

class AdminUserFormContent extends StatefulWidget {
  const AdminUserFormContent({
    super.key,
    this.user,
    required this.onSubmit,
    this.padding,
  });

  final UserEntity? user;
  final Future<void> Function(UserEntity user) onSubmit;
  final EdgeInsetsGeometry? padding;

  @override
  State<AdminUserFormContent> createState() => _AdminUserFormContentState();
}

class _AdminUserFormContentState extends State<AdminUserFormContent> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _restaurantIdController;

  bool _emailVerified = false;
  bool _loadingRestaurants = true;
  bool _isSubmitting = false;
  String _role = 'guest';
  List<RestaurantEntity> _restaurants = const [];

  final _roles = const ['admin', 'guest', 'staff', 'customer'];

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    final autoId = user?.id ?? _generateUserId();
    _idController = TextEditingController(text: autoId);
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _restaurantIdController = TextEditingController(
      text: user?.restaurantId ?? '',
    );
    _emailVerified = user?.emailVerified ?? false;
    _role = user?.role ?? 'guest';
    _loadRestaurants();
  }

  @override
  void dispose() {
    _idController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _restaurantIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    return Form(
      key: _formKey,
      child: ListView(
        padding:
            widget.padding ??
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        children: [
          AdminSectionCard(
            title: 'Profile',
            child: Column(
              children: [
                _textField(
                  _idController,
                  isEdit ? 'User ID' : 'User ID (auto)',
                  readOnly: true,
                ),
                _textField(_fullNameController, 'Full Name'),
                _textField(_emailController, 'Email'),
                _textField(_phoneController, 'Phone'),
                _textField(_countryController, 'Country'),
                _textField(_cityController, 'City'),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminSectionCard(
            title: 'Role',
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  dropdownColor: Colors.white,
                  decoration: adminInputDecoration('Role'),
                  items: _roles
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) => setState(() {
                          _role = value ?? 'guest';
                          if (_role != 'staff') {
                            _restaurantIdController.clear();
                          }
                        }),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 10.h),
                if (_role == 'staff') _restaurantDropdown(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _emailVerified,
                  onChanged: _isSubmitting
                      ? null
                      : (value) => setState(() => _emailVerified = value),
                  activeThumbColor: AppColors.primary,
                  title: const Text('Email Verified'),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 18.h,
                      width: 18.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEdit ? 'Update' : 'Create'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool required = true,
    bool readOnly = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: adminInputDecoration(label),
        validator: (value) {
          if (!required) return null;
          if (value == null || value.trim().isEmpty) return 'Required';
          return null;
        },
      ),
    );
  }

  Widget _restaurantDropdown() {
    if (_loadingRestaurants) {
      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: const LinearProgressIndicator(),
      );
    }
    if (_restaurants.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Text('No restaurants found.'),
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        initialValue: _restaurantIdController.text.isEmpty
            ? null
            : _restaurantIdController.text,
        decoration: adminInputDecoration('Restaurant'),
        items: _restaurants
            .map(
              (restaurant) => DropdownMenuItem(
                value: restaurant.id,
                child: Text(restaurant.name),
              ),
            )
            .toList(),
        onChanged: _isSubmitting
            ? null
            : (value) =>
                  setState(() => _restaurantIdController.text = value ?? ''),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Future<void> _loadRestaurants() async {
    try {
      final usecase = getIt<GetAllRestaurantsUseCase>();
      final restaurants = await usecase();
      if (!mounted) return;
      setState(() {
        _restaurants = restaurants;
        _loadingRestaurants = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _restaurants = const [];
        _loadingRestaurants = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == 'staff' && _restaurantIdController.text.trim().isEmpty) return;
    final user = UserEntity(
      id: _idController.text.trim(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      emailVerified: _emailVerified,
      phone: _phoneController.text.trim(),
      country: _countryController.text.trim(),
      city: _cityController.text.trim(),
      role: _role,
      restaurantId: _restaurantIdController.text.trim().isEmpty
          ? null
          : _restaurantIdController.text.trim(),
    );

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(user);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _generateUserId() {
    final firestore = getIt<FirebaseFirestore>();
    return firestore.collection('users').doc().id;
  }
}
