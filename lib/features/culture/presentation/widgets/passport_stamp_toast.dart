import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';

/// Toast de découverte patrimoniale gravée au carnet de trésors
/// Intègre une micro-animation de frappe de sceau et le moteur haptique CulturalHaptics.
class PassportStampToast {
  static void show(
    BuildContext context, {
    required String title,
    required PassportItemType type,
    String? milestoneLabel,
  }) {
    // Frappe haptique double impact simulant le tampon physique
    CulturalHaptics.stamp();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 3400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: EdgeInsets.zero,
        content: _StampToastContent(
          title: title,
          type: type,
          milestoneLabel: milestoneLabel,
        ),
      ),
    );
  }
}

class _StampToastContent extends StatefulWidget {
  final String title;
  final PassportItemType type;
  final String? milestoneLabel;

  const _StampToastContent({
    required this.title,
    required this.type,
    this.milestoneLabel,
  });

  @override
  State<_StampToastContent> createState() => _StampToastContentState();
}

class _StampToastContentState extends State<_StampToastContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stampAnimController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _stampAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1.45, end: 1.0).animate(
      CurvedAnimation(
        parent: _stampAnimController,
        curve: Curves.easeOutBack,
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.18, end: 0.0).animate(
      CurvedAnimation(
        parent: _stampAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    _stampAnimController.forward();
  }

  @override
  void dispose() {
    _stampAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    final borderCol = CultureTheme.accentOrange.withValues(alpha: 0.55);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sceau / Tampon avec animation de frappe physique (scale + rotation)
          AnimatedBuilder(
            animation: _stampAnimController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CultureTheme.accentOrange,
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.type.icon,
                  color: CultureTheme.accentOrange,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Textes explicatifs
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'NOUVEAU TRÉSOR GRAVÉ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                    if (widget.milestoneLabel != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: CultureTheme.cyanTurquoise.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'MARQUANT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.cyanTurquoise,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Bouton "Trésors"
          GestureDetector(
            onTap: () {
              CulturalHaptics.cardRelease();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              context.push('/culture/passport');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Trésors',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: Colors.white,
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
