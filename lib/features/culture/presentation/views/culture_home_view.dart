import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_stage1_data.dart';
import '../../core/models/culture_item.dart';
import '../../core/theme/culture_theme.dart';
import '../widgets/culture_region_bottom_sheet.dart';

/// Vue 1 : Accueil Culture
/// STRICTEMENT SANS DÉGRADÉS selon les règles d'architecture UX/UI
class CultureHomeView extends ConsumerWidget {
  final ValueChanged<int> onNavigateToTab;

  const CultureHomeView({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRegion = ref.watch(activeCultureRegionProvider).activeRegion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final featured = MockCultureStage1Data.featuredItem;
    final recommendations = [
      ...MockCultureStage1Data.personnages,
      ...MockCultureStage1Data.monuments,
      ...MockCultureStage1Data.villes,
    ].where((item) => item.matchesRegion(activeRegion?.id)).take(4).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. SECTION « À LA UNE » ─────────────────────────────────────────
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
                      Icons.star_rounded,
                      size: 14,
                      color: CultureTheme.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'À LA UNE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
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

          // Grande carte À la une
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderCol, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bandeau visuel photographique réel
                SizedBox(
                  height: 145,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (featured.imageUrl != null && featured.imageUrl!.isNotEmpty)
                        Image.asset(
                          featured.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: CultureTheme.primaryDark,
                            child: const Center(
                              child: Icon(Icons.shield_rounded, size: 40, color: Colors.white54),
                            ),
                          ),
                        )
                      else
                        Container(color: CultureTheme.primaryDark),

                      // Overlay sombre uni pour contraste texte (strictement sans dégradé)
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.accentOrange,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    featured.tag.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 1,
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
                                        featured.regionName,
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
                            Text(
                              featured.info,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(color: Colors.black, blurRadius: 4),
                                ],
                              ),
                            ),
                          ],
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
                        featured.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        featured.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        featured.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: subtitleColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              context.push('/culture/personnage/perso_soundiata');
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Découvrir Soundiata Keïta',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: CultureTheme.accentOrange,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: CultureTheme.accentOrange,
                                ),
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

          const SizedBox(height: 24),

          // ── 3. ACCÈS RAPIDES AUX UNIVERS ────────────────────────────────────
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
                      Icons.grid_view_rounded,
                      size: 14,
                      color: CultureTheme.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'UNIVERS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
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

          const SizedBox(height: 12),

          // Cartes d'accès rapide vers les 3 autres onglets principaux
          Row(
            children: [
              _buildQuickNavCard(
                context: context,
                title: 'Découverte',
                subtitle: 'Figures, Villes, Lieux',
                icon: Icons.explore_rounded,
                accentColor: CultureTheme.primaryBlue,
                isDark: isDark,
                onTap: () => onNavigateToTab(1),
              ),
              const SizedBox(width: 10),
              _buildQuickNavCard(
                context: context,
                title: 'Jeux & Contes',
                subtitle: 'Récits & Quiz',
                icon: Icons.auto_stories_rounded,
                accentColor: CultureTheme.rougeKoulikoro,
                isDark: isDark,
                onTap: () => onNavigateToTab(2),
              ),
              const SizedBox(width: 10),
              _buildQuickNavCard(
                context: context,
                title: 'Passeport',
                subtitle: 'Mon Parcours',
                icon: Icons.badge_rounded,
                accentColor: CultureTheme.cyanTurquoise,
                isDark: isDark,
                onTap: () => onNavigateToTab(3),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 4. RECOMMANDATIONS FILTRÉES ─────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.vertNaturel.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: CultureTheme.vertNaturel,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activeRegion != null
                          ? 'SÉLECTION : ${activeRegion.nom.toUpperCase()}'
                          : 'RECOMMANDATIONS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: CultureTheme.vertNaturel,
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

          if (recommendations.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.location_off_rounded, color: subtitleColor, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'Aucun élément spécifique pour cette région',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => CultureRegionBottomSheet.show(context),
                      child: const Text('Changer de région'),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final item = recommendations[index];
                return _buildRecommendationTile(
                  context,
                  item: item,
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

  Widget _buildQuickNavCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(
    BuildContext context, {
    required CultureItem item,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    String route = '/culture/personnage/${item.id}';
    if (item.id.startsWith('monument')) {
      route = '/culture/monument/${item.id}';
    } else if (item.id.startsWith('ville')) {
      route = '/culture/ville/${item.id}';
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push(route);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol),
        ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CultureTheme.accentOrange.withValues(alpha: 0.25),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.asset(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                        child: Icon(item.icon, color: CultureTheme.accentOrange, size: 20),
                      ),
                    )
                  : Container(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                      child: Icon(item.icon, color: CultureTheme.accentOrange, size: 20),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.tag.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.accentOrange,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${item.regionName}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: subtitleColor,
                  ),
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
