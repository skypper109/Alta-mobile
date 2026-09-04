import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/models/cultural_guide_models.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../exploration/data/datasources/mock_mali_regions.dart';
import '../../immersive/immersive.dart';
import '../widgets/passport_item_card.dart';

/// Vue 4 : Passeport Culturel & Mon Parcours (Étape 4 — Sceaux Royaux & Tampons)
/// Carnet personnel d'exploration culturelle du Mali
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class CulturePassportView extends ConsumerStatefulWidget {
  const CulturePassportView({super.key});

  @override
  ConsumerState<CulturePassportView> createState() =>
      _CulturePassportViewState();
}

class _CulturePassportViewState extends ConsumerState<CulturePassportView> {
  int _selectedFilterIndex = 0; // 0: Tout, 1: Figures, 2: Monuments, 3: Villes, 4: Contes, 5: Défis

  static const List<String> _filters = [
    'Tout',
    'Figures',
    'Monuments',
    'Villes',
    'Contes',
    'Défis',
  ];

  static const List<IconData> _filterIcons = [
    Icons.auto_awesome_rounded,
    Icons.person_rounded,
    Icons.account_balance_rounded,
    Icons.location_city_rounded,
    Icons.auto_stories_rounded,
    Icons.military_tech_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final passport = ref.watch(culturePassportProvider);
    final filterState = ref.watch(activeCultureRegionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final surfaceAlt =
        isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt;

    // Filtre dynamique de collection
    List<PassportEntry> displayedEntries;
    switch (_selectedFilterIndex) {
      case 1:
        displayedEntries = passport.figures;
        break;
      case 2:
        displayedEntries = passport.monuments;
        break;
      case 3:
        displayedEntries = passport.villes;
        break;
      case 4:
        displayedEntries = passport.contes;
        break;
      case 5:
        displayedEntries = passport.defis;
        break;
      default:
        displayedEntries = passport.entries;
    }

    // Filtrer par région active si nécessaire
    if (filterState.hasActiveFilter && filterState.activeRegion != null) {
      displayedEntries = displayedEntries
          .where((e) => e.regionId == filterState.activeRegion!.id)
          .toList();
    }

    return CulturalAtmosphereCanvas(
      enableParticles: true,
      enableBogolanMotifs: true,
      motifOpacity: 0.11,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. GRAND PASSEPORT DU MANDEN & STATUT ROYAL ────────────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                      'PASSEPORT DU MANDEN', Icons.verified_user_rounded, borderCol),
                  const SizedBox(height: 12),
                  _buildPassportHeaderCard(context, passport, isDark, cardBg,
                      borderCol, titleColor, subtitleColor),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── 2. RÉGIONS EXPLORÉES (LE CERCLE DU MALI) ──────────────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                      'RÉGIONS EXPLORÉES', Icons.map_rounded, borderCol),
                  const SizedBox(height: 12),
                  _buildRegionsExplorationTracker(context, passport, isDark,
                      cardBg, borderCol, titleColor, subtitleColor),
                ],
              ),
            ),



            const SizedBox(height: 28),

            // ── 4. COLLECTION DES DÉCOUVERTES (TAMPONS & SCEAUX) ──────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 260),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('COLLECTION DES ESTAMPILLAGES',
                      Icons.collections_bookmark_rounded, borderCol),
                  const SizedBox(height: 12),
                  _buildFilterPills(isDark, surfaceAlt, borderCol),
                  const SizedBox(height: 16),
                  _buildDiscoveriesGrid(context, displayedEntries, isDark,
                      surfaceAlt, subtitleColor),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── 5. BANNIÈRE GUIDE CULTUREL IA ─────────────────────────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 320),
              child: _buildAiGuideBanner(context, isDark, cardBg, borderCol,
                  titleColor, subtitleColor),
            ),
          ],
        ),
      ),
    );
  }

  // ── TITRE DE SECTION AVEC LIGNE SÉPARATRICE ─────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon, Color borderCol) {
    return Row(
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
              Icon(
                icon,
                size: 13,
                color: CultureTheme.primaryBlue,
              ),
              const SizedBox(width: 5),
              Text(
                title,
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
    );
  }

  // ── 1. CARTE ROYALE DU PASSEPORT ───────────────────────────────────────────
  Widget _buildPassportHeaderCard(
    BuildContext context,
    PassportState passport,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return CulturalInteractiveCard(
      padding: const EdgeInsets.all(20),
      showSudaneseCorners: true,
      activeAccentColor: CultureTheme.accentOrange,
      backgroundColor: cardBg,
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sceau d'or impérial
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CultureTheme.accentOrange,
                    width: 2.0,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: CultureTheme.accentOrange,
                    size: 28,
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
                          'RÉPUBLIQUE DU MALI • ALTERNIA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passeport du Voyageur',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'N° ${passport.passportNumber}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CultureTheme.cyanTurquoise,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: CultureTheme.vertNaturel
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'INITIÉ DU MANDEN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: CultureTheme.vertNaturel,
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

          const SizedBox(height: 18),

          // Ligne de statistiques récapitulatives en 4 médaillons
          Row(
            children: [
              _buildStatPill(
                icon: Icons.person_rounded,
                count: passport.figures.length,
                label: 'Figures',
                color: CultureTheme.primaryBlue,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatPill(
                icon: Icons.account_balance_rounded,
                count: passport.monuments.length,
                label: 'Monuments',
                color: CultureTheme.accentOrange,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatPill(
                icon: Icons.location_city_rounded,
                count: passport.villes.length,
                label: 'Cités',
                color: CultureTheme.cyanTurquoise,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatPill(
                icon: Icons.auto_stories_rounded,
                count: passport.contes.length,
                label: 'Contes',
                color: CultureTheme.rougeKoulikoro,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Citation ancestrale du Manden
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.08 : 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CultureTheme.accentOrange.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 16,
                  color: CultureTheme.accentOrange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '« Chaque pas posé sur les terres du Mali tisse la mémoire vivante de son histoire. »',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: subtitleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(height: 3),
            Text(
              count.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. TRACKER RÉGIONAL — DESIGN MINIMALISTE & ÉPURÉ ──────────────────────
  Widget _buildRegionsExplorationTracker(
    BuildContext context,
    PassportState passport,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    final allRegions = MockMaliRegions.regions;
    final exploredCount = passport.exploredRegionIds.length;
    final totalCount = allRegions.length;
    final filterState = ref.watch(activeCultureRegionProvider);
    final activeRegionId = filterState.activeRegion?.id;

    return CulturalInteractiveCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      showSudaneseCorners: false,
      activeAccentColor: CultureTheme.primaryBlue,
      backgroundColor: cardBg,
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ligne d'en-tête épurée : Titre, Compteur & Segments ──────────
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.explore_rounded,
                    size: 18,
                    color: CultureTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terroirs du Mali',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        Text(
                          '$exploredCount / $totalCount explorés',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: CultureTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Barre de progression segmentée (11 terroirs)
                    Row(
                      children: List.generate(totalCount, (index) {
                        final isFilled = index < exploredCount;
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(
                                right: index == totalCount - 1 ? 0 : 3),
                            decoration: BoxDecoration(
                              color: isFilled
                                  ? CultureTheme.primaryBlue
                                  : (isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Ruban horizontal épuré des 11 régions ────────────────────────
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: allRegions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final region = allRegions[index];
                final isExplored =
                    passport.exploredRegionIds.contains(region.id);
                final isSelected = activeRegionId == region.id;

                Color chipBg;
                Color chipBorder;
                Color textColor;
                Color iconColor;

                if (isSelected) {
                  chipBg = CultureTheme.primaryBlue;
                  chipBorder = CultureTheme.primaryBlue;
                  textColor = Colors.white;
                  iconColor = Colors.white;
                } else if (isExplored) {
                  chipBg = CultureTheme.primaryBlue
                      .withValues(alpha: isDark ? 0.16 : 0.10);
                  chipBorder = CultureTheme.primaryBlue
                      .withValues(alpha: isDark ? 0.35 : 0.25);
                  textColor = isDark ? Colors.white : CultureTheme.primaryBlue;
                  iconColor = CultureTheme.primaryBlue;
                } else {
                  chipBg = isDark
                      ? const Color(0xFF131B2A)
                      : const Color(0xFFF8FAFC);
                  chipBorder = borderCol;
                  textColor = subtitleColor;
                  iconColor = subtitleColor.withValues(alpha: 0.6);
                }

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (isSelected) {
                      ref
                          .read(activeCultureRegionProvider.notifier)
                          .clearFilter();
                    } else {
                      ref
                          .read(activeCultureRegionProvider.notifier)
                          .selectRegion(region);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: chipBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isExplored
                              ? (isSelected
                                  ? Icons.filter_alt_rounded
                                  : Icons.check_circle_rounded)
                              : Icons.lock_outline_rounded,
                          size: 13,
                          color: iconColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          region.nom,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: isExplored || isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }



  // ── 4. PILULES DE FILTRE DE LA COLLECTION ──────────────────────────────────
  Widget _buildFilterPills(bool isDark, Color surfaceAlt, Color borderCol) {
    return SingleChildScrollView(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CultureTheme.primaryBlue
                      : (isDark
                          ? CultureTheme.darkSurface
                          : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? CultureTheme.primaryBlue : borderCol,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _filterIcons[index],
                      size: 13,
                      color: isSelected ? Colors.white : CultureTheme.primaryBlue,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _filters[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── 5. GRILLE DES DÉCOUVERTES (TAMPONS DU PASSEPORT) ───────────────────────
  Widget _buildDiscoveriesGrid(
    BuildContext context,
    List<PassportEntry> entries,
    bool isDark,
    Color surfaceAlt,
    Color subtitleColor,
  ) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 40,
              color: subtitleColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              'Aucun tampon dans cette catégorie pour le moment.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return PassportItemCard(entry: entries[index]);
      },
    );
  }

  // ── 6. BANNIÈRE GUIDE CULTUREL IA ───────────────────────────────────────────
  Widget _buildAiGuideBanner(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return CulturalInteractiveCard(
      padding: const EdgeInsets.all(16),
      showSudaneseCorners: true,
      activeAccentColor: CultureTheme.accentOrange,
      backgroundColor: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFFFF7ED),
      borderRadius: 20,
      onTap: () {
        const guideContext = CulturalGuideContext(
          contentType: CulturalContentType.passeport,
          contentTitle: 'Mon Passeport Culturel',
          subtitle: 'Mémoire de voyage & Recommandations personnalisées',
        );
        context.push('/culture/guide', extra: guideContext);
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CultureTheme.accentOrange.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: CultureTheme.accentOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GUIDE CULTUREL IA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: CultureTheme.accentOrange,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Interrogez le guide IA sur votre parcours et vos prochaines étapes.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: CultureTheme.accentOrange,
          ),
        ],
      ),
    );
  }
}
