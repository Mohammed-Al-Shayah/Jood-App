import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:latlong2/latlong.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/domain/usecases/delete_storage_file_usecase.dart';
import 'package:jood/features/admin/domain/usecases/upload_restaurant_image_usecase.dart';
import 'package:jood/features/admin/presentation/widgets/admin_input_decoration.dart';
import 'package:jood/features/admin/presentation/widgets/admin_section_card.dart';
import 'package:jood/features/restaurants/data/models/restaurant_model.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';

enum _LocationInputMode { manual, map }

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
  late final TextEditingController _buffetDescriptionController;
  late final TextEditingController _buffetDescriptionArController;
  late final TextEditingController _buffetHighlightsController;
  late final TextEditingController _buffetHighlightsArController;
  late final TextEditingController _buffetIncludedController;
  late final TextEditingController _buffetIncludedArController;
  late final TextEditingController _buffetExcludedController;
  late final TextEditingController _buffetExcludedArController;
  late final TextEditingController _buffetTermsController;
  late final TextEditingController _buffetTermsArController;
  late final TextEditingController _buffetCancellationController;
  late final TextEditingController _buffetCancellationArController;
  late final TextEditingController _buffetOptionsController;
  late final TextEditingController _buffetOptionsArController;
  late final TextEditingController _buffetLocationController;
  late final TextEditingController _buffetLocationArController;
  late final TextEditingController _setMenuDescriptionController;
  late final TextEditingController _setMenuDescriptionArController;
  late final TextEditingController _setMenuHighlightsController;
  late final TextEditingController _setMenuHighlightsArController;
  late final TextEditingController _setMenuIncludedController;
  late final TextEditingController _setMenuIncludedArController;
  late final TextEditingController _setMenuTermsController;
  late final TextEditingController _setMenuTermsArController;
  late final TextEditingController _setMenuCancellationController;
  late final TextEditingController _setMenuCancellationArController;
  late final TextEditingController _setMenuOptionsController;
  late final TextEditingController _setMenuOptionsArController;
  late final TextEditingController _setMenuLocationController;
  late final TextEditingController _setMenuLocationArController;
  late final TextEditingController _comboDescriptionController;
  late final TextEditingController _comboDescriptionArController;
  late final TextEditingController _comboHighlightsController;
  late final TextEditingController _comboHighlightsArController;
  late final TextEditingController _comboIncludedController;
  late final TextEditingController _comboIncludedArController;
  late final TextEditingController _comboTermsController;
  late final TextEditingController _comboTermsArController;
  late final TextEditingController _comboCancellationController;
  late final TextEditingController _comboCancellationArController;
  late final TextEditingController _comboOptionsController;
  late final TextEditingController _comboOptionsArController;
  late final TextEditingController _comboLocationController;
  late final TextEditingController _comboLocationArController;

  bool _isActive = true;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;
  _LocationInputMode _locationInputMode = _LocationInputMode.manual;
  LatLng? _selectedMapLocation;
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
    _buffetDescriptionController = TextEditingController(
      text: _preferredText(
        restaurant?.buffetDescriptionEn,
        restaurant?.buffetDescription,
      ),
    );
    _buffetDescriptionArController = TextEditingController(
      text: restaurant?.buffetDescriptionAr ?? '',
    );
    _buffetHighlightsController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.buffetHighlightsEn,
          restaurant?.buffetHighlights,
        ),
      ),
    );
    _buffetHighlightsArController = TextEditingController(
      text: _joinLines(restaurant?.buffetHighlightsAr),
    );
    _buffetIncludedController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.buffetIncludedEn,
          restaurant?.buffetIncluded,
        ),
      ),
    );
    _buffetIncludedArController = TextEditingController(
      text: _joinLines(restaurant?.buffetIncludedAr),
    );
    _buffetExcludedController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.buffetExcludedEn,
          restaurant?.buffetExcluded,
        ),
      ),
    );
    _buffetExcludedArController = TextEditingController(
      text: _joinLines(restaurant?.buffetExcludedAr),
    );
    _buffetTermsController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.buffetTermsAndConditionsEn,
          restaurant?.buffetTermsAndConditions,
        ),
      ),
    );
    _buffetTermsArController = TextEditingController(
      text: _joinLines(restaurant?.buffetTermsAndConditionsAr),
    );
    _buffetCancellationController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.buffetCancellationPolicyEn,
          restaurant?.buffetCancellationPolicy,
        ),
      ),
    );
    _buffetCancellationArController = TextEditingController(
      text: _joinLines(restaurant?.buffetCancellationPolicyAr),
    );
    _buffetOptionsController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.buffetAvailableOptionsEn,
          restaurant?.buffetAvailableOptions,
        ),
      ),
    );
    _buffetOptionsArController = TextEditingController(
      text: _joinLines(restaurant?.buffetAvailableOptionsAr),
    );
    _buffetLocationController = TextEditingController(
      text: _preferredText(
        restaurant?.buffetLocationEn,
        restaurant?.buffetLocation,
      ),
    );
    _buffetLocationArController = TextEditingController(
      text: restaurant?.buffetLocationAr ?? '',
    );
    _setMenuDescriptionController = TextEditingController(
      text: _preferredText(
        restaurant?.setMenuDescriptionEn,
        restaurant?.setMenuDescription,
      ),
    );
    _setMenuDescriptionArController = TextEditingController(
      text: restaurant?.setMenuDescriptionAr ?? '',
    );
    _setMenuHighlightsController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.setMenuHighlightsEn,
          restaurant?.setMenuHighlights,
        ),
      ),
    );
    _setMenuHighlightsArController = TextEditingController(
      text: _joinLines(restaurant?.setMenuHighlightsAr),
    );
    _setMenuIncludedController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.setMenuIncludedEn,
          restaurant?.setMenuIncluded,
        ),
      ),
    );
    _setMenuIncludedArController = TextEditingController(
      text: _joinLines(restaurant?.setMenuIncludedAr),
    );
    _setMenuTermsController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.setMenuTermsAndConditionsEn,
          restaurant?.setMenuTermsAndConditions,
        ),
      ),
    );
    _setMenuTermsArController = TextEditingController(
      text: _joinLines(restaurant?.setMenuTermsAndConditionsAr),
    );
    _setMenuCancellationController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.setMenuCancellationPolicyEn,
          restaurant?.setMenuCancellationPolicy,
        ),
      ),
    );
    _setMenuCancellationArController = TextEditingController(
      text: _joinLines(restaurant?.setMenuCancellationPolicyAr),
    );
    _setMenuOptionsController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.setMenuAvailableOptionsEn,
          restaurant?.setMenuAvailableOptions,
        ),
      ),
    );
    _setMenuOptionsArController = TextEditingController(
      text: _joinLines(restaurant?.setMenuAvailableOptionsAr),
    );
    _setMenuLocationController = TextEditingController(
      text: _preferredText(
        restaurant?.setMenuLocationEn,
        restaurant?.setMenuLocation,
      ),
    );
    _setMenuLocationArController = TextEditingController(
      text: restaurant?.setMenuLocationAr ?? '',
    );
    _comboDescriptionController = TextEditingController(
      text: _preferredText(
        restaurant?.comboDescriptionEn,
        restaurant?.comboDescription,
      ),
    );
    _comboDescriptionArController = TextEditingController(
      text: restaurant?.comboDescriptionAr ?? '',
    );
    _comboHighlightsController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.comboHighlightsEn,
          restaurant?.comboHighlights,
        ),
      ),
    );
    _comboHighlightsArController = TextEditingController(
      text: _joinLines(restaurant?.comboHighlightsAr),
    );
    _comboIncludedController = TextEditingController(
      text: _joinLines(
        _preferredList(restaurant?.comboIncludedEn, restaurant?.comboIncluded),
      ),
    );
    _comboIncludedArController = TextEditingController(
      text: _joinLines(restaurant?.comboIncludedAr),
    );
    _comboTermsController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.comboTermsAndConditionsEn,
          restaurant?.comboTermsAndConditions,
        ),
      ),
    );
    _comboTermsArController = TextEditingController(
      text: _joinLines(restaurant?.comboTermsAndConditionsAr),
    );
    _comboCancellationController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.comboCancellationPolicyEn,
          restaurant?.comboCancellationPolicy,
        ),
      ),
    );
    _comboCancellationArController = TextEditingController(
      text: _joinLines(restaurant?.comboCancellationPolicyAr),
    );
    _comboOptionsController = TextEditingController(
      text: _joinLines(
        _preferredList(
          restaurant?.comboAvailableOptionsEn,
          restaurant?.comboAvailableOptions,
        ),
      ),
    );
    _comboOptionsArController = TextEditingController(
      text: _joinLines(restaurant?.comboAvailableOptionsAr),
    );
    _comboLocationController = TextEditingController(
      text: _preferredText(
        restaurant?.comboLocationEn,
        restaurant?.comboLocation,
      ),
    );
    _comboLocationArController = TextEditingController(
      text: restaurant?.comboLocationAr ?? '',
    );
    _isActive = restaurant?.isActive ?? true;
    _selectedMapLocation = _parseCoordinates();
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
    _buffetDescriptionController.dispose();
    _buffetDescriptionArController.dispose();
    _buffetHighlightsController.dispose();
    _buffetHighlightsArController.dispose();
    _buffetIncludedController.dispose();
    _buffetIncludedArController.dispose();
    _buffetExcludedController.dispose();
    _buffetExcludedArController.dispose();
    _buffetTermsController.dispose();
    _buffetTermsArController.dispose();
    _buffetCancellationController.dispose();
    _buffetCancellationArController.dispose();
    _buffetOptionsController.dispose();
    _buffetOptionsArController.dispose();
    _buffetLocationController.dispose();
    _buffetLocationArController.dispose();
    _setMenuDescriptionController.dispose();
    _setMenuDescriptionArController.dispose();
    _setMenuHighlightsController.dispose();
    _setMenuHighlightsArController.dispose();
    _setMenuIncludedController.dispose();
    _setMenuIncludedArController.dispose();
    _setMenuTermsController.dispose();
    _setMenuTermsArController.dispose();
    _setMenuCancellationController.dispose();
    _setMenuCancellationArController.dispose();
    _setMenuOptionsController.dispose();
    _setMenuOptionsArController.dispose();
    _setMenuLocationController.dispose();
    _setMenuLocationArController.dispose();
    _comboDescriptionController.dispose();
    _comboDescriptionArController.dispose();
    _comboHighlightsController.dispose();
    _comboHighlightsArController.dispose();
    _comboIncludedController.dispose();
    _comboIncludedArController.dispose();
    _comboTermsController.dispose();
    _comboTermsArController.dispose();
    _comboCancellationController.dispose();
    _comboCancellationArController.dispose();
    _comboOptionsController.dispose();
    _comboOptionsArController.dispose();
    _comboLocationController.dispose();
    _comboLocationArController.dispose();
    super.dispose();
  }

  void _handleCoverImageChanged() {
    if (!mounted) return;
    setState(() {});
  }

  LatLng? _parseCoordinates() {
    final latitude = double.tryParse(_geoLatController.text.trim());
    final longitude = double.tryParse(_geoLngController.text.trim());
    if (latitude == null || longitude == null) return null;
    if (!_isValidGeoCoordinate(latitude, longitude)) return null;
    return LatLng(latitude, longitude);
  }

  bool _isValidGeoCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  void _updateCoordinatesFromMap(LatLng point) {
    _geoLatController.text = point.latitude.toStringAsFixed(6);
    _geoLngController.text = point.longitude.toStringAsFixed(6);
    _selectedMapLocation = point;
  }

  Widget _locationMapPicker() {
    final center =
        _selectedMapLocation ??
        _parseCoordinates() ??
        const LatLng(23.588, 58.3829);

    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 250.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 14,
                  onTap: (_, point) {
                    setState(() => _updateCoordinatesFromMap(point));
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.jood.offers',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedMapLocation ?? center,
                        width: 44.w,
                        height: 44.w,
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.primary,
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap on the map to pick the restaurant location',
            style: AppTextStyles.cardMeta.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
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
                Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: Wrap(
                    spacing: 10.w,
                    runSpacing: 8.h,
                    children: [
                      ChoiceChip(
                        label: const Text('Manual'),
                        selected:
                            _locationInputMode == _LocationInputMode.manual,
                        onSelected: (_) {
                          setState(() {
                            _locationInputMode = _LocationInputMode.manual;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Pick from map'),
                        selected: _locationInputMode == _LocationInputMode.map,
                        onSelected: (_) {
                          setState(() {
                            _locationInputMode = _LocationInputMode.map;
                            _selectedMapLocation ??= _parseCoordinates();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (_locationInputMode == _LocationInputMode.map)
                  _locationMapPicker(),
                _geoNumberField(
                  _geoLatController,
                  'Geo Lat',
                  min: -90,
                  max: 90,
                ),
                _geoNumberField(
                  _geoLngController,
                  'Geo Lng',
                  min: -180,
                  max: 180,
                ),
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
          _buildCatalogContentSection(
            title: 'Buffet Booking Content',
            descriptionController: _buffetDescriptionController,
            descriptionArController: _buffetDescriptionArController,
            highlightsController: _buffetHighlightsController,
            highlightsArController: _buffetHighlightsArController,
            includedController: _buffetIncludedController,
            includedArController: _buffetIncludedArController,
            termsController: _buffetTermsController,
            termsArController: _buffetTermsArController,
            cancellationController: _buffetCancellationController,
            cancellationArController: _buffetCancellationArController,
            optionsController: _buffetOptionsController,
            optionsArController: _buffetOptionsArController,
            locationController: _buffetLocationController,
            locationArController: _buffetLocationArController,
            optionsLabel: 'Available Options',
            excludedController: _buffetExcludedController,
            excludedArController: _buffetExcludedArController,
          ),
          SizedBox(height: 14.h),
          _buildCatalogContentSection(
            title: 'Set Menu Booking Content',
            descriptionController: _setMenuDescriptionController,
            descriptionArController: _setMenuDescriptionArController,
            highlightsController: _setMenuHighlightsController,
            highlightsArController: _setMenuHighlightsArController,
            includedController: _setMenuIncludedController,
            includedArController: _setMenuIncludedArController,
            termsController: _setMenuTermsController,
            termsArController: _setMenuTermsArController,
            cancellationController: _setMenuCancellationController,
            cancellationArController: _setMenuCancellationArController,
            optionsController: _setMenuOptionsController,
            optionsArController: _setMenuOptionsArController,
            locationController: _setMenuLocationController,
            locationArController: _setMenuLocationArController,
            optionsLabel: 'Available Options',
          ),
          SizedBox(height: 14.h),
          _buildCatalogContentSection(
            title: 'Combo Booking Content',
            descriptionController: _comboDescriptionController,
            descriptionArController: _comboDescriptionArController,
            highlightsController: _comboHighlightsController,
            highlightsArController: _comboHighlightsArController,
            includedController: _comboIncludedController,
            includedArController: _comboIncludedArController,
            termsController: _comboTermsController,
            termsArController: _comboTermsArController,
            cancellationController: _comboCancellationController,
            cancellationArController: _comboCancellationArController,
            optionsController: _comboOptionsController,
            optionsArController: _comboOptionsArController,
            locationController: _comboLocationController,
            locationArController: _comboLocationArController,
            optionsLabel: 'Combo Options',
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

  Widget _buildCatalogContentSection({
    required String title,
    required TextEditingController descriptionController,
    required TextEditingController descriptionArController,
    required TextEditingController highlightsController,
    required TextEditingController highlightsArController,
    required TextEditingController includedController,
    required TextEditingController includedArController,
    required TextEditingController termsController,
    required TextEditingController termsArController,
    required TextEditingController cancellationController,
    required TextEditingController cancellationArController,
    required TextEditingController optionsController,
    required TextEditingController optionsArController,
    required TextEditingController locationController,
    required TextEditingController locationArController,
    required String optionsLabel,
    TextEditingController? excludedController,
    TextEditingController? excludedArController,
  }) {
    return AdminSectionCard(
      title: title,
      child: Column(
        children: [
          ..._localizedFields(
            englishController: descriptionController,
            arabicController: descriptionArController,
            label: 'Description',
            maxLines: 4,
            englishRequired: false,
          ),
          ..._localizedFields(
            englishController: highlightsController,
            arabicController: highlightsArController,
            label: 'Experience Highlights (one per line)',
            maxLines: 4,
            englishRequired: false,
          ),
          ..._localizedFields(
            englishController: termsController,
            arabicController: termsArController,
            label: 'Terms & Conditions (one per line)',
            maxLines: 4,
            englishRequired: false,
          ),
          ..._localizedFields(
            englishController: includedController,
            arabicController: includedArController,
            label: 'What\'s Included (one per line)',
            maxLines: 4,
            englishRequired: false,
          ),
          if (excludedController != null && excludedArController != null)
            ..._localizedFields(
              englishController: excludedController,
              arabicController: excludedArController,
              label: 'What\'s Excluded (one per line)',
              maxLines: 4,
              englishRequired: false,
            ),
          ..._localizedFields(
            englishController: cancellationController,
            arabicController: cancellationArController,
            label: 'Cancellation Policy (one per line)',
            maxLines: 4,
            englishRequired: false,
          ),
          ..._localizedFields(
            englishController: optionsController,
            arabicController: optionsArController,
            label: '$optionsLabel (one per line)',
            maxLines: 4,
            englishRequired: false,
          ),
          ..._localizedFields(
            englishController: locationController,
            arabicController: locationArController,
            label: 'Location',
            maxLines: 2,
            englishRequired: false,
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

  Widget _geoNumberField(
    TextEditingController controller,
    String label, {
    required double min,
    required double max,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: adminInputDecoration(label),
        onChanged: (_) {
          final parsed = _parseCoordinates();
          if (parsed == null) return;
          if (!mounted) return;
          setState(() => _selectedMapLocation = parsed);
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          final parsed = double.tryParse(value.trim());
          if (parsed == null) return 'Invalid number';
          if (parsed < min || parsed > max) {
            return 'Value must be between $min and $max';
          }
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

  List<String> _splitLines(String value) {
    return LineSplitter.split(value)
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
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
    final buffetDescriptionEn = _buffetDescriptionController.text.trim();
    final buffetHighlightsEn = _splitLines(_buffetHighlightsController.text);
    final buffetIncludedEn = _splitLines(_buffetIncludedController.text);
    final buffetExcludedEn = _splitLines(_buffetExcludedController.text);
    final buffetTermsEn = _splitLines(_buffetTermsController.text);
    final buffetCancellationEn = _splitLines(
      _buffetCancellationController.text,
    );
    final buffetOptionsEn = _splitLines(_buffetOptionsController.text);
    final buffetLocationEn = _buffetLocationController.text.trim();
    final setMenuDescriptionEn = _setMenuDescriptionController.text.trim();
    final setMenuHighlightsEn = _splitLines(_setMenuHighlightsController.text);
    final setMenuIncludedEn = _splitLines(_setMenuIncludedController.text);
    final setMenuTermsEn = _splitLines(_setMenuTermsController.text);
    final setMenuCancellationEn = _splitLines(
      _setMenuCancellationController.text,
    );
    final setMenuOptionsEn = _splitLines(_setMenuOptionsController.text);
    final setMenuLocationEn = _setMenuLocationController.text.trim();
    final comboDescriptionEn = _comboDescriptionController.text.trim();
    final comboHighlightsEn = _splitLines(_comboHighlightsController.text);
    final comboIncludedEn = _splitLines(_comboIncludedController.text);
    final comboTermsEn = _splitLines(_comboTermsController.text);
    final comboCancellationEn = _splitLines(_comboCancellationController.text);
    final comboOptionsEn = _splitLines(_comboOptionsController.text);
    final comboLocationEn = _comboLocationController.text.trim();

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
      buffetDescription: buffetDescriptionEn,
      buffetHighlights: buffetHighlightsEn,
      buffetIncluded: buffetIncludedEn,
      buffetExcluded: buffetExcludedEn,
      buffetTermsAndConditions: buffetTermsEn,
      buffetCancellationPolicy: buffetCancellationEn,
      buffetAvailableOptions: buffetOptionsEn,
      buffetLocation: buffetLocationEn,
      buffetDescriptionEn: buffetDescriptionEn,
      buffetDescriptionAr: _buffetDescriptionArController.text.trim(),
      buffetHighlightsEn: buffetHighlightsEn,
      buffetHighlightsAr: _splitLines(_buffetHighlightsArController.text),
      buffetIncludedEn: buffetIncludedEn,
      buffetIncludedAr: _splitLines(_buffetIncludedArController.text),
      buffetExcludedEn: buffetExcludedEn,
      buffetExcludedAr: _splitLines(_buffetExcludedArController.text),
      buffetTermsAndConditionsEn: buffetTermsEn,
      buffetTermsAndConditionsAr: _splitLines(_buffetTermsArController.text),
      buffetCancellationPolicyEn: buffetCancellationEn,
      buffetCancellationPolicyAr: _splitLines(
        _buffetCancellationArController.text,
      ),
      buffetAvailableOptionsEn: buffetOptionsEn,
      buffetAvailableOptionsAr: _splitLines(_buffetOptionsArController.text),
      buffetLocationEn: buffetLocationEn,
      buffetLocationAr: _buffetLocationArController.text.trim(),
      setMenuDescription: setMenuDescriptionEn,
      setMenuHighlights: setMenuHighlightsEn,
      setMenuIncluded: setMenuIncludedEn,
      setMenuTermsAndConditions: setMenuTermsEn,
      setMenuCancellationPolicy: setMenuCancellationEn,
      setMenuAvailableOptions: setMenuOptionsEn,
      setMenuLocation: setMenuLocationEn,
      setMenuDescriptionEn: setMenuDescriptionEn,
      setMenuDescriptionAr: _setMenuDescriptionArController.text.trim(),
      setMenuHighlightsEn: setMenuHighlightsEn,
      setMenuHighlightsAr: _splitLines(_setMenuHighlightsArController.text),
      setMenuIncludedEn: setMenuIncludedEn,
      setMenuIncludedAr: _splitLines(_setMenuIncludedArController.text),
      setMenuTermsAndConditionsEn: setMenuTermsEn,
      setMenuTermsAndConditionsAr: _splitLines(_setMenuTermsArController.text),
      setMenuCancellationPolicyEn: setMenuCancellationEn,
      setMenuCancellationPolicyAr: _splitLines(
        _setMenuCancellationArController.text,
      ),
      setMenuAvailableOptionsEn: setMenuOptionsEn,
      setMenuAvailableOptionsAr: _splitLines(_setMenuOptionsArController.text),
      setMenuLocationEn: setMenuLocationEn,
      setMenuLocationAr: _setMenuLocationArController.text.trim(),
      comboDescription: comboDescriptionEn,
      comboHighlights: comboHighlightsEn,
      comboIncluded: comboIncludedEn,
      comboTermsAndConditions: comboTermsEn,
      comboCancellationPolicy: comboCancellationEn,
      comboAvailableOptions: comboOptionsEn,
      comboLocation: comboLocationEn,
      comboDescriptionEn: comboDescriptionEn,
      comboDescriptionAr: _comboDescriptionArController.text.trim(),
      comboHighlightsEn: comboHighlightsEn,
      comboHighlightsAr: _splitLines(_comboHighlightsArController.text),
      comboIncludedEn: comboIncludedEn,
      comboIncludedAr: _splitLines(_comboIncludedArController.text),
      comboTermsAndConditionsEn: comboTermsEn,
      comboTermsAndConditionsAr: _splitLines(_comboTermsArController.text),
      comboCancellationPolicyEn: comboCancellationEn,
      comboCancellationPolicyAr: _splitLines(
        _comboCancellationArController.text,
      ),
      comboAvailableOptionsEn: comboOptionsEn,
      comboAvailableOptionsAr: _splitLines(_comboOptionsArController.text),
      comboLocationEn: comboLocationEn,
      comboLocationAr: _comboLocationArController.text.trim(),
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
