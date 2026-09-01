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
import '../widgets/culture_region_bottom_sheet.dart';
import '../widgets/passport_item_card.dart';
import '../widgets/region_filter_pill.dart';

/// Vue 4 : Passeport Culturel & Mon Parcours
/// Carnet personnel d'exploration culturelle du Mali
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class CulturePassportView extends ConsumerStatefulWidget {
  const CulturePassportView({super.key});

  @override
  ConsumerState<CulturePassportView> createState() => _CulturePassportViewState();
}

class _CulturePassportViewState extends ConsumerState<CulturePassportView> {
  int _selectedFilterIndex = 0; // 0: Tout, 1: Figures, 2: Monuments, 3: Villes, 4: Contes, 5: Défis

  @override
  Widget build(BuildContext context) {
    final passport = ref.watch(culturePassportProvider);
    final notifier = ref.read(culturePassportProvider.notifier);
    final filterState = ref.watch(activeCultureRegionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final surfaceAlt =
        isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt;

    final distinctions = notifier.distinctions;

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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
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
                      color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${displayedEntries.length} souvenir${displayedEntries.length > 1 ? 's' : ''}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.close_rounded, size: 12, color: CultureTheme.accentOrange),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── 2. CARTE EN-TÊTE DU PASSEPORT ───────────────────────────────────
          _buildPassportHeaderCard(context, passport, isDark, cardBg, borderCol, titleColor, subtitleColor),

          const SizedBox(height: 24),

          // ── 3. DÉCOUVERTE DU JOUR À L'HONNEUR ───────────────────────────────
          if (passport.featuredDiscoveryOfTheDay != null) ...[
            _buildSectionTitle('DÉCOUVERTE DU JOUR', Icons.flare_rounded, borderCol),
            const SizedBox(height: 12),
            PassportItemCard(
              entry: passport.featuredDiscoveryOfTheDay!,
              isFeatured: true,
            ),
            const SizedBox(height: 28),
          ],

          // ── 4. MON PARCOURS (RÉSUMÉ POÉTIQUE) ───────────────────────────────
          _buildSectionTitle('MON PARCOURS', Icons.insights_rounded, borderCol),
          const SizedBox(height: 12),
          _buildJourneySummary(passport, isDark, cardBg, borderCol, titleColor, subtitleColor),

          const SizedBox(height: 28),

          // ── 5. MOMENTS MÉMORABLES ───────────────────────────────────────────
          if (passport.milestones.isNotEmpty) ...[
            _buildSectionTitle('MOMENTS MÉMORABLES', Icons.auto_awesome_rounded, borderCol),
            const SizedBox(height: 12),
            _buildMilestonesCarousel(context, passport.milestones, isDark, cardBg, borderCol, titleColor, subtitleColor),
            const SizedBox(height: 28),
          ],

          // ── 6. RÉGIONS EXPLORÉES ────────────────────────────────────────────
          _buildSectionTitle('RÉGIONS EXPLORÉES', Icons.map_rounded, borderCol),
          const SizedBox(height: 12),
          _buildRegionsExplorationTracker(context, passport, isDark, cardBg, borderCol, titleColor, subtitleColor),

          const SizedBox(height: 28),

          // ── 7. COLLECTION DES DÉCOUVERTES (FILTRABLE) ───────────────────────
          _buildSectionTitle('COLLECTION DES DÉCOUVERTES', Icons.collections_bookmark_rounded, borderCol),
          const SizedBox(height: 12),
          _buildFilterPills(isDark, surfaceAlt, borderCol),
          const SizedBox(height: 16),
          _buildDiscoveriesGrid(context, displayedEntries, isDark, surfaceAlt, subtitleColor),

          const SizedBox(height: 32),

          // ── 8. SCEAUX D'AMBASSADEUR CULTUREL ────────────────────────────────
          _buildSectionTitle('SCEAUX D\'AMBASSADEUR CULTUREL', Icons.workspace_premium_rounded, borderCol),
          const SizedBox(height: 12),
          _buildDistinctionsList(distinctions, isDark, cardBg, borderCol, titleColor, subtitleColor),

          const SizedBox(height: 24),

          // ── 9. BANNIÈRE INVITATION GUIDE IA ─────────────────────────────────
          _buildAiGuideBanner(context, isDark, cardBg, borderCol, titleColor, subtitleColor),
        ],
      ),
    );
  }

  // ── TITRE DE SECTION ────────────────────────────────────────────────────────
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

  // ── 1. CARTE EN-TÊTE DU PASSEPORT ───────────────────────────────────────────
  Widget _buildPassportHeaderCard(
    BuildContext context,
    PassportState passport,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: 0.4),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CultureTheme.accentOrange,
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.public_rounded,
                    color: CultureTheme.accentOrange,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RÉPUBLIQUE DU MALI • ALTERNIA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: CultureTheme.accentOrange,
                      ),
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
                    Text(
                      'N° ${passport.passportNumber}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? CultureTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPassportMiniStat(
                  icon: Icons.person_rounded,
                  value: passport.travelerName,
                  label: 'Explorateur',
                  color: CultureTheme.primaryBlue,
                  subtitleColor: subtitleColor,
                ),
                Container(width: 1, height: 28, color: borderCol),
                _buildPassportMiniStat(
                  icon: Icons.explore_rounded,
                  value: '${passport.totalDiscoveries}',
                  label: 'Découvertes',
                  color: CultureTheme.accentOrange,
                  subtitleColor: subtitleColor,
                ),
                Container(width: 1, height: 28, color: borderCol),
                _buildPassportMiniStat(
                  icon: Icons.map_rounded,
                  value: '${passport.exploredRegionIds.length}/10',
                  label: 'Régions',
                  color: CultureTheme.cyanTurquoise,
                  subtitleColor: subtitleColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassportMiniStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color subtitleColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  // ── 2. MON PARCOURS ─────────────────────────────────────────────────────────
  Widget _buildJourneySummary(
    PassportState passport,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                color: CultureTheme.vertNaturel,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatPill(
                icon: Icons.auto_stories_rounded,
                count: passport.contes.length,
                label: 'Contes',
                color: CultureTheme.cyanTurquoise,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '« Chaque pas posé sur les terres du Mali tisse la mémoire vivante de son histoire millénaire. »',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: subtitleColor,
              height: 1.45,
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. CARROUSEL DES MOMENTS MÉMORABLES ──────────────────────────────────────
  Widget _buildMilestonesCarousel(
    BuildContext context,
    List<PassportEntry> milestones,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: milestones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = milestones[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(item.targetRoute);
            },
            child: Container(
              width: 230,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        item.type.icon,
                        color: CultureTheme.accentOrange,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: subtitleColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 4. TRACKER RÉGIONAL ─────────────────────────────────────────────────────
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Carte territoriale du voyageur',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              InkWell(
                onTap: () => CultureRegionBottomSheet.show(context),
                child: Row(
                  children: [
                    Text(
                      'Changer',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: CultureTheme.accentOrange,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allRegions.map((region) {
              final isExplored = passport.exploredRegionIds.contains(region.id);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isExplored
                      ? CultureTheme.primaryBlue.withValues(alpha: isDark ? 0.25 : 0.1)
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isExplored
                        ? CultureTheme.primaryBlue.withValues(alpha: 0.4)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExplored ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 12,
                      color: isExplored ? CultureTheme.primaryBlue : subtitleColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      region.nom,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isExplored ? FontWeight.w700 : FontWeight.w500,
                        color: isExplored ? CultureTheme.primaryBlue : subtitleColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── 5. SÉLECTEUR DE CATÉGORIES ──────────────────────────────────────────────
  Widget _buildFilterPills(bool isDark, Color surfaceAlt, Color borderCol) {
    const categories = [
      'Tout',
      'Figures',
      'Monuments',
      'Villes',
      'Contes',
      'Défis',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(categories.length, (index) {
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CultureTheme.accentOrange
                      : (isDark ? CultureTheme.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? CultureTheme.accentOrange
                        : borderCol,
                  ),
                ),
                child: Text(
                  categories[index],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── 6. GRILLE DES DÉCOUVERTES ───────────────────────────────────────────────
  Widget _buildDiscoveriesGrid(
    BuildContext context,
    List<PassportEntry> entries,
    bool isDark,
    Color surfaceAlt,
    Color subtitleColor,
  ) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 36, color: subtitleColor),
            const SizedBox(height: 10),
            Text(
              'Aucune découverte dans cette catégorie pour le moment.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
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

  // ── 7. LISTE DES DISTINCTIONS ───────────────────────────────────────────────
  Widget _buildDistinctionsList(
    List<CulturalDistinction> distinctions,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Column(
      children: distinctions.map((distinction) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: distinction.isUnlocked
                  ? distinction.sealColor.withValues(alpha: 0.4)
                  : borderCol,
              width: distinction.isUnlocked ? 1.2 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: distinction.isUnlocked
                      ? distinction.sealColor.withValues(alpha: 0.15)
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    distinction.icon,
                    size: 22,
                    color: distinction.isUnlocked
                        ? distinction.sealColor
                        : (isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
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
                          distinction.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: distinction.isUnlocked ? titleColor : subtitleColor,
                          ),
                        ),
                        if (distinction.isUnlocked) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: CultureTheme.accentOrange,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      distinction.description,
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
        );
      }).toList(),
    );
  }

  // ── 8. BANNIÈRE GUIDE CULTUREL IA ───────────────────────────────────────────
  Widget _buildAiGuideBanner(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        const guideContext = CulturalGuideContext(
          contentType: CulturalContentType.passeport,
          contentTitle: 'Mon Passeport Culturel',
          subtitle: 'Mémoire de voyage & Recommandations personnalisées',
        );
        context.push('/culture/guide', extra: guideContext);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: CultureTheme.accentOrange.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
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
                    'Interrogez le guide sur votre parcours et vos prochaines étapes.',
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
      ),
    );
  }
}
