import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import 'culture_audio_listen_badge.dart';

/// Vue narrative interactive en Motion Design 2D dédiée à l'Épopée de Soundiata Keïta
/// et aux Grands Personnages du Mali.
class SoundiataEpicStoryView extends StatefulWidget {
  final HistoricalFigureDetail figure;
  final bool isDark;

  const SoundiataEpicStoryView({
    super.key,
    required this.figure,
    required this.isDark,
  });

  @override
  State<SoundiataEpicStoryView> createState() => _SoundiataEpicStoryViewState();
}

class _SoundiataEpicStoryViewState extends State<SoundiataEpicStoryView>
    with SingleTickerProviderStateMixin {
  int _selectedChapterIndex = 0;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final item = widget.figure;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final isSoundiata = item.id == 'perso_soundiata';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. STUDIO AUDIO DU GRIOT AVEC VISUALISEUR D'ONDES ────────────────
        _buildGriotAudioStudio(isDark, titleColor, subtitleColor),

        const SizedBox(height: 24),

        // ── 2. RÉSUMÉ HISTORIQUE EN CARTE ÉDITORIALE ÉLÉGANTE ─────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'DESTIN & VISION DU BÂTISSEUR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF59E0B),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.resume,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── 3. PARCHEMIN SACRÉ DE LA CHARTE DE KOUROUKAN FOUGA (1236) ────────
        if (isSoundiata) ...[
          _buildKouroukanFougaParchment(isDark),
          const SizedBox(height: 28),
        ] else if (item.citationHistorique != null) ...[
          _buildHistoricalQuoteBanner(isDark, item.citationHistorique!),
          const SizedBox(height: 24),
        ],

        // ── 4. LES 4 CHAPITRES INTERACTIFS DE L'ÉPOPÉE ───────────────────────
        if (item.chapters.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 20,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Text(
                'L\'Épopée en Récits Vivants',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sélecteur d'onglets de chapitres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(item.chapters.length, (index) {
                final isSelected = _selectedChapterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      CulturalHaptics.tabSwitch();
                      setState(() {
                        _selectedChapterIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF59E0B)
                            : (isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF59E0B)
                              : borderCol,
                        ),
                      ),
                      child: Text(
                        'Chapitre ${index + 1}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.black : subtitleColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          // Carte active du chapitre sélectionné avec animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) {
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              );
            },
            child: _buildChapterCard(
              key: ValueKey('chapter_$_selectedChapterIndex'),
              chapter: item.chapters[_selectedChapterIndex],
              chapterNumber: _selectedChapterIndex + 1,
              isDark: isDark,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
          ),

          const SizedBox(height: 28),
        ],

        // ── 5. REPÈRES & FAITS MARQUANTS CLÉS (GRILLE ELEVATED) ───────────────
        if (item.keyFacts.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.military_tech_rounded,
                size: 20,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Text(
                'Repères Clés & Héritage',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: item.keyFacts.map((fact) {
                  return SizedBox(
                    width: cardWidth,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              fact.icon,
                              size: 18,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            fact.label.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: subtitleColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fact.value,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ],
    );
  }

  // ── STUDIO AUDIO DU GRIOT ──────────────────────────────────────────────────
  Widget _buildGriotAudioStudio(
    bool isDark,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF131D31)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône Micro / Griot avec ondes d'animation
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.record_voice_over_rounded,
                size: 22,
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
                    Text(
                      'Écouter l\'épopée orale',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Visualiseur d'ondes animées
                    const _AnimatedSoundwaveBars(),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Récit conté par la voix du Djéli (Griot)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CultureAudioListenBadge(
            contentId: 'detail_${widget.figure.id}',
            speechText:
                '${widget.figure.name}. ${widget.figure.titleHonorifique}. '
                '${widget.figure.resume}. '
                '${widget.figure.citationHistorique ?? ''}. '
                '${widget.figure.chapters.map((c) => '${c.title} : ${c.content}').join(' ')}',
            label: 'Écouter',
            compact: true,
            activeColor: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  // ── PARCHEMIN SACRÉ DE KOUROUKAN FOUGA (1236) ──────────────────────────────
  Widget _buildKouroukanFougaParchment(bool isDark) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF261507),
                      Color(0xFF1E1005),
                      Color(0xFF2C1808),
                    ]
                  : const [
                      Color(0xFFFFFBEB),
                      Color(0xFFFEF3C7),
                      Color(0xFFFFFBEB),
                    ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'UNESCO • 1236',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CHARTE DE KOUROUKAN FOUGA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF59E0B),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '« Toute vie humaine est une vie. Le tort fait à autrui demande réparation. Respectez l\'étranger, l\'aîné et la femme. »',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: isDark ? const Color(0xFFFEF3C7) : const Color(0xFF78350F),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '— Proclamée par Soundiata Keïta à Kangaba (1236). Première constitution des droits fondamentaux de l\'humanité.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFD4AF37) : const Color(0xFF92400E),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoricalQuoteBanner(bool isDark, String quote) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        quote,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          height: 1.5,
        ),
      ),
    );
  }

  // ── CARTE DU CHAPITRE DÉTAILLÉ ─────────────────────────────────────────────
  Widget _buildChapterCard({
    required Key key,
    required EditorialStoryChapter chapter,
    required int chapterNumber,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$chapterNumber',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  chapter.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            chapter.content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Visualiseur animé d'ondes sonores (Soundwave Equalizer Bars)
class _AnimatedSoundwaveBars extends StatefulWidget {
  const _AnimatedSoundwaveBars();

  @override
  State<_AnimatedSoundwaveBars> createState() => _AnimatedSoundwaveBarsState();
}

class _AnimatedSoundwaveBarsState extends State<_AnimatedSoundwaveBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final t = (_controller.value + index * 0.25) % 1.0;
            final height = 5.0 + 9.0 * math.sin(t * math.pi);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 2.5,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
