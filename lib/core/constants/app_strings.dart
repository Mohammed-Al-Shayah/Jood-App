import '../localization/app_localization_controller.dart';

class AppStrings {
  const AppStrings._();

  static String _tr(
    String key, {
    Map<String, Object?> params = const <String, Object?>{},
    String? fallback,
  }) {
    return AppLocalizationController.instance.tr(
      key,
      params: params,
      fallback: fallback,
    );
  }

  static List<String> _trList(String key) {
    return AppLocalizationController.instance.trList(key);
  }

  static String get appTitle => _tr('app_title');
  static String get adminAppTitle => _tr('admin_app_title');
  static String get home => _tr('home');
  static String get orders => _tr('orders');
  static String get profile => _tr('profile');
  static String get currentLocation => _tr('current_location');
  static String get cityName => _tr('city_name');
  static String get searchHint => _tr('search_hint');
  static String get sectionTitle => _tr('section_title');
  static String get sectionCount => _tr('section_count');
  static String get viewDetails => _tr('view_details');
  static String get call => _tr('call');
  static String get map => _tr('map');
  static String get about => _tr('about');
  static String get aboutDescription => _tr('about_description');
  static String get todayAvailability => _tr('today_availability');
  static String get nextSlotLabel => _tr('next_slot_label');
  static String get nextSlotTime => _tr('next_slot_time');
  static String get remainingLabel => _tr('remaining_label');
  static String get remainingSpots => _tr('remaining_spots');
  static String get buffetOptions => _tr('buffet_options');
  static String get lunchBuffet => _tr('lunch_buffet');
  static String get lunchBuffetDescription => _tr('lunch_buffet_description');
  static String get lunchBuffetOldPrice => _tr('lunch_buffet_old_price');
  static String get lunchBuffetPrice => _tr('lunch_buffet_price');
  static String get dinnerBuffet => _tr('dinner_buffet');
  static String get dinnerBuffetDescription => _tr('dinner_buffet_description');
  static String get dinnerBuffetOldPrice => _tr('dinner_buffet_old_price');
  static String get dinnerBuffetPrice => _tr('dinner_buffet_price');
  static String get buffetDiscountBadge => _tr('buffet_discount_badge');
  static String get checkAvailability => _tr('check_availability');
  static String get detailsOpenToday => _tr('details_open_today');
  static String get noOffersTodayExploreOtherDates =>
      _tr('no_offers_today_explore_other_dates');
  static String get detailsOpenTime => _tr('details_open_time');
  static String get detailsReviewsCount => _tr('details_reviews_count');
  static String get detailsPhoneLabel => _tr('details_phone_label');
  static String get detailsPhoneNumber => _tr('details_phone_number');
  static String get detailsAddressLabel => _tr('details_address_label');
  static String get detailsAddressValue => _tr('details_address_value');
  static String get highlightsTitle => _tr('highlights_title');
  static String get inclusionsTitle => _tr('inclusions_title');
  static String get exclusionsTitle => _tr('exclusions_title');
  static String get cancellationTitle => _tr('cancellation_title');
  static String get knowBeforeTitle => _tr('know_before_title');
  static String get selectDateTitle => _tr('select_date_title');
  static String get availableOffersFor => _tr('available_offers_for');
  static String get buffetEntry => _tr('buffet_entry');
  static String get perAdult => _tr('per_adult');
  static String get ticketsAvailable => _tr('tickets_available');
  static String get onlyTicketsLeft => _tr('only_tickets_left');
  static String get soldOut => _tr('sold_out');
  static String get more => _tr('more');
  static String get selectGuestsTitle => _tr('select_guests_title');
  static String get selectQuantityTitle => _tr('select_quantity_title');
  static String get selectNumberOfTickets => _tr('select_number_of_tickets');
  static String get adults => _tr('adults');
  static String get children => _tr('children');
  static String get combo => _tr('combo');
  static String get combos => _tr('combos');
  static String get quantity => _tr('quantity');
  static String get perPerson => _tr('per_person');
  static String get perCombo => _tr('per_combo');
  static String get samePriceForAllGuests => _tr('same_price_for_all_guests');
  static String get samePriceForAllCombos => _tr('same_price_for_all_combos');
  static String get adultsAge => _tr('adults_age');
  static String get childrenAge => _tr('children_age');
  static String get bookingSummary => _tr('booking_summary');
  static String get subtotal => _tr('subtotal');
  static String get totalPayable => _tr('total_payable');
  static String get proceedToPayment => _tr('proceed_to_payment');
  static String get paymentTitle => _tr('payment_title');
  static String get paymentSubtitle => _tr('payment_subtitle');
  static String get totalAmount => _tr('total_amount');
  static String get cardholderName => _tr('cardholder_name');
  static String get cardNumber => _tr('card_number');
  static String get expiryDate => _tr('expiry_date');
  static String get cvv => _tr('cvv');
  static String get securePaymentTitle => _tr('secure_payment_title');
  static String get securePaymentDescription =>
      _tr('secure_payment_description');
  static String get offerEnded => _tr('offer_ended');
  static String get confirmAndPay => _tr('confirm_and_pay');
  static String get bookingConfirmedTitle => _tr('booking_confirmed_title');
  static String get bookingConfirmedSubtitle =>
      _tr('booking_confirmed_subtitle');
  static String get bookingCodeLabel => _tr('booking_code_label');
  static String get bookingDetailsTitle => _tr('booking_details_title');
  static String get totalPaid => _tr('total_paid');
  static String get callRestaurant => _tr('call_restaurant');
  static String get openMap => _tr('open_map');
  static String get description => _tr('description');
  static String get continueToBooking => _tr('continue_to_booking');
  static String get whatsIncluded => _tr('whats_included');
  static String get packagesOverview => _tr('packages_overview');
  static String get availableOptions => _tr('available_options');
  static String get availableCombos => _tr('available_combos');
  static String get bookingNotes => _tr('booking_notes');
  static String get setMenuConcept => _tr('set_menu_concept');
  static String get comboConcept => _tr('combo_concept');
  static String get experienceHighlights => _tr('experience_highlights');
  static String get bookingFlowSetMenuSelectionNote =>
      _tr('booking_flow_set_menu_selection_note');
  static String get bookingFlowComboSelectionNote =>
      _tr('booking_flow_combo_selection_note');
  static String get highlightsWillAppearHereOnceConfigured =>
      _tr('highlights_will_appear_here_once_configured');
  static String get includedDetailsWillAppearHere =>
      _tr('included_details_will_appear_here');
  static String get packagesWillBeLoadedFromAttractionConfiguration =>
      _tr('packages_will_be_loaded_from_attraction_configuration');
  static String get optionsWillAppearAutomaticallyWhenConfigured =>
      _tr('options_will_appear_automatically_when_configured');
  static String get buffetFallbackDescription =>
      _tr('buffet_fallback_description');
  static String get setMenuFallbackDescription =>
      _tr('set_menu_fallback_description');
  static String get comboFallbackDescription =>
      _tr('combo_fallback_description');
  static String get attractionFallbackDescription =>
      _tr('attraction_fallback_description');
  static String get important => _tr('important');
  static String get importantItem1 => _tr('important_item_1');
  static String get importantItem2 => _tr('important_item_2');
  static String get importantItem3 => _tr('important_item_3');
  static String get backToHome => _tr('back_to_home');
  static String get somethingWentWrong => _tr('something_went_wrong');
  static String get tooManyAttempts => _tr('too_many_attempts');
  static String get homeHeroTitle => _tr('home_hero_title');
  static String get bookByCategory => _tr('book_by_category');
  static String get bookByCategorySubtitle => _tr('book_by_category_subtitle');
  static String get hotDeals => _tr('hot_deals');
  static String get hotDealsSubtitle => _tr('hot_deals_subtitle');
  static String get nearToMe => _tr('near_to_me');
  static String get discoverForYou => _tr('discover_for_you');
  static String get failedToLoadDiscoveryItems =>
      _tr('failed_to_load_discovery_items');
  static String get noItemsMatchSearch => _tr('no_items_match_search');
  static String get noItemsAvailableRightNow =>
      _tr('no_items_available_right_now');
  static String get top => _tr('top');
  static String get sortAndFilter => _tr('sort_and_filter');
  static String get done => _tr('done');
  static String get reset => _tr('reset');
  static String get explore => _tr('explore');
  static String get filterByTypeThenPickSort =>
      _tr('filter_by_type_then_pick_sort');
  static String get type => _tr('type');
  static String get all => _tr('all');
  static String get price => _tr('price');
  static String get priceSortSubtitle => _tr('price_sort_subtitle');
  static String get discount => _tr('discount');
  static String get discountSortSubtitle => _tr('discount_sort_subtitle');
  static String get rating => _tr('rating');
  static String get ratingSortSubtitle => _tr('rating_sort_subtitle');
  static String get lowToHigh => _tr('low_to_high');
  static String get highToLow => _tr('high_to_low');
  static String get from => _tr('from');
  static String get breakfast => _tr('breakfast');
  static String get lunch => _tr('lunch');
  static String get dinner => _tr('dinner');
  static String get breakfastSetMenu => _tr('breakfast_set_menu');
  static String get lunchSetMenu => _tr('lunch_set_menu');
  static String get packageA => _tr('package_a');
  static String get packageB => _tr('package_b');
  static String get login => _tr('login');
  static String get phoneNumber => _tr('phone_number');
  static String get emailAddress => _tr('email_address');
  static String get enterPhoneNumber => _tr('enter_phone_number');
  static String get enterEmail => _tr('enter_email');
  static String get password => _tr('password');
  static String get enterPassword => _tr('enter_password');
  static String get rememberMe => _tr('remember_me');
  static String get forgotPassword => _tr('forgot_password');
  static String get or => _tr('or');
  static String get loginViaEmail => _tr('login_via_email');
  static String get loginViaPhone => _tr('login_via_phone');
  static String get signUp => _tr('sign_up');
  static String get createNewAccount => _tr('create_new_account');
  static String get continueAsGuest => _tr('continue_as_guest');
  static String get enterFullName => _tr('enter_full_name');
  static String get createPassword => _tr('create_password');
  static String get phoneNumberForOtp => _tr('phone_number_for_otp');
  static String get agreeToTermsAndPrivacyPolicy =>
      _tr('agree_to_terms_and_privacy_policy');
  static String get sendOtp => _tr('send_otp');
  static String get verifyYourEmail => _tr('verify_your_email');
  static String get resendActivationLink => _tr('resend_activation_link');
  static String get loginWithPhone => _tr('login_with_phone');
  static String get forgetPassword => _tr('forget_password');
  static String get resetEmailSentCheckInbox =>
      _tr('reset_email_sent_check_inbox');
  static String get enterEmailForReset => _tr('enter_email_for_reset');
  static String get enterPhoneForOtpReset => _tr('enter_phone_for_otp_reset');
  static String get verify => _tr('verify');
  static String get sendResetLink => _tr('send_reset_link');
  static String get useEmailInstead => _tr('use_email_instead');
  static String get usePhoneInstead => _tr('use_phone_instead');
  static String get changePassword => _tr('change_password');
  static String get passwordChangedSuccessfully =>
      _tr('password_changed_successfully');
  static String get enterNewPasswordForAccount =>
      _tr('enter_new_password_for_account');
  static String get newPassword => _tr('new_password');
  static String get enterNewPassword => _tr('enter_new_password');
  static String get confirmPassword => _tr('confirm_password');
  static String get confirmPasswordHint => _tr('confirm_password_hint');
  static String get verifyOtp => _tr('verify_otp');
  static String get resend => _tr('resend');
  static String get fullNameIsRequired => _tr('full_name_is_required');
  static String get emailIsRequired => _tr('email_is_required');
  static String get enterValidEmailExample => _tr('enter_valid_email_example');
  static String get passwordIsRequired => _tr('password_is_required');
  static String get passwordMustBeAtLeast6Characters =>
      _tr('password_must_be_at_least_6_characters');
  static String get pleaseConfirmYourPassword =>
      _tr('please_confirm_your_password');
  static String get passwordsDoNotMatch => _tr('passwords_do_not_match');
  static String get phoneNumberIsRequired => _tr('phone_number_is_required');
  static String get enterValidPhoneNumber => _tr('enter_valid_phone_number');
  static String get countryIsRequired => _tr('country_is_required');
  static String get cityIsRequired => _tr('city_is_required');
  static String get pleaseAcceptTheTerms => _tr('please_accept_the_terms');
  static String get emailAlreadyRegisteredLong =>
      _tr('email_already_registered_long');
  static String get thisPhoneNumberIsAlreadyRegistered =>
      _tr('this_phone_number_is_already_registered');
  static String get phoneAuthNotEnabled => _tr('phone_auth_not_enabled');
  static String get signUpFailedPleaseTryAgain =>
      _tr('sign_up_failed_please_try_again');
  static String get enterPasswordThenResendActivationLink =>
      _tr('enter_password_then_resend_activation_link');
  static String get activationLinkResentCheckInbox =>
      _tr('activation_link_resent_check_inbox');
  static String get noUserFoundForEmail => _tr('no_user_found_for_email');
  static String get noUserFoundForPhone => _tr('no_user_found_for_phone');
  static String get emailPasswordAccountsNotEnabled =>
      _tr('email_password_accounts_not_enabled');
  static String get loginFailedPleaseTryAgain =>
      _tr('login_failed_please_try_again');
  static String get unableToSignInPleaseTryAgain =>
      _tr('unable_to_sign_in_please_try_again');
  static String get pleaseVerifyYourEmailFirst =>
      _tr('please_verify_your_email_first');
  static String get phoneAuthenticationNotEnabledForProject =>
      _tr('phone_authentication_not_enabled_for_project');
  static String get requestFailedPleaseTryAgain =>
      _tr('request_failed_please_try_again');
  static String get sessionExpiredVerifyPhoneAgain =>
      _tr('session_expired_verify_phone_again');
  static String get unableToChangePasswordPleaseTryAgain =>
      _tr('unable_to_change_password_please_try_again');
  static String get unableToVerifyPhonePleaseTryAgain =>
      _tr('unable_to_verify_phone_please_try_again');
  static String get unableToStartPhoneVerification =>
      _tr('unable_to_start_phone_verification');
  static String get emailAlreadyRegisteredUseDifferentOrLogin =>
      _tr('email_already_registered_use_different_or_login');
  static String get invalidPhoneNumber => _tr('invalid_phone_number');
  static String get invalidEmailAddress => _tr('invalid_email_address');
  static String get thisAccountHasBeenDisabled =>
      _tr('this_account_has_been_disabled');
  static String get noUserFound => _tr('no_user_found');
  static String get incorrectPassword => _tr('incorrect_password');
  static String get invalidCredentials => _tr('invalid_credentials');
  static String get passwordIsTooWeak => _tr('password_is_too_weak');
  static String get emailAlreadyInUse => _tr('email_already_in_use');
  static String get invalidOtpCode => _tr('invalid_otp_code');
  static String get otpSessionExpiredResendCode =>
      _tr('otp_session_expired_resend_code');
  static String get smsQuotaExceeded => _tr('sms_quota_exceeded');
  static String get operationNotAllowedForProject =>
      _tr('operation_not_allowed_for_project');
  static String get pleaseLoginFirst => _tr('please_login_first');
  static String get failedToLoadOrders => _tr('failed_to_load_orders');
  static String get failedToLoadOffers => _tr('failed_to_load_offers');
  static String get failedToLoadCategoryItems =>
      _tr('failed_to_load_category_items');
  static String get failedToLoadBookingOptions =>
      _tr('failed_to_load_booking_options');
  static String get booking => _tr('booking');
  static String get yourBookingsAndQrPassesWillAppearHere =>
      _tr('your_bookings_and_qr_passes_will_appear_here');
  static String get noOrdersYet => _tr('no_orders_yet');
  static String get ordersEmptySubtitle => _tr('orders_empty_subtitle');
  static String get buffet => _tr('buffet');
  static String get setMenu => _tr('set_menu');
  static String get comboCategory => _tr('combo');
  static String get attractions => _tr('attractions');
  static String get exploreExperiences => _tr('explore_experiences');
  static String get unknown => _tr('unknown');
  static String get code => _tr('code');
  static String get total => _tr('total');
  static String get viewQr => _tr('view_qr');
  static String get status => _tr('status');
  static String get vat => _tr('vat');
  static String get cancelBooking => _tr('cancel_booking');
  static String get cancellationWindowEnded => _tr('cancellation_window_ended');
  static String get bookingCancelledSuccessfully =>
      _tr('booking_cancelled_successfully');
  static String get failedToCancelBooking => _tr('failed_to_cancel_booking');
  static String get bookingQr => _tr('booking_qr');
  static String get scanOrderQr => _tr('scan_order_qr');
  static String get verifyingOrder => _tr('verifying_order');
  static String get completingOrder => _tr('completing_order');
  static String get orderDetails => _tr('order_details');
  static String get restaurant => _tr('restaurant');
  static String get date => _tr('date');
  static String get time => _tr('time');
  static String get guests => _tr('guests');
  static String get couponOffer => _tr('coupon_offer');
  static String get confirmAndComplete => _tr('confirm_and_complete');
  static String get invalidQrCode => _tr('invalid_qr_code');
  static String get noSignedInUser => _tr('no_signed_in_user');
  static String get staffAccountNotFound => _tr('staff_account_not_found');
  static String get orderNotFound => _tr('order_not_found');
  static String get staffAccountMissingRestaurantId =>
      _tr('staff_account_missing_restaurant_id');
  static String get orderCompletedSuccessfully =>
      _tr('order_completed_successfully');
  static String get failedToGenerateQrImage =>
      _tr('failed_to_generate_qr_image');
  static String get qrSavedToGallery => _tr('qr_saved_to_gallery');
  static String get couldNotSaveQrToGallery =>
      _tr('could_not_save_qr_to_gallery');
  static String get download => _tr('download');
  static String get share => _tr('share');
  static String get profileTitle => _tr('profile_title');
  static String get manageAccountDetailsAccessAndStaffTools =>
      _tr('manage_account_details_access_and_staff_tools');
  static String get failedToLoadProfile => _tr('failed_to_load_profile');
  static String get pleaseLogInToViewYourProfile =>
      _tr('please_log_in_to_view_your_profile');
  static String get noProfileData => _tr('no_profile_data');
  static String get adminDashboard => _tr('admin_dashboard');
  static String get manageOffersUsersAndActivity =>
      _tr('manage_offers_users_and_activity');
  static String get verifyCustomerBookingsOnTheSpot =>
      _tr('verify_customer_bookings_on_the_spot');
  static String get quickActions => _tr('quick_actions');
  static String get shortcutsAvailableForYourAccountRole =>
      _tr('shortcuts_available_for_your_account_role');
  static String get personalInfo => _tr('personal_info');
  static String get yourSavedDetailsAcrossTheAccount =>
      _tr('your_saved_details_across_the_account');
  static String get phone => _tr('phone');
  static String get email => _tr('email');
  static String get country => _tr('country');
  static String get city => _tr('city');
  static String get fullName => _tr('full_name');
  static String get account => _tr('account');
  static String get sessionAndAccessSettings =>
      _tr('session_and_access_settings');
  static String get logOut => _tr('log_out');
  static String get signOutFromThisDeviceAndReturnToLogin =>
      _tr('sign_out_from_this_device_and_return_to_login');
  static String get language => _tr('language');
  static String get tapToSwitchBetweenArabicAndEnglish =>
      _tr('tap_to_switch_between_arabic_and_english');
  static String get currentLanguageEnglish => _tr('current_language_english');
  static String get currentLanguageArabic => _tr('current_language_arabic');
  static String get edit => _tr('edit');
  static String get editProfile => _tr('edit_profile');
  static String get open => _tr('open');
  static String get save => _tr('save');
  static String get verifyPhone => _tr('verify_phone');
  static String get enterOtpSentToYourPhone =>
      _tr('enter_otp_sent_to_your_phone');
  static String get selectCountry => _tr('select_country');
  static String get searchCountry => _tr('search_country');
  static String get noSignedInUserFound => _tr('no_signed_in_user_found');
  static String get phoneNumberAlreadyInUse =>
      _tr('phone_number_already_in_use');
  static String get verificationLinkSentToYourNewEmail =>
      _tr('verification_link_sent_to_your_new_email');
  static String get emailPasswordSignInDisabled =>
      _tr('email_password_sign_in_disabled');
  static String get signInAgainAndRetry => _tr('sign_in_again_and_retry');
  static String get updateFailedPleaseTryAgain =>
      _tr('update_failed_please_try_again');
  static String get phoneVerificationFailedPleaseTryAgain =>
      _tr('phone_verification_failed_please_try_again');
  static String get dangerZone => _tr('danger_zone');
  static String get permanentActionsThatRemoveYourAccount =>
      _tr('permanent_actions_that_remove_your_account');
  static String get deleteAccount => _tr('delete_account');
  static String get deleteAccountDescription =>
      _tr('delete_account_description');
  static String get deleteAccountQuestion => _tr('delete_account_question');
  static String get deleteAccountWarning => _tr('delete_account_warning');
  static String get continueLabel => _tr('continue_label');
  static String get finalConfirmation => _tr('final_confirmation');
  static String get areYouAbsolutelySure => _tr('are_you_absolutely_sure');
  static String get deletingYourAccount => _tr('deleting_your_account');
  static String get reauthenticationRequired =>
      _tr('reauthentication_required');
  static String get goToLogin => _tr('go_to_login');
  static String get cancel => _tr('cancel');
  static String get notAddedYet => _tr('not_added_yet');
  static String get administrator => _tr('administrator');
  static String get restaurantStaff => _tr('restaurant_staff');
  static String get staff => _tr('staff');
  static String get member => _tr('member');
  static String get previous => _tr('previous');
  static String get next => _tr('next');
  static String get selectDate => _tr('select_date');
  static String get processing => _tr('processing');
  static String get paymentCancelled => _tr('payment_cancelled');
  static String get unableToStartPayment => _tr('unable_to_start_payment');
  static String get paymentCompletedSuccessfully =>
      _tr('payment_completed_successfully');
  static String get paymentCompletedButBookingSaveFailed =>
      _tr('payment_completed_but_booking_save_failed');
  static String get selectOptionToContinue => _tr('select_option_to_continue');
  static String get noSetMenuOptionsForDate =>
      _tr('no_set_menu_options_for_date');
  static String get noCombosAvailableForDate =>
      _tr('no_combos_available_for_date');
  static String get noMealsAvailableForDate =>
      _tr('no_meals_available_for_date');
  static String get chooseSetMenu => _tr('choose_set_menu');
  static String get chooseCombo => _tr('choose_combo');
  static String get chooseMealType => _tr('choose_meal_type');
  static String get setMenuOptionPricingSubtitle =>
      _tr('set_menu_option_pricing_subtitle');
  static String get comboOptionPricingSubtitle =>
      _tr('combo_option_pricing_subtitle');
  static String get mealTypeBookingSubtitle =>
      _tr('meal_type_booking_subtitle');
  static String get noTimeSlotsAvailableForDate =>
      _tr('no_time_slots_available_for_date');
  static String get selectTime => _tr('select_time');
  static String get selectTimeSubtitle => _tr('select_time_subtitle');
  static String get selectPackage => _tr('select_package');
  static String get selectPackageSubtitle => _tr('select_package_subtitle');
  static String get noOptionsAvailableRightNow =>
      _tr('no_options_available_right_now');
  static String get showDetails => _tr('show_details');
  static String get hideDetails => _tr('hide_details');
  static String get allPackagesCurrentlyUnavailable =>
      _tr('all_packages_currently_unavailable');
  static String get unavailable => _tr('unavailable');
  static String get meal => _tr('meal');
  static String get packageDefault => _tr('package_default');
  static String get ended => _tr('ended');
  static String get bookBuffet => _tr('book_buffet');
  static String get bookSetMenu => _tr('book_set_menu');
  static String get bookCombo => _tr('book_combo');
  static String get bookAttraction => _tr('book_attraction');
  static String get selectedOption => _tr('selected_option');
  static String get selectOptionFirst => _tr('select_option_first');
  static String get pleaseChooseAvailableOptionFirst =>
      _tr('please_choose_available_option_first');
  static String get pleaseAddAtLeastOneGuest =>
      _tr('please_add_at_least_one_guest');
  static String get pleaseAddAtLeastOneCombo =>
      _tr('please_add_at_least_one_combo');
  static String get selectedOptionNoLongerAvailable =>
      _tr('selected_option_no_longer_available');
  static String get selectedGuestsNoLongerAvailable =>
      _tr('selected_guests_no_longer_available');
  static String get pricingWasUpdated => _tr('pricing_was_updated');
  static String get goBackAndChooseAvailableOptionFirst =>
      _tr('go_back_and_choose_available_option_first');
  static String get beforeDiscount => _tr('before_discount');
  static String get setMenuItemSelectionAfterBooking =>
      _tr('set_menu_item_selection_after_booking');
  static String get comboSelectionAfterBooking =>
      _tr('combo_selection_after_booking');
  static String get missingRestaurantId => _tr('missing_restaurant_id');
  static String get noOffersAvailableForDate =>
      _tr('no_offers_available_for_date');
  static String get selectedTicketsNoLongerAvailableAdjustQuantities =>
      _tr('selected_tickets_no_longer_available_adjust_quantities');
  static String get pleaseSelectOfferFirst => _tr('please_select_offer_first');
  static String get selectedOptionNoLongerAvailableReviewBooking =>
      _tr('selected_option_no_longer_available_review_booking');
  static String get pricingWasUpdatedReviewTotal =>
      _tr('pricing_was_updated_review_total');
  static String get thawaniNotConfiguredAddKeys =>
      _tr('thawani_not_configured_add_keys');
  static String get restaurantBooking => _tr('restaurant_booking');
  static String get paymentFailedCheckThawaniKeys =>
      _tr('payment_failed_check_thawani_keys');
  static String get onlyRestaurantStaffCanRedeemOrders =>
      _tr('only_restaurant_staff_can_redeem_orders');
  static String get orderBelongsToAnotherRestaurant =>
      _tr('order_belongs_to_another_restaurant');
  static String get orderAlreadyCompleted => _tr('order_already_completed');
  static String get orderIsNotPaid => _tr('order_is_not_paid');
  static String get offerIsNotActive => _tr('offer_is_not_active');
  static String get soldOutNotEnoughTickets =>
      _tr('sold_out_not_enough_tickets');
  static String get bookingNotFound => _tr('booking_not_found');
  static String get bookingAlreadyCancelled => _tr('booking_already_cancelled');
  static String get completedBookingCannotBeCancelled =>
      _tr('completed_booking_cannot_be_cancelled');
  static String get notAuthorized => _tr('not_authorized');
  static String get bookingStatusPaid => _tr('booking_status_paid');
  static String get bookingStatusConfirmed => _tr('booking_status_confirmed');
  static String get bookingStatusCompleted => _tr('booking_status_completed');
  static String get bookingStatusCancelled => _tr('booking_status_cancelled');
  static String get bookingStatusPending => _tr('booking_status_pending');
  static String get bookingStatusFailed => _tr('booking_status_failed');
  static String get topRated => _tr('top_rated');
  static String get popular => _tr('popular');
  static String get createStory => _tr('create_story');
  static String get storyStep1Description => _tr('story_step_1_description');
  static String get storyStep2Description => _tr('story_step_2_description');
  static String get storyStep3Description => _tr('story_step_3_description');
  static String get authPlaceholder => _tr('auth_placeholder');

  static List<String> get highlightsItems => _trList('highlights_items');
  static List<String> get inclusionsItems => _trList('inclusions_items');
  static List<String> get exclusionsItems => _trList('exclusions_items');
  static List<String> get cancellationItems => _trList('cancellation_items');
  static List<String> get knowBeforeItems => _trList('know_before_items');

  static String itemsFound(int count) {
    return _tr('items_found', params: {'count': count});
  }

  static String bookingsCount(int count) {
    return _tr('bookings_count', params: {'count': count});
  }

  static String reviewsCount(int count) {
    return _tr('reviews_count', params: {'count': count});
  }

  static String stepNumber(int number) {
    return _tr('step_number', params: {'number': number});
  }

  static String bookingConfirmedAt(String restaurantName) {
    return _tr(
      'booking_confirmed_at',
      params: {'restaurantName': restaurantName},
    );
  }

  static String otpRegisterMessage(String phone) {
    return _tr('otp_register_message', params: {'phone': phone});
  }

  static String otpLoginMessage(String phone) {
    return _tr('otp_login_message', params: {'phone': phone});
  }

  static String otpResetMessage(String phone) {
    return _tr('otp_reset_message', params: {'phone': phone});
  }

  static String homeHeroSubtitle(String location) {
    return _tr('home_hero_subtitle', params: {'location': location});
  }

  static String nearToMeSubtitle(String location) {
    return _tr('near_to_me_subtitle', params: {'location': location});
  }

  static String guestsSummary(int adultsCount, int childrenCount) {
    return _tr(
      'guests_summary',
      params: {'adults': adultsCount, 'children': childrenCount},
    );
  }

  static String bookingCodeValue(String code) {
    return _tr('booking_code_value', params: {'code': code});
  }

  static String totalValue(String value) {
    return _tr('total_value', params: {'value': value});
  }

  static String statusValue(String value) {
    return _tr('status_value', params: {'value': value});
  }

  static String bookingCodeShareText(String code) {
    return _tr('booking_code_share_text', params: {'code': code});
  }

  static String percentOff(int percent) {
    return _tr('percent_off', params: {'percent': percent});
  }

  static String failedToSaveQr(Object error) {
    return _tr('failed_to_save_qr', params: {'error': error});
  }

  static String failedToShareQr(Object error) {
    return _tr('failed_to_share_qr', params: {'error': error});
  }

  static String failedToSaveQrToGallery(Object error) {
    return _tr('failed_to_save_qr_to_gallery', params: {'error': error});
  }

  static String currentLanguageLabel(String language) {
    return _tr('current_language_label', params: {'language': language});
  }

  static String childPrice(String value) {
    return _tr('child_price', params: {'value': value});
  }

  static String afterDiscount(String value) {
    return _tr('after_discount', params: {'value': value});
  }

  static String fromPrice(String value) {
    return _tr('from_price', params: {'value': value});
  }

  static String startFromPrice(String value) {
    return _tr('start_from_price', params: {'value': value});
  }

  static String packagesCount(int count) {
    return _tr('packages_count', params: {'count': count});
  }

  static String availableCount(int count) {
    return _tr('available_count', params: {'count': count});
  }

  static String availableStatus(int count) {
    return _tr('available_status', params: {'count': count});
  }

  static String onlyLeftCount(int count) {
    return _tr('only_left_count', params: {'count': count});
  }

  static String proceedToPaymentAmount(String value) {
    return _tr('proceed_to_payment_amount', params: {'value': value});
  }

  static String adultsCountLabel(int count) {
    return _tr('adults_count_label', params: {'count': count});
  }

  static String childrenCountLabel(int count) {
    return _tr('children_count_label', params: {'count': count});
  }

  static String guestsCountLabel(int count) {
    return _tr('guests_count_label', params: {'count': count});
  }

  static String combosCountLabel(int count) {
    return _tr('combos_count_label', params: {'count': count});
  }

  static String quantityCountLabel(int count) {
    return _tr('quantity_count_label', params: {'count': count});
  }

  static String vatWithRate(String rate) {
    return _tr('vat_with_rate', params: {'rate': rate});
  }

  static String spotsAvailableForSelection(int count) {
    return _tr('spots_available_for_selection', params: {'count': count});
  }

  static String combosAvailableForSelection(int count) {
    return _tr('combos_available_for_selection', params: {'count': count});
  }

  static String slotsLeftCount(int count) {
    return _tr('slots_left_count', params: {'count': count});
  }

  static String paymentFailedWithMessage(String message) {
    return _tr('payment_failed_with_message', params: {'message': message});
  }

  static String paymentFailedWithCodeAndMessage(String code, String message) {
    return _tr(
      'payment_failed_with_code_and_message',
      params: {'code': code, 'message': message},
    );
  }

  static String paymentFailedCheckThawaniKeysWithCode(String code) {
    return _tr(
      'payment_failed_check_thawani_keys_with_code',
      params: {'code': code},
    );
  }

  static String bookingStatusLabel(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'paid':
        return bookingStatusPaid;
      case 'confirmed':
        return bookingStatusConfirmed;
      case 'completed':
        return bookingStatusCompleted;
      case 'cancelled':
      case 'canceled':
        return bookingStatusCancelled;
      case 'pending':
        return bookingStatusPending;
      case 'failed':
        return bookingStatusFailed;
      default:
        if (value.trim().isEmpty) return unknown;
        final words = value
            .trim()
            .replaceAll('_', ' ')
            .replaceAll('-', ' ')
            .split(' ')
            .where((word) => word.isNotEmpty)
            .map(
              (word) =>
                  '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
            )
            .toList();
        return words.isEmpty ? value : words.join(' ');
    }
  }
}
