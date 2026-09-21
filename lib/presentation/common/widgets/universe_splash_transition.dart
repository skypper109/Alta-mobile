import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/culture/core/theme/culture_theme.dart';

enum UniverseDestination {
  culture,
  education,
}

class UniverseSplashTransition {
  static void toCulture(BuildContext context,
      {required VoidCallback onComplete}) {
    _showTransition(
      context,
      destination: UniverseDestination.culture,
      onComplete: onComplete,
    );
  }

  static void toEducation(BuildContext context,
      {required VoidCallback onComplete}) {
    _showTransition(
      context,
      destination: UniverseDestination.education,
      onComplete: onComplete,
    );
  }

  static void _showTransition(
    BuildContext context, {
    required UniverseDestination destination,
    required VoidCallback onComplete,
  }) {
    HapticFeedback.heavyImpact();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, anim1, anim2) {
        return _UniverseSplashView(
          destination: destination,
          onFinish: () {
            Navigator.of(dialogContext, rootNavigator: true).pop();
            onComplete();
          },
        );
      },
    );
  }
}

class _UniverseSplashView extends StatefulWidget {
  const _UniverseSplashView({
    required this.destination,
    required this.onFinish,
  });

  final UniverseDestination destination;
  final VoidCallback onFinish;

  @override
  State<_UniverseSplashView> createState() => _UniverseSplashViewState();
}

class _UniverseSplashViewState extends State<_UniverseSplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _ctrl.forward();

    // Fermeture automatique et passage à l'univers après l'animation
    Timer(const Duration(milliseconds: 1750), () {
      if (mounted) {
        HapticFeedback.mediumImpact();
        widget.onFinish();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isToCulture = widget.destination == UniverseDestination.culture;

    final bgColors = isToCulture
        ? const [
            Color(0xFF0F172A),
            Color(0xFF451A03),
            Color(0xFF78350F),
            Color(0xFF1E1B4B),
          ]
        : const [
            Color(0xFF060B18),
            Color(0xFF0B1936),
            Color(0xFF1E2E65),
            Color(0xFF0F172A),
          ];

    final primaryAccent =
        isToCulture ? CultureTheme.accentOrange : AppColors.secondary;

    final title = isToCulture ? 'UNIVERS CULTUREL' : 'ESPACE ÉDUCATION';

    final subtitle = isToCulture
        ? 'Voyage immersif au cœur des contes, monuments et traditions du Mali'
        : 'Reprise des séances d\'entraînement et du tutorat pédagogique';

    final icon = isToCulture ? Icons.public_rounded : Icons.psychology_rounded;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fond flouté & dégradé cosmique immersif
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: bgColors,
                ),
              ),
            ),
          ),

          // Halos lumineux d'arrière-plan
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnim.value * 0.7,
                  child: Center(
                    child: Container(
                      width: 280 * _scaleAnim.value,
                      height: 280 * _scaleAnim.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryAccent.withValues(alpha: 0.18),
                        boxShadow: [
                          BoxShadow(
                            color: primaryAccent.withValues(alpha: 0.35),
                            blurRadius: 90,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Contenu centré avec animations coordonnées
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sphère emblématique pulsante
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isToCulture
                                    ? [
                                        const Color(0xFFF1851F),
                                        const Color(0xFFB45309),
                                      ]
                                    : [
                                        const Color(0xFF40BBCC),
                                        const Color(0xFF314999),
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryAccent.withValues(alpha: 0.45),
                                  blurRadius: 36,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 4,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.7),
                                width: 2.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Badge de transition
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primaryAccent.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            isToCulture
                                ? '✦ VOYAGE CULTUREL'
                                : '✦ SAVOIRS & RÉVISION',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: primaryAccent,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Titre principal
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Sous-titre
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Barre de progression lumineuse fine
                        SizedBox(
                          width: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _ctrl.value,
                              minHeight: 4,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
