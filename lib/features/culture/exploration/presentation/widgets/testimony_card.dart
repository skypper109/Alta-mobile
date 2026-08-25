import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/region_testimony.dart';

/// Carte de récit et témoignage de la mémoire vivante
class TestimonyCard extends StatelessWidget {
  final RegionTestimony testimony;
  final Color accentColor;
  final bool isPlaying;
  final VoidCallback onTogglePlay;

  const TestimonyCard({
    super.key,
    required this.testimony,
    required this.accentColor,
    required this.isPlaying,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? CultureTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPlaying
              ? CultureTheme.orPatrimoine
              : (isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder),
          width: isPlaying ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPlaying ? CultureTheme.orPatrimoine : Colors.black)
                .withValues(alpha: isPlaying ? (isDark ? 0.25 : 0.15) : (isDark ? 0.20 : 0.04)),
            blurRadius: isPlaying ? 18 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : Conteur, Qualité & Durée
          Row(
            children: [
              // Avatar stylisé du conteur
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      CultureTheme.orPatrimoine,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    testimony.conteur.isNotEmpty
                        ? testimony.conteur[0].toUpperCase()
                        : 'C',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nom & Qualité du conteur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimony.conteur,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      testimony.qualiteConteur,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Badge Durée
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? CultureTheme.darkSurfaceAlt
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      testimony.duree,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Titre de l'histoire
          Text(
            testimony.titreHistoire,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 6),

          // Extrait de témoignage
          Text(
            testimony.extrait,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 14),

          // Barre d'écoute interactive
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onTogglePlay();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isPlaying
                    ? CultureTheme.orPatrimoine.withValues(alpha: 0.15)
                    : (isDark
                        ? CultureTheme.darkSurfaceAlt
                        : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPlaying
                      ? CultureTheme.orPatrimoine
                      : (isDark
                          ? CultureTheme.darkBorder
                          : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? CultureTheme.orPatrimoine
                          : accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isPlaying
                          ? 'En écoute... (Récit oral transmis)'
                          : 'Écouter le récit oral',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPlaying
                            ? CultureTheme.orPatrimoine
                            : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                    ),
                  ),
                  if (isPlaying)
                    Row(
                      children: List.generate(4, (i) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 3,
                          height: 8.0 + (i % 3) * 6.0,
                          decoration: BoxDecoration(
                            color: CultureTheme.orPatrimoine,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
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
