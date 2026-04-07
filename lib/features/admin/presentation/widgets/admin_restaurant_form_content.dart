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
import 'package:jood/features/restaurants/data/models/restaurant_model.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';

class AdminRestaurantFormContent extends StatefulWidget {
  const AdminRestaurantFormContent({
    super.key,
    this.restaurant,
    required this.onSubmit,
    this.padding,
  });

  final RestaurantEntity? restaurant;
  final Future<void> Function(RestaurantEntity restaurant) onSubmit;
  final EdgeInsetsGeometry? padding;

  @override
  State<AdminRestaurantFormContent> createState() =>
      _AdminRestaurantFormContentState();
}

class _AdminRestaurantFormContentState
    extends State<AdminRestaurantFormContent> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _nameArController;
  late final TextEditingController _cityIdController;
  late final TextEditingController _cityIdArController;
  late final TextEditingController _areaController;
  late final TextEditingController _areaArController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewsCountController;
  late final TextEditingController _coverImageUrlController;
  late final TextEditingController _aboutController;
  late final TextEditingController _aboutArController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _addressArController;
  late final TextEditingController _geoLatController;
  late final TextEditingController _geoLngController;
  late final TextEditingController _openFromController;
  late final TextEditingController _openToController;
  late final TextEditingController _highlightsController;
  late final TextEditingController _highlightsArController;
  late final TextEditingController _inclusionsController;
  late final TextEditingController _inclusionsArController;
  late final TextEditingController _exclusionsController;
  late final TextEditingController _exclusionsArController;
  late final TextEditingController _cancellationController;
  late final TextEditingController _cancellationArController;
  late final TextEditingController _knowBeforeController;
  late final TextEditingController _knowBeforeArController;
  late final TextEditingController _badgeController;
  late final TextEditingController _priceFromController;
  late final TextEditingController _discountController;
  late final TextEditingController _slotsLeftController;
  late final TextEditingController _priceFromValueController;
  late final TextEditingController _discountValueController;

  bool _isActive = true;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    final restaurant = widget.restaurant;
    _nameController = TextEditingController(
      text: _preferredText(restaurant?.nameEn, restaurant?.name),
    );
    _nameArController = TextEditingController(text: restaurant?.nameAr ?? '');
    _cityIdController = TextEditingController(
      text: _preferredText(restaurant?.cityIdEn, restaurant?.cityId),
    );
    _cityIdArController = TextEditingController(
      text: restaurant?.cityIdAr ?? '',
    );
    _areaController = TextEditingController(
      text: _preferredText(restaurant?.areaEn, restaurant?.area),
    );
    _areaArController = TextEditingController(text: restaurant?.areaAr ?? '');
    _ratingController = TextEditingController(
      text: restaurant?.rating.toString() ?? '',
    );
    _reviewsCountController = TextEditingController(
      text: restaurant?.reviewsCount.toString() ?? '',
    );
    _coverImageUrlController = TextEditingController(
      text: restaurant?.coverImageUrl ?? '',
    )..addListener(_handleCoverImageChanged);
    _aboutController = TextEditingController(
      text: _preferredText(restaurant?.aboutEn, restaurant?.about),
    );
    _aboutArController = TextEditingController(text: restaurant?.aboutAr ?? '');
    _phoneController = TextEditingController(text: restaurant?.phone ?? '');
    _addressController = TextEditingController(
      text: _preferredText(restaurant?.addressEn, restaurant?.address),
    );
    _addressArController = TextEditingController(
      text: restaurant?.addressAr ?? '',
    );
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
      text: _joinList(
        _preferredList(restaurant?.highlightsEn, restaurant?.highlights),
      ),
    );
    _highlightsArController = TextEditingController(
      text: _joinList(restaurant?.highlightsAr),
    );
    _inclusionsController = TextEditingController(
      text: _joinList(
        _preferredList(restaurant?.inclusionsEn, restaurant?.inclusions),
      ),
    );
    _inclusionsArController = TextEditingController(
      text: _joinList(restaurant?.inclusionsAr),
    );
    _exclusionsController = TextEditingController(
      text: _joinList(
        _preferredList(restaurant?.exclusionsEn, restaurant?.exclusions),
      ),
    );
    _exclusionsArController = TextEditingController(
      text: _joinList(restaurant?.exclusionsAr),
    );
    _cancellationController = TextEditingController(
      text: _joinList(
        _preferredList(
          restaurant?.cancellationPolicyEn,
          restaurant?.cancellationPolicy,
        ),
      ),
    );
    _cancellationArController = TextEditingController(
      text: _joinList(restaurant?.cancellationPolicyAr),
    );
    _knowBeforeController = TextEditingController(
      text: _joinList(
        _preferredList(
          restaurant?.knowBeforeYouGoEn,
          restaurant?.knowBeforeYouGo,
        ),
      ),
    );
    _knowBeforeArController = TextEditingController(
      text: _joinList(restaurant?.knowBeforeYouGoAr),
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
    _nameArController.dispose();
    _cityIdController.dispose();
    _cityIdArController.dispose();
    _areaController.dispose();
    _areaArController.dispose();
    _ratingController.dispose();
    _reviewsCountController.dispose();
    _coverImageUrlController
      ..removeListener(_handleCoverImageChanged)
      ..dispose();
    _aboutController.dispose();
    _aboutArController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _addressArController.dispose();
    _geoLatController.dispose();
    _geoLngController.dispose();
    _openFromController.dispose();
    _openToController.dispose();
    _highlightsController.dispose();
    _highlightsArController.dispose();
    _inclusionsController.dispose();
    _inclusionsArController.dispose();
    _exclusionsController.dispose();
    _exclusionsArController.dispose();
    _cancellationController.dispose();
    _cancellationArController.dispose();
    _knowBeforeController.dispose();
    _knowBeforeArController.dispose();
    _badgeController.dispose();
    _priceFromController.dispose();
    _discountController.dispose();
    _slotsLeftController.dispose();
    _priceFromValueController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  void _handleCoverImageChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.restaurant != null;
    return Form(
      key: _formKey,
      child: ListView(
        padding:
            widget.padding ??
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        children: [
          AdminSectionCard(
            title: 'Basics',
            child: Column(
              children: [
                ..._localizedFields(
                  englishController: _nameController,
                  arabicController: _nameArController,
                  label: 'Name',
                ),
                ..._localizedFields(
                  englishController: _cityIdController,
                  arabicController: _cityIdArController,
                  label: 'City ID',
                ),
                ..._localizedFields(
                  englishController: _areaController,
                  arabicController: _areaArController,
                  label: 'Area',
                ),
                _numberField(_ratingController, 'Rating (double)'),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminSectionCard(
            title: 'Contact & Location',
            child: Column(
              children: [
                _textField(_phoneController, 'Phone'),
                ..._localizedFields(
                  englishController: _addressController,
                  arabicController: _addressArController,
                  label: 'Address',
                  maxLines: 2,
                ),
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
                ..._localizedFields(
                  englishController: _aboutController,
                  arabicController: _aboutArController,
                  label: 'About',
                  maxLines: 3,
                ),
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
                ..._localizedFields(
                  englishController: _highlightsController,
                  arabicController: _highlightsArController,
                  label: 'Highlights',
                  maxLines: 2,
                ),
                ..._localizedFields(
                  englishController: _inclusionsController,
                  arabicController: _inclusionsArController,
                  label: 'Inclusions',
                  maxLines: 2,
                ),
                ..._localizedFields(
                  englishController: _exclusionsController,
                  arabicController: _exclusionsArController,
                  label: 'Exclusions',
                  maxLines: 2,
                ),
                ..._localizedFields(
                  englishController: _cancellationController,
                  arabicController: _cancellationArController,
                  label: 'Cancellation Policy',
                  maxLines: 2,
                ),
                ..._localizedFields(
                  englishController: _knowBeforeController,
                  arabicController: _knowBeforeArController,
                  label: 'Know Before You Go',
                  maxLines: 2,
                ),
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
                        onPressed: _isUploadingImage || _isSubmitting
                            ? null
                            : _pickAndUploadImage,
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
                        onPressed: _isUploadingImage || _isSubmitting
                            ? null
                            : _deleteImage,
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
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _isActive = value),
              activeThumbColor: AppColors.primary,
              title: const Text('Active'),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUploadingImage || _isSubmitting ? null : _submit,
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

  List<Widget> _localizedFields({
    required TextEditingController englishController,
    required TextEditingController arabicController,
    required String label,
    int maxLines = 1,
  }) {
    return [
      _textField(englishController, '$label (EN)', maxLines: maxLines),
      _textField(
        arabicController,
        '$label (AR optional)',
        maxLines: maxLines,
        required: false,
      ),
    ];
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool readOnly = false,
    bool required = true,
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
        validator: required
            ? (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null
            : null,
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

  List<String> _splitList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _joinList(List<String>? values) {
    if (values == null || values.isEmpty) return '';
    return values.join(', ');
  }

  List<String> _preferredList(List<String>? english, List<String>? fallback) {
    final normalizedEnglish = _cleanList(english);
    if (normalizedEnglish.isNotEmpty) return normalizedEnglish;
    return _cleanList(fallback);
  }

  String _preferredText(String? english, String? fallback) {
    final normalizedEnglish = english?.trim() ?? '';
    if (normalizedEnglish.isNotEmpty) return normalizedEnglish;
    return fallback?.trim() ?? '';
  }

  List<String> _cleanList(List<String>? values) {
    if (values == null) return const [];
    return values
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final nameEn = _nameController.text.trim();
    final cityIdEn = _cityIdController.text.trim();
    final areaEn = _areaController.text.trim();
    final aboutEn = _aboutController.text.trim();
    final addressEn = _addressController.text.trim();
    final existingRestaurant = widget.restaurant;
    final highlightsEn = _splitList(_highlightsController.text);
    final inclusionsEn = _splitList(_inclusionsController.text);
    final exclusionsEn = _splitList(_exclusionsController.text);
    final cancellationPolicyEn = _splitList(_cancellationController.text);
    final knowBeforeYouGoEn = _splitList(_knowBeforeController.text);

    final restaurant = RestaurantModel(
      id: widget.restaurant?.id ?? '',
      name: nameEn,
      cityId: cityIdEn,
      area: areaEn,
      rating: double.parse(_ratingController.text.trim()),
      reviewsCount:
          int.tryParse(_reviewsCountController.text.trim()) ??
          existingRestaurant?.reviewsCount ??
          0,
      coverImageUrl: _coverImageUrlController.text.trim(),
      about: aboutEn,
      phone: _phoneController.text.trim(),
      address: addressEn,
      geoLat: double.parse(_geoLatController.text.trim()),
      geoLng: double.parse(_geoLngController.text.trim()),
      openFrom: _openFromController.text.trim(),
      openTo: _openToController.text.trim(),
      highlights: highlightsEn,
      inclusions: inclusionsEn,
      exclusions: exclusionsEn,
      cancellationPolicy: cancellationPolicyEn,
      knowBeforeYouGo: knowBeforeYouGoEn,
      isActive: _isActive,
      createdAt: existingRestaurant?.createdAt ?? now,
      badge: _badgeController.text.trim(),
      priceFrom: _priceFromController.text.trim(),
      discount: _discountController.text.trim(),
      slotsLeft: _slotsLeftController.text.trim(),
      priceFromValue:
          double.tryParse(_priceFromValueController.text.trim()) ??
          existingRestaurant?.priceFromValue ??
          0,
      discountValue:
          double.tryParse(_discountValueController.text.trim()) ??
          existingRestaurant?.discountValue ??
          0,
      nameEn: nameEn,
      nameAr: _nameArController.text.trim(),
      cityIdEn: cityIdEn,
      cityIdAr: _cityIdArController.text.trim(),
      areaEn: areaEn,
      areaAr: _areaArController.text.trim(),
      aboutEn: aboutEn,
      aboutAr: _aboutArController.text.trim(),
      addressEn: addressEn,
      addressAr: _addressArController.text.trim(),
      highlightsEn: highlightsEn,
      highlightsAr: _splitList(_highlightsArController.text),
      inclusionsEn: inclusionsEn,
      inclusionsAr: _splitList(_inclusionsArController.text),
      exclusionsEn: exclusionsEn,
      exclusionsAr: _splitList(_exclusionsArController.text),
      cancellationPolicyEn: cancellationPolicyEn,
      cancellationPolicyAr: _splitList(_cancellationArController.text),
      knowBeforeYouGoEn: knowBeforeYouGoEn,
      knowBeforeYouGoAr: _splitList(_knowBeforeArController.text),
    );

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(restaurant);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Failed to save restaurant.',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
        errorBuilder: (_, _, _) => Container(
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
    } catch (_) {
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
