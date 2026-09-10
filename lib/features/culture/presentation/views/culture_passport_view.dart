import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../exploration/data/datasources/mock_mali_regions.dart';
import '../../immersive/immersive.dart';
import '../widgets/passport_item_card.dart';

/// Vue 4 : Passeport Culturel & Mon Parcours (Sceaux Royaux, XP & Tampons)
/// Carnet personnel d'exploration culturelle du Mali & Carte Initiatique
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI AlterniA
class CulturePassportView extends ConsumerStatefulWidget {
  final bool showBackButton;

  const CulturePassportView({
    super.key,
    this.showBackButton = false,
  });

  @override
  ConsumerState<CulturePassportView> createState() =>
      _CulturePassportViewState();
}

class _CulturePassportViewState extends ConsumerState<CulturePassportView> {
  int _selectedFilterIndex = 0; // 0: Héros, 1: Monuments, 2: Villes, 3: Contes, 4: Défis

  static const List<String> _filters = [
    'Héros',
    'Monuments',
    'Villes',
    'Contes',
    'Défis',
  ];

  static const List<IconData> _filterIcons = [
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
      case 0:
        displayedEntries = passport.figures;
        break;
      case 1:
        displayedEntries = passport.monuments;
        break;
      case 2:
        displayedEntries = passport.villes;
        break;
      case 3:
        displayedEntries = passport.contes;
        break;
      case 4:
      default:
        displayedEntries = passport.defis;
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
            // ── OPTIONNEL : BOUTON RETOUR QUAND OUVERT EN STANDALONE ──────────
            if (widget.showBackButton) ...[
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      CulturalHaptics.cardPress();
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/culture');
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? CultureTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderCol),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PASSEPORT CULTUREL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: CultureTheme.primaryBlue,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: CultureTheme.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${passport.entries.length} Gravés',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ── 0. CARTE D'IDENTITÉ INITIATIQUE & EXPÉRIENCE XP ────────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('POINTS D\'EXPÉRIENCE',
                      Icons.military_tech_rounded, borderCol),
                  const SizedBox(height: 12),
                  _buildInitiaticXpCard(context, passport, isDark, cardBg,
                      borderCol, titleColor, subtitleColor, surfaceAlt),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── 1. RÉGIONS EXPLORÉES (LE CERCLE DU MALI) ──────────────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 100),
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

            // ── 2. COLLECTION DES DÉCOUVERTES (TAMPONS & SCEAUX) ──────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('COLLECTION DES TRÉSORS',
                      Icons.auto_awesome_rounded, borderCol),
                  const SizedBox(height: 12),
                  _buildFilterPills(isDark, surfaceAlt, borderCol),
                  const SizedBox(height: 16),
                  _buildDiscoveriesGrid(context, displayedEntries, isDark,
                      surfaceAlt, subtitleColor),
                ],
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
          decoration: BoxDecoration(
            color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CultureTheme.primaryBlue.withValues(alpha: 0.25),
              width: 0.8,
            ),
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

  // ── 0. CARTE D'EXPÉRIENCE XP & NIVEAU (DESIGN MINIMALISTE ÉPURÉ) ──────────
  Widget _buildInitiaticXpCard(
    BuildContext context,
    PassportState passport,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
    Color surfaceAlt,
  ) {
    return CulturalInteractiveCard(
      padding: const EdgeInsets.all(16),
      showSudaneseCorners: false,
      activeAccentColor: CultureTheme.accentOrange,
      backgroundColor: cardBg,
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Rangée 1 : Titre épuré & Badge Niveau uniquement ─────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.stars_rounded,
                        size: 20,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Passeport d\'Exploration',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              // Badge de niveau épuré (uniquement le niveau)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CultureTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'NIVEAU ${passport.rankLevel}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Rangée 2 : Jauge globale d'XP épurée ───────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    CulturalRollingXpCounter(
                      targetXp: passport.totalXp,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: CultureTheme.primaryBlue,
                        height: 1.0,
                      ),
                      suffix: 'XP',
                      suffixStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                    Text(
                      '${passport.totalXp} / ${passport.nextRankXp} XP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Barre de progression élastique animée (AUCUN DÉGRADÉ)
                CulturalSpringProgressBar(
                  progress: passport.rankProgress,
                  height: 6,
                  fillColor: CultureTheme.accentOrange,
                  trackColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Rangée 3 : 4 Piliers XP épurés ───────────────────────────────
          Row(
            children: [
              // Pilier 1 : Défis & Quiz
              Expanded(
                child: _buildXpPillarItem(
                  label: 'Défis & Quiz',
                  xp: passport.defisXp,
                  icon: Icons.military_tech_rounded,
                  color: CultureTheme.primaryBlue,
                  isSelected: _selectedFilterIndex == 4,
                  isDark: isDark,
                  onTap: () {
                    CulturalHaptics.tabSwitch();
                    setState(() {
                      _selectedFilterIndex = 4;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Pilier 2 : Contes
              Expanded(
                child: _buildXpPillarItem(
                  label: 'Contes',
                  xp: passport.contesXp,
                  icon: Icons.auto_stories_rounded,
                  color: CultureTheme.accentOrange,
                  isSelected: _selectedFilterIndex == 3,
                  isDark: isDark,
                  onTap: () {
                    CulturalHaptics.tabSwitch();
                    setState(() {
                      _selectedFilterIndex = 3;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Pilier 3 : Monuments
              Expanded(
                child: _buildXpPillarItem(
                  label: 'Monuments',
                  xp: passport.monumentsXp + passport.villesXp,
                  icon: Icons.account_balance_rounded,
                  color: CultureTheme.cyanTurquoise,
                  isSelected: _selectedFilterIndex == 1,
                  isDark: isDark,
                  onTap: () {
                    CulturalHaptics.tabSwitch();
                    setState(() {
                      _selectedFilterIndex = 1;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Pilier 4 : Héros
              Expanded(
                child: _buildXpPillarItem(
                  label: 'Héros',
                  xp: passport.figuresXp,
                  icon: Icons.person_rounded,
                  color: CultureTheme.accentOrange,
                  isSelected: _selectedFilterIndex == 0,
                  isDark: isDark,
                  onTap: () {
                    CulturalHaptics.tabSwitch();
                    setState(() {
                      _selectedFilterIndex = 0;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PILLULE DE PILIER XP ÉPURÉE ───────────────────────────────────────────
  Widget _buildXpPillarItem({
    required String label,
    required int xp,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.22 : 0.12)
              : (isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : (isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Icon(icon, size: 15, color: color),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '+$xp XP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
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

  // ── 1. TRACKER RÉGIONAL — DESIGN MINIMALISTE & ÉPURÉ ──────────────────────
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
      activeAccentColor: CultureTheme.accentOrange,
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
                  color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.explore_rounded,
                    size: 18,
                    color: CultureTheme.accentOrange,
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
                          'Villes & Villages',
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
                            color: CultureTheme.accentOrange,
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
                                  ? CultureTheme.accentOrange
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
                  chipBg = CultureTheme.accentOrange;
                  chipBorder = CultureTheme.accentOrange;
                  textColor = Colors.white;
                  iconColor = Colors.white;
                } else if (isExplored) {
                  chipBg = CultureTheme.accentOrange
                      .withValues(alpha: isDark ? 0.16 : 0.10);
                  chipBorder = CultureTheme.accentOrange
                      .withValues(alpha: isDark ? 0.35 : 0.25);
                  textColor = isDark ? Colors.white : CultureTheme.accentOrange;
                  iconColor = CultureTheme.accentOrange;
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
                    CulturalHaptics.tabSwitch();
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
                  child: AnimatedScale(
                    scale: isSelected ? 1.04 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
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
                CulturalHaptics.tabSwitch();
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              child: AnimatedScale(
                scale: isSelected ? 1.04 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CultureTheme.accentOrange
                        : (isDark
                            ? CultureTheme.darkSurface
                            : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? CultureTheme.accentOrange : borderCol,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _filterIcons[index],
                        size: 13,
                        color: isSelected ? Colors.white : CultureTheme.accentOrange,
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
        return AnimatedCulturalReveal(
          key: ValueKey('passport_entry_${_selectedFilterIndex}_${entries[index].id}'),
          delay: Duration(milliseconds: 40 * (index % 8)),
          child: PassportItemCard(entry: entries[index]),
        );
      },
    );
  }
}
