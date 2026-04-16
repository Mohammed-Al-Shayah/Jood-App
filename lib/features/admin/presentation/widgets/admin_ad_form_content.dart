import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/domain/usecases/delete_storage_file_usecase.dart';
import 'package:jood/features/admin/domain/usecases/upload_ad_image_usecase.dart';
import 'package:jood/features/admin/presentation/widgets/admin_input_decoration.dart';
import 'package:jood/features/admin/presentation/widgets/admin_section_card.dart';
import 'package:jood/features/ads/data/models/ad_model.dart';
import 'package:jood/features/ads/domain/entities/ad_entity.dart';
import 'package:jood/features/attractions/domain/entities/attraction_entity.dart';
import 'package:jood/features/attractions/domain/usecases/get_all_attractions_usecase.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';
import 'package:jood/features/offers/domain/usecases/get_offers_usecase.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';
import 'package:jood/features/restaurants/domain/usecases/get_all_restaurants_usecase.dart';

class AdminAdFormContent extends StatefulWidget {
  const AdminAdFormContent({
    super.key,
    this.ad,
    required this.onSubmit,
    this.padding,
  });

  final AdEntity? ad;
  final Future<void> Function(AdEntity ad) onSubmit;
  final EdgeInsetsGeometry? padding;

  @override
  State<AdminAdFormContent> createState() => _AdminAdFormContentState();
}

class _AdminAdFormContentState extends State<AdminAdFormContent> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _displaySecondsController;

  List<RestaurantEntity> _restaurants = const [];
  List<AttractionEntity> _attractions = const [];
  List<OfferEntity> _offers = const [];

  String _category = 'buffet';
  String? _venueId;
  String? _offerId;
  bool _isActive = true;
  bool _isLoadingOptions = true;
  bool _isPickingImage = false;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;
  String? _loadError;
  String? _imageError;

  bool get _isEdit => widget.ad != null;

  @override
  void initState() {
    super.initState();
    final ad = widget.ad;
    _titleController = TextEditingController(text: ad?.title ?? '');
    _imageUrlController = TextEditingController(text: ad?.imageUrl ?? '')
      ..addListener(_handleImageChanged);
    _sortOrderController = TextEditingController(
      text: (ad?.sortOrder ?? 0).toString(),
    );
    _displaySecondsController = TextEditingController(
      text: (ad?.displaySeconds ?? 3).toString(),
    );
    _category = _normalizedCategory(ad?.targetCategory ?? 'buffet');
    _venueId = ad?.targetVenueId;
    _offerId = ad?.targetOfferId;
    _isActive = ad?.isActive ?? true;
    _loadOptions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController
      ..removeListener(_handleImageChanged)
      ..dispose();
    _sortOrderController.dispose();
    _displaySecondsController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() => _loadError = null);
    try {
      final results = await Future.wait([
        getIt<GetAllRestaurantsUseCase>()(),
        getIt<GetAllAttractionsUseCase>()(),
        getIt<GetOffersUseCase>()(),
      ]);
      if (!mounted) return;
      setState(() {
        _restaurants = results[0] as List<RestaurantEntity>;
        _attractions = results[1] as List<AttractionEntity>;
        _offers = results[2] as List<OfferEntity>;
        _isLoadingOptions = false;
      });
      _syncSelectionWithAvailableOptions();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingOptions = false;
        _loadError = 'Failed to load venues and offers.';
      });
    }
  }

  void _handleImageChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _syncSelectionWithAvailableOptions() {
    final availableVenues = _venueOptions;
    if (_venueId != null &&
        !availableVenues.any((venue) => venue.id == _venueId)) {
      _venueId = null;
    }
    final availableOffers = _offerOptions;
    if (_offerId != null &&
        !availableOffers.any((offer) => offer.id == _offerId)) {
      _offerId = null;
    }
    if (mounted) setState(() {});
  }

  List<_VenueOption> get _venueOptions {
    final matchingVenueIds = _offers
        .where((offer) => _normalizedOfferCategory(offer) == _category)
        .map((offer) => offer.restaurantId)
        .toSet();

    if (_category == 'attraction') {
      final venues = _attractions
          .where(
            (venue) =>
                matchingVenueIds.contains(venue.id) || venue.id == _venueId,
          )
          .map((venue) => _VenueOption(id: venue.id, name: venue.name))
          .toList(growable: false);
      venues.sort((left, right) => left.name.compareTo(right.name));
      return venues;
    }

    final venues = _restaurants
        .where(
          (venue) =>
              matchingVenueIds.contains(venue.id) || venue.id == _venueId,
        )
        .map((venue) => _VenueOption(id: venue.id, name: venue.name))
        .toList(growable: false);
    venues.sort((left, right) => left.name.compareTo(right.name));
    return venues;
  }

  List<OfferEntity> get _offerOptions {
    if (_venueId == null || _venueId!.trim().isEmpty) return const [];
    final todayKey = _todayKey();
    final currentAdOfferId = widget.ad?.targetOfferId ?? '';
    final offers = _offers.where((offer) {
      if (_normalizedOfferCategory(offer) != _category) return false;
      if (offer.restaurantId != _venueId) return false;
      if (offer.id == currentAdOfferId) return true;
      final status = offer.status.trim().toLowerCase();
      return status == 'active' && offer.date.compareTo(todayKey) >= 0;
    }).toList();
    offers.sort((left, right) {
      final byDate = left.date.compareTo(right.date);
      if (byDate != 0) return byDate;
      final byStart = left.startTime.compareTo(right.startTime);
      if (byStart != 0) return byStart;
      return _offerLabel(left).compareTo(_offerLabel(right));
    });
    return offers;
  }

  String _normalizedCategory(String value) {
    final raw = value.trim().toLowerCase().replaceAll(' ', '_');
    if (raw == 'setmenu') return 'set_menu';
    if (raw.isEmpty) return 'buffet';
    return raw;
  }

  String _normalizedOfferCategory(OfferEntity offer) {
    final raw = offer.bookingCategory.trim().toLowerCase().replaceAll(' ', '_');
    if (raw == 'setmenu') return 'set_menu';
    if (raw.isNotEmpty) return raw;
    if (offer.bookableType.trim().toLowerCase() == 'attraction') {
      return 'attraction';
    }
    return 'buffet';
  }

  String _categoryLabel(String value) {
    switch (value) {
      case 'buffet':
        return 'Buffet';
      case 'set_menu':
        return 'Set Menu';
      case 'combo':
        return 'Combo';
      case 'attraction':
        return 'Attraction';
      default:
        return value;
    }
  }

  String _offerLabel(OfferEntity offer) {
    final title = offer.packageName.trim().isNotEmpty
        ? offer.packageName
        : offer.title;
    final timeRange = offer.endTime.trim().isEmpty
        ? offer.startTime
        : '${offer.startTime} - ${offer.endTime}';
    return '$title | ${offer.date} | $timeRange';
  }

  OfferEntity? _selectedOffer() {
    if (_offerId == null) return null;
    for (final offer in _offerOptions) {
      if (offer.id == _offerId) return offer;
    }
    return null;
  }

  String _selectedVenueName() {
    final venueId = _venueId;
    if (venueId == null) return '';
    for (final venue in _venueOptions) {
      if (venue.id == venueId) return venue.name;
    }
    return '';
  }

  Future<void> _pickAndUploadImage() async {
    if (_isPickingImage || _isUploadingImage || _isSubmitting) return;
    setState(() => _imageError = null);
    final picker = ImagePicker();
    try {
      setState(() => _isPickingImage = true);
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      if (!mounted) return;
      setState(() => _isUploadingImage = true);
      final url = await getIt<UploadAdImageUseCase>()(
        adId: widget.ad?.id ?? '',
        file: picked,
      );
      _imageUrlController.text = url;
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Image uploaded successfully.',
        type: SnackBarType.success,
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      final message = error.code == 'already_active'
          ? 'Image picker is already open.'
          : 'Failed to upload image.';
      setState(() => _imageError = message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _imageError = 'Failed to upload image.');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _deleteImage() async {
    final url = _imageUrlController.text.trim();
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
      _imageUrlController.text = '';
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

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final selectedOffer = _selectedOffer();
    if (selectedOffer == null) {
      setState(() => _loadError = 'Select a target offer first.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _loadError = null;
    });

    final now = DateTime.now();
    final ad = AdModel(
      id: widget.ad?.id ?? '',
      title: _titleController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      isActive: _isActive,
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      displaySeconds: int.tryParse(_displaySecondsController.text.trim()) ?? 3,
      targetCategory: _category,
      targetVenueId: selectedOffer.restaurantId,
      targetVenueName: _selectedVenueName(),
      targetOfferId: selectedOffer.id,
      targetOfferTitle: _offerLabel(selectedOffer),
      targetOfferDate: selectedOffer.date,
      createdAt: widget.ad?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await widget.onSubmit(ad);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedOffer = _selectedOffer();

    return Form(
      key: _formKey,
      child: ListView(
        padding:
            widget.padding ??
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        children: [
          if (_isLoadingOptions)
            const LinearProgressIndicator(color: AppColors.primary),
          if (_loadError != null && _loadError!.trim().isNotEmpty) ...[
            Text(
              _loadError!,
              style: AppTextStyles.cardMeta.copyWith(color: Colors.red),
            ),
            SizedBox(height: 12.h),
          ],
          AdminSectionCard(
            title: 'Ad details',
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: adminInputDecoration('Ad title'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter the ad title.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _sortOrderController,
                  keyboardType: TextInputType.number,
                  decoration: adminInputDecoration('Sort order'),
                  validator: (value) {
                    if (int.tryParse((value ?? '').trim()) == null) {
                      return 'Enter a valid sort order.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _displaySecondsController,
                  keyboardType: TextInputType.number,
                  decoration: adminInputDecoration('Display seconds'),
                  validator: (value) {
                    final seconds = int.tryParse((value ?? '').trim());
                    if (seconds == null || seconds < 1 || seconds > 10) {
                      return 'Choose a value between 1 and 10 seconds.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                SwitchListTile.adaptive(
                  value: _isActive,
                  onChanged: _isSubmitting
                      ? null
                      : (value) => setState(() => _isActive = value),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Active'),
                  subtitle: const Text(
                    'Only active ads appear on the home slider.',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          AdminSectionCard(
            title: 'Target offer',
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey<String>('ad-category-$_category'),
                  initialValue: _category,
                  isExpanded: true,
                  decoration: adminInputDecoration('Category'),
                  items: const [
                    DropdownMenuItem(value: 'buffet', child: Text('Buffet')),
                    DropdownMenuItem(
                      value: 'set_menu',
                      child: Text('Set Menu'),
                    ),
                    DropdownMenuItem(value: 'combo', child: Text('Combo')),
                    DropdownMenuItem(
                      value: 'attraction',
                      child: Text('Attraction'),
                    ),
                  ],
                  selectedItemBuilder: (context) => const [
                    Text(
                      'Buffet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Set Menu',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('Combo', maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      'Attraction',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  onChanged: _isSubmitting || _isLoadingOptions
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _category = value;
                            _venueId = null;
                            _offerId = null;
                          });
                        },
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  key: ValueKey<String?>('ad-venue-${_category}_$_venueId'),
                  isExpanded: true,
                  initialValue:
                      _venueOptions.any((venue) => venue.id == _venueId)
                      ? _venueId
                      : null,
                  decoration: adminInputDecoration(
                    _category == 'attraction' ? 'Attraction' : 'Venue',
                  ),
                  items: _venueOptions
                      .map(
                        (venue) => DropdownMenuItem(
                          value: venue.id,
                          child: Text(venue.name),
                        ),
                      )
                      .toList(growable: false),
                  selectedItemBuilder: (context) => _venueOptions
                      .map(
                        (venue) => Text(
                          venue.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                      .toList(growable: false),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Select a venue first.';
                    }
                    return null;
                  },
                  onChanged: _isSubmitting || _isLoadingOptions
                      ? null
                      : (value) {
                          setState(() {
                            _venueId = value;
                            _offerId = null;
                          });
                        },
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  key: ValueKey<String?>('ad-offer-${_venueId}_$_offerId'),
                  isExpanded: true,
                  initialValue:
                      _offerOptions.any((offer) => offer.id == _offerId)
                      ? _offerId
                      : null,
                  decoration: adminInputDecoration('Offer'),
                  items: _offerOptions
                      .map(
                        (offer) => DropdownMenuItem(
                          value: offer.id,
                          child: Text(
                            _offerLabel(offer),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  selectedItemBuilder: (context) => _offerOptions
                      .map(
                        (offer) => Text(
                          _offerLabel(offer),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                      .toList(growable: false),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Select the offer this ad should open.';
                    }
                    return null;
                  },
                  onChanged: _isSubmitting || _isLoadingOptions
                      ? null
                      : (value) => setState(() => _offerId = value),
                ),
                if (selectedOffer != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      'Ad will open ${_categoryLabel(_category)} booking for ${_selectedVenueName()} on ${selectedOffer.date}.',
                      style: AppTextStyles.cardMeta,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          AdminSectionCard(
            title: 'Ad image',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _imageUrlController,
                  decoration: adminInputDecoration('Image URL'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Upload an image for the ad.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          _isPickingImage || _isUploadingImage || _isSubmitting
                          ? null
                          : _pickAndUploadImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: _isUploadingImage
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload_outlined),
                      label: const Text('Upload image'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isUploadingImage || _isSubmitting
                          ? null
                          : _deleteImage,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete image'),
                    ),
                  ],
                ),
                if (_imageError != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    _imageError!,
                    style: AppTextStyles.cardMeta.copyWith(color: Colors.red),
                  ),
                ],
                if (_imageUrlController.text.trim().isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.network(
                      _imageUrlController.text.trim(),
                      height: 180.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 140.h,
                        width: double.infinity,
                        color: const Color(0xFFF6F7FB),
                        alignment: Alignment.center,
                        child: Text(
                          'Invalid image URL',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting || _isLoadingOptions ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(_isEdit ? 'Update ad' : 'Create ad'),
            ),
          ),
        ],
      ),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}

class _VenueOption {
  const _VenueOption({required this.id, required this.name});

  final String id;
  final String name;
}
