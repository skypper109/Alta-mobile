import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/datasources/mock_culture_stories_data.dart';
import '../../core/models/cultural_guide_models.dart';
import '../../core/models/culture_story_models.dart';
import '../../core/theme/culture_theme.dart';
import '../widgets/ask_cultural_guide_button.dart';
import '../widgets/authentic_photo_hero.dart';
import '../widgets/connected_contents_section.dart';
import '../widgets/story_audio_player_sheet.dart';

/// Fiche détaillée d'un Conte Malien (Écouter, Lire, Commencer l'expérience)
class StoryDetailScreen extends StatelessWidget {
  final String id;
  final InteractiveStory? story;

  const StoryDetailScreen({
    super.key,
    required this.id,
    this.story,
  });

  @override
  Widget build(BuildContext context) {
    final item = story ?? MockCultureStoriesData.getStoryById(id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. GRANDE PHOTOGRAPHIE AUTHENTIQUE (HERO) ──────────────────────
          SliverToBoxAdapter(
            child: AuthenticPhotoHero(
              photoUrl: item.photoUrl,
              photoCredits: item.photoCredits,
              tag: item.tag,
              regionName: item.regionName,
              subtitleInfo: item.origin,
              accentColor: CultureTheme.rougeKoulikoro,
            ),
          ),

          // ── 2. CORPS ÉDITORIAL & ACTIONS ──────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Titre du conte
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Sous-titre & Narrateur
                Text(
                  item.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: CultureTheme.rougeKoulikoro,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Badge Origine & Récitant
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_pin_rounded,
                            size: 13,
                            color: CultureTheme.accentOrange,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.narrator,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: CultureTheme.accentOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.readingDuration,
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

                const SizedBox(height: 20),

                // ── 3. ACTIONS MAJEURES (EXPÉRIENCE, ÉCOUTER, LIRE) ───────────
                // Bouton principal : Commencer l'expérience interactive
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/culture/conte/${item.id}/play');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: CultureTheme.rougeKoulikoro,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Commencer l\'expérience interactive',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Boutons secondaires : Écouter & Lire
                Row(
                  children: [
                    // Écouter
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          StoryAudioPlayerSheet.show(context, item);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.headphones_rounded,
                                size: 18,
                                color: CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Écouter (${item.audioDuration})',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Lire
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/culture/conte/${item.id}/read');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: CultureTheme.primaryBlue.withValues(alpha: 0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.menu_book_rounded,
                                size: 18,
                                color: CultureTheme.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Lire le conte',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: CultureTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 4. RÉSUMÉ & THÉMATIQUES ─────────────────────────────────
                Text(
                  'Le Récit en Bref',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.summary,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: subtitleColor,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 16),

                // Guide Culturel IA Contextuel (Morale & Analyse)
                AskCulturalGuideButton(
                  contextData: CulturalGuideContext(
                    contentType: CulturalContentType.conte,
                    contentId: item.id,
                    contentTitle: item.title,
                    subtitle: 'Conte • ${item.regionName}',
                    regionId: item.regionId,
                    regionName: item.regionName,
                    photoUrl: item.photoUrl,
                  ),
                ),

                const SizedBox(height: 20),

                // ── 5. MORALE ANCESTRALE ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CultureTheme.orPatrimoine.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_rounded,
                        color: CultureTheme.orPatrimoine,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enseignement Traditionnel',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? CultureTheme.orPatrimoine : const Color(0xFFB45309),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.moral,
                              style: GoogleFonts.merriweather(
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                                height: 1.45,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── 6. LIENS CULTURELS & MAILLAGE PATRIMONIAL ───────────────
                ConnectedContentsSection(
                  items: item.connectedItems,
                  title: 'Patrimoine & Lieux Liés au Conte',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
