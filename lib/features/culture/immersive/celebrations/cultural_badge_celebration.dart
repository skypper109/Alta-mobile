import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';

/// Modal de célébration élégante pour les badges, tampons du passeport et niveaux culturels.
/// Séquence animée : Apparition fond -> Badge avec scale/rotation -> Titre -> XP -> Bouton Continuer.
class CulturalBadgeCelebration extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? category;
  final int xpGained;
  final IconData badgeIcon;
  final String? photoUrl;
  final VoidCallback? onDismiss;

  const CulturalBadgeCelebration({
    super.key,
    required this.title,
    required this.subtitle,
    this.category,
    this.xpGained = 50,
    this.badgeIcon = Icons.military_tech_rounded,
    this.photoUrl,
    this.onDismiss,
  });

  /// Méthode d'affichage modale pratique
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    String? category,
    int xpGained = 50,
    IconData badgeIcon = Icons.military_tech_rounded,
    String? photoUrl,
    VoidCallback? onDismiss,
  }) {
    HapticFeedback.heavyImpact();
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (context) => CulturalBadgeCelebration(
        title: title,
        subtitle: subtitle,
        category: category,
        xpGained: xpGained,
        badgeIcon: badgeIcon,
        photoUrl: photoUrl,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<CulturalBadgeCelebration> createState() => _CulturalBadgeCelebrationState();
}

class _CulturalBadgeCelebrationState extends State<CulturalBadgeCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    HapticFeedback.mediumImpact();
    widget.onDismiss?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderCol, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 1. ÉTOILE SUPÉRIEURE SUBTILE ──────────────────────────────
              const Icon(
                Icons.auto_awesome_rounded,
                size: 24,
                color: CultureTheme.accentOrange,
              ),
              const SizedBox(height: 12),

              // ── 2. BADGE AVEC ANIMATION SCALE & ROTATION ───────────────────
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CultureTheme.accentOrange,
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: widget.photoUrl != null
                        ? ClipOval(
                            child: Image.asset(
                              widget.photoUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            widget.badgeIcon,
                            size: 44,
                            color: CultureTheme.accentOrange,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── 3. CONTENU TEXTUEL & RÉCOMPENSES ──────────────────────────
              FadeTransition(
                opacity: _contentFadeAnimation,
                child: Column(
                  children: [
                    // Catégorie / Statut
                    Text(
                      widget.category?.toUpperCase() ?? 'NOUVELLE DÉCOUVERTE !',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Nom du badge
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Sous-titre explicatif
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pilule XP
                    if (widget.xpGained > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: CultureTheme.primaryBlue.withValues(
                            alpha: isDark ? 0.25 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: CultureTheme.primaryBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: CultureTheme.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${widget.xpGained} XP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: CultureTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── 4. BOUTON CONTINUER ────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CultureTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Continuer l\'exploration',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
