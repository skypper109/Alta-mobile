import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_stories_data.dart';
import '../../core/models/culture_story_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';
import '../widgets/culture_region_bottom_sheet.dart';
import '../widgets/story_audio_player_sheet.dart';

/// Vue 3 : Contes & Récits Interactifs du Mali
/// Immersion culturelle chaleureuse, ambiance de Veillée sous l'arbre à palabres
/// Écoute audio intégrée (Voix du Griot) et lecture interactive
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class CultureContesView extends ConsumerWidget {
  const CultureContesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final activeRegion = filterState.activeRegion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final filteredStories = MockCultureStoriesData.getFiltered(
      regionId: activeRegion?.id,
    );

    // Contes en cours de progression (Continuer)
    final inProgressStories = filteredStories
        .where((s) => s.progress > 0.0 && s.progress < 1.0)
        .toList();

    // Conte à la une
    final featuredStory = filteredStories.firstWhere(
      (s) => s.isFeatured,
      orElse: () => filteredStories.isNotEmpty
          ? filteredStories.first
          : MockCultureStoriesData.stories.first,
    );

    // Autres contes recommandés
    final otherStories =
        filteredStories.where((s) => s.id != featuredStory.id).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 0. BANNIÈRE AMBIANCE VEILLÉE TRADITIONNELLE DU MALI ─────────────
          _buildVeilleeBanner(
            context: context,
            isDark: isDark,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            featuredStory: featuredStory,
          ),
          const SizedBox(height: 20),

          // ── 1. SECTION « CONTINUER L'HISTOIRE » (SI EN COURS) ───────────────
          if (inProgressStories.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 13,
                        color: CultureTheme.accentOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'CONTINUER L\'ÉCOUTE & LECTURE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Container(height: 1, color: borderCol)),
              ],
            ),
            const SizedBox(height: 12),
            ...inProgressStories.map((story) => _buildContinueCard(
                  story: story,
                  context: context,
                  isDark: isDark,
                  cardBg: cardBg,
                  borderCol: borderCol,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                )),
            const SizedBox(height: 24),
          ],

          // ── 2. SECTION « À DÉCOUVRIR » (HERO STORY CARD) ────────────────────
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      size: 13,
                      color: CultureTheme.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CONTE EN VEDETTE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: borderCol)),
            ],
          ),

          const SizedBox(height: 12),

          _buildFeaturedStoryCard(
            story: featuredStory,
            context: context,
            isDark: isDark,
            cardBg: cardBg,
            borderCol: borderCol,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
          ),

          const SizedBox(height: 26),

          // ── 3. SECTION « PAR RÉGION & RECOMMANDATIONS » ─────────────────────
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.library_books_rounded,
                      size: 13,
                      color: CultureTheme.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activeRegion != null
                          ? 'CONTES  : ${activeRegion.nom.toUpperCase()}'
                          : 'RÉCITS ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: borderCol)),
            ],
          ),

          const SizedBox(height: 14),

          if (otherStories.isEmpty && inProgressStories.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.auto_stories_outlined,
                        color: subtitleColor, size: 30),
                    const SizedBox(height: 10),
                    Text(
                      'Aucun autre conte pour cette région',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => CultureRegionBottomSheet.show(context),
                      child: const Text('Explorer tout le Mali'),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: otherStories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final story = otherStories[index];
                return AnimatedCulturalReveal(
                  key: ValueKey('story_${story.id}'),
                  delay: Duration(milliseconds: 40 * (index % 8)),
                  child: _buildStoryRowCard(
                    story: story,
                    context: context,
                    isDark: isDark,
                    cardBg: cardBg,
                    borderCol: borderCol,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── 0. BANNIÈRE VEILLÉE TRADITIONNELLE ────────────────────────────────────
  Widget _buildVeilleeBanner({
    required BuildContext context,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required InteractiveStory featuredStory,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.nightlight_round,
                        size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'VEILLÉE AU CLAIR DE LUNE',
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
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  StoryAudioPlayerSheet.show(context, featuredStory);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.headphones_rounded,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        'Écouter le conte',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
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
          const SizedBox(height: 10),
          Text(
            '« Quand la nuit enveloppe la savane, les enfants s\'assoient au pied du vieux baobab et le Griot ouvre la boîte à mémoires du Manden. »',
            style: GoogleFonts.merriweather(
              fontSize: 12.5,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFFFED7AA) : const Color(0xFF9A3412),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— Formule rituelle des conteurs du fleuve Djoliba',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── CARTE CONTINUER ────────────────────────────────────────────────────────
  Widget _buildContinueCard({
    required InteractiveStory story,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/culture/conte/${story.id}/play');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CultureTheme.accentOrange.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Vignette
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset(
                  story.photoUrl,
                  fit: BoxFit.cover,
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
                        'EN COURS (${(story.progress * 100).toInt()}%)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.accentOrange,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${story.regionName}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
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
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: story.progress,
                      minHeight: 4,
                      backgroundColor:
                          isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          CultureTheme.accentOrange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                StoryAudioPlayerSheet.show(context, story);
              },
              icon: const Icon(Icons.headphones_rounded,
                  color: CultureTheme.accentOrange),
            ),
          ],
        ),
      ),
    );
  }

  // ── GRANDE CARTE FEATURED (À DÉCOUVRIR) ─────────────────────────────────────
  Widget _buildFeaturedStoryCard({
    required InteractiveStory story,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final featuredHeroTag = 'story_featured_${story.id}';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header photographique immersif (Hero)
          SizedBox(
            height: 165,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  story.photoUrl,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withValues(alpha: 0.38),
                ),
                // Badges supérieurs
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 11, color: CultureTheme.accentOrange),
                        const SizedBox(width: 4),
                        Text(
                          story.regionName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      story.tag.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Corps éditorial
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  story.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: CultureTheme.accentOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  story.summary,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: subtitleColor,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Actions doubles : Écouter la veillée + Lire le conte
                Row(
                  children: [
                    // Bouton Écouter le Griot
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          StoryAudioPlayerSheet.show(context, story);
                        },
                        icon: const Icon(Icons.headphones_rounded, size: 16),
                        label: Text(
                          'Écouter (${story.audioDuration})',
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
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Bouton Vivre le conte
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.push('/culture/conte/${story.id}',
                              extra: featuredHeroTag);
                        },
                        icon: const Icon(Icons.auto_stories_rounded,
                            size: 16, color: Colors.white),
                        label: Text(
                          'Lire le conte',
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
                          padding: const EdgeInsets.symmetric(vertical: 11),
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

  // ── LIGNE DE CONTE RECOMMANDÉ ─────────────────────────────────────────────
  Widget _buildStoryRowCard({
    required InteractiveStory story,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final rowHeroTag = 'story_row_${story.id}';

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/culture/conte/${story.id}', extra: rowHeroTag);
      },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vignette authentique (Hero)
            Container(
              width: 82,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.25),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Hero(
                  tag: rowHeroTag,
                  child: Image.asset(
                    story.photoUrl,
                    fit: BoxFit.cover,
                  ),
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
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: CultureTheme.accentOrange
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          story.tag.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 10, color: CultureTheme.accentOrange),
                          const SizedBox(width: 2),
                          Text(
                            story.regionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    story.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    story.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: CultureTheme.accentOrange,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bouton direct d'écoute audio
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          StoryAudioPlayerSheet.show(context, story);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: CultureTheme.accentOrange
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.headphones_rounded,
                                  size: 12,
                                  color: CultureTheme.accentOrange),
                              const SizedBox(width: 4),
                              Text(
                                story.audioDuration,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lire le conte',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CultureTheme.accentOrange,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
                            color: CultureTheme.accentOrange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
