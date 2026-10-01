import 'package:alternia/presentation/common/widgets/alternia_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_challenges_data.dart';
import '../../core/datasources/mock_culture_proverbs_data.dart';
import '../../core/datasources/mock_culture_stories_data.dart';
import '../../core/models/culture_challenge_models.dart';
import '../../core/models/culture_proverb_models.dart';
import '../../core/models/culture_story_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';
import '../widgets/culture_share_sheet.dart';
import '../widgets/story_audio_player_sheet.dart';

/// Vue 3 : Jeux & Contes du Mali (Étape 3 — Veillée sous l'arbre à palabres)
/// Univers interactif fusionnant Contes oraux immersifs, Devinettes, Défis et Proverbes
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class CultureJeuxContesView extends ConsumerStatefulWidget {
  const CultureJeuxContesView({super.key});

  @override
  ConsumerState<CultureJeuxContesView> createState() =>
      _CultureJeuxContesViewState();
}

class _CultureJeuxContesViewState extends ConsumerState<CultureJeuxContesView> {
  int _selectedFilterIndex = 0; // 0: Contes, 1: Devinettes, 2: Défis, 3: Proverbes
  final FlutterTts _flutterTts = FlutterTts();
  String? _currentlySpeakingProverbId;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('fr-FR');
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(0.95);
      _flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => _currentlySpeakingProverbId = null);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _toggleSpeakProverb(CultureProverb p) async {
    HapticFeedback.lightImpact();
    if (_currentlySpeakingProverbId == p.id) {
      await _flutterTts.stop();
      setState(() => _currentlySpeakingProverbId = null);
    } else {
      setState(() => _currentlySpeakingProverbId = p.id);
      final text = 'Sagesse du Mali. ${p.text}. Signification : ${p.meaning}';
      await _flutterTts.speak(text);
    }
  }

  static const List<String> _filters = [
    'Contes ',
    'Devinettes ',
    'Défis ',
    'Proverbes ',
  ];

  static const List<IconData> _filterIcons = [
    Icons.auto_stories_rounded,
    Icons.lightbulb_rounded,
    Icons.psychology_rounded,
    Icons.format_quote_rounded,
  ];

  Color _getFilterColor(int index) {
    switch (index) {
      case 0:
        return CultureTheme.accentOrange;
      case 1:
        return CultureTheme.accentOrange;
      case 2:
        return CultureTheme.accentOrange;
      case 3:
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
    final filteredProverbs = MockCultureProverbsData.getFiltered(
      regionId: activeRegion?.id,
    );
    final featuredProverb = MockCultureProverbsData.featuredProverb;

    return CulturalAtmosphereCanvas(
      enableParticles: true,
      enableBogolanMotifs: true,
      motifOpacity: 0.11,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          : index == 2
                              ? MockCultureChallengesData.quizPacks.length
                              : filteredProverbs.length;

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
                                color:
                                    isSelected ? Colors.white : subtitleColor,
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
                }),
              ),
            ),

            const SizedBox(height: 18),

            // ── 2. SOUS-UNIVERS 1 : CONTES & RÉCITS DES VEILLÉES ───────────────
            if (_selectedFilterIndex == 0) ...[

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

            // ── 3. SOUS-UNIVERS 2 : DEVINETTES   ─────────────────────────────
            if (_selectedFilterIndex == 1) ...[
              _buildSectionHeader(
                title: 'DEVINETTES TRADITIONNELLES  ',
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

            // ── 5. SOUS-UNIVERS 4 : PROVERBES & SAGESSES DU MALI ─────────────
            if (_selectedFilterIndex == 3) ...[
              _buildProverbsSection(
                proverbs: filteredProverbs,
                featuredProverb: featuredProverb,
                context: context,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
              const SizedBox(height: 20),
            ],

            // Footer Logo Culture avec "iA" en jaune !
            const Center(
              child: Opacity(
                opacity: 0.5,
                child: AlterniaLogo(
                  size: 24,
                  showText: true,
                  iaColor: CultureTheme.iaYellow,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            // Icône conte minimaliste
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_stories_rounded,
                  size: 20, color: CultureTheme.accentOrange),
            ),
            const SizedBox(width: 12),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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

  // ── 4. LISTE DES DEVINETTES (INTERACTIF & PARTAGEABLE) ──────────────────────
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
                          'FORMULE TRADITIONNELLE',
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
                          // Bouton Partager interactif
                          TextButton.icon(
                            onPressed: () {
                              CultureShareSheet.show(
                                context: context,
                                riddle: riddle,
                              );
                            },
                            icon: const Icon(
                              Icons.share_rounded,
                              size: 13,
                              color: CultureTheme.accentOrange,
                            ),
                            label: Text(
                              'Partager',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: CultureTheme.accentOrange,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Trouver la réponse',
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

  // ── 5. SECTION PROVERBES & SAGESSES DU MALI ─────────────────────────────────
  Widget _buildProverbsSection({
    required List<CultureProverb> proverbs,
    required CultureProverb featuredProverb,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grand Proverbe en Vedette (La Parole du Jour)
        AnimatedCulturalReveal(
          delay: const Duration(milliseconds: 60),
          child: _buildHeroProverbCard(
            proverb: featuredProverb,
            context: context,
            isDark: isDark,
            cardBg: cardBg,
            borderCol: borderCol,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
          ),
        ),
        const SizedBox(height: 24),

        // Section Tous les Proverbes
        _buildSectionHeader(
          title: 'PAROLES DES ANCIENS & SAGESSES',
          icon: Icons.format_quote_rounded,
          color: CultureTheme.accentOrange,
          borderCol: borderCol,
          count: proverbs.length,
        ),
        const SizedBox(height: 14),

        ...proverbs.map((proverb) {
          final index = proverbs.indexOf(proverb);
          return AnimatedCulturalReveal(
            delay: Duration(milliseconds: 50 * index),
            child: _buildProverbRowItem(
              proverb: proverb,
              context: context,
              isDark: isDark,
              cardBg: cardBg,
              borderCol: borderCol,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
          );
        }),
      ],
    );
  }

  // ── 6. CARTE DU GRAND PROVERBE EN VEDETTE (PAROLE DU JOUR) ──────────────────
  Widget _buildHeroProverbCard({
    required CultureProverb proverb,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final isSpeaking = _currentlySpeakingProverbId == proverb.id;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? CultureTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── SCÈNE THÉÂTRALE PANORAMIQUE 16:9 AVEC ACTEUR & FOND ────────────
          SizedBox(
            width: double.infinity,
            height: 190,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    proverb.stageImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF131B2A),
                    ),
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.50),
                  ),

                  // Crochets d'angles soudano-sahéliens
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LocalCornerPainter(
                        color: CultureTheme.accentOrange,
                        strokeWidth: 2.0,
                        cornerSize: 14.0,
                      ),
                    ),
                  ),

                  // Badges supérieurs
                  Positioned(
                    top: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: CultureTheme.accentOrange
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.fireplace_rounded,
                                size: 12,
                                color: CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'PAROLE DU JOUR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: CultureTheme.accentOrange,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: CultureTheme.cyanTurquoise
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            proverb.regionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: CultureTheme.cyanTurquoise,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Texte Bambara original au centre de la scène
                  if (proverb.originalText != null &&
                      proverb.originalText!.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '« ${proverb.originalText} »',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFFB347),
                            shadows: const [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                  // Orateur au bas de la scène
                  Positioned(
                    bottom: 10,
                    left: 14,
                    right: 14,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CultureTheme.accentOrange,
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              proverb.speakerAvatar,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: CultureTheme.accentOrange,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${proverb.speakerName} • ${proverb.speakerRole}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── DÉTAILS & ACTIONS DU GRAND PROVERBE ───────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '« ${proverb.text} »',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  proverb.meaning,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    height: 1.45,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Bouton Écouter (TTS)
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleSpeakProverb(proverb),
                        icon: Icon(
                          isSpeaking
                              ? Icons.volume_up_rounded
                              : Icons.headphones_rounded,
                          size: 16,
                        ),
                        label: Text(
                          isSpeaking ? 'Arrêter' : 'Écouter',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CultureTheme.accentOrange,
                          side: BorderSide(
                            color: CultureTheme.accentOrange
                                .withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Bouton Partager Carte 16:9
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          CultureShareSheet.show(
                            context: context,
                            proverb: proverb,
                          );
                        },
                        icon: const Icon(
                          Icons.share_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Partager la carte',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
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

  // ── 7. ÉLÉMENT LISTE PROVERBE (INTERACTIF & PARTAGEABLE) ───────────────────
  Widget _buildProverbRowItem({
    required CultureProverb proverb,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final isSpeaking = _currentlySpeakingProverbId == proverb.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CulturalInteractiveCard(
        padding: const EdgeInsets.all(16),
        showSudaneseCorners: true,
        activeAccentColor: CultureTheme.accentOrange,
        backgroundColor: cardBg,
        borderRadius: 18,
        onTap: () {
          CultureShareSheet.show(
            context: context,
            proverb: proverb,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne En-tête : Thème, Région, XP et bouton Partager
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    proverb.theme.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: CultureTheme.cyanTurquoise.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    proverb.regionName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: CultureTheme.cyanTurquoise,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${proverb.xpReward} XP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton Partage direct
                GestureDetector(
                  onTap: () {
                    CultureShareSheet.show(
                      context: context,
                      proverb: proverb,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      size: 14,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Citation en langue originale (Bambara...)
            if (proverb.originalText != null &&
                proverb.originalText!.isNotEmpty) ...[
              Text(
                '« ${proverb.originalText} »',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 4),
            ],

            // Proverbe en français
            Text(
              '« ${proverb.text} »',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.35,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 6),

            // Signification & Enseignement
            Text(
              proverb.meaning,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                height: 1.4,
                color: subtitleColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Pied de carte : Orateur & Boutons d'Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundImage: AssetImage(proverb.speakerAvatar),
                      backgroundColor: CultureTheme.accentOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      proverb.speakerName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Bouton Écouter
                    IconButton(
                      onPressed: () => _toggleSpeakProverb(proverb),
                      icon: Icon(
                        isSpeaking
                            ? Icons.volume_up_rounded
                            : Icons.volume_mute_rounded,
                        size: 18,
                        color: isSpeaking
                            ? CultureTheme.cyanTurquoise
                            : CultureTheme.accentOrange,
                      ),
                      tooltip: 'Écouter la parole',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),

                    // Bouton Partager la carte
                    TextButton.icon(
                      onPressed: () {
                        CultureShareSheet.show(
                          context: context,
                          proverb: proverb,
                        );
                      },
                      icon: const Icon(
                        Icons.share_rounded,
                        size: 13,
                        color: CultureTheme.accentOrange,
                      ),
                      label: Text(
                        'Partager la carte',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Peintre de crochets d'angles soudano-sahéliens pour la carte vedette
class _LocalCornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerSize;

  _LocalCornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const pad = 8.0;

    // Haut-Gauche
    canvas.drawLine(
        Offset(pad, pad + cornerSize), const Offset(pad, pad), paint);
    canvas.drawLine(
        const Offset(pad, pad), Offset(pad + cornerSize, pad), paint);

    // Haut-Droite
    canvas.drawLine(Offset(size.width - pad - cornerSize, pad),
        Offset(size.width - pad, pad), paint);
    canvas.drawLine(Offset(size.width - pad, pad),
        Offset(size.width - pad, pad + cornerSize), paint);

    // Bas-Gauche
    canvas.drawLine(Offset(pad, size.height - pad - cornerSize),
        Offset(pad, size.height - pad), paint);
    canvas.drawLine(Offset(pad, size.height - pad),
        Offset(pad + cornerSize, size.height - pad), paint);

    // Bas-Droite
    canvas.drawLine(Offset(size.width - pad - cornerSize, size.height - pad),
        Offset(size.width - pad, size.height - pad), paint);
    canvas.drawLine(Offset(size.width - pad, size.height - pad),
        Offset(size.width - pad, size.height - pad - cornerSize), paint);
  }

  @override
  bool shouldRepaint(_LocalCornerPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      cornerSize != oldDelegate.cornerSize;
}

