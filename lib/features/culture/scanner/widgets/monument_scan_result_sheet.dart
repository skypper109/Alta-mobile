import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/culture_theme.dart';
import '../models/monument_scan_models.dart';

/// Feuille de résultat immersive après identification certifiée par le Scanner IA
class MonumentScanResultSheet extends StatelessWidget {
  final MonumentScanResult result;
  final bool isAudioPlaying;
  final VoidCallback onToggleAudio;
  final VoidCallback onResetScan;

  const MonumentScanResultSheet({
    super.key,
    required this.result,
    required this.isAudioPlaying,
    required this.onToggleAudio,
    required this.onResetScan,
  });

  @override
  Widget build(BuildContext context) {
    final target = result.target;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final surfaceAlt =
        isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── TIREUR DU SHEET ────────────────────────────────────────────────
            Container(
              width: 44,
              height: 4.5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── BADGE DE CERTITUDE IA ET STATUTS ──────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: CultureTheme.accentOrange
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: CultureTheme.accentOrange
                                  .withValues(alpha: 0.45),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${result.confidencePercent} CERTITUDE IA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: CultureTheme.accentOrange,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderCol),
                          ),
                          child: Text(
                            target.regionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Bouton fermer / nouveau scan
                        IconButton(
                          onPressed: () {
                            if (isAudioPlaying) onToggleAudio();
                            onResetScan();
                          },
                          icon: const Icon(Icons.close_rounded, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: subtitleColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── TITRE ET SUBTITLE DU MONUMENT ─────────────────────────
                    Text(
                      target.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      target.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── HERO PHOTO AVEC BADGE XP PASSEPORT ─────────────────────
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.asset(
                              target.photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(
                                  Icons.museum_rounded,
                                  size: 40,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Badge de tampon passeport débloqué
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: CultureTheme.accentOrange,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.card_membership_rounded,
                                  size: 14,
                                  color: CultureTheme.accentOrange,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Tampon débloqué • +${target.xpEarned} XP',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── LECTEUR AUDIO ORAL DE VIVIENNE (TTS 100% SUR APPAREIL) ────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isAudioPlaying
                            ? CultureTheme.accentOrange.withValues(alpha: 0.12)
                            : surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAudioPlaying
                              ? CultureTheme.accentOrange
                              : borderCol,
                          width: isAudioPlaying ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: onToggleAudio,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: CultureTheme.accentOrange,
                                shape: BoxShape.circle,
                                boxShadow: isAudioPlaying
                                    ? [
                                        BoxShadow(
                                          color: CultureTheme.accentOrange
                                              .withValues(alpha: 0.45),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                isAudioPlaying
                                    ? Icons.stop_rounded
                                    : Icons.volume_up_rounded,
                                size: 26,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        isAudioPlaying
                                            ? 'Vivienne récite l\'histoire...'
                                            : 'Écouter le récit avec Vivienne',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: titleColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: CultureTheme.accentOrange
                                            .withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'TTS Local',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: CultureTheme.accentOrange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isAudioPlaying
                                      ? 'Lecture vocale en cours • Toucher pour couper'
                                      : 'Voix Vivienne 100% hors-ligne sur votre appareil',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── SIGNATURES VISUELLES DÉTECTÉES PAR L'IA ────────────────
                    Text(
                      'SIGNATURES ARCHITECTURALES DÉTECTÉES',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: subtitleColor,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: target.detectionFeatures.map((feat) {
                        return Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 40,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderCol),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                feat.icon,
                                size: 14,
                                color: CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  feat.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: CultureTheme.accentOrange
                                      .withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  feat.confidencePercent,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: CultureTheme.accentOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // ── SECRETS & MYSTÈRES HISTORIQUES INÉDITS ─────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CultureTheme.iaYellow.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CultureTheme.iaYellow.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.key_rounded,
                                size: 18,
                                color: CultureTheme.iaYellow,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SECRETS & MYSTÈRES DU LIEU',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: CultureTheme.iaYellow,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            target.secretsAndMysteries,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: titleColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── ACTIONS RAPIDES & MAILLAGE ─────────────────────────────
                    Row(
                      children: [
                        // Bouton fiche complète
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              if (isAudioPlaying) onToggleAudio();
                              context.push(target.routePath);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CultureTheme.accentOrange,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.menu_book_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Fiche complète',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Bouton Poser une question au sage
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (isAudioPlaying) onToggleAudio();
                            context.push('/culture/sage');
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: surfaceAlt,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderCol),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.smart_toy_rounded,
                                size: 22,
                                color: CultureTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ],
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
