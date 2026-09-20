import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_challenges_data.dart';
import '../../core/datasources/mock_culture_stories_data.dart';
import '../../core/models/culture_challenge_models.dart';
import '../../core/models/culture_story_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../../../presentation/common/widgets/alternia_logo.dart';
import '../../immersive/immersive.dart';
import '../widgets/story_audio_player_sheet.dart';

/// Vue 3 : Jeux & Contes du Mali (Étape 3 — Veillée sous l'arbre à palabres)
/// Univers interactif fusionnant Contes oraux immersifs, Devinettes N'Da et Défis du Savoir
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class CultureJeuxContesView extends ConsumerStatefulWidget {
  const CultureJeuxContesView({super.key});

  @override
  ConsumerState<CultureJeuxContesView> createState() =>
      _CultureJeuxContesViewState();
}

class _CultureJeuxContesViewState extends ConsumerState<CultureJeuxContesView> {
  int _selectedFilterIndex = 0; // 0: Contes, 1: Devinettes, 2: Défis

  static const List<String> _filters = [
    'Contes ',
    'Devinettes ',
    'Défis ',
  ];

  static const List<IconData> _filterIcons = [
    Icons.auto_stories_rounded,
    Icons.lightbulb_rounded,
    Icons.psychology_rounded,
  ];

  Color _getFilterColor(int index) {
    switch (index) {
      case 0:
        return CultureTheme.accentOrange;
      case 1:
        return CultureTheme.accentOrange;
      case 2:
        return CultureTheme.accentOrange;
      default:
        return CultureTheme.accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final activeRegion = filterState.activeRegion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    // Données filtrées par région
    final filteredStories = MockCultureStoriesData.getFiltered(
      regionId: activeRegion?.id,
    );
    final filteredRiddles = MockCultureChallengesData.getFilteredRiddles(
      regionId: activeRegion?.id,
    );
    final featuredStory = filteredStories.firstWhere(
      (s) => s.isFeatured,
      orElse: () => filteredStories.isNotEmpty
          ? filteredStories.first
          : MockCultureStoriesData.stories.first,
    );

    return CulturalAtmosphereCanvas(
      enableParticles: true,
      enableBogolanMotifs: true,
      motifOpacity: 0.11,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
           children: [
            // ── L'ÉPREUVE ÉCLAIR DU CRÉPUSCULE ───────────────────────────────
            const AnimatedCulturalReveal(
              delay: Duration(milliseconds: 60),
              child: CulturalSpeedTrialWidget(),
            ),

            const SizedBox(height: 20),

            // ── 1. SÉLECTEUR D'UNIVERS INTERACTIF ──────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  final activeCol = _getFilterColor(index);
                  final int count = index == 0
                      ? filteredStories.length
                      : index == 1
                          ? filteredRiddles.length
                          : MockCultureChallengesData.quizPacks.length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeCol
                              : (isDark
                                  ? CultureTheme.darkSurface
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? activeCol : borderCol,
                            width: isSelected ? 1.4 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _filterIcons[index],
                              size: 14,
                              color: isSelected ? Colors.white : activeCol,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _filters[index],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : subtitleColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : activeCol.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : activeCol,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  ]
        }),
      ),
    ),

          const SizedBox(height: 18),

          // ── 2. SOUS-UNIVERS 1 : CONTES & RÉCITS DES VEILLÉES ───────────────
          if (_selectedFilterIndex == 0) ...[
            // Grand Conte en Vedette
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 80),
              child: _buildHeroStoryCard(
                story: featuredStory,
                context: context,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
            ),
            const SizedBox(height: 24),

            // Section Tous les Contes
            _buildSectionHeader(
              title: 'TOUS LES CONTES & RÉCITS',
              icon: Icons.auto_stories_rounded,
              color: CultureTheme.accentOrange,
              borderCol: borderCol,
              count: filteredStories.length,
            ),
            const SizedBox(height: 14),

            ...filteredStories.map((story) {
              final index = filteredStories.indexOf(story);
              return AnimatedCulturalReveal(
                delay: Duration(milliseconds: 60 * index),
                child: _buildStoryRowItem(
                  story: story,
                  context: context,
                  isDark: isDark,
                  cardBg: cardBg,
                  borderCol: borderCol,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                ),
              );
            }),
            const SizedBox(height: 20),
          ],

          // ── 3. SOUS-UNIVERS 2 : DEVINETTES N'DA ─────────────────────────────
          if (_selectedFilterIndex == 1) ...[
            _buildSectionHeader(
              title: 'DEVINETTES TRADITIONNELLES N\'DA',
              icon: Icons.lightbulb_rounded,
              color: CultureTheme.accentOrange,
              borderCol: borderCol,
              count: filteredRiddles.length,
            ),
            const SizedBox(height: 14),
            _buildRiddlesList(
              riddles: filteredRiddles,
              context: context,
              isDark: isDark,
              cardBg: cardBg,
              borderCol: borderCol,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
            const SizedBox(height: 20),
          ],

            // ── 4. SOUS-UNIVERS 3 : DÉFIS CULTURELS & QUIZ ─────────────────────
            if (_selectedFilterIndex == 2) ...[
              // Défi en Vedette
              AnimatedCulturalReveal(
                delay: const Duration(milliseconds: 60),
                child: _buildFeaturedChallengeCard(
                  context: context,
                  isDark: isDark,
                  cardBg: cardBg,
                  borderCol: borderCol,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                ),
              ),
              const SizedBox(height: 22),

              _buildSectionHeader(
                title: 'TOUS LES QUIZ DU SAVOIR',
                icon: Icons.psychology_rounded,
                color: CultureTheme.primaryBlue,
                borderCol: borderCol,
                count: MockCultureChallengesData.quizPacks.length,
              ),
              const SizedBox(height: 14),
              _buildQuizGrid(
                context: context,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
              const SizedBox(height: 20),
            ],
        ],
        ),
      ),
    );
  }

  // ── EN-TÊTE DE SECTION AVEC COMPTEUR ────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required Color borderCol,
    int? count,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: color,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 5),
                Text(
                  '($count)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: borderCol)),
      ],
    );
  }

  // ── 1. CARTE VEDETTE CONTE SOUS L'ARBRE (INTERACTIVE) ──────────────────────
  Widget _buildHeroStoryCard({
    required InteractiveStory story,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return CulturalInteractiveCard(
      padding: EdgeInsets.zero,
      showSudaneseCorners: true,
      activeAccentColor: CultureTheme.accentOrange,
      backgroundColor: cardBg,
      borderRadius: 22,
      onTap: () {
        context.push(
          '/culture/conte/${story.id}/play',
          extra: story,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image photographique réelle
          SizedBox(
            height: 145,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (story.photoUrl.isNotEmpty)
                  Image.asset(
                    story.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: CultureTheme.primaryDark,
                      child: const Center(
                        child: Icon(Icons.auto_stories_rounded,
                            size: 40, color: Colors.white54),
                      ),
                    ),
                  )
                else
                  Container(color: CultureTheme.primaryDark),

                // Overlay sombre uni pour contraste texte
                Container(
                  color: Colors.black.withValues(alpha: 0.40),
                ),

                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: CultureTheme.accentOrange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'VEILLÉE SOUS L\'ARBRE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 11,
                                  color: CultureTheme.accentOrange,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  story.regionName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${story.readingDuration} • ${story.origin}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Corps descriptif et actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  story.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CultureTheme.accentOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  story.summary,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: subtitleColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Bouton Écouter
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          StoryAudioPlayerSheet.show(context, story);
                        },
                        icon: const Icon(Icons.headphones_rounded, size: 16),
                        label: Text(
                          'Écouter',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CultureTheme.accentOrange,
                          side: BorderSide(
                            color:
                                CultureTheme.accentOrange.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Bouton Jouer / Lire
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.push(
                            '/culture/conte/${story.id}/play',
                            extra: story,
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded,
                            size: 18, color: Colors.white),
                        label: Text(
                          'Explorer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CultureTheme.accentOrange,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. ÉLÉMENT LISTE CONTE (INTERACTIF) ────────────────────────────────────
  Widget _buildStoryRowItem({
    required InteractiveStory story,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CulturalInteractiveCard(
        padding: const EdgeInsets.all(12),
        showSudaneseCorners: false,
        activeAccentColor: CultureTheme.accentOrange,
        backgroundColor: cardBg,
        borderRadius: 18,
        onTap: () {
          context.push('/culture/conte/${story.id}', extra: story);
        },
        child: Row(
          children: [
            // Vignette photo réelle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: story.photoUrl.isNotEmpty
                    ? Image.asset(
                        story.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: CultureTheme.accentOrange
                              .withValues(alpha: 0.15),
                          child: const Icon(Icons.auto_stories_rounded,
                              size: 24, color: CultureTheme.accentOrange),
                        ),
                      )
                    : Container(
                        color:
                            CultureTheme.accentOrange.withValues(alpha: 0.15),
                        child: const Icon(Icons.auto_stories_rounded,
                            size: 24, color: CultureTheme.accentOrange),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              CultureTheme.accentOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          story.regionName.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        story.readingDuration,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    story.moral,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                StoryAudioPlayerSheet.show(context, story);
              },
              icon: const Icon(
                Icons.headphones_rounded,
                size: 20,
                color: CultureTheme.accentOrange,
              ),
              tooltip: 'Écouter le conte',
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: CultureTheme.accentOrange,
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. CARTE DU GRAND DÉFI EN VEDETTE ─────────────────────────────────────
  Widget _buildFeaturedChallengeCard({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final featuredPack = MockCultureChallengesData.quizPacks.first;

    return CulturalInteractiveCard(
      padding: EdgeInsets.zero,
      showSudaneseCorners: false,
      activeAccentColor: CultureTheme.accentOrange,
      backgroundColor: cardBg,
      borderRadius: 22,
      onTap: () {
        context.push('/culture/quiz/${featuredPack.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visuel authentique du Défi
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: 145,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    featuredPack.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: CultureTheme.primaryBlue,
                      child: const Center(
                        child: Icon(Icons.account_balance_rounded,
                            color: Colors.white, size: 40),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.40),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.5, vertical: 4),
                      decoration: BoxDecoration(
                        color: CultureTheme.accentOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'DÉFI DU SAVOIR EN VEDETTE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          featuredPack.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          featuredPack.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pied de carte avec statistiques et action
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${featuredPack.xpReward} XP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${featuredPack.questionsCount} questions • ~${featuredPack.timeMinutes} min',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: CultureTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Relever le défi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: Colors.white),
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

  // ── 4. GRILLE DE QUIZ DU SAVOIR (INTERACTIF) ───────────────────────────────
  Widget _buildQuizGrid({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final packs = MockCultureChallengesData.quizPacks;

    return Column(
      children: packs.map((pack) {
        final color = pack.themeColor;
        final quizId = pack.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderCol, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      pack.icon,
                      color: color,
                      size: 24,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              pack.category.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pack.regionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pack.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pack.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            '${pack.questionsCount} questions',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ~${pack.timeMinutes} min',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: CultureTheme.accentOrange
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '+${pack.xpReward} XP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: CultureTheme.accentOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_circle_fill_rounded,
                  size: 28,
                  color: color,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── 4. LISTE DES DEVINETTES N'DA (INTERACTIF) ───────────────────────────────
  Widget _buildRiddlesList({
    required List<TraditionalRiddle> riddles,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Column(
      children: riddles.map((riddle) {
        final index = riddles.indexOf(riddle);
        return AnimatedCulturalReveal(
          delay: Duration(milliseconds: 60 * index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: CulturalInteractiveCard(
              padding: const EdgeInsets.all(16),
              showSudaneseCorners: true,
              activeAccentColor: CultureTheme.accentOrange,
              backgroundColor: cardBg,
              borderRadius: 18,
              onTap: () {
                context.push('/culture/devinette/${riddle.id}', extra: riddle);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color:
                              CultureTheme.accentOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: CultureTheme.accentOrange
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'FORMULE N\'DA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: CultureTheme.cyanTurquoise
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${riddle.xpReward} XP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.cyanTurquoise,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '« ${riddle.riddleText} »',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        riddle.regionName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Trouver la réponse (N\'Gana)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: CultureTheme.accentOrange,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: CultureTheme.accentOrange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Modèle pour les proverbes traditionnels du Mali
class _MalianProverb {
  final String id;
  final String text;
  final String? originalText;
  final String meaning;
  final String origin;
  final String theme;
  final String? regionId;
  final String regionName;

  const _MalianProverb({
    required this.id,
    required this.text,
    this.originalText,
    required this.meaning,
    required this.origin,
    required this.theme,
    this.regionId,
    required this.regionName,
  });
}

/// Données authentiques de proverbes et sagesses du Mali
const List<_MalianProverb> _malianProverbs = [
  _MalianProverb(
    id: 'prov_humilite',
    text: "L'eau chaude n'oublie jamais qu'elle a été froide.",
    originalText: "Ji kalan tɛ ɲina a nɛnɛ kɔ.",
    meaning:
        "Peu importe ton ascension ou ta réussite, n'oublie jamais d'où tu viens et garde l'humilité.",
    origin: "Tradition Bamanan (Manden)",
    theme: "Humilité",
    regionId: "koulikoro",
    regionName: "Koulikoro / Manden",
  ),
  _MalianProverb(
    id: 'prov_sagesse_vieillesse',
    text: "Ce qu'un vieillard voit assis, un jeune homme debout ne peut l'apercevoir.",
    originalText: "Kɔrɔkɛ sigilen fɛn min ye, kamalen lɔnin t'o ye.",
    meaning:
        "L'expérience et la sagesse acquises avec le temps surpassent la seule vivacité ou la fougue de la jeunesse.",
    origin: "Tradition Bamanan (Ségou)",
    theme: "Sagesse & Respect",
    regionId: "segou",
    regionName: "Ségou",
  ),
  _MalianProverb(
    id: 'prov_solidarite',
    text: "Une seule main ne peut pas ramasser la farine.",
    originalText: "Bolo kelen tɛ mugu ta.",
    meaning:
        "L'union et l'entraide communautaire sont indispensables pour accomplir de grandes œuvres.",
    origin: "Sagesse Populaire & Dogon",
    theme: "Solidarité",
    regionId: "mopti",
    regionName: "Mopti / Pays Dogon",
  ),
  _MalianProverb(
    id: 'prov_savoir_tombouctou',
    text: "L'encre de l'écolier est plus précieuse que le sang du martyr.",
    originalText: "Al-’ilmu nūr (Le savoir est lumière)",
    meaning:
        "La quête du savoir, la préservation des manuscrits et la tolérance sont les plus hautes vertus de la cité savante.",
    origin: "Tradition des Sages de Tombouctou",
    theme: "Savoir & Éducation",
    regionId: "tombouctou",
    regionName: "Tombouctou",
  ),
  _MalianProverb(
    id: 'prov_verite_nature',
    text: "Même si la bûche séjourne cent ans dans l'eau, elle ne deviendra jamais un crocodile.",
    originalText: "Jiri koro men ji la cogo o cogo, a tɛ kɛ bama ye.",
    meaning:
        "Chacun doit assumer sa vraie nature et ses racines, nul ne peut masquer son identité profonde.",
    origin: "Tradition Sénoufo / Kénédougou",
    theme: "Vérité & Identité",
    regionId: "sikasso",
    regionName: "Sikasso",
  ),
  _MalianProverb(
    id: 'prov_racines',
    text: "L'arbre qui s'élève vers le ciel doit la vigueur de ses branches à la profondeur de ses racines.",
    originalText: "Yiri janya be bɔ a dugukolo jukɔrɔ.",
    meaning:
        "La prospérité d'un être humain repose sur son attachement à son terroir, à sa mémoire et à ses aïeux.",
    origin: "Tradition Khassonké / Soninké",
    theme: "Racines",
    regionId: "kayes",
    regionName: "Kayes",
  ),
  _MalianProverb(
    id: 'prov_patience_unite',
    text: "Si tu veux aller vite, marche seul ; mais si tu veux aller loin, marchons ensemble.",
    originalText: "A borey kulu ga bindi (Ensemble nous avançons)",
    meaning:
        "La concertation et le cheminement collectif garantissent un avenir stable et pérenne pour la communauté.",
    origin: "Tradition Songhaï & Sahélienne",
    theme: "Patience & Unité",
    regionId: "gao",
    regionName: "Gao",
  ),
  _MalianProverb(
    id: 'prov_parole_donnee',
    text: "La parole est comme l'eau : une fois versée à terre, nul ne peut la ramasser.",
    originalText: "Kuma ye ji ye, n'a bɔra a tɛ se ka sɔrɔ tuguni.",
    meaning:
        "La parole donnée engage l'honneur et la dignité humaine ; il convient de mesurer chaque parole prononcée.",
    origin: "Parole des Griots & Anciens",
    theme: "Honneur & Tempérance",
    regionId: null,
    regionName: "Tout le Mali",
  ),
];

