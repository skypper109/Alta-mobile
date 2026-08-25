import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/mali_region.dart';

/// Fiche contextuelle d'aperçu d'une région sélectionnée
class RegionPreviewCard extends StatelessWidget {
  final MaliRegion region;
  final VoidCallback onExplore;
  final VoidCallback onClose;

  const RegionPreviewCard({
    super.key,
    required this.region,
    required this.onExplore,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = region.couleurAccent;

    return GestureDetector(
      onTap: onExplore,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? CultureTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: accent.withValues(alpha: isDark ? 0.45 : 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.25 : 0.15),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // ── En-tête de la fiche avec icône, code région, titre et fermeture ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge d'icône thématique
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accent.withValues(alpha: isDark ? 0.50 : 0.30),
                  ),
                ),
                child: Icon(
                  region.icone,
                  color: accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Titre et sous-titre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          region.nom,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            region.code,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      region.surnom,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Bouton Fermer
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onClose();
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? CultureTheme.darkSurfaceAlt
                        : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Description contextuelle ───────────────────────────────────────
          Text(
            region.descriptionCourte,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              height: 1.45,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),

          // ── Badges des trésors / points forts ──────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: region.pointsForts.take(3).map((tag) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? CultureTheme.darkSurfaceAlt
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? CultureTheme.darkBorder
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 12,
                        color: accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Bouton d'action "Explorer la région" ────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                onExplore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Explorer la région',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
