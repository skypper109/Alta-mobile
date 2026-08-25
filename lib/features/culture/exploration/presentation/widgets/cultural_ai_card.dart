import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';

/// Point d'entrée contextuel vers le guide IA culturel d'Alternia
class CulturalAiCard extends StatelessWidget {
  final String regionId;
  final String regionNom;
  final VoidCallback onAskAi;

  const CulturalAiCard({
    super.key,
    required this.regionId,
    required this.regionNom,
    required this.onAskAi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF314999),
              Color(0xFF1D2E68),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF314999).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône IA
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 26,
                color: CultureTheme.cyanTurquoise,
              ),
            ),
            const SizedBox(width: 14),

            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Une question sur $regionNom ?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Le guide IA d\'Alternia répond à toutes vos curiosités.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Bouton IA
            ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                onAskAi();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CultureTheme.cyanTurquoise,
                foregroundColor: const Color(0xFF090E18),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Guider',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
