import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/heritage_item.dart';

/// Carte de patrimoine matériel et architectural
class HeritageCard extends StatelessWidget {
  final HeritageItem heritage;
  final Color accentColor;
  final VoidCallback onExplore;

  const HeritageCard({
    super.key,
    required this.heritage,
    required this.accentColor,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? CultureTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : CultureTheme.primaryBlue)
                .withValues(alpha: isDark ? 0.30 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête visuelle avec bannière stylisée et badges
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: isDark ? 0.70 : 0.60),
                  isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFE2E8F0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
            ),
            child: Stack(
              children: [
                // Icône en filigrane
                Positioned(
                  right: 16,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.18,
                    child: Icon(
                      Icons.account_balance_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Badges en haut à gauche
                Positioned(
                  top: 14,
                  left: 14,
                  child: Row(
                    children: [
                      if (heritage.estUnesco) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: CultureTheme.cyanTurquoise,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PATRIMOINE UNESCO',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          heritage.categorie,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenu textuel et action
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom du monument
                Text(
                  heritage.nom,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),

                // Époque / Localisation
                if (heritage.epoque != null || heritage.localisation != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (heritage.epoque != null) ...[
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 13,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          heritage.epoque!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (heritage.localisation != null) ...[
                        Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            heritage.localisation!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                const SizedBox(height: 10),

                // Description
                Text(
                  heritage.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Bouton Explorer le patrimoine
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onExplore();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Explorer le patrimoine',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
