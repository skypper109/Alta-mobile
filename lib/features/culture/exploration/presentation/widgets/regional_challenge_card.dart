import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/regional_challenge.dart';

/// Section gamifiée "À vous de jouer" — Défi culturel régional
class RegionalChallengeCard extends StatelessWidget {
  final RegionalChallenge challenge;
  final Color accentColor;
  final VoidCallback onStartChallenge;

  const RegionalChallengeCard({
    super.key,
    required this.challenge,
    required this.accentColor,
    required this.onStartChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    CultureTheme.darkSurfaceAlt,
                    const Color(0xFF1E1730),
                  ]
                : [
                    const Color(0xFFFFFBEB),
                    const Color(0xFFFEF3C7),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: CultureTheme.orPatrimoine.withValues(alpha: isDark ? 0.40 : 0.60),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: CultureTheme.orPatrimoine.withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rangée supérieure : Badge Gamification + XP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: CultureTheme.orPatrimoine.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CultureTheme.orPatrimoine.withValues(alpha: 0.50),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.military_tech_rounded,
                        size: 16,
                        color: CultureTheme.orPatrimoine,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'DÉFI DE LA RÉGION',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.orPatrimoine,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge +XP
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CultureTheme.orPatrimoine,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${challenge.xpPoints} XP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Titre du défi
            Text(
              challenge.titre,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 6),

            // Description du défi
            Text(
              challenge.description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                height: 1.45,
              ),
            ),

            const SizedBox(height: 16),

            // Bouton Relever le défi
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  onStartChallenge();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CultureTheme.orPatrimoine,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      size: 18,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Relever le défi (${challenge.tempsEstime})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
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
