import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/culture_filter_controller.dart';
import '../../../core/datasources/mock_culture_challenges_data.dart';
import '../../../core/datasources/mock_culture_stage1_data.dart';
import '../../../core/datasources/mock_culture_stories_data.dart';
import '../../../core/models/cultural_guide_models.dart';
import '../../../core/models/culture_item.dart';
import '../../../core/models/culture_story_models.dart';
import '../../../core/theme/culture_theme.dart';
import '../../../presentation/widgets/ask_cultural_guide_button.dart';
import '../../../presentation/widgets/authentic_photo_hero.dart';
import '../../data/models/mali_region.dart';

/// Fiche Détaillée d'une Région du Mali (Design System Unifié Alternia Culture)
class RegionDetailScreen extends ConsumerWidget {
  final MaliRegion region;

  const RegionDetailScreen({
    super.key,
    required this.region,
  });

  String _resolveRegionPhoto(String regionId) {
    switch (regionId) {
      case 'kayes':
        return 'assets/images/culture/monuments/fort_medine.jpg';
      case 'koulikoro':
        return 'assets/images/culture/personnages/soundiata.jpg';
      case 'sikasso':
        return 'assets/images/culture/monuments/tata_sikasso.jpg';
      case 'segou':
        return 'assets/images/culture/villes/segou_koro.jpg';
      case 'mopti':
        return 'assets/images/culture/villes/djenne_ville.jpg';
      case 'tombouctou':
        return 'assets/images/culture/villes/tombouctou_ville.jpg';
      case 'gao':
        return 'assets/images/culture/monuments/tombeau_askia.jpg';
      case 'kidal':
      case 'taoudenit':
      case 'menaka':
        return 'assets/images/culture/villes/tombouctou_ville.jpg';
      case 'bamako':
      default:
        return 'assets/images/culture/monuments/fort_medine.jpg';
    }
  }

  void _applyGlobalFilter(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    ref.read(activeCultureRegionProvider.notifier).selectRegion(region);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Filtre actif : ${region.nom} (appliqué à tout l\'univers Culture)',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: CultureTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final bgColor = isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground;

    final activeGlobalRegion = ref.watch(activeCultureRegionProvider).activeRegion;
    final isFilterActive = activeGlobalRegion?.id == region.id;

    final photoUrl = _resolveRegionPhoto(region.id);

    // Trésors culturels associés
    final monuments = MockCultureStage1Data.monuments
        .where((m) => m.regionId == region.id)
        .toList();
    final figures = MockCultureStage1Data.personnages
        .where((p) => p.regionId == region.id)
        .toList();
    final stories = MockCultureStoriesData.stories
        .where((s) => s.regionId == region.id)
        .toList();
    final riddles = MockCultureChallengesData.riddles
        .where((r) => r.regionId == region.id)
        .toList();
    final villes = MockCultureStage1Data.villes
        .where((v) => v.regionId == region.id)
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. PHOTOGRAPHIE RÉELLE AUTHENTIQUE DU TERROIR ─────────────────
          SliverToBoxAdapter(
            child: AuthenticPhotoHero(
              photoUrl: photoUrl,
              photoCredits: '${region.nom} • Archives du Patrimoine National',
              tag: region.code,
              regionName: region.nom,
              subtitleInfo: region.surnom,
              accentColor: CultureTheme.primaryBlue,
            ),
          ),

          // ── 2. CORPS ÉDITORIAL & DÉCOUVERTES CULTURELLES ──────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // En-tête : Nom & Surnom
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            region.nom,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: titleColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            region.surnom,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: CultureTheme.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bouton filtre global
                    GestureDetector(
                      onTap: () => _applyGlobalFilter(context, ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFilterActive ? Colors.green : CultureTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (isFilterActive ? Colors.green : CultureTheme.primaryBlue)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFilterActive ? Icons.check_circle_rounded : Icons.filter_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isFilterActive ? 'Filtre Actif' : 'Filtrer Culture',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
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

                // Données géographiques clés (Chef-lieu, Population, Superficie)
                Row(
                  children: [
                    _buildInfoCard(
                      label: 'CHEF-LIEU',
                      value: region.chefLieu,
                      icon: Icons.location_city_rounded,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderCol: borderCol,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoCard(
                      label: 'SUPERFICIE',
                      value: region.superficie,
                      icon: Icons.map_rounded,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderCol: borderCol,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoCard(
                      label: 'POPULATION',
                      value: region.population,
                      icon: Icons.groups_rounded,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderCol: borderCol,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Présentation historique & culturelle
                Text(
                  'Histoire & Mémoire du Terroir',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  region.descriptionComplete,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: subtitleColor,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 16),

                // Guide Culturel IA Contextuel
                AskCulturalGuideButton(
                  contextData: CulturalGuideContext(
                    contentType: CulturalContentType.region,
                    contentId: region.id,
                    contentTitle: region.nom,
                    subtitle: region.surnom,
                    regionId: region.id,
                    regionName: region.nom,
                  ),
                ),

                const SizedBox(height: 24),

                // ── 3. MONUMENTS DU TERROIR ─────────────────────────────────
                if (monuments.isNotEmpty) ...[
                  _buildSectionHeader('MONUMENTS HISTORIQUES', CultureTheme.rougeKoulikoro),
                  const SizedBox(height: 10),
                  ...monuments.map((m) => _buildCultureItemTile(
                        item: m,
                        route: '/culture/monument/${m.id}',
                        accentColor: CultureTheme.rougeKoulikoro,
                        context: context,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderCol: borderCol,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                      )),
                  const SizedBox(height: 20),
                ],

                // ── 4. PERSONNAGES HISTORIQUES ──────────────────────────────
                if (figures.isNotEmpty) ...[
                  _buildSectionHeader('FIGURES HISTORIQUES & SOUVERAINS', CultureTheme.accentOrange),
                  const SizedBox(height: 10),
                  ...figures.map((p) => _buildCultureItemTile(
                        item: p,
                        route: '/culture/personnage/${p.id}',
                        accentColor: CultureTheme.accentOrange,
                        context: context,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderCol: borderCol,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                      )),
                  const SizedBox(height: 20),
                ],

                // ── 5. CONTES & TRADITIONS ORALES ───────────────────────────
                if (stories.isNotEmpty) ...[
                  _buildSectionHeader('CONTES & TRADITIONS ORALES', CultureTheme.primaryBlue),
                  const SizedBox(height: 10),
                  ...stories.map((s) => _buildStoryTile(
                        story: s,
                        context: context,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderCol: borderCol,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                      )),
                  const SizedBox(height: 20),
                ],

                // ── 6. DÉFIS & DEVINETTES N'DA ──────────────────────────────
                if (riddles.isNotEmpty) ...[
                  _buildSectionHeader('DÉFIS & DEVINETTES DU TERROIR', CultureTheme.cyanTurquoise),
                  const SizedBox(height: 10),
                  ...riddles.map((r) => _buildRiddleTile(
                        riddle: r,
                        context: context,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderCol: borderCol,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                      )),
                  const SizedBox(height: 20),
                ],

                // ── 7. VILLES & VILLAGES ────────────────────────────────────
                if (villes.isNotEmpty) ...[
                  _buildSectionHeader('VILLES & CITÉS HISTORIQUES', CultureTheme.orPatrimoine),
                  const SizedBox(height: 10),
                  ...villes.map((v) => _buildCultureItemTile(
                        item: v,
                        route: '/culture/ville/${v.id}',
                        accentColor: CultureTheme.orPatrimoine,
                        context: context,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderCol: borderCol,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                      )),
                  const SizedBox(height: 20),
                ],

                // ── 8. SYMBOLES & TRADITIONS DU TERROIR ─────────────────────
                _buildSectionHeader('POINTS FORTS & TRADITIONS', CultureTheme.vertNaturel),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...region.pointsForts.map((pt) => _buildTag(pt, CultureTheme.primaryBlue, isDark, cardBg, borderCol)),
                    ...region.symbolesEtTraditions.map((sy) => _buildTag(sy, CultureTheme.accentOrange, isDark, cardBg, borderCol)),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: CultureTheme.primaryBlue),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCultureItemTile({
    required CultureItem item,
    required String route,
    required Color accentColor,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(route);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
          ),
          child: Row(
            children: [
              if (item.imageUrl != null)
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(item.imageUrl!, fit: BoxFit.cover),
                  ),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: accentColor, size: 20),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: CultureTheme.primaryBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryTile({
    required InteractiveStory story,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/culture/conte/${story.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(12),
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
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderCol),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(story.photoUrl, fit: BoxFit.cover),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      'Récit • ${story.audioDuration}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: CultureTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: CultureTheme.primaryBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiddleTile({
    required dynamic riddle,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/culture/defis/devinettes?id=${riddle.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(12),
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
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: CultureTheme.cyanTurquoise.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology_rounded, color: CultureTheme.cyanTurquoise, size: 22),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Devinette N\'Da • ${riddle.category}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '+${riddle.xpReward} XP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: CultureTheme.accentOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: CultureTheme.cyanTurquoise),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color accentColor, bool isDark, Color cardBg, Color borderCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 12, color: accentColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
