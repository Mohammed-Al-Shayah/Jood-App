import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/osm_geocoding_service.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/domain/usecases/delete_storage_file_usecase.dart';
import 'package:jood/features/admin/domain/usecases/upload_attraction_image_usecase.dart';
import 'package:jood/features/admin/presentation/widgets/admin_input_decoration.dart';
import 'package:jood/features/admin/presentation/widgets/admin_location_fullscreen_map.dart';
import 'package:jood/features/admin/presentation/widgets/admin_osm_tile_layer.dart';
import 'package:jood/features/admin/presentation/widgets/admin_section_card.dart';
import 'package:jood/features/attractions/domain/entities/attraction_entity.dart';

enum _LocationInputMode { manual, map }

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
  static const LatLng _omanMapCenter = LatLng(23.588, 58.3829);
  static const double _initialMapZoom = 16;
  static const double _minMapZoom = 5;
  static const double _maxMapZoom = 19;

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
  late final TextEditingController _locationSearchController;
  late final TextEditingController _geoLatController;
  late final TextEditingController _geoLngController;
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
  late final TextEditingController _catalogExcludedController;
  late final TextEditingController _catalogExcludedArController;
  late final TextEditingController _catalogTermsController;
  late final TextEditingController _catalogTermsArController;
  late final TextEditingController _catalogCancellationController;
  late final TextEditingController _catalogCancellationArController;
  late final TextEditingController _catalogOptionsController;
  late final TextEditingController _catalogOptionsArController;
  late final TextEditingController _catalogLocationController;
  late final TextEditingController _catalogLocationArController;
  late final TextEditingController _badgeController;
  late final TextEditingController _priceFromController;
  late final TextEditingController _discountController;
  late final TextEditingController _slotsLeftController;

  bool _isActive = true;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;
  bool _isSearchingLocation = false;
  bool _isResolvingAddress = false;
  _LocationInputMode _locationInputMode = _LocationInputMode.manual;
  final MapController _locationMapController = MapController();
  LatLng? _selectedMapLocation;
  double _locationMapZoom = _initialMapZoom;
  String? _imageError;
  String? _locationSearchError;
  List<OsmPlaceResult> _locationSearchResults = const [];

  @override
  void initState() {
    super.initState();
    final attraction = widget.attraction;
    final initialPoint = _resolveInitialGeoPoint(attraction);
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
    final initialAreaEn = _preferredText(attraction?.areaEn, attraction?.area);
    _areaController = TextEditingController(text: initialAreaEn);
    final initialAreaAr = attraction?.areaAr.trim() ?? '';
    _areaArController = TextEditingController(text: initialAreaAr);
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
    _locationSearchController = TextEditingController();
    _geoLatController = TextEditingController(
      text: initialPoint.latitude.toStringAsFixed(6),
    );
    _geoLngController = TextEditingController(
      text: initialPoint.longitude.toStringAsFixed(6),
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
    _catalogExcludedController = TextEditingController(
      text: _joinLines(
        _preferredList(
          attraction?.catalogExcludedEn,
          attraction?.catalogExcluded,
        ),
      ),
    );
    _catalogExcludedArController = TextEditingController(
      text: _joinLines(attraction?.catalogExcludedAr),
    );
    _catalogTermsController = TextEditingController(
      text: _joinLines(
        _preferredListWithFallback(
          primaryEnglish: attraction?.catalogTermsAndConditionsEn,
          primaryLocalized: attraction?.catalogTermsAndConditions,
          fallbackEnglish: attraction?.bookingNotesEn,
          fallbackLocalized: attraction?.bookingNotes,
        ),
      ),
    );
    _catalogTermsArController = TextEditingController(
      text: _joinLines(
        _preferredListWithFallback(
          primaryEnglish: attraction?.catalogTermsAndConditionsAr,
          primaryLocalized: attraction?.catalogTermsAndConditionsAr,
          fallbackEnglish: attraction?.bookingNotesAr,
          fallbackLocalized: attraction?.bookingNotesAr,
        ),
      ),
    );
    _catalogCancellationController = TextEditingController(
      text: _joinLines(
        _preferredList(
          attraction?.catalogCancellationPolicyEn,
          attraction?.catalogCancellationPolicy,
        ),
      ),
    );
    _catalogCancellationArController = TextEditingController(
      text: _joinLines(attraction?.catalogCancellationPolicyAr),
    );
    _catalogOptionsController = TextEditingController(
      text: _joinLines(
        _preferredListWithFallback(
          primaryEnglish: attraction?.catalogAvailableOptionsEn,
          primaryLocalized: attraction?.catalogAvailableOptions,
          fallbackEnglish: attraction?.packageOverviewEn,
          fallbackLocalized: attraction?.packageOverview,
        ),
      ),
    );
    _catalogOptionsArController = TextEditingController(
      text: _joinLines(
        _preferredListWithFallback(
          primaryEnglish: attraction?.catalogAvailableOptionsAr,
          primaryLocalized: attraction?.catalogAvailableOptionsAr,
          fallbackEnglish: attraction?.packageOverviewAr,
          fallbackLocalized: attraction?.packageOverviewAr,
        ),
      ),
    );
    _catalogLocationController = TextEditingController(
      text: _preferredTextWithFallback(
        primaryEnglish: attraction?.catalogLocationEn,
        primaryLocalized: attraction?.catalogLocation,
        fallbackEnglish: attraction?.addressEn,
        fallbackLocalized: attraction?.address,
      ),
    );
    _catalogLocationArController = TextEditingController(
      text: _preferredTextWithFallback(
        primaryEnglish: attraction?.catalogLocationAr,
        primaryLocalized: attraction?.catalogLocationAr,
        fallbackEnglish: attraction?.addressAr,
        fallbackLocalized: attraction?.addressAr,
      ),
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
    _locationSearchController.dispose();
    _geoLatController.dispose();
    _geoLngController.dispose();
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
    _catalogExcludedController.dispose();
    _catalogExcludedArController.dispose();
    _catalogTermsController.dispose();
    _catalogTermsArController.dispose();
    _catalogCancellationController.dispose();
    _catalogCancellationArController.dispose();
    _catalogOptionsController.dispose();
    _catalogOptionsArController.dispose();
    _catalogLocationController.dispose();
    _catalogLocationArController.dispose();
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

  LatLng _resolveInitialGeoPoint(AttractionEntity? attraction) {
    if (attraction == null) return _omanMapCenter;
    final latitude = attraction.geoLat;
    final longitude = attraction.geoLng;
    if (!_isValidGeoCoordinate(latitude, longitude)) return _omanMapCenter;
    if (latitude == 0 && longitude == 0) return _omanMapCenter;
    return LatLng(latitude, longitude);
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

  void _moveLocationMapTo(LatLng point, {double? zoom}) {
    if (_locationInputMode != _LocationInputMode.map) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _locationInputMode != _LocationInputMode.map) return;
      final targetZoom = (zoom ?? _locationMapZoom)
          .clamp(_minMapZoom, _maxMapZoom)
          .toDouble();
      _locationMapZoom = targetZoom;
      _locationMapController.move(point, targetZoom);
    });
  }

  void _zoomLocationMapBy(double delta) {
    if (_locationInputMode != _LocationInputMode.map) return;
    final camera = _locationMapController.camera;
    final nextZoom = (camera.zoom + delta)
        .clamp(_minMapZoom, _maxMapZoom)
        .toDouble();
    _locationMapZoom = nextZoom;
    _locationMapController.move(camera.center, nextZoom);
  }

  Future<void> _openFullscreenLocationMap() async {
    final selectedLocation = _selectedMapLocation ?? _parseCoordinates();
    final result = await showAdminLocationFullscreenMap(
      context: context,
      initialCenter: selectedLocation ?? _omanMapCenter,
      selectedLocation: selectedLocation ?? _omanMapCenter,
      initialZoom: _locationMapZoom,
      minZoom: _minMapZoom,
      maxZoom: _maxMapZoom,
    );
    if (!mounted || result == null) return;
    setState(() {
      _locationMapZoom = result.zoom;
      _updateCoordinatesFromMap(result.point);
    });
    _moveLocationMapTo(result.point, zoom: result.zoom);
    await _resolveLocalizedAddressFromCoordinates(result.point);
  }

  String _languageCode() {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'ar' ? 'ar' : 'en';
  }

  Future<void> _searchLocation() async {
    final query = _locationSearchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _locationSearchError = 'Type a place to search.';
        _locationSearchResults = const [];
      });
      return;
    }

    final coordinatePoint = OsmGeocodingService.tryParseCoordinates(query);
    if (coordinatePoint != null) {
      setState(() {
        _updateCoordinatesFromMap(coordinatePoint);
        _locationSearchError = null;
        _locationSearchResults = const [];
      });
      _moveLocationMapTo(coordinatePoint);
      await _resolveLocalizedAddressFromCoordinates(coordinatePoint);
      return;
    }

    setState(() {
      _isSearchingLocation = true;
      _locationSearchError = null;
    });

    try {
      final results = await OsmGeocodingService.searchPlaces(
        query,
        languageCode: _languageCode(),
      );
      if (!mounted) return;
      setState(() {
        _locationSearchResults = results;
        if (results.isEmpty) {
          _locationSearchError = 'No places found. Try another keyword.';
        }
      });
    } on OsmGeocodingException catch (error) {
      if (!mounted) return;
      setState(() {
        _locationSearchResults = const [];
        _locationSearchError = error.message;
      });
    } finally {
      if (mounted) {
        setState(() => _isSearchingLocation = false);
      }
    }
  }

  Future<void> _onMapPointPicked(LatLng point) async {
    if (!mounted) return;
    setState(() => _updateCoordinatesFromMap(point));
    _moveLocationMapTo(point);
    await _resolveLocalizedAddressFromCoordinates(point);
  }

  Future<void> _resolveLocalizedAddressFromCoordinates(
    LatLng point, {
    OsmPlaceResult? fallback,
  }) async {
    if (!mounted) return;
    setState(() => _isResolvingAddress = true);
    try {
      final english = await OsmGeocodingService.reverseGeocode(
        point,
        languageCode: 'en',
      );
      final arabic = await OsmGeocodingService.reverseGeocode(
        point,
        languageCode: 'ar',
      );
      if (!mounted) return;
      if (english == null && arabic == null && fallback == null) return;
      _applyResolvedLocation(
        english: english ?? fallback ?? arabic,
        arabic: arabic ?? fallback ?? english,
      );
    } on OsmGeocodingException {
      if (!mounted) return;
      if (fallback != null) {
        _applyResolvedLocation(english: fallback, arabic: fallback);
      }
      // Keep current values if reverse lookup fails.
    } finally {
      if (mounted) {
        setState(() => _isResolvingAddress = false);
      }
    }
  }

  void _selectSearchResult(OsmPlaceResult result) {
    setState(() {
      _updateCoordinatesFromMap(result.point);
      _locationSearchError = null;
      _locationSearchResults = const [];
      _locationSearchController.text = result.displayName;
    });
    _moveLocationMapTo(result.point);
    _resolveLocalizedAddressFromCoordinates(result.point, fallback: result);
  }

  void _applyResolvedLocation({
    OsmPlaceResult? english,
    OsmPlaceResult? arabic,
  }) {
    final englishAddress = english?.displayName.trim() ?? '';
    if (englishAddress.isNotEmpty) {
      _addressController.text = englishAddress;
    }
    final arabicAddress = arabic?.displayName.trim() ?? '';
    if (arabicAddress.isNotEmpty) {
      _addressArController.text = arabicAddress;
    }

    final englishCity = english?.city.trim() ?? '';
    if (englishCity.isNotEmpty) {
      _cityIdController.text = englishCity;
    }
    final arabicCity = arabic?.city.trim() ?? '';
    if (arabicCity.isNotEmpty) {
      _cityIdArController.text = arabicCity;
    }

    final englishArea = english == null ? '' : _areaFromPlaceResult(english);
    if (englishArea.isNotEmpty) {
      _areaController.text = englishArea;
    } else {
      final country = english?.country.trim() ?? '';
      if (country.isNotEmpty) _areaController.text = country;
    }

    final arabicArea = arabic == null ? '' : _areaFromPlaceResult(arabic);
    if (arabicArea.isNotEmpty) {
      _areaArController.text = arabicArea;
    } else {
      final country = arabic?.country.trim() ?? '';
      if (country.isNotEmpty) _areaArController.text = country;
    }
  }

  String _areaFromPlaceResult(OsmPlaceResult result) {
    for (final key in [
      'suburb',
      'neighbourhood',
      'quarter',
      'city_district',
      'district',
      'town',
      'village',
      'state',
      'region',
    ]) {
      final value = result.addressParts[key]?.trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  Widget _locationMapPicker() {
    final center =
        _selectedMapLocation ?? _parseCoordinates() ?? _omanMapCenter;

    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _locationSearchController,
            textInputAction: TextInputAction.search,
            decoration: adminInputDecoration('Search place in Oman').copyWith(
              suffixIcon: IconButton(
                onPressed: _isSearchingLocation ? null : _searchLocation,
                icon: _isSearchingLocation
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
              ),
            ),
            onFieldSubmitted: (_) {
              if (_isSearchingLocation) return;
              _searchLocation();
            },
          ),
          if (_locationSearchError != null) ...[
            SizedBox(height: 8.h),
            Text(
              _locationSearchError!,
              style: AppTextStyles.cardMeta.copyWith(color: Colors.redAccent),
            ),
          ],
          if (_locationSearchResults.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              constraints: BoxConstraints(maxHeight: 180.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE3E7EF)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _locationSearchResults.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: Color(0xFFE3E7EF)),
                itemBuilder: (context, index) {
                  final result = _locationSearchResults[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      result.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            ),
          ],
          SizedBox(height: 10.h),
          SizedBox(
            height: 360.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _locationMapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: _locationMapZoom,
                      onPositionChanged: (camera, _) {
                        _locationMapZoom = camera.zoom
                            .clamp(_minMapZoom, _maxMapZoom)
                            .toDouble();
                      },
                      onTap: (_, point) => _onMapPointPicked(point),
                    ),
                    children: [
                      const AdminOsmTileLayer(),
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
                  PositionedDirectional(
                    end: 10.w,
                    bottom: 10.h,
                    child: Material(
                      color: Colors.white,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(10.r),
                      child: IconButton(
                        tooltip: 'Open full screen map',
                        onPressed: _openFullscreenLocationMap,
                        icon: const Icon(Icons.fullscreen),
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE3E7EF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Zoom out',
                    onPressed: () => _zoomLocationMapBy(-1),
                    icon: const Icon(Icons.remove),
                  ),
                  Container(
                    width: 1,
                    height: 24.h,
                    color: const Color(0xFFE3E7EF),
                  ),
                  IconButton(
                    tooltip: 'Zoom in',
                    onPressed: () => _zoomLocationMapBy(1),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tap on the map to pick the attraction location',
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              if (_isResolvingAddress)
                SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ],
      ),
    );
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
                _numberField(_ratingController, 'Rating'),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminSectionCard(
            title: 'Contact & Location',
            child: Column(
              children: [
                _textField(_phoneController, 'Phone'),
                ..._localizedTextFields(
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
                          final parsed = _parseCoordinates();
                          setState(() {
                            _locationInputMode = _LocationInputMode.map;
                            _selectedMapLocation ??= parsed;
                          });
                          final point = _selectedMapLocation ?? parsed;
                          if (point != null) {
                            _moveLocationMapTo(point);
                          }
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
            title: 'Attractions',
            child: Column(
              children: [
                ..._localizedTextFields(
                  englishController: _catalogDescriptionController,
                  arabicController: _catalogDescriptionArController,
                  label: 'Description',
                  maxLines: 4,
                  englishRequired: false,
                ),
                ..._localizedTextFields(
                  englishController: _catalogHighlightsController,
                  arabicController: _catalogHighlightsArController,
                  label: 'Experience Highlights (one per line)',
                  maxLines: 4,
                  englishRequired: false,
                ),
                ..._localizedTextFields(
                  englishController: _catalogTermsController,
                  arabicController: _catalogTermsArController,
                  label: 'Terms & Conditions (one per line)',
                  maxLines: 4,
                  englishRequired: false,
                ),
                ..._localizedTextFields(
                  englishController: _catalogIncludedController,
                  arabicController: _catalogIncludedArController,
                  label: 'What\'s Included (one per line)',
                  maxLines: 4,
                  englishRequired: false,
                ),
                ..._localizedTextFields(
                  englishController: _catalogExcludedController,
                  arabicController: _catalogExcludedArController,
                  label: 'What\'s Excluded (one per line)',
                  maxLines: 4,
                  englishRequired: false,
                ),
                ..._localizedTextFields(
                  englishController: _catalogCancellationController,
                  arabicController: _catalogCancellationArController,
                  label: 'Cancellation Policy (one per line)',
                  maxLines: 4,
                  englishRequired: false,
                ),
                ..._localizedTextFields(
                  englishController: _catalogOptionsController,
                  arabicController: _catalogOptionsArController,
                  label: 'Available Options (one per line)',
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
          _moveLocationMapTo(parsed);
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

  List<String> _preferredListWithFallback({
    required List<String>? primaryEnglish,
    required List<String>? primaryLocalized,
    required List<String>? fallbackEnglish,
    required List<String>? fallbackLocalized,
  }) {
    final primary = _preferredList(primaryEnglish, primaryLocalized);
    if (primary.isNotEmpty) return primary;
    return _preferredList(fallbackEnglish, fallbackLocalized);
  }

  String _preferredText(String? english, String? fallback) {
    final normalizedEnglish = english?.trim() ?? '';
    if (normalizedEnglish.isNotEmpty) return normalizedEnglish;
    return fallback?.trim() ?? '';
  }

  String _preferredTextWithFallback({
    required String? primaryEnglish,
    required String? primaryLocalized,
    required String? fallbackEnglish,
    required String? fallbackLocalized,
  }) {
    final primary = _preferredText(primaryEnglish, primaryLocalized);
    if (primary.isNotEmpty) return primary;
    return _preferredText(fallbackEnglish, fallbackLocalized);
  }

  List<String> _cleanList(List<String>? values) {
    if (values == null) return const [];
    return values
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _preservedOrEmpty(
    List<String> preferred,
    List<String> fallback,
  ) {
    if (preferred.isNotEmpty) return preferred;
    return fallback;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      showAppSnackBar(
        context,
        'Please fill all required fields.',
        type: SnackBarType.error,
        fromTop: true,
      );
      return;
    }
    final now = DateTime.now();
    final nameEn = _nameController.text.trim();
    final cityIdEn = _cityIdController.text.trim();
    final areaEn = _areaController.text.trim();
    final aboutEn = _aboutController.text.trim();
    final addressEn = _addressController.text.trim();
    final geoLat = double.parse(_geoLatController.text.trim());
    final geoLng = double.parse(_geoLngController.text.trim());
    final existingAttraction = widget.attraction;
    final highlightsEn = _splitCsv(_highlightsController.text);
    final inclusionsEn = _splitCsv(_inclusionsController.text);
    final catalogDescriptionEn = _catalogDescriptionController.text.trim();
    final catalogHighlightsEn = _splitLines(_catalogHighlightsController.text);
    final catalogIncludedEn = _splitLines(_catalogIncludedController.text);
    final catalogExcludedEn = _splitLines(_catalogExcludedController.text);
    final catalogTermsEn = _splitLines(_catalogTermsController.text);
    final catalogTermsAr = _splitLines(_catalogTermsArController.text);
    final catalogCancellationEn = _splitLines(
      _catalogCancellationController.text,
    );
    final catalogCancellationAr = _splitLines(
      _catalogCancellationArController.text,
    );
    final catalogOptionsEn = _splitLines(_catalogOptionsController.text);
    final catalogOptionsAr = _splitLines(_catalogOptionsArController.text);
    final catalogLocationEn = _catalogLocationController.text.trim();
    final catalogLocationAr = _catalogLocationArController.text.trim();
    final packageOverviewEn = _preservedOrEmpty(
      _cleanList(existingAttraction?.packageOverviewEn),
      _cleanList(existingAttraction?.packageOverview),
    );
    final packageOverviewAr = _cleanList(existingAttraction?.packageOverviewAr);
    final bookingNotesEn = _preservedOrEmpty(
      _cleanList(existingAttraction?.bookingNotesEn),
      _cleanList(existingAttraction?.bookingNotes),
    );
    final bookingNotesAr = _cleanList(existingAttraction?.bookingNotesAr);

    final attraction = AttractionEntity(
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
      geoLat: geoLat,
      geoLng: geoLng,
      highlights: highlightsEn,
      inclusions: inclusionsEn,
      catalogDescription: catalogDescriptionEn,
      catalogHighlights: catalogHighlightsEn,
      catalogIncluded: catalogIncludedEn,
      catalogExcluded: catalogExcludedEn,
      catalogTermsAndConditions: catalogTermsEn,
      catalogCancellationPolicy: catalogCancellationEn,
      catalogAvailableOptions: catalogOptionsEn,
      catalogLocation: catalogLocationEn,
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
      catalogExcludedEn: catalogExcludedEn,
      catalogExcludedAr: _splitLines(_catalogExcludedArController.text),
      catalogTermsAndConditionsEn: catalogTermsEn,
      catalogTermsAndConditionsAr: catalogTermsAr,
      catalogCancellationPolicyEn: catalogCancellationEn,
      catalogCancellationPolicyAr: catalogCancellationAr,
      catalogAvailableOptionsEn: catalogOptionsEn,
      catalogAvailableOptionsAr: catalogOptionsAr,
      catalogLocationEn: catalogLocationEn,
      catalogLocationAr: catalogLocationAr,
      packageOverviewEn: packageOverviewEn,
      packageOverviewAr: packageOverviewAr,
      bookingNotesEn: bookingNotesEn,
      bookingNotesAr: bookingNotesAr,
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
        fromTop: true,
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
