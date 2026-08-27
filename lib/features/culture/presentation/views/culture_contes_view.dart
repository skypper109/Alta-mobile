import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_stories_data.dart';
import '../../core/models/culture_story_models.dart';
import '../../core/theme/culture_theme.dart';
import '../widgets/culture_region_bottom_sheet.dart';
import '../widgets/region_filter_pill.dart';

/// Vue 3 : Contes & Récits Interactifs du Mali
/// Immersion culturelle chaleureuse, épurée et authentique
class CultureContesView extends ConsumerWidget {
  const CultureContesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final activeRegion = filterState.activeRegion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final filteredStories = MockCultureStoriesData.getFiltered(
      regionId: activeRegion?.id,
    );

    // Contes en cours de progression (Continuer)
    final inProgressStories =
        filteredStories.where((s) => s.progress > 0.0 && s.progress < 1.0).toList();

    // Conte à la une
    final featuredStory = filteredStories.firstWhere(
      (s) => s.isFeatured,
      orElse: () => filteredStories.isNotEmpty ? filteredStories.first : MockCultureStoriesData.stories.first,
    );

    // Autres contes recommandés
    final otherStories = filteredStories.where((s) => s.id != featuredStory.id).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. FILTRE RÉGIONAL TRANSVERSAL ──────────────────────────────────
          Row(
            children: [
              const RegionFilterPill(),
              const Spacer(),
              if (filterState.hasActiveFilter)
                GestureDetector(
                  onTap: () => ref.read(activeCultureRegionProvider.notifier).clearFilter(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${filteredStories.length} conte${filteredStories.length > 1 ? 's' : ''}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: CultureTheme.rougeKoulikoro,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.close_rounded, size: 12, color: CultureTheme.rougeKoulikoro),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // ── 2. SECTION « CONTINUER L'HISTOIRE » (SI EN COURS) ───────────────
          if (inProgressStories.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 13,
                        color: CultureTheme.rougeKoulikoro,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'CONTINUER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: CultureTheme.rougeKoulikoro,
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

          // ── 3. SECTION « À DÉCOUVRIR » (HERO STORY CARD) ────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      'À DÉCOUVRIR',
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

          // ── 4. SECTION « PAR RÉGION & RECOMMANDATIONS » ─────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.library_books_rounded,
                      size: 13,
                      color: CultureTheme.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activeRegion != null
                          ? 'RÉCITS : ${activeRegion.nom.toUpperCase()}'
                          : 'RÉCITS & LÉGENDES DU MALI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: CultureTheme.primaryBlue,
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
                    Icon(Icons.auto_stories_outlined, color: subtitleColor, size: 30),
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
                return _buildStoryRowCard(
                  story: story,
                  context: context,
                  isDark: isDark,
                  cardBg: cardBg,
                  borderCol: borderCol,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                );
              },
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
            color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.35),
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
                  color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.3),
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
                          color: CultureTheme.rougeKoulikoro,
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
                      backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(CultureTheme.rougeKoulikoro),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CultureTheme.rougeKoulikoro,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/culture/conte/${story.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header photographique immersif
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
                  // Dégradé assombrissant pour lisibilité
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x99000000),
                            Colors.transparent,
                            Color(0x80000000),
                          ],
                          stops: [0.0, 0.45, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Badges supérieurs
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 11, color: CultureTheme.accentOrange),
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
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: CultureTheme.rougeKoulikoro,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
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
                      color: CultureTheme.rougeKoulikoro,
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
                  const SizedBox(height: 14),

                  // Pied de carte : Narrateur + CTA
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderCol),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.headphones_rounded, size: 12, color: subtitleColor),
                            const SizedBox(width: 5),
                            Text(
                              story.audioDuration,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: CultureTheme.rougeKoulikoro,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Vivre le conte',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
                          ],
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/culture/conte/${story.id}');
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
            // Vignette authentique
            Container(
              width: 82,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.25),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          story.tag.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.rougeKoulikoro,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 10, color: CultureTheme.accentOrange),
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
                      fontSize: 14.5,
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
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: CultureTheme.rougeKoulikoro,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.headphones_rounded, size: 11, color: subtitleColor),
                      const SizedBox(width: 4),
                      Text(
                        story.audioDuration,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Découvrir →',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: CultureTheme.rougeKoulikoro,
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
    );
  }
}
