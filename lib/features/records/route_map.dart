import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/tokens.dart';
import '../../data/models.dart';

/// A map with a route drawn on it. Map pictures come from OpenStreetMap, so
/// they need an internet connection.
class RouteMap extends StatefulWidget {
  const RouteMap({
    super.key,
    required this.route,
    this.follow = false,
    this.height = 220,
  });

  final List<GeoPoint> route;

  /// Keep the latest point in view (used while recording).
  final bool follow;
  final double height;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final MapController _controller = MapController();
  bool _ready = false;

  List<LatLng> get _points =>
      [for (final p in widget.route) LatLng(p.lat, p.lon)];

  @override
  void didUpdateWidget(RouteMap old) {
    super.didUpdateWidget(old);
    if (widget.follow && _ready && widget.route.isNotEmpty) {
      final last = _points.last;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.move(last, 16.5);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pts = _points;
    final spread = pts.length >= 2 &&
        pts.any((p) => p.latitude != pts.first.latitude ||
            p.longitude != pts.first.longitude);
    final options = MapOptions(
      initialCenter: pts.isEmpty ? const LatLng(36.19, 44.01) : pts.last,
      initialZoom: pts.isEmpty ? 3 : 16,
      initialCameraFit: (spread && !widget.follow)
          ? CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(pts),
              padding: const EdgeInsets.all(36),
              maxZoom: 17,
            )
          : null,
      interactionOptions: const InteractionOptions(
        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      ),
      onMapReady: () => _ready = true,
    );
    return Semantics(
      label: 'Map of the route',
      child: SizedBox(
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: FlutterMap(
            mapController: _controller,
            options: options,
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'pages.dev.crossgym',
              ),
              if (pts.length >= 2)
                PolylineLayer(polylines: [
                  Polyline(
                      points: pts, strokeWidth: 5, color: scheme.secondary),
                ]),
              if (pts.isNotEmpty)
                MarkerLayer(markers: [
                  Marker(
                    point: pts.first,
                    width: 16,
                    height: 16,
                    child: _dot(AppColors.volt),
                  ),
                  if (pts.length >= 2)
                    Marker(
                      point: pts.last,
                      width: 16,
                      height: 16,
                      child: _dot(AppColors.coral),
                    ),
                ]),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color c) => DecoratedBox(
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      );
}
