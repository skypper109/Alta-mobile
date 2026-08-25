import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';

/// En-tête immersif pour l'écran "Explorer le Mali"
class CultureExplorationHeader extends StatelessWidget {
  final VoidCallback onBack;
  final int totalRegionsCount;

  const CultureExplorationHeader({
    super.key,
    required this.onBack,
    required this.totalRegionsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Rangée supérieure : Bouton retour + Badge Univers Culture ────────
          Row(
            children: [
              // Bouton Retour
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onBack();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? CultureTheme.darkSurface : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : CultureTheme.primaryBlue)
                            .withValues(alpha: isDark ? 0.30 : 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: isDark ? Colors.white : CultureTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Badge Univers Culture
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CultureTheme.ocreTerre.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CultureTheme.ocreTerre.withValues(alpha: isDark ? 0.50 : 0.30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.public_rounded,
                      size: 14,
                      color: CultureTheme.ocreTerre,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'UNIVERS CULTURE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.ocreTerre,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Compteur de régions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? CultureTheme.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
                  ),
                ),
                child: Text(
                  '$totalRegionsCount Régions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? CultureTheme.cyanTurquoise : CultureTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Titre Principal ────────────────────────────────────────────────
          Text(
            'Explorer le Mali',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),

          // ── Sous-titre évocateur ───────────────────────────────────────────
          Text(
            'Découvrez les histoires, les patrimoines et les trésors de chaque région.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
