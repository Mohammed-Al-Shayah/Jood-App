import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

class RestaurantMapScreen extends StatelessWidget {
  const RestaurantMapScreen({
    super.key,
    required this.restaurantName,
    required this.latitude,
    required this.longitude,
  });

  final String restaurantName;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurantName,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 16.sp),
        ),
      ),
      body: FlutterMap( 
        options: MapOptions(initialCenter: point, initialZoom: 15.5),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.jood.offers',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: point,
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
            attributions: [TextSourceAttribution('OpenStreetMap contributors')],
          ),
        ],
      ),
    );
  }
}
