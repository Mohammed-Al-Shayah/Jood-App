import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

class AdminOsmTileLayer extends StatelessWidget {
  const AdminOsmTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.jood.offers',
      tileProvider: NetworkTileProvider(silenceExceptions: true),
    );
  }
}
