import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';

/// Bannière d'invitation à la contribution citoyenne
class ContributionBanner extends StatelessWidget {
  final String regionNom;
  final Color accentColor;
  final VoidCallback onContribute;

  const ContributionBanner({
    super.key,
    required this.regionNom,
    required this.accentColor,
    required this.onContribute,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? CultureTheme.darkSurface : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? CultureTheme.darkBorder : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CultureTheme.ocreTerre.withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                size: 24,
                color: CultureTheme.ocreTerre,
              ),
            ),
            const SizedBox(width: 14),

            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vous connaissez $regionNom ?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Partagez une histoire, une photo ou un souvenir familial.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Bouton Je contribue
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onContribute();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? CultureTheme.darkSurfaceAlt
                    : CultureTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Contribuer',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
