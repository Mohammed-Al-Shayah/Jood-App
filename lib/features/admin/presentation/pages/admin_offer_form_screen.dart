import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/utils/date_utils.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/admin/presentation/widgets/admin_section_card.dart';
import 'package:jood/features/admin/presentation/widgets/admin_input_decoration.dart';
import 'package:jood/features/offers/data/models/offer_model.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';
import 'package:jood/features/restaurants/domain/usecases/get_all_restaurants_usecase.dart';

class AdminOfferFormScreen extends StatefulWidget {
  const AdminOfferFormScreen({super.key, this.offer});

  final OfferEntity? offer;

  @override
  State<AdminOfferFormScreen> createState() => _AdminOfferFormScreenState();
}

class _AdminOfferFormScreenState extends State<AdminOfferFormScreen> {
  final _formKey = GlobalKey<FormState>();

  List<RestaurantEntity> _restaurants = const [];
  bool _loadingRestaurants = true;

  String? _restaurantId;
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
  late final TextEditingController _entryConditionsController;

  final _statusOptions = const ['active', 'low', 'sold_out'];
  DateTimeRange? _selectedRange;
  bool _syncingChildPrice = false;

  @override
  void initState() {
    super.initState();
    final offer = widget.offer;
    _restaurantId = offer?.restaurantId;
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
    _entryConditionsController = TextEditingController(
      text: _joinList(offer?.entryConditions),
    );
    _priceAdultController.addListener(_syncChildPriceFromAdult);
    _loadRestaurants();
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
    _entryConditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.offer != null;
    return AdminShell(
      title: isEdit ? 'Edit Offer' : 'Create Offer',
      body: _loadingRestaurants
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(0, 6.h, 0, 24.h),
                children: [
                  AdminSectionCard(
                    title: 'Basics',
                    child: Column(
                      children: [
                        _restaurantDropdown(),
                        _textField(_titleController, 'Title'),
                        if (isEdit) _dateField() else _dateRangeField(),
                        _timeField(_startTimeController, 'Start Time'),
                        _timeField(_endTimeController, 'End Time'),
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
                    child: _textField(
                      _entryConditionsController,
                      'Conditions (comma separated)',
                    ),
                  ),
                  SizedBox(height: 16.h),
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

  Widget _restaurantDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: DropdownButtonFormField<String>(
        initialValue: _restaurantId,
        decoration: adminInputDecoration('Restaurant'),
        items: _restaurants
            .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
            .toList(),
        onChanged: (value) => setState(() => _restaurantId = value),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Required' : null,
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
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: adminInputDecoration(label),
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Required' : null,
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

  Future<void> _loadRestaurants() async {
    final usecase = getIt<GetAllRestaurantsUseCase>();
    final restaurants = await usecase();
    if (mounted) {
      setState(() {
        _restaurants = restaurants;
        _loadingRestaurants = false;
        if (restaurants.isNotEmpty) {
          final exists =
              _restaurantId != null &&
              restaurants.any((r) => r.id == _restaurantId);
          if (!exists) {
            _restaurantId = restaurants.first.id;
          }
        }
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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

  String _formatNumber(double value) {
    var text = value.toStringAsFixed(3);
    text = text.replaceAll(RegExp(r'0+$'), '');
    text = text.replaceAll(RegExp(r'\.$'), '');
    return text;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final isEdit = widget.offer != null;
    final offerId = widget.offer?.id ?? '';
    final createdAt = widget.offer?.createdAt ?? now;
    final restaurantId = _restaurantId ?? '';
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
    final entryConditions = _splitList(_entryConditionsController.text);

    if (isEdit) {
      final parsedDate = DateTime.tryParse(_dateController.text.trim());
      if (parsedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid date format. Use YYYY-MM-DD.')),
        );
        return;
      }
      final offer = OfferModel(
        id: offerId,
        restaurantId: restaurantId,
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
        createdAt: createdAt,
        updatedAt: now,
      );
      Navigator.of(context).pop(offer);
      return;
    }

    final range = _selectedRange;
    if (range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range.')),
      );
      return;
    }
    final offers = _offersForRange(
      restaurantId: restaurantId,
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
    );
    Navigator.of(context).pop(offers);
  }

  List<OfferEntity> _offersForRange({
    required String restaurantId,
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
          restaurantId: restaurantId,
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
        ),
      );
    }
    return offers;
  }
}
