import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/cultural_guide_models.dart';
import '../../core/theme/culture_theme.dart';

/// Bouton flottant élégant pour accéder au Guide Culturel IA
class FloatingCulturalGuideButton extends StatelessWidget {
  final CulturalGuideContext? contextData;

  const FloatingCulturalGuideButton({super.key, this.contextData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/culture/guide', extra: contextData ?? CulturalGuideContext.general);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: CultureTheme.accentOrange,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: CultureTheme.accentOrange.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Guide IA',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
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
}
