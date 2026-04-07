import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/domain/usecases/delete_storage_file_usecase.dart';
import 'package:jood/features/admin/domain/usecases/upload_attraction_image_usecase.dart';
import 'package:jood/features/admin/presentation/widgets/admin_input_decoration.dart';
import 'package:jood/features/admin/presentation/widgets/admin_section_card.dart';
import 'package:jood/features/attractions/data/models/attraction_model.dart';
import 'package:jood/features/attractions/domain/entities/attraction_entity.dart';

class AdminAttractionFormContent extends StatefulWidget {
  const AdminAttractionFormContent({
    super.key,
    this.attraction,
    required this.onSubmit,
    this.padding,
  });

  final AttractionEntity? attraction;
  final Future<void> Function(AttractionEntity attraction) onSubmit;
  final EdgeInsetsGeometry? padding;

  @override
  State<AdminAttractionFormContent> createState() =>
      _AdminAttractionFormContentState();
}

class _AdminAttractionFormContentState
    extends State<AdminAttractionFormContent> {
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
  late final TextEditingController _highlightsController;
  late final TextEditingController _highlightsArController;
  late final TextEditingController _inclusionsController;
  late final TextEditingController _inclusionsArController;
  late final TextEditingController _catalogDescriptionController;
  late final TextEditingController _catalogDescriptionArController;
  late final TextEditingController _catalogHighlightsController;
  late final TextEditingController _catalogHighlightsArController;
  late final TextEditingController _catalogIncludedController;
  late final TextEditingController _catalogIncludedArController;
  late final TextEditingController _packageOverviewController;
  late final TextEditingController _packageOverviewArController;
  late final TextEditingController _bookingNotesController;
  late final TextEditingController _bookingNotesArController;
  late final TextEditingController _badgeController;
  late final TextEditingController _priceFromController;
  late final TextEditingController _discountController;
  late final TextEditingController _slotsLeftController;

  bool _isActive = true;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    final attraction = widget.attraction;
    _nameController = TextEditingController(
      text: _preferredText(attraction?.nameEn, attraction?.name),
    );
    _nameArController = TextEditingController(text: attraction?.nameAr ?? '');
    _cityIdController = TextEditingController(
      text: _preferredText(attraction?.cityIdEn, attraction?.cityId),
    );
    _cityIdArController = TextEditingController(
      text: attraction?.cityIdAr ?? '',
    );
    _areaController = TextEditingController(
      text: _preferredText(attraction?.areaEn, attraction?.area),
    );
    _areaArController = TextEditingController(text: attraction?.areaAr ?? '');
    _ratingController = TextEditingController(
      text: attraction?.rating.toString() ?? '',
    );
    _reviewsCountController = TextEditingController(
      text: attraction?.reviewsCount.toString() ?? '',
    );
    _coverImageUrlController = TextEditingController(
      text: attraction?.coverImageUrl ?? '',
    )..addListener(_handleCoverImageChanged);
    _aboutController = TextEditingController(
      text: _preferredText(attraction?.aboutEn, attraction?.about),
    );
    _aboutArController = TextEditingController(text: attraction?.aboutAr ?? '');
    _phoneController = TextEditingController(text: attraction?.phone ?? '');
    _addressController = TextEditingController(
      text: _preferredText(attraction?.addressEn, attraction?.address),
    );
    _addressArController = TextEditingController(
      text: attraction?.addressAr ?? '',
    );
    _highlightsController = TextEditingController(
      text: _joinCsv(
        _preferredList(attraction?.highlightsEn, attraction?.highlights),
      ),
    );
    _highlightsArController = TextEditingController(
      text: _joinCsv(attraction?.highlightsAr),
    );
    _inclusionsController = TextEditingController(
      text: _joinCsv(
        _preferredList(attraction?.inclusionsEn, attraction?.inclusions),
      ),
    );
    _inclusionsArController = TextEditingController(
      text: _joinCsv(attraction?.inclusionsAr),
    );
    _catalogDescriptionController = TextEditingController(
      text: _preferredText(
        attraction?.catalogDescriptionEn,
        attraction?.catalogDescription,
      ),
    );
    _catalogDescriptionArController = TextEditingController(
      text: attraction?.catalogDescriptionAr ?? '',
    );
    _catalogHighlightsController = TextEditingController(
      text: _joinLines(
        _preferredList(
          attraction?.catalogHighlightsEn,
          attraction?.catalogHighlights,
        ),
      ),
    );
    _catalogHighlightsArController = TextEditingController(
      text: _joinLines(attraction?.catalogHighlightsAr),
    );
    _catalogIncludedController = TextEditingController(
      text: _joinLines(
        _preferredList(
          attraction?.catalogIncludedEn,
          attraction?.catalogIncluded,
        ),
      ),
    );
    _catalogIncludedArController = TextEditingController(
      text: _joinLines(attraction?.catalogIncludedAr),
    );
    _packageOverviewController = TextEditingController(
      text: _joinLines(
        _preferredList(
          attraction?.packageOverviewEn,
          attraction?.packageOverview,
        ),
      ),
    );
    _packageOverviewArController = TextEditingController(
      text: _joinLines(attraction?.packageOverviewAr),
    );
    _bookingNotesController = TextEditingController(
      text: _joinLines(
        _preferredList(attraction?.bookingNotesEn, attraction?.bookingNotes),
      ),
    );
    _bookingNotesArController = TextEditingController(
      text: _joinLines(attraction?.bookingNotesAr),
    );
    _badgeController = TextEditingController(text: attraction?.badge ?? '');
    _priceFromController = TextEditingController(
      text: attraction?.priceFrom ?? '',
    );
    _discountController = TextEditingController(
      text: attraction?.discount ?? '',
    );
    _slotsLeftController = TextEditingController(
      text: attraction?.slotsLeft ?? '',
    );
    _isActive = attraction?.isActive ?? true;
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
    _highlightsController.dispose();
    _highlightsArController.dispose();
    _inclusionsController.dispose();
    _inclusionsArController.dispose();
    _catalogDescriptionController.dispose();
    _catalogDescriptionArController.dispose();
    _catalogHighlightsController.dispose();
    _catalogHighlightsArController.dispose();
    _catalogIncludedController.dispose();
    _catalogIncludedArController.dispose();
    _packageOverviewController.dispose();
    _packageOverviewArController.dispose();
    _bookingNotesController.dispose();
    _bookingNotesArController.dispose();
    _badgeController.dispose();
    _priceFromController.dispose();
    _discountController.dispose();
    _slotsLeftController.dispose();
    super.dispose();
  }

  void _handleCoverImageChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.attraction != null;
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
                ..._localizedTextFields(
                  englishController: _nameController,
                  arabicController: _nameArController,
                  label: 'Name',
                ),
                ..._localizedTextFields(
                  englishController: _cityIdController,
                  arabicController: _cityIdArController,
                  label: 'City ID',
                ),
                ..._localizedTextFields(
                  englishController: _areaController,
                  arabicController: _areaArController,
                  label: 'Area',
                ),
                _numberField(_ratingController, 'Rating'),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminSectionCard(
            title: 'Contact',
            child: Column(
              children: [
                _textField(_phoneController, 'Phone'),
                ..._localizedTextFields(
                  englishController: _addressController,
                  arabicController: _addressArController,
                  label: 'Address',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminSectionCard(
            title: 'Content',
            child: Column(
              children: [
                ..._localizedTextFields(
                  englishController: _aboutController,
                  arabicController: _aboutArController,
                  label: 'About',
                  maxLines: 4,
                ),
                ..._localizedTextFields(
                  englishController: _highlightsController,
                  arabicController: _highlightsArController,
                  label: 'Highlights (comma separated)',
                  maxLines: 2,
                ),
                ..._localizedTextFields(
                  englishController: _inclusionsController,
                  arabicController: _inclusionsArController,
                  label: 'Inclusions (comma separated)',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminSectionCard(
            title: 'Booking Catalog',
            child: Column(
              children: [
                ..._localizedTextFields(
                  englishController: _catalogDescriptionController,
                  arabicController: _catalogDescriptionArController,
                  label: 'Catalog Description',
                  maxLines: 4,
                ),
                ..._localizedTextFields(
                  englishController: _catalogHighlightsController,
                  arabicController: _catalogHighlightsArController,
                  label: 'Catalog Highlights (one per line)',
                  maxLines: 4,
                ),
                ..._localizedTextFields(
                  englishController: _catalogIncludedController,
                  arabicController: _catalogIncludedArController,
                  label: 'Included Items (one per line)',
                  maxLines: 4,
                ),
                ..._localizedTextFields(
                  englishController: _packageOverviewController,
                  arabicController: _packageOverviewArController,
                  label: 'Package Overview (one per line)',
                  maxLines: 4,
                ),
                ..._localizedTextFields(
                  englishController: _bookingNotesController,
                  arabicController: _bookingNotesArController,
                  label: 'Booking Notes (one per line)',
                  maxLines: 4,
                  englishRequired: false,
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
                _optionalField(_coverImageUrlController, 'Cover Image URL'),
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
                                width: 16.h,
                                height: 16.h,
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
                      width: 18.h,
                      height: 18.h,
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

  List<Widget> _localizedTextFields({
    required TextEditingController englishController,
    required TextEditingController arabicController,
    required String label,
    int maxLines = 1,
    bool englishRequired = true,
  }) {
    return [
      _textField(
        englishController,
        '$label (EN)',
        maxLines: maxLines,
        required: englishRequired,
      ),
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
    bool required = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: adminInputDecoration(label),
        validator: required
            ? (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  Widget _optionalField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return _textField(controller, label, maxLines: maxLines, required: false);
  }

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  List<String> _splitCsv(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _splitLines(String value) {
    return value
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _joinCsv(List<String>? values) {
    if (values == null || values.isEmpty) return '';
    return values.join(', ');
  }

  String _joinLines(List<String>? values) {
    if (values == null || values.isEmpty) return '';
    return values.join('\n');
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final nameEn = _nameController.text.trim();
    final cityIdEn = _cityIdController.text.trim();
    final areaEn = _areaController.text.trim();
    final aboutEn = _aboutController.text.trim();
    final addressEn = _addressController.text.trim();
    final existingAttraction = widget.attraction;
    final highlightsEn = _splitCsv(_highlightsController.text);
    final inclusionsEn = _splitCsv(_inclusionsController.text);
    final catalogDescriptionEn = _catalogDescriptionController.text.trim();
    final catalogHighlightsEn = _splitLines(_catalogHighlightsController.text);
    final catalogIncludedEn = _splitLines(_catalogIncludedController.text);
    final packageOverviewEn = _splitLines(_packageOverviewController.text);
    final bookingNotesEn = _splitLines(_bookingNotesController.text);

    final attraction = AttractionModel(
      id: widget.attraction?.id ?? '',
      name: nameEn,
      cityId: cityIdEn,
      area: areaEn,
      rating: double.parse(_ratingController.text.trim()),
      reviewsCount:
          int.tryParse(_reviewsCountController.text.trim()) ??
          existingAttraction?.reviewsCount ??
          0,
      coverImageUrl: _coverImageUrlController.text.trim(),
      about: aboutEn,
      phone: _phoneController.text.trim(),
      address: addressEn,
      highlights: highlightsEn,
      inclusions: inclusionsEn,
      catalogDescription: catalogDescriptionEn,
      catalogHighlights: catalogHighlightsEn,
      catalogIncluded: catalogIncludedEn,
      packageOverview: packageOverviewEn,
      bookingNotes: bookingNotesEn,
      isActive: _isActive,
      createdAt: existingAttraction?.createdAt ?? now,
      badge: existingAttraction?.badge ?? _badgeController.text.trim(),
      priceFrom:
          existingAttraction?.priceFrom ?? _priceFromController.text.trim(),
      discount: existingAttraction?.discount ?? _discountController.text.trim(),
      slotsLeft:
          existingAttraction?.slotsLeft ?? _slotsLeftController.text.trim(),
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
      highlightsAr: _splitCsv(_highlightsArController.text),
      inclusionsEn: inclusionsEn,
      inclusionsAr: _splitCsv(_inclusionsArController.text),
      catalogDescriptionEn: catalogDescriptionEn,
      catalogDescriptionAr: _catalogDescriptionArController.text.trim(),
      catalogHighlightsEn: catalogHighlightsEn,
      catalogHighlightsAr: _splitLines(_catalogHighlightsArController.text),
      catalogIncludedEn: catalogIncludedEn,
      catalogIncludedAr: _splitLines(_catalogIncludedArController.text),
      packageOverviewEn: packageOverviewEn,
      packageOverviewAr: _splitLines(_packageOverviewArController.text),
      bookingNotesEn: bookingNotesEn,
      bookingNotesAr: _splitLines(_bookingNotesArController.text),
    );

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(attraction);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Failed to save attraction.',
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
      return _imagePlaceholder('No image selected');
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        url,
        height: 160.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder('Invalid image URL'),
      ),
    );
  }

  Widget _imagePlaceholder(String message) {
    return Container(
      height: 160.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_activity_outlined,
            color: AppColors.primary,
            size: 30.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
          ),
        ],
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
      final url = await getIt<UploadAttractionImageUseCase>()(
        attractionId: widget.attraction?.id ?? '',
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
