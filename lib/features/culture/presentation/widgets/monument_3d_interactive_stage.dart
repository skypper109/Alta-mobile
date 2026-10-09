import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/vivienne_tts_service.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import '../../scanner/models/monument_scan_models.dart';
import '../../scanner/widgets/monument_3d_viewer_modal.dart';

/// Scène d'exploration 3D interactive embarquée pour les monuments culturels
/// Offre :
/// - Rotation 360° fluide au doigt (orbite azimut & élévation)
/// - Zoom par pincement (pinch-to-zoom) & déplacement 2D
/// - Points d'intérêt 3D ancrés et animés en perspective
/// - 3 Ambiances lumineuses du Sahel (Zénith, Crépuscule, Nuit)
/// - Mode Écorché / Fil de fer (Wireframe) architectural
/// - Narration vocale TTS instantanée des points clés
class Monument3DInteractiveStage extends StatefulWidget {
  final MonumentScanTarget target;
  final double height;
  final bool showHeader;
  final VoidCallback? onExpandFullscreen;

  const Monument3DInteractiveStage({
    super.key,
    required this.target,
    this.height = 360,
    this.showHeader = true,
    this.onExpandFullscreen,
  });

  @override
  State<Monument3DInteractiveStage> createState() =>
      _Monument3DInteractiveStageState();
}

class _Monument3DInteractiveStageState
    extends State<Monument3DInteractiveStage>
    with TickerProviderStateMixin {
  // Angles et échelle de caméra
  double _rotX = -0.20;
  double _rotY = 0.42;
  double _scale = 1.05;
  Offset _panOffset = Offset.zero;

  // Contrôles
  bool _autoRotate = true;
  bool _showWireframe = false;
  LightingEnvironment _lighting = LightingEnvironment.soleilSahelien;
  Architectural3DHotspot? _activeHotspot;
  bool _isSpeakingHotspot = false;

  late final AnimationController _orbitController;
  late final AnimationController _particlesController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..addListener(() {
        if (_autoRotate && mounted) {
          setState(() {
            _rotY += 0.0035;
          });
        }
      });
    _orbitController.repeat();

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _particlesController.dispose();
    _pulseController.dispose();
    try {
      VivienneTtsService.instance.stop();
    } catch (_) {}
    super.dispose();
  }

  void _cycleLighting() {
    CulturalHaptics.tabSwitch();
    setState(() {
      if (_lighting == LightingEnvironment.soleilSahelien) {
        _lighting = LightingEnvironment.crepuscule;
      } else if (_lighting == LightingEnvironment.crepuscule) {
        _lighting = LightingEnvironment.nuitEtoilee;
      } else {
        _lighting = LightingEnvironment.soleilSahelien;
      }
    });
  }

  void _resetCamera({double rotX = -0.20, double rotY = 0.42, double scale = 1.05}) {
    HapticFeedback.selectionClick();
    setState(() {
      _rotX = rotX;
      _rotY = rotY;
      _scale = scale;
      _panOffset = Offset.zero;
      _activeHotspot = null;
      _autoRotate = true;
    });
  }

  void _toggleWireframe() {
    CulturalHaptics.tabSwitch();
    setState(() => _showWireframe = !_showWireframe);
  }

  void _selectHotspot(Architectural3DHotspot hp) {
    CulturalHaptics.stamp();
    setState(() {
      _activeHotspot = (_activeHotspot == hp) ? null : hp;
      _autoRotate = false;
      _isSpeakingHotspot = false;
    });
    try {
      VivienneTtsService.instance.stop();
    } catch (_) {}
  }

  Future<void> _narrateHotspot(Architectural3DHotspot hp) async {
    CulturalHaptics.audioToggle();
    if (_isSpeakingHotspot) {
      try {
        await VivienneTtsService.instance.stop();
      } catch (_) {}
      setState(() => _isSpeakingHotspot = false);
      return;
    }

    setState(() => _isSpeakingHotspot = true);
    final text = '${hp.title}. ${hp.subtitle}. ${hp.description}';
    try {
      await VivienneTtsService.instance.speak(text);
    } catch (_) {}
    if (mounted) {
      setState(() => _isSpeakingHotspot = false);
    }
  }

  List<Color> _getBackgroundGradients() {
    switch (_lighting) {
      case LightingEnvironment.soleilSahelien:
        return const [
          Color(0xFF231F17),
          Color(0xFF171410),
          Color(0xFF0C0A08),
        ];
      case LightingEnvironment.crepuscule:
        return const [
          Color(0xFF381A16),
          Color(0xFF221012),
          Color(0xFF0E0709),
        ];
      case LightingEnvironment.nuitEtoilee:
        return const [
          Color(0xFF0F1A30),
          Color(0xFF091122),
          Color(0xFF040710),
        ];
    }
  }

  String _getLightingName() {
    switch (_lighting) {
      case LightingEnvironment.soleilSahelien:
        return 'Zénith Saharien';
      case LightingEnvironment.crepuscule:
        return 'Crépuscule d\'Ocre';
      case LightingEnvironment.nuitEtoilee:
        return 'Nuit Saharienne';
    }
  }

  IconData _getLightingIcon() {
    switch (_lighting) {
      case LightingEnvironment.soleilSahelien:
        return Icons.wb_sunny_rounded;
      case LightingEnvironment.crepuscule:
        return Icons.wb_twilight_rounded;
      case LightingEnvironment.nuitEtoilee:
        return Icons.nights_stay_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotspots = Monument3DViewerModal.getHotspotsForTarget(widget.target);
    final isDjenne = widget.target.id.toLowerCase().contains('djenne');
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      height: widget.height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0A08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. DÉGRADÉ ATMOSPHÉRIQUE TEINTÉ ───────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.15,
                colors: _getBackgroundGradients(),
              ),
            ),
          ),

          // ── 2. PARTICULES DE POUSSIÈRE SAHÉLIENNE EN SUSPENSION ───────────
          AnimatedBuilder(
            animation: _particlesController,
            builder: (context, _) {
              return CustomPaint(
                painter: MonumentAtmosphericDustPainter(
                  progress: _particlesController.value,
                  lighting: _lighting,
                ),
              );
            },
          ),

          // ── 3. PODESTAT & OMBRE DE CONTACT 3D ─────────────────────────────
          Center(
            child: CustomPaint(
              size: const Size(260, 260),
              painter: MonumentPedestalShadowPainter(
                rotX: _rotX,
                scale: _scale,
              ),
            ),
          ),

          // ── 4. CANEVAS 3D INTERACTIF AU DOIGT (DRAG, PINCH, ZOOM) ─────────
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: (_) => setState(() => _autoRotate = false),
              onScaleUpdate: (details) {
                setState(() {
                  if (details.pointerCount > 1) {
                    _panOffset += details.focalPointDelta;
                  } else {
                    _rotY += details.focalPointDelta.dx * 0.011;
                    _rotX -= details.focalPointDelta.dy * 0.011;
                    _rotX = _rotX.clamp(-math.pi / 2.6, math.pi / 2.6);
                  }
                  _scale = (_scale * details.scale).clamp(0.65, 2.6);
                });
              },
              onDoubleTap: () => _resetCamera(),
              child: Center(
                child: CustomPaint(
                  size: const Size(340, 340),
                  painter: MonumentRealistic3DPainter(
                    target: widget.target,
                    rotX: _rotX,
                    rotY: _rotY,
                    scale: _scale,
                    panOffset: _panOffset,
                    lighting: _lighting,
                    showWireframe: _showWireframe,
                  ),
                ),
              ),
            ),
          ),

          // ── 5. HOTSPOTS 3D ANCRÉS EN COORDONNÉES RÉELLES ──────────────────
          for (final hp in hotspots) _buildProjected3DHotspot(hp),

          // ── 6. EN-TÊTE D'INFORMATIONS SUPÉRIEUR ───────────────────────────
          if (widget.showHeader)
            Positioned(
              left: 14,
              top: 14,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.view_in_ar_rounded,
                          size: 13,
                          color: CultureTheme.accentOrange,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isDjenne ? 'Grande Mosquée 360°' : 'Vue interactive 360°',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _cycleLighting,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getLightingIcon(),
                            size: 12,
                            color: const Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _getLightingName(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── 7. BOUTONS DE COMMANDE LATÉRAUX (HUD) ──────────────────────────
          // Décalés vers le bas pour ne jamais chevaucher le bouton Favori de l'en-tête
          Positioned(
            right: 12,
            top: topPadding > 0 ? topPadding + 88 : 48,
            child: Column(
              children: [
                // Auto-rotation Play/Pause
                _buildHudButton(
                  icon: _autoRotate
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  tooltip: _autoRotate ? 'Mettre en pause' : 'Rotation auto',
                  isActive: _autoRotate,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _autoRotate = !_autoRotate);
                  },
                ),
                const SizedBox(height: 7),

                // Écorché / Wireframe
                _buildHudButton(
                  icon: Icons.grid_4x4_rounded,
                  tooltip: 'Mode Blueprint / Wireframe',
                  isActive: _showWireframe,
                  onTap: _toggleWireframe,
                ),
                const SizedBox(height: 7),

                // Ambiance lumineuse / Éclairage (Zénith, Crépuscule, Nuit)
                _buildHudButton(
                  icon: _getLightingIcon(),
                  tooltip: 'Éclairage: ${_getLightingName()}',
                  onTap: _cycleLighting,
                ),
                const SizedBox(height: 7),

                // Reset caméra
                _buildHudButton(
                  icon: Icons.restart_alt_rounded,
                  tooltip: 'Réinitialiser vue',
                  onTap: () => _resetCamera(),
                ),
              ],
            ),
          ),

          // ── 8. BARRE INFÉRIEURE : SÉLECTEUR RAPIDE DE VUES + PLEIN ÉCRAN ────
          // Alignement horizontal parfait et unifié sans aucune superposition
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Row(
              children: [
                // Vues architecturales
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildPresetChip('Façade', () => _resetCamera(rotX: -0.15, rotY: 0.0)),
                        const SizedBox(width: 6),
                        _buildPresetChip('3/4 Haut', () => _resetCamera(rotX: -0.38, rotY: 0.62)),
                        const SizedBox(width: 6),
                        _buildPresetChip('Minarets', () => _resetCamera(rotX: 0.12, rotY: 0.25, scale: 1.35)),
                        if (isDjenne) ...[
                          const SizedBox(width: 6),
                          _buildPresetChip('Cour Sahn', () => _resetCamera(rotX: -0.35, rotY: 3.14)),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bouton Plein écran 3D aligné sur la même rangée
                if (widget.onExpandFullscreen != null) ...[
                  const SizedBox(width: 8),
                  _buildFullscreenPill(widget.onExpandFullscreen!),
                ],
              ],
            ),
          ),

          // ── 9. CARTE FLOTTANTE D'INFO DU HOTSPOT ACTIF ───────────────────
          // Positionnée au-dessus de la barre inférieure pour éviter tout conflit
          if (_activeHotspot != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 58,
              child: _buildActiveHotspotCard(_activeHotspot!),
            ),
        ],
      ),
    );
  }

  Widget _buildFullscreenPill(VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fullscreen_rounded,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'Plein écran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildHudButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isActive
                ? CultureTheme.accentOrange
                : Colors.black.withValues(alpha: 0.68),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? CultureTheme.accentOrange
                  : Colors.white.withValues(alpha: 0.2),
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
            ],
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProjected3DHotspot(Architectural3DHotspot hp) {
    const double d = 420.0;
    final double cosY = math.cos(_rotY);
    final double sinY = math.sin(_rotY);
    final double x1 = hp.x * cosY + hp.z * sinY;
    final double z1 = -hp.x * sinY + hp.z * cosY;

    final double cosX = math.cos(_rotX);
    final double sinX = math.sin(_rotX);
    final double y2 = hp.y * cosX - z1 * sinX;
    final double z2 = hp.y * sinX + z1 * cosX;

    // Cache les points d'intérêt sur la face cachée arrière
    if (z2 < -80) return const SizedBox.shrink();

    final double denom = d + z2;
    if (denom <= 20.0) return const SizedBox.shrink();

    final double proj = (d / denom) * _scale;
    final double screenX = x1 * proj + _panOffset.dx;
    final double screenY = y2 * proj + _panOffset.dy;

    if (!screenX.isFinite || !screenY.isFinite) return const SizedBox.shrink();

    final bool isSelected = _activeHotspot == hp;

    return Center(
      child: Transform.translate(
        offset: Offset(screenX, screenY),
        child: GestureDetector(
          onTap: () => _selectHotspot(hp),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Halo pulsant
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final pulseScale = 1.0 + _pulseController.value * 0.45;
                  final pulseAlpha = (1.0 - _pulseController.value) * 0.5;
                  return Transform.scale(
                    scale: pulseScale,
                    child: Container(
                      width: isSelected ? 34 : 26,
                      height: isSelected ? 34 : 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CultureTheme.accentOrange.withValues(alpha: pulseAlpha),
                      ),
                    ),
                  );
                },
              ),
              // Pin principal
              Container(
                width: isSelected ? 30 : 24,
                height: isSelected ? 30 : 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.white : CultureTheme.accentOrange,
                  border: Border.all(
                    color: isSelected ? CultureTheme.accentOrange : Colors.white,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.7),
                      blurRadius: isSelected ? 12 : 6,
                    ),
                  ],
                ),
                child: Icon(
                  hp.icon,
                  size: isSelected ? 15 : 12,
                  color: isSelected ? CultureTheme.accentOrange : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveHotspotCard(Architectural3DHotspot hp) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CultureTheme.accentOrange, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(hp.icon, color: CultureTheme.accentOrange, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hp.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      hp.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: CultureTheme.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Bouton écouter audio
              GestureDetector(
                onTap: () => _narrateHotspot(hp),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isSpeakingHotspot
                        ? const Color(0xFF10B981)
                        : CultureTheme.accentOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isSpeakingHotspot
                          ? const Color(0xFF10B981)
                          : CultureTheme.accentOrange,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSpeakingHotspot
                            ? Icons.volume_up_rounded
                            : Icons.record_voice_over_rounded,
                        size: 12,
                        color: _isSpeakingHotspot ? Colors.black : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isSpeakingHotspot ? 'Stop' : 'Écouter',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _isSpeakingHotspot ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  try {
                    VivienneTtsService.instance.stop();
                  } catch (_) {}
                  setState(() => _activeHotspot = null);
                },
                icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hp.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              height: 1.4,
              color: const Color(0xFFE2E8F0),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
