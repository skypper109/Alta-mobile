import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_stage1_data.dart';
import '../../core/models/culture_item.dart';
import '../../core/theme/culture_theme.dart';
import '../../../../presentation/common/widgets/alternia_logo.dart';
import '../../immersive/immersive.dart';
import '../widgets/culture_region_bottom_sheet.dart';

/// Vue 2 : Découverte — Hub Central d'Exploration Culturelle du Mali
/// Grandes Figures, Monuments Historiques, Patrimoine, Villes & Villages, Explorer le Mali
/// Accès direct en 1 clic aux fiches détaillées avec photographies réelles.
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class CultureDecouvrirView extends ConsumerStatefulWidget {
  const CultureDecouvrirView({super.key});

  @override
  ConsumerState<CultureDecouvrirView> createState() =>
      _CultureDecouvrirViewState();
}

class _CultureDecouvrirViewState extends ConsumerState<CultureDecouvrirView> {
  int _selectedFilterIndex = 0; // 0: Tout, 1: Figures, 2: Monuments, 3: Villes, 4: Patrimoine, 5: Explorer

  static const List<String> _categories = [
    'Tout',
    'Grandes Figures',
    'Monuments Historiques',
    'Villes & Villages',
    'Patrimoine',
    'Explorer le Mali',
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

    // Filtre par région
    final regionId = activeRegion?.id;
    final figures = MockCultureStage1Data.personnages
        .where((i) => i.matchesRegion(regionId))
        .toList();
    final monuments = MockCultureStage1Data.monuments
        .where((i) => i.matchesRegion(regionId))
        .toList();
    final villes = MockCultureStage1Data.villes
        .where((i) => i.matchesRegion(regionId))
        .toList();
    final featured = MockCultureStage1Data.featuredItem;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. BARRE HORIZONTALE DE CATÉGORIES ──────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_categories.length, (index) {
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
                            ? CultureTheme.primaryBlue
                            : (isDark
                                ? CultureTheme.darkSurface
                                : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? CultureTheme.primaryBlue
                              : borderCol,
                        ),
                      ),
                      child: Text(
                        _categories[index],
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
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // ── 3. HERO ÉDITORIAL (À DÉCOUVRIR AUJOURD'HUI) ─────────────────────
          if (_selectedFilterIndex == 0) ...[
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 60),
              child: _buildFeaturedCard(
                featured: featured,
                context: context,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
            ),
            const SizedBox(height: 26),
          ],

          // ── 4. OUTIL : EXPLORER LE MALI (CARTE / SÉLECTEUR) ─────────────────
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 5) ...[
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 110),
              child: _buildExploreMaliCard(
                context: context,
                activeRegionName: activeRegion?.nom,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
            ),
            const SizedBox(height: 26),
          ],

          // ── 5. SECTION GRANDES FIGURES ──────────────────────────────────────
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: 'GRANDES FIGURES DU MALI',
                    icon: Icons.person_rounded,
                    color: CultureTheme.primaryBlue,
                    borderCol: borderCol,
                    onSeeAll: () => context.push('/culture/personnages'),
                  ),
                  const SizedBox(height: 14),
                  _buildItemsGrid(
                    items: figures,
                    categoryRoute: 'personnage',
                    isDark: isDark,
                    cardBg: cardBg,
                    borderCol: borderCol,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ── 6. SECTION MONUMENTS HISTORIQUES ────────────────────────────────
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) ...[
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 210),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: 'MONUMENTS HISTORIQUES',
                    icon: Icons.museum_rounded,
                    color: CultureTheme.accentOrange,
                    borderCol: borderCol,
                    onSeeAll: () => context.push('/culture/monuments'),
                  ),
                  const SizedBox(height: 14),
                  _buildItemsGrid(
                    items: monuments,
                    categoryRoute: 'monument',
                    isDark: isDark,
                    cardBg: cardBg,
                    borderCol: borderCol,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ── 7. SECTION VILLES & VILLAGES ────────────────────────────────────
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 3) ...[
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 260),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: 'VILLES & TERROIRS DU MALI',
                    icon: Icons.location_city_rounded,
                    color: CultureTheme.cyanTurquoise,
                    borderCol: borderCol,
                    onSeeAll: () => context.push('/culture/villes'),
                  ),
                  const SizedBox(height: 14),
                  _buildItemsGrid(
                    items: villes,
                    categoryRoute: 'ville',
                    isDark: isDark,
                    cardBg: cardBg,
                    borderCol: borderCol,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ── 8. SECTION PATRIMOINE IMMATÉRIEL ────────────────────────────────
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 4) ...[
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 310),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: 'PATRIMOINE & TRADITIONS VIVANTES',
                    icon: Icons.history_edu_rounded,
                    color: CultureTheme.vertNaturel,
                    borderCol: borderCol,
                  ),
                  const SizedBox(height: 14),
                  _buildHeritageSection(
                    context: context,
                    isDark: isDark,
                    cardBg: cardBg,
                    borderCol: borderCol,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 28),

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
    );
  }

  // ── EN-TÊTE DE SECTION AVEC BOUTON VOIR TOUT ────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required Color borderCol,
    VoidCallback? onSeeAll,
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
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: borderCol)),
        if (onSeeAll != null) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onSeeAll();
            },
            child: Text(
              'Voir tout',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── CARTE FEATURED ÉDITORIALE ──────────────────────────────────────────────
  Widget _buildFeaturedCard({
    required CultureItem featured,
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
        context.push('/culture/personnage/perso_soundiata');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: CultureTheme.primaryBlue
                .withValues(alpha: isDark ? 0.35 : 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CultureTheme.primaryBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: featured.imageUrl != null &&
                        featured.imageUrl!.isNotEmpty
                    ? Image.asset(
                        featured.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: CultureTheme.primaryBlue
                              .withValues(alpha: 0.1),
                          child: const Icon(Icons.shield_rounded,
                              size: 28, color: CultureTheme.primaryBlue),
                        ),
                      )
                    : Container(
                        color: CultureTheme.primaryBlue.withValues(alpha: 0.1),
                        child: const Icon(Icons.shield_rounded,
                            size: 28, color: CultureTheme.primaryBlue),
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
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: CultureTheme.accentOrange
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          featured.tag.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        featured.regionName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    featured.title,
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
                    featured.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: CultureTheme.primaryBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  // ── CARTE OUTIL : EXPLORER LE MALI (NON BLOQUANT) ──────────────────────────
  Widget _buildExploreMaliCard({
    required BuildContext context,
    required String? activeRegionName,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CultureTheme.primaryBlue.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CultureTheme.primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: CultureTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPLORER LE MALI PAR RÉGION',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.primaryBlue,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeRegionName != null
                          ? 'Région active : $activeRegionName'
                          : 'Explorez les 10 terroirs et cités millénaires',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    CultureRegionBottomSheet.show(context);
                  },
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: Text(
                    'Changer de région',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CultureTheme.primaryBlue,
                    side: BorderSide(
                      color: CultureTheme.primaryBlue.withValues(alpha: 0.4),
                    ),
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
    );
  }

  // ── GRILLE D'ITEMS CULTURELS (PERSONNAGES, MONUMENTS, VILLES) ──────────────
  Widget _buildItemsGrid({
    required List<CultureItem> items,
    required String categoryRoute,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text(
          'Aucun élément trouvé pour cette région.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: subtitleColor,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.74,
      ),
      itemCount: items.take(4).length,
      itemBuilder: (context, index) {
        final item = items[index];
        return AnimatedCulturalReveal(
          delay: Duration(milliseconds: 35 * index),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/culture/$categoryRoute/${item.id}');
            },
            child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderCol),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photographie réelle
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        Image.asset(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: CultureTheme.primaryBlue
                                .withValues(alpha: 0.1),
                            child: Icon(item.icon,
                                color: CultureTheme.primaryBlue, size: 30),
                          ),
                        )
                      else
                        Container(
                          color: CultureTheme.primaryBlue.withValues(alpha: 0.1),
                          child: Icon(item.icon,
                              color: CultureTheme.primaryBlue, size: 30),
                        ),

                      // Badge région en haut à droite
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.regionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Textes
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: CultureTheme.accentOrange,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.info,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: subtitleColor,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: CultureTheme.primaryBlue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    );
  }

  // ── SECTION PATRIMOINE IMMATÉRIEL ───────────────────────────────────────────
  Widget _buildHeritageSection({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final heritageItems = [
      {
        'title': 'La Charte du Manden (1236)',
        'subtitle': 'L\'une des plus anciennes déclarations des droits de l\'Homme.',
        'region': 'Koulikoro',
        'icon': Icons.gavel_rounded,
      },
      {
        'title': 'Le Crépissage de Djenné',
        'subtitle': 'Tradition vivante et solidaire de restauration architecturale.',
        'region': 'Mopti',
        'icon': Icons.handyman_rounded,
      },
      {
        'title': 'Les Manuscrits Anciens',
        'subtitle': 'Trésors scientifiques, astronomiques et littéraires de Tombouctou.',
        'region': 'Tombouctou',
        'icon': Icons.menu_book_rounded,
      },
    ];

    return Column(
      children: heritageItems.map((item) {
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
                  color: CultureTheme.vertNaturel.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    item['icon'] as IconData,
                    color: CultureTheme.vertNaturel,
                    size: 22,
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
                          item['title'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['subtitle'] as String,
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
}
