import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/features/admin/presentation/widgets/admin_osm_tile_layer.dart';
import 'package:latlong2/latlong.dart';

class AdminLocationMapResult {
  const AdminLocationMapResult({required this.point, required this.zoom});

  final LatLng point;
  final double zoom;
}

Future<AdminLocationMapResult?> showAdminLocationFullscreenMap({
  required BuildContext context,
  required LatLng initialCenter,
  required LatLng selectedLocation,
  required double initialZoom,
  required double minZoom,
  required double maxZoom,
}) {
  return showDialog<AdminLocationMapResult>(
    context: context,
    useSafeArea: false,
    builder: (_) => _AdminLocationFullscreenMap(
      initialCenter: initialCenter,
      selectedLocation: selectedLocation,
      initialZoom: initialZoom,
      minZoom: minZoom,
      maxZoom: maxZoom,
    ),
  );
}

class _AdminLocationFullscreenMap extends StatefulWidget {
  const _AdminLocationFullscreenMap({
    required this.initialCenter,
    required this.selectedLocation,
    required this.initialZoom,
    required this.minZoom,
    required this.maxZoom,
  });

  final LatLng initialCenter;
  final LatLng selectedLocation;
  final double initialZoom;
  final double minZoom;
  final double maxZoom;

  @override
  State<_AdminLocationFullscreenMap> createState() =>
      _AdminLocationFullscreenMapState();
}

class _AdminLocationFullscreenMapState
    extends State<_AdminLocationFullscreenMap> {
  final MapController _mapController = MapController();
  late LatLng _selectedLocation = widget.selectedLocation;
  late double _zoom = widget.initialZoom;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    final nextZoom = (camera.zoom + delta)
        .clamp(widget.minZoom, widget.maxZoom)
        .toDouble();
    _zoom = nextZoom;
    _mapController.move(camera.center, nextZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: widget.initialZoom,
              onPositionChanged: (camera, _) {
                _zoom = camera.zoom
                    .clamp(widget.minZoom, widget.maxZoom)
                    .toDouble();
              },
              onTap: (_, point) {
                setState(() => _selectedLocation = point);
              },
            ),
            children: [
              const AdminOsmTileLayer(),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 52,
                    height: 52,
                    child: const Icon(
                      Icons.location_pin,
                      color: AppColors.primary,
                      size: 52,
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
            top: 18,
            start: 12,
            child: SafeArea(
              child: _MapFloatingButton(
                tooltip: 'Close',
                icon: Icons.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          PositionedDirectional(
            top: 18,
            end: 12,
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(
                  AdminLocationMapResult(point: _selectedLocation, zoom: _zoom),
                ),
                icon: const Icon(Icons.check),
                label: const Text('Use location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 12,
            bottom: 72,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MapFloatingButton(
                    tooltip: 'Zoom in',
                    icon: Icons.add,
                    onPressed: () => _zoomBy(1),
                  ),
                  const SizedBox(height: 8),
                  _MapFloatingButton(
                    tooltip: 'Zoom out',
                    icon: Icons.remove,
                    onPressed: () => _zoomBy(-1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFloatingButton extends StatelessWidget {
  const _MapFloatingButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
        color: AppColors.primary,
      ),
    );
  }
}
