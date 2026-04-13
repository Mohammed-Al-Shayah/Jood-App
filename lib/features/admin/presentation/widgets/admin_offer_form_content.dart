import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/date_utils.dart';
import 'package:jood/core/utils/guest_pricing_utils.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/widgets/admin_input_decoration.dart';
import 'package:jood/features/admin/presentation/widgets/admin_section_card.dart';
import 'package:jood/features/attractions/domain/usecases/get_all_attractions_usecase.dart';
import 'package:jood/features/offers/data/models/offer_model.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';
import 'package:jood/features/restaurants/domain/usecases/get_all_restaurants_usecase.dart';

class AdminOfferFormContent extends StatefulWidget {
  const AdminOfferFormContent({
    super.key,
    this.offer,
    this.initialCategory,
    required this.onSubmit,
    this.padding,
  });

  final OfferEntity? offer;
  final String? initialCategory;
  final Future<void> Function(Object result) onSubmit;
  final EdgeInsetsGeometry? padding;

  @override
  State<AdminOfferFormContent> createState() => _AdminOfferFormContentState();
}

class _AdminOfferFormContentState extends State<AdminOfferFormContent> {
  final _formKey = GlobalKey<FormState>();

  final List<_VenueOption> _restaurantVenues = [];
  final List<_VenueOption> _attractionVenues = [];
  final Map<String, _RestaurantCategorySupport> _restaurantSupportById = {};
  bool _loadingVenues = true;
  bool _isSubmitting = false;
  final List<_AttractionPackageDraft> _attractionPackages = [];

  String? _venueId;
  late String _category;
  late String _mealType;
  late String _guestPricingMode;

  late final TextEditingController _dateController;
  late final TextEditingController _dateRangeController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _currencyController;
  late final TextEditingController _priceAdultController;
  late final TextEditingController _priceAdultOriginalController;
  late final TextEditingController _priceChildController;
  late final TextEditingController _capacityAdultController;
  late final TextEditingController _capacityChildController;
  late final TextEditingController _bookedAdultController;
  late final TextEditingController _bookedChildController;
  late final TextEditingController _statusController;
  late final TextEditingController _titleController;
  late final TextEditingController _titleArController;
  late final TextEditingController _packageNameController;
  late final TextEditingController _packageNameArController;
  late final TextEditingController _packageDescriptionController;
  late final TextEditingController _packageDescriptionArController;
  late final TextEditingController _entryConditionsController;
  late final TextEditingController _entryConditionsArController;

  final _statusOptions = const ['active', 'low', 'sold_out'];
  final _categoryOptions = const ['buffet', 'set_menu', 'combo', 'attraction'];
  final _buffetMeals = const ['breakfast', 'lunch', 'dinner', 'brunch'];
  final _setMenuMeals = const ['breakfast', 'lunch', 'dinner'];

  DateTimeRange? _selectedRange;
  bool _syncingChildPrice = false;

  bool get _isEdit => widget.offer != null;
  bool get _isAttraction => _category == 'attraction';
  bool get _isSetMenu => _category == 'set_menu';
  bool get _isCombo => _category == 'combo';
  bool get _isBuffet => _category == 'buffet';
  bool get _usesAttractionPackages => _isAttraction && !_isEdit;
  bool get _isCategoryLocked =>
      (widget.initialCategory ?? '').trim().isNotEmpty;
  bool get _usesPersonPricing => usesUnifiedGuestCount(
    guestPricingMode: _guestPricingMode,
    bookingCategory: _category,
    bookableType: _isAttraction ? 'attraction' : 'restaurant',
  );
  bool get _isCouponPricing => isCouponGuestPricingMode(
    guestPricingMode: _guestPricingMode,
    bookingCategory: _category,
    bookableType: _isAttraction ? 'attraction' : 'restaurant',
  );

  String get _unifiedPriceLabel {
    if (_isCombo) return 'Price Per Combo';
    if (_isCouponPricing) return 'Price Per Coupon';
    return 'Price Per Person';
  }

  String get _unifiedOriginalPriceLabel {
    if (_isCombo) return 'Original Price Per Combo';
    if (_isCouponPricing) return 'Original Price Per Coupon';
    return 'Original Price Per Person';
  }

  String get _unifiedCapacityLabel {
    if (_isCombo) return 'Available Quantity';
    if (_isCouponPricing) return 'Available Coupons';
    return 'Capacity Persons';
  }

  String get _unifiedBookedLabel {
    if (_isCombo) return 'Booked Quantity';
    if (_isCouponPricing) return 'Booked Coupons';
    return 'Booked Persons';
  }

  List<_VenueOption> get _currentVenues =>
      _isAttraction ? _attractionVenues : _restaurantVenues;

  List<String> get _currentMealOptions =>
      _isSetMenu ? _setMenuMeals : _buffetMeals;

  @override
  void initState() {
    super.initState();
    final offer = widget.offer;
    _category = _resolveInitialCategory(offer, widget.initialCategory);
    final isAttraction = _category == 'attraction';
    _guestPricingMode = normalizeGuestPricingMode(
      offer?.guestPricingMode,
      bookingCategory: _category,
      bookableType: isAttraction ? 'attraction' : 'restaurant',
    );
    final usesPersonPricing = usesUnifiedGuestCount(
      guestPricingMode: _guestPricingMode,
      bookingCategory: _category,
      bookableType: isAttraction ? 'attraction' : 'restaurant',
    );
    final totalCapacity =
        (offer?.capacityAdult ?? 0) + (offer?.capacityChild ?? 0);
    final totalBooked = (offer?.bookedAdult ?? 0) + (offer?.bookedChild ?? 0);
    final combinedCapacityText = offer == null ? '' : totalCapacity.toString();
    final combinedBookedText = offer == null ? '0' : totalBooked.toString();
    _mealType = offer?.mealType.trim().isNotEmpty == true
        ? offer!.mealType.trim().toLowerCase()
        : _defaultMealTypeForCategory(_category);
    _venueId = offer?.restaurantId;
    _dateController = TextEditingController(text: offer?.date ?? '');
    _dateRangeController = TextEditingController();
    _startTimeController = TextEditingController(text: offer?.startTime ?? '');
    _endTimeController = TextEditingController(text: offer?.endTime ?? '');
    _currencyController = TextEditingController(text: offer?.currency ?? 'OMR');
    _priceAdultController = TextEditingController(
      text: offer?.priceAdult.toString() ?? '',
    );
    _priceAdultOriginalController = TextEditingController(
      text: offer?.priceAdultOriginal.toString() ?? '',
    );
    _priceChildController = TextEditingController(
      text: usesPersonPricing ? '0' : (offer?.priceChild.toString() ?? ''),
    );
    _capacityAdultController = TextEditingController(
      text: usesPersonPricing
          ? combinedCapacityText
          : (offer?.capacityAdult.toString() ?? ''),
    );
    _capacityChildController = TextEditingController(
      text: usesPersonPricing ? '0' : (offer?.capacityChild.toString() ?? ''),
    );
    _bookedAdultController = TextEditingController(
      text: usesPersonPricing
          ? combinedBookedText
          : (offer?.bookedAdult.toString() ?? '0'),
    );
    _bookedChildController = TextEditingController(
      text: usesPersonPricing ? '0' : (offer?.bookedChild.toString() ?? '0'),
    );
    _statusController = TextEditingController(text: offer?.status ?? 'active');
    _titleController = TextEditingController(
      text: _preferredText(offer?.titleEn, offer?.title),
    );
    _titleArController = TextEditingController(text: offer?.titleAr ?? '');
    _packageNameController = TextEditingController(
      text: _preferredText(
        offer?.packageNameEn,
        offer?.packageName.isNotEmpty == true
            ? offer?.packageName
            : offer?.title,
      ),
    );
    _packageNameArController = TextEditingController(
      text: _preferredText(
        offer?.packageNameAr,
        offer?.packageNameAr.isNotEmpty == true
            ? offer?.packageNameAr
            : offer?.titleAr,
      ),
    );
    _packageDescriptionController = TextEditingController(
      text: _preferredText(
        offer?.packageDescriptionEn,
        offer?.packageDescription,
      ),
    );
    _packageDescriptionArController = TextEditingController(
      text: offer?.packageDescriptionAr ?? '',
    );
    _entryConditionsController = TextEditingController(
      text: _joinLines(
        _preferredList(offer?.entryConditionsEn, offer?.entryConditions),
      ),
    );
    _entryConditionsArController = TextEditingController(
      text: _joinLines(offer?.entryConditionsAr),
    );
    if (!_isEdit && (_isBuffet || _isSetMenu)) {
      _titleController.text = _defaultTitleForMealType(_category, _mealType);
    }
    _priceAdultController.addListener(_syncChildPriceFromAdult);
    if (_usesAttractionPackages) {
      _attractionPackages.add(_createAttractionPackageDraft());
    }
    _loadVenues();
  }

  @override
  void dispose() {
    _priceAdultController.removeListener(_syncChildPriceFromAdult);
    for (final package in _attractionPackages) {
      package.dispose();
    }
    _dateController.dispose();
    _dateRangeController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _currencyController.dispose();
    _priceAdultController.dispose();
    _priceAdultOriginalController.dispose();
    _priceChildController.dispose();
    _capacityAdultController.dispose();
    _capacityChildController.dispose();
    _bookedAdultController.dispose();
    _bookedChildController.dispose();
    _statusController.dispose();
    _titleController.dispose();
    _titleArController.dispose();
    _packageNameController.dispose();
    _packageNameArController.dispose();
    _packageDescriptionController.dispose();
    _packageDescriptionArController.dispose();
    _entryConditionsController.dispose();
    _entryConditionsArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingVenues) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: widget.padding ?? EdgeInsets.fromLTRB(0, 6.h, 0, 24.h),
        children: [
          AdminSectionCard(
            title: 'Basics',
            child: Column(
              children: [
                if (!_isCategoryLocked) _categoryDropdown(),
                _venueDropdown(),
                if (_restaurantCategoryWarning != null)
                  _categoryWarningCard(_restaurantCategoryWarning!),
                if (!_isAttraction) ...[
                  _titleField(),
                  _textField(
                    _titleArController,
                    '${_titleLabel()} (AR optional)',
                    required: false,
                  ),
                ],
                if (_isEdit) _dateField() else _dateRangeField(),
                _timeField(_startTimeController, 'Start Time'),
                _timeField(_endTimeController, 'End Time'),
                if (_isBuffet || _isSetMenu) _mealTypeDropdown(),
                if (_isAttraction && !_usesAttractionPackages) ...[
                  _textField(_packageNameController, 'Package Name (EN)'),
                  _textField(
                    _packageNameArController,
                    'Package Name (AR optional)',
                    required: false,
                  ),
                  _multilineField(
                    _packageDescriptionController,
                    'Package Description (EN)',
                    minLines: 3,
                  ),
                  _multilineField(
                    _packageDescriptionArController,
                    'Package Description (AR optional)',
                    minLines: 3,
                    required: false,
                  ),
                ],
                _textField(_currencyController, 'Currency'),
                if (_isAttraction) _guestPricingModeDropdown(),
                if (!_usesAttractionPackages) _statusDropdown(),
              ],
            ),
          ),
          if (_usesAttractionPackages) ...[
            SizedBox(height: 14.h),
            _attractionPackagesSection(),
          ] else ...[
            SizedBox(height: 14.h),
            AdminSectionCard(
              title: 'Pricing',
              child: Column(
                children: [
                  if (_usesPersonPricing) ...[
                    _numberField(_priceAdultController, _unifiedPriceLabel),
                    _numberField(
                      _priceAdultOriginalController,
                      _unifiedOriginalPriceLabel,
                    ),
                  ] else ...[
                    _numberField(_priceAdultController, 'Price Adult'),
                    _numberField(
                      _priceAdultOriginalController,
                      'Price Adult Original',
                    ),
                    _numberField(_priceChildController, 'Price Child'),
                  ],
                ],
              ),
            ),
            SizedBox(height: 14.h),
            AdminSectionCard(
              title: 'Capacity',
              child: Column(
                children: [
                  if (_usesPersonPricing) ...[
                    _intField(_capacityAdultController, _unifiedCapacityLabel),
                    _intField(_bookedAdultController, _unifiedBookedLabel),
                  ] else ...[
                    _intField(_capacityAdultController, 'Capacity Adult'),
                    _intField(_capacityChildController, 'Capacity Child'),
                    _intField(_bookedAdultController, 'Booked Adult'),
                    _intField(_bookedChildController, 'Booked Child'),
                  ],
                ],
              ),
            ),
            SizedBox(height: 14.h),
            AdminSectionCard(
              title: 'Entry Conditions',
              child: Column(
                children: [
                  _multilineField(
                    _entryConditionsController,
                    'Entry Conditions (EN, one condition per line)',
                    minLines: 4,
                    required: false,
                  ),
                  _multilineField(
                    _entryConditionsArController,
                    'Entry Conditions (AR optional, one condition per line)',
                    minLines: 4,
                    required: false,
                  ),
                ],
              ),
            ),
          ],
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
                      width: 18.h,
                      height: 18.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isEdit ? 'Update' : 'Create'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: DropdownButtonFormField<String>(
        initialValue: _category,
        decoration: adminInputDecoration('Category'),
        items: _categoryOptions
            .map(
              (category) => DropdownMenuItem(
                value: category,
                child: Text(_displayCategory(category)),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null || value == _category) return;
          setState(() {
            final previousCategory = _category;
            final previousMealType = _mealType;
            _category = value;
            _mealType = _defaultMealTypeForCategory(value);
            if (!_isAttraction) {
              _packageNameController.clear();
              _packageNameArController.clear();
              _packageDescriptionController.clear();
              _packageDescriptionArController.clear();
            }
            _syncCategorySpecificFields(
              previousCategory: previousCategory,
              nextCategory: value,
            );
            _syncSelectedVenue();
            _maybeSyncTitleWithMealType(
              previousCategory: previousCategory,
              previousMealType: previousMealType,
            );
          });
        },
      ),
    );
  }

  Widget _venueDropdown() {
    final venues = _currentVenues;
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: DropdownButtonFormField<String>(
        initialValue: venues.any((item) => item.id == _venueId)
            ? _venueId
            : null,
        decoration: adminInputDecoration(
          _isAttraction ? 'Attraction' : 'Restaurant',
        ),
        isExpanded: true,
        items: venues
            .map(
              (venue) => DropdownMenuItem(
                value: venue.id,
                child: Text(venue.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        selectedItemBuilder: (context) => venues
            .map((venue) => Text(venue.name, overflow: TextOverflow.ellipsis))
            .toList(),
        onChanged: (value) => setState(() => _venueId = value),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _guestPricingModeDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: DropdownButtonFormField<String>(
        initialValue: _guestPricingMode,
        decoration: adminInputDecoration('Guest Pricing Mode'),
        items: const [
          DropdownMenuItem(
            value: guestPricingModePerson,
            child: Text('Person'),
          ),
          DropdownMenuItem(
            value: guestPricingModeCoupon,
            child: Text('Coupon'),
          ),
          DropdownMenuItem(
            value: guestPricingModeAdultsChildren,
            child: Text('Adults + Children'),
          ),
        ],
        onChanged: (value) {
          if (value == null || value == _guestPricingMode) return;
          setState(() {
            _guestPricingMode = value;
            _syncGuestPricingModeFields();
          });
        },
      ),
    );
  }

  Widget _mealTypeDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: DropdownButtonFormField<String>(
        initialValue: _currentMealOptions.contains(_mealType)
            ? _mealType
            : null,
        decoration: adminInputDecoration(
          _isSetMenu ? 'Set Menu Type' : 'Meal Type',
        ),
        items: _currentMealOptions
            .map(
              (meal) => DropdownMenuItem(
                value: meal,
                child: Text(_displayMealType(meal)),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() {
          final previousCategory = _category;
          final previousMealType = _mealType;
          _mealType = value ?? _defaultMealTypeForCategory(_category);
          _maybeSyncTitleWithMealType(
            previousCategory: previousCategory,
            previousMealType: previousMealType,
          );
        }),
      ),
    );
  }

  Widget _statusDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: DropdownButtonFormField<String>(
        initialValue: _statusController.text.isNotEmpty
            ? _statusController.text
            : null,
        decoration: adminInputDecoration('Status'),
        items: _statusOptions
            .map(
              (status) => DropdownMenuItem(value: status, child: Text(status)),
            )
            .toList(),
        onChanged: (value) => setState(() {
          _statusController.text = value ?? '';
        }),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _attractionPackagesSection() {
    return AdminSectionCard(
      title: 'Packages',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add multiple packages for the same time slot. Each package will be saved as a separate offer with its own price, capacity, status, and conditions.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          ..._attractionPackages.asMap().entries.map((entry) {
            final index = entry.key;
            final package = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _attractionPackages.length - 1 ? 0 : 14.h,
              ),
              child: _attractionPackageCard(package, index),
            );
          }),
          SizedBox(height: 14.h),
          OutlinedButton.icon(
            onPressed: _addAttractionPackage,
            icon: const Icon(Icons.add),
            label: const Text('Add package'),
          ),
        ],
      ),
    );
  }

  Widget _attractionPackageCard(_AttractionPackageDraft package, int index) {
    return Container(
      key: ValueKey(package),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Package ${index + 1}',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 15.sp),
                ),
              ),
              if (_attractionPackages.length > 1)
                IconButton(
                  onPressed: () => _removeAttractionPackage(index),
                  tooltip: 'Remove package',
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          _textField(package.packageNameController, 'Package Name (EN)'),
          _textField(
            package.packageNameArController,
            'Package Name (AR optional)',
            required: false,
          ),
          _multilineField(
            package.packageDescriptionController,
            'Package Description (EN)',
            minLines: 3,
          ),
          _multilineField(
            package.packageDescriptionArController,
            'Package Description (AR optional)',
            minLines: 3,
            required: false,
          ),
          if (_usesPersonPricing) ...[
            _numberField(package.priceAdultController, _unifiedPriceLabel),
            _numberField(
              package.priceAdultOriginalController,
              _unifiedOriginalPriceLabel,
            ),
            _intField(package.capacityAdultController, _unifiedCapacityLabel),
            _intField(package.bookedAdultController, _unifiedBookedLabel),
          ] else ...[
            _numberField(package.priceAdultController, 'Price Adult'),
            _numberField(
              package.priceAdultOriginalController,
              'Price Adult Original',
            ),
            _numberField(package.priceChildController, 'Price Child'),
            _intField(package.capacityAdultController, 'Capacity Adult'),
            _intField(package.capacityChildController, 'Capacity Child'),
            _intField(package.bookedAdultController, 'Booked Adult'),
            _intField(package.bookedChildController, 'Booked Child'),
          ],
          Padding(
            padding: EdgeInsets.only(bottom: 18.h),
            child: DropdownButtonFormField<String>(
              initialValue: _statusOptions.contains(package.status)
                  ? package.status
                  : null,
              decoration: adminInputDecoration('Status'),
              items: _statusOptions
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                package.status = value ?? 'active';
              }),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
            ),
          ),
          _multilineField(
            package.entryConditionsController,
            'Entry Conditions (EN, one condition per line)',
            minLines: 3,
            required: false,
          ),
          _multilineField(
            package.entryConditionsArController,
            'Entry Conditions (AR optional, one condition per line)',
            minLines: 3,
            required: false,
          ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    VoidCallback? onTap,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: adminInputDecoration(label),
        validator:
            validator ??
            (required
                ? (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null
                : null),
      ),
    );
  }

  Widget _titleField() {
    return _textField(
      _titleController,
      '${_titleLabel()} (EN)',
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        return _titleMismatchError(value);
      },
    );
  }

  Widget _categoryWarningCard(String message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF5C28B)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309)),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: const Color(0xFF92400E),
                  fontSize: 12.sp,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _multilineField(
    TextEditingController controller,
    String label, {
    required int minLines,
    bool required = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines + 2,
        decoration: adminInputDecoration(label),
        validator: required
            ? (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  List<String> _splitLines(String value) {
    return value
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _joinLines(List<String>? values) {
    if (values == null || values.isEmpty) return '';
    return values.join('\n');
  }

  String _preferredText(String? english, String? fallback) {
    final normalizedEnglish = english?.trim() ?? '';
    if (normalizedEnglish.isNotEmpty) return normalizedEnglish;
    return fallback?.trim() ?? '';
  }

  List<String> _preferredList(List<String>? english, List<String>? fallback) {
    final normalizedEnglish = _splitLines((english ?? const []).join('\n'));
    if (normalizedEnglish.isNotEmpty) return normalizedEnglish;
    return _splitLines((fallback ?? const []).join('\n'));
  }

  Widget _dateField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: _dateController,
        decoration: adminInputDecoration('Date (YYYY-MM-DD)'),
        readOnly: true,
        onTap: _pickDate,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          final parsed = DateTime.tryParse(value.trim());
          if (parsed == null) return 'Invalid date';
          return null;
        },
      ),
    );
  }

  Widget _dateRangeField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: _dateRangeController,
        decoration: adminInputDecoration(
          'Date Range (YYYY-MM-DD to YYYY-MM-DD)',
        ),
        readOnly: true,
        onTap: _pickDateRange,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          if (_selectedRange == null) return 'Invalid date range';
          return null;
        },
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

  Future<void> _loadVenues() async {
    try {
      final restaurants = await getIt<GetAllRestaurantsUseCase>()();
      final attractions = await getIt<GetAllAttractionsUseCase>()();
      if (!mounted) return;
      _restaurantVenues
        ..clear()
        ..addAll(
          restaurants.map((restaurant) {
            return _VenueOption(
              id: restaurant.id,
              name: restaurant.name.trim().isEmpty
                  ? restaurant.id
                  : restaurant.name,
            );
          }),
        );
      _restaurantSupportById
        ..clear()
        ..addEntries(
          restaurants.map((restaurant) {
            return MapEntry(
              restaurant.id,
              _RestaurantCategorySupport(
                name: restaurant.name.trim().isEmpty
                    ? restaurant.id
                    : restaurant.name,
                supportsBuffet: restaurant.supportsBuffet,
                supportsSetMenu: restaurant.supportsSetMenu,
              ),
            );
          }),
        );
      _attractionVenues
        ..clear()
        ..addAll(
          attractions.map((attraction) {
            return _VenueOption(
              id: attraction.id,
              name: attraction.name.trim().isEmpty
                  ? attraction.id
                  : attraction.name,
            );
          }),
        );
      setState(() {
        _loadingVenues = false;
        _syncSelectedVenue();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingVenues = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_dateController.text.trim()) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    _dateController.text = AppDateUtils.formatDate(picked);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialRange = _selectedRange ?? DateTimeRange(start: now, end: now);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    _selectedRange = picked;
    final start = AppDateUtils.formatDate(picked.start);
    final end = AppDateUtils.formatDate(picked.end);
    _dateRangeController.text = '$start to $end';
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked == null) return;
    controller.text = _formatTime(picked);
  }

  void _syncChildPriceFromAdult() {
    if (_syncingChildPrice) return;
    if (_usesPersonPricing) {
      if (_priceChildController.text.trim() == '0') return;
      _syncingChildPrice = true;
      _priceChildController.text = '0';
      _syncingChildPrice = false;
      return;
    }
    final raw = _priceAdultController.text.trim();
    if (raw.isEmpty) {
      _syncingChildPrice = true;
      _priceChildController.text = '';
      _syncingChildPrice = false;
      return;
    }
    final parsed = double.tryParse(raw);
    if (parsed == null) return;
    final child = parsed / 2;
    final formatted = _formatNumber(child);
    _syncingChildPrice = true;
    _priceChildController.text = formatted;
    _syncingChildPrice = false;
  }

  void _addAttractionPackage() {
    setState(() {
      _attractionPackages.add(_createAttractionPackageDraft());
    });
  }

  void _removeAttractionPackage(int index) {
    if (_attractionPackages.length <= 1) return;
    final package = _attractionPackages.removeAt(index);
    package.dispose();
    setState(() {});
  }

  _AttractionPackageDraft _createAttractionPackageDraft() {
    return _AttractionPackageDraft(
      packageName: '',
      packageNameAr: '',
      packageDescription: '',
      packageDescriptionAr: '',
      priceAdult: '',
      priceAdultOriginal: '',
      priceChild: _usesPersonPricing ? '0' : '',
      capacityAdult: '',
      capacityChild: _usesPersonPricing ? '0' : '',
      bookedAdult: '0',
      bookedChild: '0',
      status: 'active',
      entryConditions: '',
      entryConditionsAr: '',
    );
  }

  void _syncCategorySpecificFields({
    required String previousCategory,
    required String nextCategory,
  }) {
    if (nextCategory == 'set_menu' || nextCategory == 'combo') {
      _guestPricingMode = guestPricingModePerson;
      _syncGuestPricingModeFields();
      return;
    }

    if (nextCategory == 'attraction') {
      _guestPricingMode = guestPricingModePerson;
      _syncGuestPricingModeFields();
      if (!_isEdit && _attractionPackages.isEmpty) {
        _attractionPackages.add(_createAttractionPackageDraft());
      }
      return;
    }

    _guestPricingMode = guestPricingModeAdultsChildren;
    if (previousCategory == 'attraction') {
      for (final package in _attractionPackages) {
        package.dispose();
      }
      _attractionPackages.clear();
      _priceChildController.clear();
      _capacityChildController.text = '0';
      _bookedChildController.text = '0';
    }
    _syncGuestPricingModeFields();
  }

  void _syncGuestPricingModeFields() {
    if (_usesPersonPricing) {
      final totalCapacity =
          (int.tryParse(_capacityAdultController.text.trim()) ?? 0) +
          (int.tryParse(_capacityChildController.text.trim()) ?? 0);
      final totalBooked =
          (int.tryParse(_bookedAdultController.text.trim()) ?? 0) +
          (int.tryParse(_bookedChildController.text.trim()) ?? 0);
      _capacityAdultController.text =
          totalCapacity == 0 &&
              _capacityAdultController.text.trim().isEmpty &&
              _capacityChildController.text.trim().isEmpty
          ? ''
          : totalCapacity.toString();
      _bookedAdultController.text = totalBooked.toString();
      _syncingChildPrice = true;
      _priceChildController.text = '0';
      _syncingChildPrice = false;
      _capacityChildController.text = '0';
      _bookedChildController.text = '0';
      for (final package in _attractionPackages) {
        final packageTotalCapacity =
            (int.tryParse(package.capacityAdultController.text.trim()) ?? 0) +
            (int.tryParse(package.capacityChildController.text.trim()) ?? 0);
        final packageTotalBooked =
            (int.tryParse(package.bookedAdultController.text.trim()) ?? 0) +
            (int.tryParse(package.bookedChildController.text.trim()) ?? 0);
        package.capacityAdultController.text =
            packageTotalCapacity == 0 &&
                package.capacityAdultController.text.trim().isEmpty &&
                package.capacityChildController.text.trim().isEmpty
            ? ''
            : packageTotalCapacity.toString();
        package.bookedAdultController.text = packageTotalBooked.toString();
        package.priceChildController.text = '0';
        package.capacityChildController.text = '0';
        package.bookedChildController.text = '0';
      }
      return;
    }
    _syncChildPriceFromAdult();
  }

  String _unifiedBookedCapacityErrorMessage({int? packageIndex}) {
    final suffix = packageIndex == null
        ? '.'
        : ' in package ${packageIndex + 1}.';
    if (_isCombo) {
      return 'Booked quantity cannot exceed available quantity$suffix';
    }
    if (_isCouponPricing) {
      return 'Booked coupons cannot exceed available coupons$suffix';
    }
    return 'Booked persons cannot exceed capacity$suffix';
  }

  void _syncSelectedVenue() {
    final venues = _currentVenues;
    final exists =
        _venueId != null && venues.any((item) => item.id == _venueId);
    if (!exists) {
      _venueId = venues.isEmpty ? null : venues.first.id;
    }
  }

  String? get _restaurantCategoryWarning {
    if (!(_isBuffet || _isSetMenu)) return null;
    final venueId = _venueId;
    if (venueId == null || venueId.trim().isEmpty) return null;
    final support = _restaurantSupportById[venueId];
    if (support == null) return null;

    if (_isSetMenu && !support.supportsSetMenu) {
      return '${support.name} is not enabled for Set Menu in booking catalog. Enable Set Menu support for the restaurant before creating new set menu offers.';
    }

    if (_isBuffet && !support.supportsBuffet) {
      return '${support.name} is not enabled for Buffet in booking catalog. Enable Buffet support for the restaurant before creating new buffet offers.';
    }

    return null;
  }

  String _resolveInitialCategory(OfferEntity? offer, String? initialCategory) {
    final rawCategory = (offer?.bookingCategory ?? initialCategory ?? '')
        .trim()
        .toLowerCase();
    if (rawCategory == 'set menu') return 'set_menu';
    if (rawCategory == 'setmenu') return 'set_menu';
    if (rawCategory == 'combos') return 'combo';
    if (rawCategory == 'attractions') return 'attraction';
    if (_categoryOptions.contains(rawCategory)) return rawCategory;
    if ((offer?.bookableType ?? '').trim().toLowerCase() == 'attraction') {
      return 'attraction';
    }
    return 'buffet';
  }

  String _defaultMealTypeForCategory(String category) {
    if (category == 'set_menu') return 'breakfast';
    if (category == 'buffet') return 'breakfast';
    return '';
  }

  String _defaultTitleForMealType(String category, String mealType) {
    if (mealType.trim().isEmpty) return '';
    final normalizedCategory = category.trim().toLowerCase();
    if (normalizedCategory != 'buffet' && normalizedCategory != 'set_menu') {
      return '';
    }
    return _displayMealType(mealType);
  }

  void _maybeSyncTitleWithMealType({
    required String previousCategory,
    required String previousMealType,
  }) {
    final currentTitle = _titleController.text.trim();
    final previousDefault = _defaultTitleForMealType(
      previousCategory,
      previousMealType,
    ).toLowerCase();
    if (currentTitle.isEmpty || currentTitle.toLowerCase() == previousDefault) {
      final nextDefault = _defaultTitleForMealType(_category, _mealType);
      if (nextDefault.isNotEmpty) {
        _titleController.text = nextDefault;
      }
    }
  }

  String sectionLabel() {
    switch (_category) {
      case 'set_menu':
        return 'Set Menu Offer';
      case 'combo':
        return 'Combo Offer';
      case 'attraction':
        return 'Attraction Offer';
      default:
        return 'Buffet Offer';
    }
  }

  String _displayCategory(String category) {
    switch (category) {
      case 'set_menu':
        return 'Set Menu';
      case 'combo':
        return 'Combo';
      case 'attraction':
        return 'Attraction';
      default:
        return 'Buffet';
    }
  }

  String _displayMealType(String meal) {
    final normalized = meal.trim().toLowerCase();
    switch (normalized) {
      case 'set_breakfast':
      case 'breakfast':
        return _isSetMenu ? 'Breakfast Set Menu' : 'Breakfast';
      case 'set_lunch':
      case 'lunch':
        return _isSetMenu ? 'Lunch Set Menu' : 'Lunch';
      case 'set_dinner':
      case 'dinner':
        return _isSetMenu ? 'Dinner Set Menu' : 'Dinner';
      case 'brunch':
        return 'Brunch';
      default:
        return normalized;
    }
  }

  String _titleLabel() {
    if (_isAttraction) return 'Offer Title';
    if (_isSetMenu) return 'Set Menu Title';
    if (_isCombo) return 'Combo Title';
    return 'Offer Title';
  }

  String? _titleMismatchError(String? value) {
    if (!(_isBuffet || _isSetMenu)) return null;
    final title = (value ?? '').trim().toLowerCase();
    final mealType = _mealType.trim().toLowerCase();
    final baseMealType = _baseMealType(mealType);
    final displayMealType = _displayMealType(mealType).trim().toLowerCase();
    if (title.isEmpty || baseMealType.isEmpty) return null;
    if (title.contains(baseMealType) || title.contains(displayMealType)) {
      return null;
    }
    return _isSetMenu
        ? 'Title must match the selected set menu type.'
        : 'Title must match the selected meal type.';
  }

  String _baseMealType(String mealType) {
    final normalized = mealType.trim().toLowerCase();
    if (normalized.startsWith('set_')) {
      return normalized.substring(4);
    }
    return normalized;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatNumber(double value) {
    var text = value.toStringAsFixed(3);
    while (text.contains('.') && text.endsWith('0')) {
      text = text.substring(0, text.length - 1);
    }
    if (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  List<String> _entryConditions() {
    return _splitLines(_entryConditionsController.text);
  }

  List<String> _entryConditionsAr() {
    return _splitLines(_entryConditionsArController.text);
  }

  String? _attractionPackagesCountError() {
    for (var index = 0; index < _attractionPackages.length; index++) {
      final package = _attractionPackages[index];
      final adultCapacity = int.tryParse(
        package.capacityAdultController.text.trim(),
      );
      final adultBooked = int.tryParse(
        package.bookedAdultController.text.trim(),
      );
      if (adultCapacity != null &&
          adultBooked != null &&
          adultBooked > adultCapacity) {
        return _usesPersonPricing
            ? _unifiedBookedCapacityErrorMessage(packageIndex: index)
            : 'Booked adult cannot exceed adult capacity in package ${index + 1}.';
      }
      if (_usesPersonPricing) continue;
      final childCapacity = int.tryParse(
        package.capacityChildController.text.trim(),
      );
      final childBooked = int.tryParse(
        package.bookedChildController.text.trim(),
      );
      if (childCapacity != null &&
          childBooked != null &&
          childBooked > childCapacity) {
        return 'Booked child cannot exceed child capacity in package ${index + 1}.';
      }
    }
    return null;
  }

  String? _singleOfferCountError({
    required int capacityAdult,
    required int capacityChild,
    required int bookedAdult,
    required int bookedChild,
  }) {
    if (bookedAdult > capacityAdult) {
      return _usesPersonPricing
          ? _unifiedBookedCapacityErrorMessage()
          : 'Booked adult cannot exceed adult capacity.';
    }
    if (bookedChild > capacityChild) {
      return 'Booked child cannot exceed child capacity.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final categoryWarning = _restaurantCategoryWarning;
    if (categoryWarning != null) {
      showAppSnackBar(context, categoryWarning, type: SnackBarType.error);
      return;
    }

    final now = DateTime.now();
    final venueId = _venueId ?? '';
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    final currency = _currencyController.text.trim();
    final bookingCategory = _category;
    final bookableType = _isAttraction ? 'attraction' : 'restaurant';
    final guestPricingMode = _isAttraction
        ? _guestPricingMode
        : _usesPersonPricing
        ? guestPricingModePerson
        : guestPricingModeAdultsChildren;

    Object? result;

    if (_usesAttractionPackages) {
      final range = _selectedRange;
      if (range == null) {
        showAppSnackBar(
          context,
          'Please select a date range.',
          type: SnackBarType.error,
        );
        return;
      }
      if (_attractionPackages.isEmpty) {
        showAppSnackBar(
          context,
          'Add at least one package.',
          type: SnackBarType.error,
        );
        return;
      }
      final countError = _attractionPackagesCountError();
      if (countError != null) {
        showAppSnackBar(context, countError, type: SnackBarType.error);
        return;
      }
      result = _offersForAttractionPackages(
        venueId: venueId,
        range: range,
        startTime: startTime,
        endTime: endTime,
        currency: currency,
        createdAt: now,
        updatedAt: now,
        bookingCategory: bookingCategory,
        bookableType: bookableType,
        guestPricingMode: guestPricingMode,
      );
    } else {
      final priceAdult = double.parse(_priceAdultController.text.trim());
      final priceAdultOriginal = double.parse(
        _priceAdultOriginalController.text.trim(),
      );
      final priceChild = _usesPersonPricing
          ? 0.0
          : double.parse(_priceChildController.text.trim());
      final capacityAdult = int.parse(_capacityAdultController.text.trim());
      final capacityChild = _usesPersonPricing
          ? 0
          : int.parse(_capacityChildController.text.trim());
      final bookedAdult = int.parse(_bookedAdultController.text.trim());
      final bookedChild = _usesPersonPricing
          ? 0
          : int.parse(_bookedChildController.text.trim());
      final countError = _singleOfferCountError(
        capacityAdult: capacityAdult,
        capacityChild: capacityChild,
        bookedAdult: bookedAdult,
        bookedChild: bookedChild,
      );
      if (countError != null) {
        showAppSnackBar(context, countError, type: SnackBarType.error);
        return;
      }
      final status = _statusController.text.trim();
      final packageName = _isAttraction
          ? _packageNameController.text.trim()
          : '';
      final packageNameAr = _isAttraction
          ? _packageNameArController.text.trim()
          : '';
      final title = _isAttraction && packageName.isNotEmpty
          ? packageName
          : _titleController.text.trim();
      final titleAr = _isAttraction
          ? packageNameAr
          : _titleArController.text.trim();
      final packageDescription = _isAttraction
          ? _packageDescriptionController.text.trim()
          : '';
      final packageDescriptionAr = _isAttraction
          ? _packageDescriptionArController.text.trim()
          : '';
      final mealType = (_isBuffet || _isSetMenu) ? _mealType : '';
      final entryConditions = _entryConditions();
      final entryConditionsAr = _entryConditionsAr();

      if (_isEdit) {
        final parsedDate = DateTime.tryParse(_dateController.text.trim());
        if (parsedDate == null) {
          showAppSnackBar(
            context,
            'Invalid date format. Use YYYY-MM-DD.',
            type: SnackBarType.error,
          );
          return;
        }
        result = OfferModel(
          id: widget.offer!.id,
          restaurantId: venueId,
          date: AppDateUtils.formatDate(parsedDate),
          startTime: startTime,
          endTime: endTime,
          currency: currency,
          priceAdult: priceAdult,
          priceAdultOriginal: priceAdultOriginal,
          priceChild: priceChild,
          capacityAdult: capacityAdult,
          capacityChild: capacityChild,
          bookedAdult: bookedAdult,
          bookedChild: bookedChild,
          status: status,
          title: title,
          entryConditions: entryConditions,
          createdAt: widget.offer!.createdAt,
          updatedAt: now,
          bookingCategory: bookingCategory,
          bookableType: bookableType,
          guestPricingMode: guestPricingMode,
          mealType: mealType,
          packageName: packageName,
          packageDescription: packageDescription,
          titleEn: title,
          titleAr: titleAr,
          entryConditionsEn: entryConditions,
          entryConditionsAr: entryConditionsAr,
          packageNameEn: packageName,
          packageNameAr: packageNameAr,
          packageDescriptionEn: packageDescription,
          packageDescriptionAr: packageDescriptionAr,
        );
      } else {
        final range = _selectedRange;
        if (range == null) {
          showAppSnackBar(
            context,
            'Please select a date range.',
            type: SnackBarType.error,
          );
          return;
        }
        result = _offersForRange(
          venueId: venueId,
          range: range,
          startTime: startTime,
          endTime: endTime,
          currency: currency,
          priceAdult: priceAdult,
          priceAdultOriginal: priceAdultOriginal,
          priceChild: priceChild,
          capacityAdult: capacityAdult,
          capacityChild: capacityChild,
          bookedAdult: bookedAdult,
          bookedChild: bookedChild,
          status: status,
          title: title,
          titleAr: titleAr,
          entryConditions: entryConditions,
          entryConditionsAr: entryConditionsAr,
          createdAt: now,
          updatedAt: now,
          bookingCategory: bookingCategory,
          bookableType: bookableType,
          guestPricingMode: guestPricingMode,
          mealType: mealType,
          packageName: packageName,
          packageNameAr: packageNameAr,
          packageDescription: packageDescription,
          packageDescriptionAr: packageDescriptionAr,
        );
      }
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(result);
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().trim().replaceFirst('Exception: ', '');
      showAppSnackBar(
        context,
        message.isEmpty ? 'Failed to save offer.' : message,
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  List<OfferEntity> _offersForAttractionPackages({
    required String venueId,
    required DateTimeRange range,
    required String startTime,
    required String endTime,
    required String currency,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String bookingCategory,
    required String bookableType,
    required String guestPricingMode,
  }) {
    final offers = <OfferEntity>[];
    for (final package in _attractionPackages) {
      final packageName = package.packageNameController.text.trim();
      final packageNameAr = package.packageNameArController.text.trim();
      offers.addAll(
        _offersForRange(
          venueId: venueId,
          range: range,
          startTime: startTime,
          endTime: endTime,
          currency: currency,
          priceAdult: double.parse(package.priceAdultController.text.trim()),
          priceAdultOriginal: double.parse(
            package.priceAdultOriginalController.text.trim(),
          ),
          priceChild: _usesPersonPricing
              ? 0
              : double.parse(package.priceChildController.text.trim()),
          capacityAdult: int.parse(package.capacityAdultController.text.trim()),
          capacityChild: _usesPersonPricing
              ? 0
              : int.parse(package.capacityChildController.text.trim()),
          bookedAdult: int.parse(package.bookedAdultController.text.trim()),
          bookedChild: _usesPersonPricing
              ? 0
              : int.parse(package.bookedChildController.text.trim()),
          status: package.status,
          title: packageName,
          titleAr: packageNameAr,
          entryConditions: package.entryConditions(),
          entryConditionsAr: package.entryConditionsAr(),
          createdAt: createdAt,
          updatedAt: updatedAt,
          bookingCategory: bookingCategory,
          bookableType: bookableType,
          guestPricingMode: guestPricingMode,
          mealType: '',
          packageName: packageName,
          packageNameAr: packageNameAr,
          packageDescription: package.packageDescriptionController.text.trim(),
          packageDescriptionAr: package.packageDescriptionArController.text
              .trim(),
        ),
      );
    }
    return offers;
  }

  List<OfferEntity> _offersForRange({
    required String venueId,
    required DateTimeRange range,
    required String startTime,
    required String endTime,
    required String currency,
    required double priceAdult,
    required double priceAdultOriginal,
    required double priceChild,
    required int capacityAdult,
    required int capacityChild,
    required int bookedAdult,
    required int bookedChild,
    required String status,
    required String title,
    required String titleAr,
    required List<String> entryConditions,
    required List<String> entryConditionsAr,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String bookingCategory,
    required String bookableType,
    required String guestPricingMode,
    required String mealType,
    required String packageName,
    required String packageNameAr,
    required String packageDescription,
    required String packageDescriptionAr,
  }) {
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    final days = end.difference(start).inDays;
    if (days < 0) return [];
    final offers = <OfferEntity>[];
    for (var index = 0; index <= days; index++) {
      final date = start.add(Duration(days: index));
      offers.add(
        OfferModel(
          id: '',
          restaurantId: venueId,
          date: AppDateUtils.formatDate(date),
          startTime: startTime,
          endTime: endTime,
          currency: currency,
          priceAdult: priceAdult,
          priceAdultOriginal: priceAdultOriginal,
          priceChild: priceChild,
          capacityAdult: capacityAdult,
          capacityChild: capacityChild,
          bookedAdult: bookedAdult,
          bookedChild: bookedChild,
          status: status,
          title: title,
          entryConditions: entryConditions,
          createdAt: createdAt,
          updatedAt: updatedAt,
          bookingCategory: bookingCategory,
          bookableType: bookableType,
          guestPricingMode: guestPricingMode,
          mealType: mealType,
          packageName: packageName,
          packageDescription: packageDescription,
          titleEn: title,
          titleAr: titleAr,
          entryConditionsEn: entryConditions,
          entryConditionsAr: entryConditionsAr,
          packageNameEn: packageName,
          packageNameAr: packageNameAr,
          packageDescriptionEn: packageDescription,
          packageDescriptionAr: packageDescriptionAr,
        ),
      );
    }
    return offers;
  }
}

class _AttractionPackageDraft {
  _AttractionPackageDraft({
    required String packageName,
    required String packageNameAr,
    required String packageDescription,
    required String packageDescriptionAr,
    required String priceAdult,
    required String priceAdultOriginal,
    required String priceChild,
    required String capacityAdult,
    required String capacityChild,
    required String bookedAdult,
    required String bookedChild,
    required this.status,
    required String entryConditions,
    required String entryConditionsAr,
  }) : packageNameController = TextEditingController(text: packageName),
       packageNameArController = TextEditingController(text: packageNameAr),
       packageDescriptionController = TextEditingController(
         text: packageDescription,
       ),
       packageDescriptionArController = TextEditingController(
         text: packageDescriptionAr,
       ),
       priceAdultController = TextEditingController(text: priceAdult),
       priceAdultOriginalController = TextEditingController(
         text: priceAdultOriginal,
       ),
       priceChildController = TextEditingController(text: priceChild),
       capacityAdultController = TextEditingController(text: capacityAdult),
       capacityChildController = TextEditingController(text: capacityChild),
       bookedAdultController = TextEditingController(text: bookedAdult),
       bookedChildController = TextEditingController(text: bookedChild),
       entryConditionsController = TextEditingController(text: entryConditions),
       entryConditionsArController = TextEditingController(
         text: entryConditionsAr,
       );

  final TextEditingController packageNameController;
  final TextEditingController packageNameArController;
  final TextEditingController packageDescriptionController;
  final TextEditingController packageDescriptionArController;
  final TextEditingController priceAdultController;
  final TextEditingController priceAdultOriginalController;
  final TextEditingController priceChildController;
  final TextEditingController capacityAdultController;
  final TextEditingController capacityChildController;
  final TextEditingController bookedAdultController;
  final TextEditingController bookedChildController;
  final TextEditingController entryConditionsController;
  final TextEditingController entryConditionsArController;
  String status;

  List<String> entryConditions() {
    return _splitLines(entryConditionsController.text);
  }

  List<String> entryConditionsAr() {
    return _splitLines(entryConditionsArController.text);
  }

  static List<String> _splitLines(String value) {
    return value
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  void dispose() {
    packageNameController.dispose();
    packageNameArController.dispose();
    packageDescriptionController.dispose();
    packageDescriptionArController.dispose();
    priceAdultController.dispose();
    priceAdultOriginalController.dispose();
    priceChildController.dispose();
    capacityAdultController.dispose();
    capacityChildController.dispose();
    bookedAdultController.dispose();
    bookedChildController.dispose();
    entryConditionsController.dispose();
    entryConditionsArController.dispose();
  }
}

class _VenueOption {
  const _VenueOption({required this.id, required this.name});

  final String id;
  final String name;
}

class _RestaurantCategorySupport {
  const _RestaurantCategorySupport({
    required this.name,
    required this.supportsBuffet,
    required this.supportsSetMenu,
  });

  final String name;
  final bool supportsBuffet;
  final bool supportsSetMenu;
}
