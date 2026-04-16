import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/features/ads/domain/entities/ad_entity.dart';

class HomeAdsCarousel extends StatefulWidget {
  const HomeAdsCarousel({super.key, required this.ads, required this.onTap});

  final List<AdEntity> ads;
  final ValueChanged<AdEntity> onTap;

  @override
  State<HomeAdsCarousel> createState() => _HomeAdsCarouselState();
}

class _HomeAdsCarouselState extends State<HomeAdsCarousel> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant HomeAdsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ads != widget.ads) {
      _currentIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _autoPlayTimer?.cancel();
    if (widget.ads.length <= 1) return;
    final safeIndex = _currentIndex < 0
        ? 0
        : _currentIndex >= widget.ads.length
        ? widget.ads.length - 1
        : _currentIndex;
    final currentAd = widget.ads[safeIndex];
    _autoPlayTimer = Timer(
      Duration(seconds: currentAd.resolvedDisplaySeconds),
      _goToNextPage,
    );
  }

  void _goToNextPage() {
    if (!mounted || !_pageController.hasClients || widget.ads.length <= 1) {
      return;
    }
    final nextIndex = (_currentIndex + 1) % widget.ads.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 178.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.ads.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _restartTimer();
            },
            itemBuilder: (context, index) {
              final ad = widget.ads[index];
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 10.w),
                child: _AdCard(ad: ad, onTap: () => widget.onTap(ad)),
              );
            },
          ),
        ),
        if (widget.ads.length > 1) ...[
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.ads.length, (index) {
              final selected = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: selected ? 18.w : 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : const Color(0xFFD7DEE8),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _AdCard extends StatelessWidget {
  const _AdCard({required this.ad, required this.onTap});

  final AdEntity ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18.r,
                spreadRadius: -3,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: CachedNetworkImage(
                  imageUrl: ad.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: const Color(0xFFF3F6FA)),
                  errorWidget: (_, _, _) => Container(
                    color: const Color(0xFFF3F6FA),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textMuted,
                      size: 28.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
