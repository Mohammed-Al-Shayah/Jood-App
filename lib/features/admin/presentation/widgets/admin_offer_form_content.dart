import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/utils/date_utils.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/widgets/admin_input_decoration.dart';
import 'package:jood/features/admin/presentation/widgets/admin_section_card.dart';
import 'package:jood/features/offers/data/models/offer_model.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';

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

  String? _venueId;
  late String _category;
  late String _mealType;

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
  late final TextEditingController _packageNameController;
  late final TextEditingController _packageDescriptionController;
  late final TextEditingController _entryConditionsController;

  final _statusOptions = const ['active', 'low', 'sold_out'];
  final _categoryOptions = const ['buffet', 'set_menu', 'attraction'];
  final _buffetMeals = const ['breakfast', 'lunch', 'dinner', 'brunch'];
  final _setMenuMeals = const ['breakfast', 'lunch', 'dinner'];

  DateTimeRange? _selectedRange;
  bool _syncingChildPrice = false;

  bool get _isEdit => widget.offer != null;
  bool get _isAttraction => _category == 'attraction';
  bool get _isSetMenu => _category == 'set_menu';
  bool get _isBuffet => _category == 'buffet';
  bool get _isCategoryLocked =>
      (widget.initialCategory ?? '').trim().isNotEmpty;

  List<_VenueOption> get _currentVenues =>
      _isAttraction ? _attractionVenues : _restaurantVenues;

  List<String> get _currentMealOptions =>
      _isSetMenu ? _setMenuMeals : _buffetMeals;

  @override
  void initState() {
    super.initState();
    final offer = widget.offer;
    _category = _resolveInitialCategory(offer, widget.initialCategory);
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
      text: offer?.priceChild.toString() ?? '',
    );
    _capacityAdultController = TextEditingController(
      text: offer?.capacityAdult.toString() ?? '',
    );
    _capacityChildController = TextEditingController(
      text: offer?.capacityChild.toString() ?? '',
    );
    _bookedAdultController = TextEditingController(
      text: offer?.bookedAdult.toString() ?? '0',
    );
    _bookedChildController = TextEditingController(
      text: offer?.bookedChild.toString() ?? '0',
    );
    _statusController = TextEditingController(text: offer?.status ?? 'active');
    _titleController = TextEditingController(text: offer?.title ?? '');
    _packageNameController = TextEditingController(
      text: offer?.packageName ?? '',
    );
    _packageDescriptionController = TextEditingController(
      text: offer?.packageDescription ?? '',
    );
    _entryConditionsController = TextEditingController(
      text: (offer?.entryConditions ?? const []).join('\n'),
    );
    if (!_isEdit && (_isBuffet || _isSetMenu)) {
      _titleController.text = _defaultTitleForMealType(_category, _mealType);
    }
    _priceAdultController.addListener(_syncChildPriceFromAdult);
    _loadVenues();
  }

  @override
  void dispose() {
    _priceAdultController.removeListener(_syncChildPriceFromAdult);
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
    _packageNameController.dispose();
    _packageDescriptionController.dispose();
    _entryConditionsController.dispose();
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
                _titleField(),
                if (_isEdit) _dateField() else _dateRangeField(),
                _timeField(_startTimeController, 'Start Time'),
                _timeField(_endTimeController, 'End Time'),
                if (_isBuffet || _isSetMenu) _mealTypeDropdown(),
                if (_isAttraction) ...[
                  _textField(_packageNameController, 'Package Name'),
                  _multilineField(
                    _packageDescriptionController,
                    'Package Description',
                    minLines: 3,
                  ),
                ],
                _textField(_currencyController, 'Currency'),
                _statusDropdown(),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminSectionCard(
            title: 'Pricing',
            child: Column(
              children: [
                _numberField(_priceAdultController, 'Price Adult'),
                _numberField(
                  _priceAdultOriginalController,
                  'Price Adult Original',
                ),
                _numberField(_priceChildController, 'Price Child'),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminSectionCard(
            title: 'Capacity',
            child: Column(
              children: [
                _intField(_capacityAdultController, 'Capacity Adult'),
                _intField(_capacityChildController, 'Capacity Child'),
                _intField(_bookedAdultController, 'Booked Adult'),
                _intField(_bookedChildController, 'Booked Child'),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminSectionCard(
            title: 'Entry Conditions',
            child: _multilineField(
              _entryConditionsController,
              'One condition per line',
              minLines: 4,
              required: false,
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
              _packageDescriptionController.clear();
            }
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
      _titleLabel(),
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
      final restaurantsSnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .get();
      final attractionsSnapshot = await FirebaseFirestore.instance
          .collection('attractions')
          .get();
      if (!mounted) return;
      _restaurantVenues
        ..clear()
        ..addAll(
          restaurantsSnapshot.docs.map((doc) {
            final data = doc.data();
            final name = (data['name'] as String?)?.trim();
            return _VenueOption(
              id: doc.id,
              name: name == null || name.isEmpty ? doc.id : name,
            );
          }),
        );
      _restaurantSupportById
        ..clear()
        ..addEntries(
          restaurantsSnapshot.docs.map((doc) {
            final data = doc.data();
            final name = (data['name'] as String?)?.trim();
            return MapEntry(
              doc.id,
              _RestaurantCategorySupport(
                name: name == null || name.isEmpty ? doc.id : name,
                supportsBuffet: _restaurantSupportsCategory(data, 'buffet'),
                supportsSetMenu: _restaurantSupportsCategory(data, 'set_menu'),
              ),
            );
          }),
        );
      _attractionVenues
        ..clear()
        ..addAll(
          attractionsSnapshot.docs.map((doc) {
            final data = doc.data();
            final name = (data['name'] as String?)?.trim();
            return _VenueOption(
              id: doc.id,
              name: name == null || name.isEmpty ? doc.id : name,
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

  void _syncSelectedVenue() {
    final venues = _currentVenues;
    final exists =
        _venueId != null && venues.any((item) => item.id == _venueId);
    if (!exists) {
      _venueId = venues.isEmpty ? null : venues.first.id;
    }
  }

  bool _restaurantSupportsCategory(Map<String, dynamic> data, String category) {
    final bookingCatalog = _asMap(data['bookingCatalog']);
    final supportedCategories = _normalizedStringList(
      bookingCatalog['supportedCategories'],
    );

    if (category == 'buffet') {
      if (supportedCategories.isEmpty) return true;
      return supportedCategories.contains('buffet');
    }

    if (category == 'set_menu') {
      final setMenuConfig = _asMap(bookingCatalog['setMenu']);
      if (supportedCategories.contains('set_menu') ||
          supportedCategories.contains('setmenu')) {
        return true;
      }
      if (setMenuConfig.isNotEmpty) {
        return setMenuConfig['enabled'] as bool? ?? true;
      }
      return false;
    }

    return true;
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
    return _entryConditionsController.text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
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
    final priceAdult = double.parse(_priceAdultController.text.trim());
    final priceAdultOriginal = double.parse(
      _priceAdultOriginalController.text.trim(),
    );
    final priceChild = double.parse(_priceChildController.text.trim());
    final capacityAdult = int.parse(_capacityAdultController.text.trim());
    final capacityChild = int.parse(_capacityChildController.text.trim());
    final bookedAdult = int.parse(_bookedAdultController.text.trim());
    final bookedChild = int.parse(_bookedChildController.text.trim());
    final status = _statusController.text.trim();
    final title = _titleController.text.trim();
    final packageName = _isAttraction ? _packageNameController.text.trim() : '';
    final packageDescription = _isAttraction
        ? _packageDescriptionController.text.trim()
        : '';
    final mealType = (_isBuffet || _isSetMenu) ? _mealType : '';
    final bookingCategory = _category;
    final bookableType = _isAttraction ? 'attraction' : 'restaurant';
    final entryConditions = _entryConditions();

    Object? result;

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
        mealType: mealType,
        packageName: packageName,
        packageDescription: packageDescription,
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
        entryConditions: entryConditions,
        createdAt: now,
        updatedAt: now,
        bookingCategory: bookingCategory,
        bookableType: bookableType,
        mealType: mealType,
        packageName: packageName,
        packageDescription: packageDescription,
      );
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(result);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Failed to save offer.',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
    required List<String> entryConditions,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String bookingCategory,
    required String bookableType,
    required String mealType,
    required String packageName,
    required String packageDescription,
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
          mealType: mealType,
          packageName: packageName,
          packageDescription: packageDescription,
        ),
      );
    }
    return offers;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }

  List<String> _normalizedStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(
          (item) => item.toString().trim().toLowerCase().replaceAll(' ', '_'),
        )
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
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
