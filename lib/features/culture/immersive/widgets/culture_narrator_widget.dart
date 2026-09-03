import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';
import '../controllers/narration_coordinator.dart';

/// Widget réutilisable : Narrateur Culturel / Griot
///
/// Fonctionnalités :
/// - Portrait culturel circulaire avec bordures nettes et flat
/// - Respiration légère permanente (cycle doux et apaisant)
/// - Halo discret (pulsation subtile de contour uni)
/// - Légère oscillation naturelle (micro-flottement et micro-rotation)
/// - Indicateur visuel réactif synchronisé avec [NarrationCoordinator] lorsque FlutterTTS parle
/// - STRICTEMENT SANS DÉGRADÉS (aplats et opacités unies selon la charte UX/UI)
/// - SANS AUCUN EMOJI (icônes vectorielles officielles uniquement)
class CultureNarratorWidget extends ConsumerStatefulWidget {
  /// Chemin de l'image du narrateur (ex: Griot, Soundiata, ou avatar culturel)
  final String imagePath;

  /// Diamètre du portrait (par défaut 110.0)
  final double size;

  /// Titre ou nom du narrateur (ex: 'Griot Moderne', 'La Voix de la Mémoire')
  final String? name;

  /// Sous-titre ou titre traditionnel (ex: 'Gardien de la tradition orale')
  final String? subtitle;

  /// Afficher ou masquer le badge textuel sous le portrait
  final bool showBadge;

  /// Couleur principale du contour et du halo (flat, sans dégradé)
  final Color primaryColor;

  /// Couleur secondaire d'accentuation (flat, sans dégradé)
  final Color accentColor;

  /// Override manuel de l'état de parole (si null, écoute narrationCoordinatorProvider)
  final bool? isSpeakingOverride;

  /// Action lors du tap sur le narrateur (ex: activer/couper la voix)
  final VoidCallback? onTap;

  const CultureNarratorWidget({
    super.key,
    this.imagePath = 'assets/images/culture/robot_sage.jpg',
    this.size = 110.0,
    this.name = 'Griot-Bot',
    this.subtitle = 'Mémoire vivante du Mali',
    this.showBadge = true,
    this.primaryColor = CultureTheme.accentOrange,
    this.accentColor = CultureTheme.cyanTurquoise,
    this.isSpeakingOverride,
    this.onTap,
  });

  @override
  ConsumerState<CultureNarratorWidget> createState() =>
      _CultureNarratorWidgetState();
}

class _CultureNarratorWidgetState extends ConsumerState<CultureNarratorWidget>
    with TickerProviderStateMixin {
  // Contrôleur de respiration et de pulsation permanente (3.6s par cycle)
  late final AnimationController _breathingController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _haloAnimation;

  // Contrôleur d'oscillation naturelle subtile (5.2s par cycle déphasé)
  late final AnimationController _oscillationController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _verticalFloatAnimation;

  // Contrôleur des ondes vocales lorsque la parole est active
  late final AnimationController _speakingBarsController;

  @override
  void initState() {
    super.initState();

    // 1. Respiration douce et naturelle
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.985, end: 1.025).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    _haloAnimation = Tween<double>(begin: 4.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 2. Oscillation naturelle imperceptible (sensation de présence humaine)
    _oscillationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.012, end: 0.012).animate(
      CurvedAnimation(
        parent: _oscillationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _verticalFloatAnimation = Tween<double>(begin: -2.5, end: 2.5).animate(
      CurvedAnimation(
        parent: _oscillationController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 3. Animation d'égaliseur vocal pour la parole
    _speakingBarsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _oscillationController.dispose();
    _speakingBarsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier l'état de parole soit par l'override soit via NarrationCoordinator
    final narrationSnapshot = ref.watch(narrationCoordinatorProvider);
    final isSpeaking = widget.isSpeakingOverride ?? narrationSnapshot.isSpeaking;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── AVATAR VIVANT AVEC RESPIRATION, HALO ET MICRO-OSCILLATION ───
          AnimatedBuilder(
            animation: Listenable.merge([
              _breathingController,
              _oscillationController,
              _speakingBarsController,
            ]),
            builder: (context, child) {
              final haloSize = _haloAnimation.value;
              final currentScale = _scaleAnimation.value;
              final currentRotation = _rotationAnimation.value;
              final currentFloat = _verticalFloatAnimation.value;

              return Transform.translate(
                offset: Offset(0, currentFloat),
                child: Transform.rotate(
                  angle: currentRotation,
                  child: Transform.scale(
                    scale: currentScale,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Anneau de halo externe discret (UNI sans dégradé)
                        Container(
                          width: widget.size + (haloSize * 2.2),
                          height: widget.size + (haloSize * 2.2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isSpeaking
                                    ? widget.primaryColor
                                    : widget.primaryColor)
                                .withValues(
                              alpha: isSpeaking ? 0.22 : 0.10,
                            ),
                          ),
                        ),

                        // Anneau de halo intermédiaire
                        Container(
                          width: widget.size + (haloSize * 1.2),
                          height: widget.size + (haloSize * 1.2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.primaryColor.withValues(
                              alpha: isSpeaking ? 0.35 : 0.18,
                            ),
                          ),
                        ),

                        // Cadre principal du portrait
                        Container(
                          width: widget.size,
                          height: widget.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CultureTheme.darkSurface,
                            border: Border.all(
                              color: isSpeaking
                                  ? widget.primaryColor
                                  : widget.primaryColor.withValues(alpha: 0.7),
                              width: isSpeaking ? 2.8 : 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              widget.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: CultureTheme.darkSurfaceAlt,
                                  child: Center(
                                    child: Icon(
                                      Icons.record_voice_over_rounded,
                                      size: widget.size * 0.45,
                                      color: widget.primaryColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Indicateur d'onde vocale en direct si en train de parler
                        if (isSpeaking)
                          Positioned(
                            bottom: -4,
                            child: _buildAudioWaveIndicator(),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── BADGE D'IDENTITÉ CULTURELLE ─────────────────────────────────
          if (widget.showBadge) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: CultureTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSpeaking
                      ? widget.primaryColor.withValues(alpha: 0.6)
                      : CultureTheme.darkBorder,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSpeaking
                        ? Icons.volume_up_rounded
                        : Icons.auto_stories_rounded,
                    size: 13,
                    color: isSpeaking
                        ? widget.primaryColor
                        : CultureTheme.cyanTurquoise,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isSpeaking
                        ? 'Parole du Griot...'
                        : (widget.name ?? 'Le Griot'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.subtitle != null && !isSpeaking) ...[
              const SizedBox(height: 3),
              Text(
                widget.subtitle!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: CultureTheme.textMutedDark,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Indicateur visuel d'ondes vocales (4 barres animées, STRICTEMENT sans dégradé)
  Widget _buildAudioWaveIndicator() {
    final t = _speakingBarsController.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CultureTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBar(height: 6 + (8 * math.sin(t * math.pi)).abs()),
          const SizedBox(width: 3),
          _buildBar(height: 6 + (12 * math.cos(t * math.pi)).abs()),
          const SizedBox(width: 3),
          _buildBar(height: 6 + (10 * math.sin(t * math.pi * 1.3)).abs()),
          const SizedBox(width: 3),
          _buildBar(height: 6 + (7 * math.cos(t * math.pi * 0.9)).abs()),
        ],
      ),
    );
  }

  Widget _buildBar({required double height}) {
    return Container(
      width: 2.8,
      height: height.clamp(4.0, 18.0),
      decoration: BoxDecoration(
        color: widget.primaryColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
