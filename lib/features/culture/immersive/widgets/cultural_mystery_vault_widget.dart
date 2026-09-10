import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../controllers/narration_coordinator.dart';
import '../services/cultural_haptics.dart';
import 'cultural_rolling_xp_counter.dart';

/// Médaillon Sacré & Coffre de Sagesse du Jour (« Rompre le Sceau des Anciens »)
/// Déclenche une explosion géométrique radiale, secousse haptique lourde, et gain d'XP immédiat.
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI AlterniA.
class CulturalMysteryVaultWidget extends ConsumerStatefulWidget {
  const CulturalMysteryVaultWidget({super.key});

  @override
  ConsumerState<CulturalMysteryVaultWidget> createState() =>
      _CulturalMysteryVaultWidgetState();
}

class _CulturalMysteryVaultWidgetState
    extends ConsumerState<CulturalMysteryVaultWidget>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _revealController;
  late final Animation<double> _bloomScaleAnimation;
  late final Animation<double> _contentFadeAnimation;

  bool _isUnlocked = false;

  static const String _proverbBamana =
      '« Banna tɛ mɔgɔ faga, jatigi tè mɔgɔ faga. »';
  static const String _proverbFrench =
      '« Ce n\'est pas la maladie qui tue l\'homme, c\'est le destin. La patience et l\'honneur soutiennent toujours le voyageur du Sahel. »';
  static const String _proverbMoral =
      'Sagesse des Anciens du Mandé • La persévérance triomphe des épreuves.';

  @override
  void initState() {
    super.initState();
    // Rotation lente et hypnotique du sceau fermé
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Contrôleur de déflagration géométrique lors de l'ouverture
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _bloomScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeOutBack,
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _unlockSeal() {
    if (_isUnlocked) return;

    HapticFeedback.heavyImpact();
    CulturalHaptics.celebration();

    setState(() {
      _isUnlocked = true;
    });

    _rotationController.stop();
    _revealController.forward();

    // Enregistrement de la découverte au Passeport
    ref.read(culturePassportProvider.notifier).recordDiscovery(
          id: 'sagesse_du_jour',
          type: PassportItemType.defi,
          title: 'Sceau de la Sagesse du Jour',
          subtitle: 'Proverbe des Anciens du Sahel',
          regionName: 'Tout le Mali',
          photoUrl: 'assets/images/culture/villes/bandiagara_falaise.jpg',
          tag: 'Sagesse',
          culturalQuote: _proverbBamana,
          targetRoute: '',
          xpEarned: 25,
        );
  }

  void _speakProverb() {
    HapticFeedback.mediumImpact();
    final coordinator = ref.read(narrationCoordinatorProvider.notifier);
    final snapshot = ref.read(narrationCoordinatorProvider);

    if (snapshot.isSpeaking && snapshot.activeContentId == 'sagesse_jour') {
      coordinator.stop();
    } else {
      coordinator.speak(
        '$_proverbBamana. En français : $_proverbFrench. $_proverbMoral',
        contentId: 'sagesse_jour',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final narration = ref.watch(narrationCoordinatorProvider);
    final isSpeaking = narration.isSpeaking && narration.activeContentId == 'sagesse_jour';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isUnlocked
            ? (isDark ? CultureTheme.darkSurface : const Color(0xFFFFFBF5))
            : cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isUnlocked
              ? CultureTheme.accentOrange
              : borderCol,
          width: _isUnlocked ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isUnlocked
                ? CultureTheme.accentOrange.withValues(alpha: isDark ? 0.22 : 0.10)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── EN-TÊTE DU MÉDAILLON ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      size: 18,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SAGESSE DU JOUR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                      Text(
                        _isUnlocked ? 'Sceau Dévoilé • Mandé' : 'Médaillon Mystère des Anciens',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CultureTheme.primaryBlue.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: CultureTheme.primaryBlue,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+25 XP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── CORPS INTERACTIF : SCEAU FERMÉ VS RÉVÉLATION ÉLITE ─────────────
          if (!_isUnlocked)
            GestureDetector(
              onTap: _unlockSeal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                    style: BorderStyle.solid,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    // Le sceau mystique en rotation douce continue
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                          border: Border.all(
                            color: CultureTheme.accentOrange,
                            width: 2.2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Losange intérieur Bogolan
                            Transform.rotate(
                              angle: math.pi / 4,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 26,
                              color: CultureTheme.accentOrange,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Rompre le Sceau des Anciens',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Touchez pour entendre la parole et graver 25 XP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ScaleTransition(
              scale: _bloomScaleAnimation,
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Proverbe traditionnel en Bambara
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CultureTheme.accentOrange.withValues(
                          alpha: isDark ? 0.16 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _proverbBamana,
                            style: GoogleFonts.merriweather(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              color: CultureTheme.accentOrange,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _proverbFrench,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: titleColor,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Barre d'actions & écoute audio du Griot
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Compteur XP roulant
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: CultureTheme.cyanTurquoise,
                            ),
                            const SizedBox(width: 5),
                            CulturalRollingXpCounter(
                              targetXp: 25,
                              prefix: '+',
                              suffix: ' XP au Passeport',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: CultureTheme.cyanTurquoise,
                              ),
                            ),
                          ],
                        ),

                        // Bouton Voix du Griot
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _speakProverb,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSpeaking
                                  ? CultureTheme.accentOrange
                                  : CultureTheme.accentOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: CultureTheme.accentOrange,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSpeaking ? Icons.volume_up_rounded : Icons.headphones_rounded,
                                  size: 14,
                                  color: isSpeaking ? Colors.white : CultureTheme.accentOrange,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isSpeaking ? 'Griot en voix' : 'Écouter le sage',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isSpeaking ? Colors.white : CultureTheme.accentOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
