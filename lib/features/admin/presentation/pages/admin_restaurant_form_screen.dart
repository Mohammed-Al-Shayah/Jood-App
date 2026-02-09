import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/domain/usecases/delete_storage_file_usecase.dart';
import 'package:jood/features/admin/domain/usecases/upload_restaurant_image_usecase.dart';
import 'package:jood/features/admin/presentation/widgets/admin_input_decoration.dart';
import 'package:jood/features/admin/presentation/widgets/admin_section_card.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/restaurants/data/models/restaurant_model.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';

class AdminRestaurantFormScreen extends StatefulWidget {
  const AdminRestaurantFormScreen({super.key, this.restaurant});

  final RestaurantEntity? restaurant;

  @override
  State<AdminRestaurantFormScreen> createState() =>
      _AdminRestaurantFormScreenState();
}

class _AdminRestaurantFormScreenState extends State<AdminRestaurantFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _cityIdController;
  late final TextEditingController _areaController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewsCountController;
  late final TextEditingController _coverImageUrlController;
  late final TextEditingController _aboutController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _geoLatController;
  late final TextEditingController _geoLngController;
  late final TextEditingController _openFromController;
  late final TextEditingController _openToController;
  late final TextEditingController _highlightsController;
  late final TextEditingController _inclusionsController;
  late final TextEditingController _exclusionsController;
  late final TextEditingController _cancellationController;
  late final TextEditingController _knowBeforeController;
  late final TextEditingController _badgeController;
  late final TextEditingController _priceFromController;
  late final TextEditingController _discountController;
  late final TextEditingController _slotsLeftController;
  late final TextEditingController _priceFromValueController;
  late final TextEditingController _discountValueController;

  bool _isActive = true;
  bool _isUploadingImage = false;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    final restaurant = widget.restaurant;
    _nameController = TextEditingController(text: restaurant?.name ?? '');
    _cityIdController = TextEditingController(text: restaurant?.cityId ?? '');
    _areaController = TextEditingController(text: restaurant?.area ?? '');
    _ratingController = TextEditingController(
      text: restaurant?.rating.toString() ?? '',
    );
    _reviewsCountController = TextEditingController(
      text: restaurant?.reviewsCount.toString() ?? '',
    );
    _coverImageUrlController = TextEditingController(
      text: restaurant?.coverImageUrl ?? '',
    );
    _aboutController = TextEditingController(text: restaurant?.about ?? '');
    _phoneController = TextEditingController(text: restaurant?.phone ?? '');
    _addressController = TextEditingController(text: restaurant?.address ?? '');
    _geoLatController = TextEditingController(
      text: restaurant?.geoLat.toString() ?? '',
    );
    _geoLngController = TextEditingController(
      text: restaurant?.geoLng.toString() ?? '',
    );
    _openFromController = TextEditingController(
      text: restaurant?.openFrom ?? '',
    );
    _openToController = TextEditingController(text: restaurant?.openTo ?? '');
    _highlightsController = TextEditingController(
      text: _joinList(restaurant?.highlights),
    );
    _inclusionsController = TextEditingController(
      text: _joinList(restaurant?.inclusions),
    );
    _exclusionsController = TextEditingController(
      text: _joinList(restaurant?.exclusions),
    );
    _cancellationController = TextEditingController(
      text: _joinList(restaurant?.cancellationPolicy),
    );
    _knowBeforeController = TextEditingController(
      text: _joinList(restaurant?.knowBeforeYouGo),
    );
    _badgeController = TextEditingController(text: restaurant?.badge ?? '');
    _priceFromController = TextEditingController(
      text: restaurant?.priceFrom ?? '',
    );
    _discountController = TextEditingController(
      text: restaurant?.discount ?? '',
    );
    _slotsLeftController = TextEditingController(
      text: restaurant?.slotsLeft ?? '',
    );
    _priceFromValueController = TextEditingController(
      text: restaurant?.priceFromValue.toString() ?? '',
    );
    _discountValueController = TextEditingController(
      text: restaurant?.discountValue.toString() ?? '',
    );
    _isActive = restaurant?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityIdController.dispose();
    _areaController.dispose();
    _ratingController.dispose();
    _reviewsCountController.dispose();
    _coverImageUrlController.dispose();
    _aboutController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _geoLatController.dispose();
    _geoLngController.dispose();
    _openFromController.dispose();
    _openToController.dispose();
    _highlightsController.dispose();
    _inclusionsController.dispose();
    _exclusionsController.dispose();
    _cancellationController.dispose();
    _knowBeforeController.dispose();
    _badgeController.dispose();
    _priceFromController.dispose();
    _discountController.dispose();
    _slotsLeftController.dispose();
    _priceFromValueController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.restaurant != null;
    return AdminShell(
      title: isEdit ? 'Edit Restaurant' : 'Create Restaurant',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
          children: [
            AdminSectionCard(
              title: 'Basics',
              child: Column(
                children: [
                  _textField(_nameController, 'Name'),
                  _textField(_cityIdController, 'City ID'),
                  _textField(_areaController, 'Area'),
                  _numberField(_ratingController, 'Rating (double)'),
                  _intField(_reviewsCountController, 'Reviews Count'),
                  _textField(_badgeController, 'Badge'),
                  _textField(_priceFromController, 'Price From'),
                  _textField(_discountController, 'Discount'),
                  _textField(_slotsLeftController, 'Slots Left'),
                  _numberField(_priceFromValueController, 'Price From Value'),
                  _numberField(_discountValueController, 'Discount Value'),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            AdminSectionCard(
              title: 'Contact & Location',
              child: Column(
                children: [
                  _textField(_phoneController, 'Phone'),
                  _textField(_addressController, 'Address'),
                  _numberField(_geoLatController, 'Geo Lat'),
                  _numberField(_geoLngController, 'Geo Lng'),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            AdminSectionCard(
              title: 'About & Hours',
              child: Column(
                children: [
                  _textField(_aboutController, 'About', maxLines: 3),
                  _timeField(_openFromController, 'Open From'),
                  _timeField(_openToController, 'Open To'),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            AdminSectionCard(
              title: 'Lists (comma separated)',
              child: Column(
                children: [
                  _textField(_highlightsController, 'Highlights'),
                  _textField(_inclusionsController, 'Inclusions'),
                  _textField(_exclusionsController, 'Exclusions'),
                  _textField(_cancellationController, 'Cancellation Policy'),
                  _textField(_knowBeforeController, 'Know Before You Go'),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            AdminSectionCard(
              title: 'Cover Image',
              child: Column(
                children: [
                  _imagePreview(),
                  SizedBox(height: 10.h),
                  _textField(_coverImageUrlController, 'Cover Image URL'),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _isUploadingImage ? null : _pickAndUploadImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: _isUploadingImage
                              ? SizedBox(
                                  height: 16.h,
                                  width: 16.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Upload Image'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _isUploadingImage ? null : _deleteImage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: const Text('Delete Image'),
                        ),
                      ),
                    ],
                  ),
                  if (_imageError != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        _imageError!,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            AdminSectionCard(
              title: 'Visibility',
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeThumbColor: AppColors.primary,
                title: const Text('Active'),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(isEdit ? 'Update' : 'Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: adminInputDecoration(label),
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _timeField(TextEditingController controller, String label) {
    return _textField(
      controller,
      label,
      readOnly: true,
      onTap: () => _pickTime(controller),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: adminInputDecoration(label),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          final parsed = double.tryParse(value);
          if (parsed == null) return 'Invalid number';
          return null;
        },
      ),
    );
  }

  Widget _intField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: adminInputDecoration(label),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          final parsed = int.tryParse(value);
          if (parsed == null) return 'Invalid number';
          return null;
        },
      ),
    );
  }

  List<String> _splitList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _joinList(List<String>? values) {
    if (values == null || values.isEmpty) return '';
    return values.join(', ');
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked == null) return;
    controller.text = _formatTime(picked);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final restaurant = RestaurantModel(
      id: widget.restaurant?.id ?? '',
      name: _nameController.text.trim(),
      cityId: _cityIdController.text.trim(),
      area: _areaController.text.trim(),
      rating: double.parse(_ratingController.text.trim()),
      reviewsCount: int.parse(_reviewsCountController.text.trim()),
      coverImageUrl: _coverImageUrlController.text.trim(),
      about: _aboutController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      geoLat: double.parse(_geoLatController.text.trim()),
      geoLng: double.parse(_geoLngController.text.trim()),
      openFrom: _openFromController.text.trim(),
      openTo: _openToController.text.trim(),
      highlights: _splitList(_highlightsController.text),
      inclusions: _splitList(_inclusionsController.text),
      exclusions: _splitList(_exclusionsController.text),
      cancellationPolicy: _splitList(_cancellationController.text),
      knowBeforeYouGo: _splitList(_knowBeforeController.text),
      isActive: _isActive,
      createdAt: widget.restaurant?.createdAt ?? now,
      badge: _badgeController.text.trim(),
      priceFrom: _priceFromController.text.trim(),
      discount: _discountController.text.trim(),
      slotsLeft: _slotsLeftController.text.trim(),
      priceFromValue: double.parse(_priceFromValueController.text.trim()),
      discountValue: double.parse(_discountValueController.text.trim()),
    );
    Navigator.of(context).pop(restaurant);
  }

  Widget _imagePreview() {
    final url = _coverImageUrlController.text.trim();
    if (url.isEmpty) {
      return Container(
        height: 140.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'No image selected',
          style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        url,
        height: 140.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 140.h,
          width: double.infinity,
          color: const Color(0xFFF6F7FB),
          alignment: Alignment.center,
          child: Text(
            'Invalid image URL',
            style: TextStyle(fontSize: 12.sp, color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    setState(() => _imageError = null);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _isUploadingImage = true);
    try {
      final url = await getIt<UploadRestaurantImageUseCase>()(
        restaurantId: widget.restaurant?.id ?? '',
        file: picked,
      );
      _coverImageUrlController.text = url;
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Image uploaded successfully.',
        type: SnackBarType.success,
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _imageError = 'Failed to upload image.');
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _deleteImage() async {
    final url = _coverImageUrlController.text.trim();
    if (url.isEmpty) {
      setState(() => _imageError = 'No image to delete.');
      return;
    }
    setState(() {
      _isUploadingImage = true;
      _imageError = null;
    });
    try {
      await getIt<DeleteStorageFileUseCase>()(url);
      _coverImageUrlController.text = '';
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Image deleted successfully.',
        type: SnackBarType.success,
      );
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() => _imageError = 'Failed to delete image.');
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }
}
