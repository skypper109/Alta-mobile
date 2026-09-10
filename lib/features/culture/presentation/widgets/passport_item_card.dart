import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';

/// Carte de collection d'art pour un élément gravé au Passeport
/// Dotée d'un retour haptique calibré, d'une micro-interaction ressort et d'un sceau vivant.
class PassportItemCard extends StatefulWidget {
  final PassportEntry entry;
  final bool isFeatured;

  const PassportItemCard({
    super.key,
    required this.entry,
    this.isFeatured = false,
  });

  @override
  State<PassportItemCard> createState() => _PassportItemCardState();
}

class _PassportItemCardState extends State<PassportItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.976).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.entry.targetRoute.isEmpty) return;
    setState(() => _isPressed = true);
    _pressController.forward();
    CulturalHaptics.cardPress();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.entry.targetRoute.isEmpty) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
    CulturalHaptics.cardRelease();
    final stampHeroTag = 'passport_stamp_${widget.entry.id}';
    context.push(widget.entry.targetRoute, extra: stampHeroTag);
  }

  void _handleTapCancel() {
    if (widget.entry.targetRoute.isEmpty) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  String _formatDate(DateTime date) {
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    final stampHeroTag = 'passport_stamp_${widget.entry.id}';
    final entry = widget.entry;
    final isFeatured = widget.isFeatured;

    final currentBorder = _isPressed
        ? CultureTheme.accentOrange
        : (isFeatured ? CultureTheme.accentOrange : borderCol);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: currentBorder,
              width: _isPressed ? 1.8 : (isFeatured ? 1.6 : 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? (_isPressed ? 0.38 : 0.22) : 0.05,
                ),
                blurRadius: _isPressed ? 6 : 12,
                offset: Offset(0, _isPressed ? 1.5 : 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. PHOTOGRAPHIE RÉELLE & TAMPON D'AUTHENTICITÉ (HERO) ──────
              SizedBox(
                height: isFeatured ? 170 : 135,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: stampHeroTag,
                      child: Image.asset(
                        entry.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: CultureTheme.primaryDark,
                          child: Center(
                            child: Icon(
                              entry.type.icon,
                              size: 36,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Voile sombre subtil
                    Container(
                      color: Colors.black.withValues(alpha: 0.18),
                    ),

                    // Badge de catégorie / type (Haut Gauche)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              entry.type.icon,
                              size: 11,
                              color: CultureTheme.accentOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.tag.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Région (Haut Droite)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CultureTheme.primaryBlue.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              entry.regionName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sceau dateur de découverte vivant (Bas Droite)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Transform.rotate(
                        angle: -0.035, // Micro-angle d'authenticité de tampon manuel
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: CultureTheme.accentOrange,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 11,
                                color: CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 4.5),
                              Text(
                                'GRAVÉ LE ${_formatDate(entry.discoveredAt).toUpperCase()}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. INFORMATIONS & CITATION PATRIMONIALE ───────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.isMilestone && entry.milestoneLabel != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 11,
                                  color: CultureTheme.accentOrange,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  entry.milestoneLabel!.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: CultureTheme.accentOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],

                    Text(
                      entry.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isFeatured ? 16 : 14.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3),

                    Text(
                      entry.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                        height: 1.3,
                      ),
                      maxLines: isFeatured ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (entry.culturalQuote != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: borderCol,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          entry.culturalQuote!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
