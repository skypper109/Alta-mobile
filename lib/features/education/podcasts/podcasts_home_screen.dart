// ─── AlterniA — Podcasts de Révision (Éducation Malienne) ───────────────────
// Révision audio mains libres, conforme à la charte officielle AlterniA,
// sans dégradé et sans sticker, avec narration TTS  intégrée.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import 'podcast_model.dart';
import 'podcast_player_screen.dart';

class PodcastsHomeScreen extends StatefulWidget {
  const PodcastsHomeScreen({super.key});

  @override
  State<PodcastsHomeScreen> createState() => _PodcastsHomeScreenState();
}

class _PodcastsHomeScreenState extends State<PodcastsHomeScreen> {
  String _selectedCategory = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Mathématiques',
    'Physique-Chimie',
    'Histoire-Géo',
    'Philosophie',
    'SVT',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AltaColors.backgroundDark : AltaColors.backgroundLight;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    final filteredPodcasts = _selectedCategory == 'Tous'
        ? PodcastCatalog.podcasts
        : PodcastCatalog.podcasts
            .where((p) =>
                p.subject.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: textPri, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'PODCASTS DE RÉVISION',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AltaColors.secondary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // ── 1. BANNIÈRE HERO SOTRAMA & MAINS LIBRES ─────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AltaColors.primary, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AltaColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.headphones_rounded,
                                  size: 13, color: AltaColors.secondary),
                              const SizedBox(width: 6),
                              Text(
                                'MODE MAINS LIBRES & SOTRAMA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AltaColors.secondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Révision Audio du Programme',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPri,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Les notions clés racontées en 6 minutes par la voix haute fidélité  d\'AlternIA.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: textSec,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AltaColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      size: 36,
                      color: AltaColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 2. FILTRE PAR MATIÈRE ────────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AltaColors.primary
                            : (isDark
                                ? AltaColors.surfaceAltDark
                                : AltaColors.surfaceAltLight),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AltaColors.primary : borderCol,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : textPri,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── 3. LISTE DES COURS AUDIO DISPONIBLES ────────────────────────
            Text(
              'Cours Disponibles au Programme (${filteredPodcasts.length})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            const SizedBox(height: 12),

            ...filteredPodcasts.map((podcast) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  children: [
                    // Pochette matière sobre
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AltaColors.surfaceAltDark
                            : AltaColors.surfaceAltLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AltaColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Icon(podcast.icon,
                          color: AltaColors.primary, size: 28),
                    ),
                    const SizedBox(width: 14),

                    // Infos podcast
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AltaColors.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  podcast.subject.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AltaColors.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                podcast.classLevel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: textSec,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${podcast.durationMinutes} min',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textSec,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            podcast.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            podcast.summary,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: textSec,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Bouton Écouter
                    IconButton(
                      icon:
                          const Icon(Icons.play_circle_fill_rounded, size: 36),
                      color: AltaColors.accent,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PodcastPlayerScreen(podcast: podcast),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
