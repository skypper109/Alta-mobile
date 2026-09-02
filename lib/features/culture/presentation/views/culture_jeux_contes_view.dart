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
import '../widgets/story_audio_player_sheet.dart';

/// Vue 3 : Jeux & Contes du Mali
/// Univers interactif fusionnant Contes immersifs, Défis, Devinettes N'Da, Quiz et Guide IA
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class CultureJeuxContesView extends ConsumerStatefulWidget {
  const CultureJeuxContesView({super.key});

  @override
  ConsumerState<CultureJeuxContesView> createState() =>
      _CultureJeuxContesViewState();
}

class _CultureJeuxContesViewState extends ConsumerState<CultureJeuxContesView> {
  int _selectedFilterIndex = 0; // 0: Tout, 1: Contes, 2: Défis & Quiz, 3: Devinettes N'Da

  static const List<String> _filters = [
    'Tout l\'univers',
    'Contes & Récits',
    'Défis & Quiz',
    'Devinettes N\'Da',
  ];

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
    final dailyChallenge = MockCultureChallengesData.dailyChallenge;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. SÉLECTEUR DE SOUS-UNIVERS PLEINE LARGEUR RESPONSIVE ───────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
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
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CultureTheme.rougeKoulikoro
                            : (isDark
                                ? CultureTheme.darkSurface
                                : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? CultureTheme.rougeKoulikoro
                              : borderCol,
                        ),
                      ),
                      child: Text(
                        _filters[index],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : subtitleColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // ── 2. HERO VEDETTE INTERACTIF ─────────────────────────────────────
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
            _buildHeroStoryCard(
              story: featuredStory,
              context: context,
              isDark: isDark,
              cardBg: cardBg,
              borderCol: borderCol,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
            const SizedBox(height: 24),
          ] else if (_selectedFilterIndex == 2 || _selectedFilterIndex == 3) ...[
            _buildDailyChallengeCard(
              context: context,
              challenge: dailyChallenge,
              isDark: isDark,
              cardBg: cardBg,
              borderCol: borderCol,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
            const SizedBox(height: 24),
          ],

          // ── 3. SECTION CONTES & RÉCITS DU MALI ──────────────────────────────
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
            _buildSectionHeader(
              title: 'CONTES & RÉCITS TRADITIONNELS',
              icon: Icons.auto_stories_rounded,
              color: CultureTheme.rougeKoulikoro,
              borderCol: borderCol,
            ),
            const SizedBox(height: 14),
            ...filteredStories.take(3).map((story) => _buildStoryRowItem(
                  story: story,
                  context: context,
                  isDark: isDark,
                  cardBg: cardBg,
                  borderCol: borderCol,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                )),
            const SizedBox(height: 28),
          ],

          // ── 6. SECTION DÉFIS CULTURELS & QUIZ ───────────────────────────────
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) ...[
            _buildSectionHeader(
              title: 'DÉFIS & QUIZ DU SAVOIR',
              icon: Icons.psychology_rounded,
              color: CultureTheme.primaryBlue,
              borderCol: borderCol,
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
            const SizedBox(height: 28),
          ],

          // ── 7. SECTION DEVINETTES TRADITIONNELLES N'DA ──────────────────────
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 3) ...[
            _buildSectionHeader(
              title: 'DEVINETTES TRADITIONNELLES (N\'DA)',
              icon: Icons.lightbulb_rounded,
              color: CultureTheme.accentOrange,
              borderCol: borderCol,
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
        ],
      ),
    );
  }

  // ── EN-TÊTE DE SECTION ──────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required Color borderCol,
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
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: borderCol)),
      ],
    );
  }

  // ── 1. HERO STORY CARD (SANS DÉGRADÉ) ───────────────────────────────────────
  Widget _buildHeroStoryCard({
    required InteractiveStory story,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: 0.4),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
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
                  color: Colors.black.withValues(alpha: 0.45),
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
                              'CONTE EN VEDETTE',
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
                          foregroundColor: CultureTheme.primaryBlue,
                          side: BorderSide(
                            color:
                                CultureTheme.primaryBlue.withValues(alpha: 0.5),
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
                            '/culture/conte-interactif/${story.id}',
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

  // ── 2. CARTE DÉFI DU JOUR ───────────────────────────────────────────────────
  Widget _buildDailyChallengeCard({
    required BuildContext context,
    required TraditionalRiddle challenge,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CultureTheme.cyanTurquoise.withValues(alpha: 0.4),
          width: 1.4,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.cyanTurquoise.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'DÉFI DU JOUR',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: CultureTheme.cyanTurquoise,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${challenge.xpReward} XP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: CultureTheme.accentOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            challenge.formulaIntro,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            challenge.category,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CultureTheme.cyanTurquoise,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.riddleText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: subtitleColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/culture/quiz/quiz_empires');
              },
              icon: const Icon(Icons.play_arrow_rounded,
                  size: 18, color: Colors.white),
              label: Text(
                'Relever le défi maintenant',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CultureTheme.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. ÉLÉMENT LISTE CONTE ──────────────────────────────────────────────────
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          // Vignette photo réelle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: story.photoUrl.isNotEmpty
                  ? Image.asset(
                      story.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: CultureTheme.rougeKoulikoro
                            .withValues(alpha: 0.15),
                        child: const Icon(Icons.auto_stories_rounded,
                            size: 24, color: CultureTheme.rougeKoulikoro),
                      ),
                    )
                  : Container(
                      color:
                          CultureTheme.rougeKoulikoro.withValues(alpha: 0.15),
                      child: const Icon(Icons.auto_stories_rounded,
                          size: 24, color: CultureTheme.rougeKoulikoro),
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
                            CultureTheme.rougeKoulikoro.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        story.regionName.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.rougeKoulikoro,
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
              context.push('/culture/conte/${story.id}', extra: story);
            },
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: CultureTheme.accentOrange,
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. GRILLE DE QUIZ DU SAVOIR ────────────────────────────────────────────
  Widget _buildQuizGrid({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final quizzes = [
      {
        'id': 'quiz_empires',
        'title': 'Les Grands Empires du Mali',
        'desc': 'Sundiata, Kouroukan Fouga & Mansa Moussa',
        'questions': '10 questions',
        'xp': '+120 XP',
        'color': CultureTheme.primaryBlue,
        'icon': Icons.account_balance_rounded,
      },
      {
        'id': 'quiz_monuments',
        'title': 'Monuments & Architecture Banco',
        'desc': 'Djenné, Tombouctou & Askia',
        'questions': '8 questions',
        'xp': '+100 XP',
        'color': CultureTheme.accentOrange,
        'icon': Icons.museum_rounded,
      },
    ];

    return Column(
      children: quizzes.map((quiz) {
        final color = quiz['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    quiz['icon'] as IconData,
                    color: color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz['title'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quiz['desc'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          quiz['questions'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          quiz['xp'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/culture/quiz/${quiz['id']}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Jouer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── 6. LISTE DES DEVINETTES N'DA ────────────────────────────────────────────
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
      children: riddles.take(3).map((riddle) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: CultureTheme.cyanTurquoise.withValues(alpha: 0.12),
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
              const SizedBox(height: 8),
              Text(
                '« ${riddle.riddleText} »',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 10),
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
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/culture/devinette/${riddle.id}',
                          extra: riddle);
                    },
                    child: Row(
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
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
