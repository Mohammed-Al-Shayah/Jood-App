import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/admin/presentation/web/admin_web_navigation.dart';
import 'package:jood/features/admin/presentation/web/pages/admin_web_bookings_page.dart';
import 'package:jood/features/admin/presentation/web/pages/admin_web_ads_page.dart';
import 'package:jood/features/admin/presentation/web/pages/admin_web_offers_page.dart';
import 'package:jood/features/admin/presentation/web/pages/admin_web_overview_page.dart';
import 'package:jood/features/admin/presentation/web/pages/admin_web_payments_page.dart';
import 'package:jood/features/admin/presentation/web/pages/admin_web_refunds_page.dart';
import 'package:jood/features/admin/presentation/web/pages/admin_web_restaurants_page.dart';
import 'package:jood/features/admin/presentation/web/pages/admin_web_attractions_page.dart';
import 'package:jood/features/admin/presentation/web/pages/admin_web_users_page.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_sidebar.dart';
import 'package:jood/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:jood/features/users/domain/entities/user_entity.dart';

class AdminWebShellScreen extends StatefulWidget {
  const AdminWebShellScreen({super.key, required this.currentUser});

  final UserEntity currentUser;

  @override
  State<AdminWebShellScreen> createState() => _AdminWebShellScreenState();
}

class _AdminWebShellScreenState extends State<AdminWebShellScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AdminWebSection _selectedSection = AdminWebSection.overview;
  AdminWebSectionRequest? _bookingsRequest;
  AdminWebSectionRequest? _paymentsRequest;
  int _sectionViewSeed = 0;

  void _setSection(AdminWebSection section, {AdminWebSectionRequest? request}) {
    final sectionChanged = _selectedSection != section;
    final requestChanged = request != null;
    if (!sectionChanged && !requestChanged) return;
    setState(() {
      _selectedSection = section;
      switch (section) {
        case AdminWebSection.bookings:
          _bookingsRequest = request;
          break;
        case AdminWebSection.payments:
          _paymentsRequest = request;
          break;
        default:
          break;
      }
      _sectionViewSeed++;
    });
  }

  String _sectionKey(AdminWebSection section) {
    switch (section) {
      case AdminWebSection.bookings:
        return '${section.name}-${_bookingsRequest?.cacheKey ?? 'default'}-$_sectionViewSeed';
      case AdminWebSection.payments:
        return '${section.name}-${_paymentsRequest?.cacheKey ?? 'default'}-$_sectionViewSeed';
      default:
        return '${section.name}-$_sectionViewSeed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showSidebar = width >= 1100;
    final collapsedSidebar = width >= 1100 && width < 1360;
    final horizontalPadding = width >= 1440
        ? 28.0
        : width >= 1200
        ? 24.0
        : width >= 700
        ? 18.0
        : 14.0;
    final verticalPadding = width >= 700 ? 24.0 : 16.0;
    final drawerWidth = width < 420 ? width * 0.88 : 300.0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: showSidebar
          ? null
          : Drawer(
              width: drawerWidth,
              child: AdminWebSidebar(
                currentUser: widget.currentUser,
                selectedSection: _selectedSection,
                onSelectSection: (section) {
                  Navigator.of(context).pop();
                  _setSection(section);
                },
                onSignOut: () => getIt<SignOutUseCase>()(),
              ),
            ),
      body: Row(
        children: [
          if (showSidebar)
            AdminWebSidebar(
              currentUser: widget.currentUser,
              selectedSection: _selectedSection,
              onSelectSection: _setSection,
              onSignOut: () => getIt<SignOutUseCase>()(),
              collapsed: collapsedSidebar,
            ),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding,
                ),
                child: Column(
                  children: [
                    _AdminWebTopBar(
                      currentUser: widget.currentUser,
                      section: _selectedSection,
                      showMenuButton: !showSidebar,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    SizedBox(height: 24.h),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: KeyedSubtree(
                          key: ValueKey(_sectionKey(_selectedSection)),
                          child: _buildSectionPage(_selectedSection),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPage(AdminWebSection section) {
    switch (section) {
      case AdminWebSection.overview:
        return AdminWebOverviewPage(onSelectSection: _setSection);
      case AdminWebSection.restaurants:
        return const AdminWebRestaurantsPage();
      case AdminWebSection.buffet:
        return const AdminWebOffersPage(
          sectionMode: AdminWebOfferSectionMode.buffet,
        );
      case AdminWebSection.setMenu:
        return const AdminWebOffersPage(
          sectionMode: AdminWebOfferSectionMode.setMenu,
        );
      case AdminWebSection.combo:
        return const AdminWebOffersPage(
          sectionMode: AdminWebOfferSectionMode.combo,
        );
      case AdminWebSection.attractions:
        return const AdminWebAttractionsPage();
      case AdminWebSection.offers:
        return const AdminWebOffersPage();
      case AdminWebSection.ads:
        return const AdminWebAdsPage();
      case AdminWebSection.bookings:
        return AdminWebBookingsPage(initialRequest: _bookingsRequest);
      case AdminWebSection.payments:
        return AdminWebPaymentsPage(initialRequest: _paymentsRequest);
      case AdminWebSection.refunds:
        return const AdminWebRefundsPage();
      case AdminWebSection.users:
        return const AdminWebUsersPage();
    }
  }
}

class _AdminWebTopBar extends StatelessWidget {
  const _AdminWebTopBar({
    required this.currentUser,
    required this.section,
    required this.showMenuButton,
    required this.onMenuTap,
  });

  final UserEntity currentUser;
  final AdminWebSection section;
  final bool showMenuButton;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final titleFontSize = compact ? 22.0 : 28.0;

    final menuButton = showMenuButton
        ? IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          )
        : null;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.label,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          section.subtitle,
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.cardMeta.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
          ),
        ),
      ],
    );

    final userBadge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.14),
            child: Text(
              _initials(currentUser.fullName),
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.primary,
                fontSize: 13.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 180 : 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  currentUser.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (menuButton != null) ...[
                    menuButton,
                    SizedBox(width: 12.w),
                  ],
                  Expanded(child: titleBlock),
                ],
              ),
              SizedBox(height: 14.h),
              userBadge,
            ],
          );
        }

        return Row(
          children: [
            if (menuButton != null) ...[menuButton, SizedBox(width: 12.w)],
            Expanded(child: titleBlock),
            SizedBox(width: 16.w),
            userBadge,
          ],
        );
      },
    );
  }
}

String _initials(String text) {
  final parts = text
      .trim()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty || parts.first.isEmpty) return 'AD';
  if (parts.length == 1) {
    final word = parts.first;
    return word.length >= 2
        ? word.substring(0, 2).toUpperCase()
        : word.substring(0, 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
