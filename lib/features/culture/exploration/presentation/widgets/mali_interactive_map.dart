import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../core/theme/culture_theme.dart';
import '../../data/models/mali_geo_regions.dart';
import '../../data/models/mali_historical_place_marker.dart';
import '../../data/models/mali_region.dart';
import 'historical_place_red_pin.dart';

/// Type d'affichage cartographique (Plan ou Satellite)
enum MaliMapLayerType {
  street, // Carte routière & administrative OpenStreetMap
  satellite, // Vue satellite réelle haute résolution (Esri)
}

/// Carte interactive du Mali motorisée par FlutterMap.
/// - Fluidité absolue 60/120 FPS sans saccades
/// - Délimitations colorées et nettes des 8 régions
/// - Villes phares indiquées avec badges
/// - Vue Satellite réelle disponible en 1 clic
/// - 18 monuments historiques en points rouges avec fiches interactives
class MaliInteractiveMap extends StatefulWidget {
  final List<MaliRegion> regions;
  final String? selectedRegionId;
  final ValueChanged<String?> onRegionSelected;

  final String? selectedPlaceId;
  final ValueChanged<MaliHistoricalPlaceMarker?>? onPlaceSelected;
  final List<MaliHistoricalPlaceMarker>? markers;
  final MaliMapLayerType initialLayerType;

  const MaliInteractiveMap({
    super.key,
    required this.regions,
    required this.selectedRegionId,
    required this.onRegionSelected,
    this.selectedPlaceId,
    this.onPlaceSelected,
    this.markers,
    this.initialLayerType = MaliMapLayerType.satellite,
  });

  @override
  State<MaliInteractiveMap> createState() => _MaliInteractiveMapState();
}

class _MaliInteractiveMapState extends State<MaliInteractiveMap>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  AnimationController? _cameraAnimController;
  late MaliMapLayerType _layerType;

  List<MaliHistoricalPlaceMarker> get _allMarkers =>
      widget.markers ?? MaliHistoricalPlacesRegistry.all;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _layerType = widget.initialLayerType;
  }

  MapCamera? get _safeCamera {
    try {
      return _mapController.camera;
    } catch (_) {
      return null;
    }
  }

  @override
  void didUpdateWidget(covariant MaliInteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Centrage cinématique fluide sur un monument sélectionné
    if (widget.selectedPlaceId != oldWidget.selectedPlaceId &&
        widget.selectedPlaceId != null) {
      final place = _allMarkers
          .where((m) =>
              m.id == widget.selectedPlaceId ||
              m.scannerId == widget.selectedPlaceId ||
              m.id.replaceAll('monument_', '') ==
                  widget.selectedPlaceId!.replaceAll('monument_', ''))
          .firstOrNull;
      if (place != null) {
        final camera = _safeCamera;
        final currentZoom = camera?.zoom ?? 12.0;
        final targetZoom = currentZoom < 15.5 ? 16.5 : currentZoom;
        _animatedMapMove(place.latLng, targetZoom);
        return;
      }
    }

    // Centrage sur une région sélectionnée
    if (widget.selectedRegionId != oldWidget.selectedRegionId) {
      if (widget.selectedRegionId != null) {
        final center =
            MaliRegionCoordinates.getRegionCenter(widget.selectedRegionId);
        final zoom =
            MaliRegionCoordinates.getRegionZoom(widget.selectedRegionId);
        _animatedMapMove(center, zoom);
      } else if (oldWidget.selectedRegionId != null &&
          widget.selectedPlaceId == null) {
        _animatedMapMove(
          MaliRegionCoordinates.maliCenter,
          MaliRegionCoordinates.maliOverviewZoom,
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraAnimController?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Animation de transition caméra douce sans bloquer l'arbre de rendu
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    _cameraAnimController?.dispose();

    final camera = _safeCamera;
    if (camera == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _safeCamera != null) {
          _animatedMapMove(destLocation, destZoom);
        }
      });
      return;
    }

    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );
    _cameraAnimController = controller;

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
        if (_cameraAnimController == controller) {
          _cameraAnimController = null;
        }
      }
    });

    controller.forward();
  }

  void _zoomIn() {
    HapticFeedback.lightImpact();
    final camera = _safeCamera;
    if (camera != null && camera.zoom < 20.0) {
      _animatedMapMove(camera.center, (camera.zoom + 1.2).clamp(4.0, 20.0));
    }
  }

  void _zoomOut() {
    HapticFeedback.lightImpact();
    final camera = _safeCamera;
    if (camera != null && camera.zoom > 4.5) {
      _animatedMapMove(camera.center, (camera.zoom - 1.2).clamp(4.0, 20.0));
    }
  }

  void _focusBamako() {
    HapticFeedback.mediumImpact();
    widget.onRegionSelected('bamako');
    _animatedMapMove(
      MaliRegionCoordinates.getRegionCenter('bamako'),
      13.5,
    );
  }

  void _toggleMapLayer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _layerType = _layerType == MaliMapLayerType.street
          ? MaliMapLayerType.satellite
          : MaliMapLayerType.street;
    });
  }

  void _recenterOverview() {
    HapticFeedback.mediumImpact();
    if (widget.selectedPlaceId != null && widget.onPlaceSelected != null) {
      widget.onPlaceSelected!(null);
    }
    if (widget.selectedRegionId != null) {
      widget.onRegionSelected(null);
    }
    _animatedMapMove(
      MaliRegionCoordinates.maliCenter,
      MaliRegionCoordinates.maliOverviewZoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSatellite = _layerType == MaliMapLayerType.satellite;

    // Détermine le centre et le zoom initiaux (avec zoom 16.5 sur le monument ciblé)
    final selectedMarker = widget.selectedPlaceId != null
        ? _allMarkers
            .where((m) =>
                m.id == widget.selectedPlaceId ||
                m.scannerId == widget.selectedPlaceId ||
                m.id.replaceAll('monument_', '') ==
                    widget.selectedPlaceId!.replaceAll('monument_', ''))
            .firstOrNull
        : null;

    final initialCenter = selectedMarker != null
        ? selectedMarker.latLng
        : MaliRegionCoordinates.getRegionCenter(widget.selectedRegionId);

    final initialZoom = selectedMarker != null
        ? 16.5
        : MaliRegionCoordinates.getRegionZoom(widget.selectedRegionId);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1322) : const Color(0xFFF7F4EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? CultureTheme.darkBorder : const Color(0xFFE8E2D5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF6B5A42))
                .withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── 1. MOTEUR FLUTTER_MAP HAUTE PERFORMANCE ───────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
              minZoom: 4.5,
              maxZoom: 20.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (_, __) {
                if (widget.selectedPlaceId != null &&
                    widget.onPlaceSelected != null) {
                  widget.onPlaceSelected!(null);
                }
              },
            ),
            children: [
              // ── A. TUILES FOND DE CARTE HAUTE DÉFINITION & STABILITÉ ─────────
              if (isSatellite) ...[
                // Vue Satellite Google Maps Hybrid (haute résolution sub-métrique sans filigrane 'not yet available')
                TileLayer(
                  urlTemplate:
                      'https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                  subdomains: const ['0', '1', '2', '3'],
                  fallbackUrl:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.alternia.det_mobile',
                  maxNativeZoom: 19,
                  maxZoom: 20.0,
                  keepBuffer: 3,
                  panBuffer: 1,
                  tileProvider: NetworkTileProvider(
                    silenceExceptions: true,
                  ),
                  evictErrorTileStrategy: EvictErrorTileStrategy.none,
                  errorTileCallback: (tile, error, stackTrace) {},
                ),
              ] else ...[
                // Vue Plan / Cartographie culturelle (CartoDB)
                TileLayer(
                  urlTemplate: isDark
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                      : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.alternia.det_mobile',
                  maxNativeZoom: 19,
                  maxZoom: 20.0,
                  keepBuffer: 3,
                  panBuffer: 1,
                  tileProvider: NetworkTileProvider(
                    silenceExceptions: true,
                  ),
                  evictErrorTileStrategy: EvictErrorTileStrategy.none,
                  errorTileCallback: (tile, error, stackTrace) {},
                ),
              ],

              // ── B. CALQUE DES VILLES PRINCIPALES DU MALI ───────────────────
              MarkerLayer(
                markers: MaliGeoRegionsRegistry.majorCities.map((city) {
                  final isCapital = city.isCapital;
                  return Marker(
                    point: city.latLng,
                    width: isCapital ? 90 : 76,
                    height: 26,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark || isSatellite
                                ? const Color(0xFF0F172A)
                                : Colors.white)
                            .withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCapital
                              ? const Color(0xFFFFB300)
                              : (isDark || isSatellite
                                  ? Colors.white24
                                  : const Color(0xFFCBD5E1)),
                          width: isCapital ? 1.4 : 0.8,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCapital
                                ? Icons.star_rounded
                                : Icons.location_city_rounded,
                            size: 11,
                            color: isCapital
                                ? const Color(0xFFFFB300)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 3.5),
                          Flexible(
                            child: Text(
                              city.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isCapital ? 9.5 : 8.5,
                                fontWeight: isCapital
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                color: isDark || isSatellite
                                    ? Colors.white
                                    : const Color(0xFF1E284A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // ── D. CALQUE DES 18 MONUMENTS HISTORIQUES (POINTS ROUGES) ────
              MarkerLayer(
                markers: _allMarkers.map((marker) {
                  final isSelected = marker.id == widget.selectedPlaceId;
                  final isRegionActive = widget.selectedRegionId != null;
                  final isSameRegion = !isRegionActive ||
                      marker.regionId == widget.selectedRegionId;

                  final shouldDisplayLabel =
                      isSelected || (isRegionActive && isSameRegion);

                  return Marker(
                    point: marker.latLng,
                    width: shouldDisplayLabel ? 92 : 28,
                    height: shouldDisplayLabel ? 46 : 28,
                    alignment: Alignment.topCenter,
                    child: HistoricalPlaceRedPin(
                      marker: marker,
                      isSelected: isSelected,
                      isDimmed: isRegionActive && !isSameRegion,
                      showLabel: shouldDisplayLabel,
                      onTap: () {
                        final currentZoom = _mapController.camera.zoom;
                        final targetZoom =
                            currentZoom < 15.5 ? 16.5 : currentZoom;
                        _animatedMapMove(marker.latLng, targetZoom);
                        widget.onPlaceSelected?.call(marker);
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── 2. SÉLECTEUR DE VUE FLOTTANT (GOOGLE PLAN / SATELLITE HD) (Haut Gauche) ──
          Positioned(
            top: 14,
            left: 14,
            child: _buildLayerToggleSwitch(isSatellite, isDark),
          ),

          // ── 3. COMMANDES DE ZOOM & RECENTRAGE (Haut Droite) ────────────────
          Positioned(
            top: 14,
            right: 14,
            child: _buildZoomControls(isDark, isSatellite),
          ),

          // ── 4. BADGE CONTEXTUEL CULTUREL (Bas Gauche) ──────────────────────
          Positioned(
            bottom: 12,
            left: 14,
            child: _buildInteractiveHintBadge(isDark, isSatellite),
          ),
        ],
      ),
    );
  }

  // ── SÉLECTEUR DE COUCHE FLOTTANT (GOOGLE PLAN / SATELLITE HYBRIDE) ─────────
  Widget _buildLayerToggleSwitch(bool isSatellite, bool isDark) {
    return GestureDetector(
      onTap: _toggleMapLayer,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (isDark || isSatellite
                  ? const Color(0xFF0F172A)
                  : Colors.white)
              .withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSatellite
                ? const Color(0xFF00E676)
                : (isDark ? CultureTheme.darkBorder : const Color(0xFFE8ECF2)),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSatellite ? Icons.satellite_alt_rounded : Icons.map_rounded,
              size: 15,
              color: isSatellite
                  ? const Color(0xFF00E676)
                  : const Color(0xFF283B7E),
            ),
            const SizedBox(width: 6),
            Text(
              isSatellite ? 'Google Satellite' : 'Google Plan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isDark || isSatellite
                    ? Colors.white
                    : const Color(0xFF1E284A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── COMMANDES FLOTTANTES ZOOM IN / OUT / BAMAKO / RECENTRER ────────────────
  Widget _buildZoomControls(bool isDark, bool isSatellite) {
    final bgColor = (isDark || isSatellite
            ? const Color(0xFF0F172A)
            : Colors.white)
        .withValues(alpha: 0.94);
    final borderCol = isDark || isSatellite
        ? Colors.white24
        : const Color(0xFFE8ECF2);
    final iconColor =
        isDark || isSatellite ? Colors.white : const Color(0xFF1E284A);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom In
          GestureDetector(
            onTap: _zoomIn,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 40,
              height: 38,
              child: Center(
                child: Icon(Icons.add_rounded, size: 22, color: iconColor),
              ),
            ),
          ),
          Container(width: 24, height: 1, color: borderCol),

          // Raccourci Focus Bamako (Zoom 13.5 direct sur la capitale)
          GestureDetector(
            onTap: _focusBamako,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 40,
              height: 36,
              child: Center(
                child: Icon(
                  Icons.location_city_rounded,
                  size: 19,
                  color: (widget.selectedRegionId == 'bamako')
                      ? const Color(0xFF00E676)
                      : iconColor.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
          Container(width: 24, height: 1, color: borderCol),

          // Recentrer sur le Mali global
          GestureDetector(
            onTap: _recenterOverview,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 40,
              height: 36,
              child: Center(
                child: Icon(
                  Icons.filter_center_focus_rounded,
                  size: 19,
                  color: (widget.selectedRegionId != null ||
                          widget.selectedPlaceId != null)
                      ? const Color(0xFFDF6E21)
                      : iconColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          Container(width: 24, height: 1, color: borderCol),

          // Zoom Out
          GestureDetector(
            onTap: _zoomOut,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 40,
              height: 38,
              child: Center(
                child: Icon(Icons.remove_rounded, size: 22, color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BADGE D'INDICATION INTERACTIF ──────────────────────────────────────────
  Widget _buildInteractiveHintBadge(bool isDark, bool isSatellite) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isDark || isSatellite
                ? const Color(0xFF0F172A)
                : Colors.white)
            .withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark || isSatellite
              ? Colors.white24
              : const Color(0xFFE8ECF2),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF00E676),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Google Maps HD · ${_allMarkers.length} Sites',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark || isSatellite
                  ? Colors.white
                  : const Color(0xFF1E284A),
            ),
          ),
        ],
      ),
    );
  }
}
