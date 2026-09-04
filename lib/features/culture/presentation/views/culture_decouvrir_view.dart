import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_stage1_data.dart';
import '../../core/models/culture_item.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';

/// Vue 2 : Découverte — Hub Central d'Exploration Culturelle du Mali (Étape 2)
/// Grandes Figures, Monuments Historiques, Villes & Terroirs
/// Ambiance culturelle 60 FPS, cartes interactives avec ornementation soudanaise
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class CultureDecouvrirView extends ConsumerStatefulWidget {
  const CultureDecouvrirView({super.key});

  @override
  ConsumerState<CultureDecouvrirView> createState() =>
      _CultureDecouvrirViewState();
}

class _CultureDecouvrirViewState extends ConsumerState<CultureDecouvrirView> {
  int _selectedFilterIndex = 0; // 0: Héros, 1: Monuments, 2: Villes & Terroirs

  static const List<String> _categories = [
    'Personnages',
    'Monuments ',
    'Villes & Villages',
  ];

  static const List<IconData> _categoryIcons = [
    Icons.shield_rounded,
    Icons.account_balance_rounded,
    Icons.location_city_rounded,
  ];

  Color _getCategoryColor(int index) {
    switch (index) {
      case 0:
        return CultureTheme.primaryBlue;
      case 1:
        return const Color.fromRGBO(241, 133, 31, 1);
      case 2:
        return CultureTheme.cyanTurquoise;
      default:
        return CultureTheme.primaryBlue;
    }
  }

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

    final categoryColor = _getCategoryColor(_selectedFilterIndex);

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
            // ── 1. BARRE HORIZONTALE DE SÉLECTION DE CATÉGORIE ─────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  final activeCol = _getCategoryColor(index);
                  final int count = index == 0
                      ? figures.length
                      : index == 1
                          ? monuments.length
                          : villes.length;

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
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeCol
                              : (isDark
                                  ? CultureTheme.darkSurface
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? activeCol : borderCol,
                            width: isSelected ? 1.4 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _categoryIcons[index],
                              size: 14,
                              color: isSelected ? Colors.white : activeCol,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _categories[index],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : activeCol.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : activeCol,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 18),

            // ── 2. CARTE VEDETTE DE LA CATÉGORIE ───────────────────────────────
            AnimatedCulturalReveal(
              key: ValueKey('hero_$_selectedFilterIndex'),
              delay: const Duration(milliseconds: 80),
              child: _buildCategoryHeroCard(
                context: context,
                categoryIndex: _selectedFilterIndex,
                categoryColor: categoryColor,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
            ),

            const SizedBox(height: 22),

            // ── 3. GRILLE DE TOUS LES ITEMS DE LA CATÉGORIE ────────────────────
            if (_selectedFilterIndex == 0) ...[
              _buildSectionHeader(
                title: 'TOUS LES HÉROS & FIGURES',
                icon: Icons.shield_rounded,
                color: CultureTheme.primaryBlue,
                borderCol: borderCol,
                count: figures.length,
              ),
              const SizedBox(height: 14),
              _buildItemsGrid(
                items: figures,
                categoryRoute: 'personnage',
                categoryColor: CultureTheme.primaryBlue,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
            ] else if (_selectedFilterIndex == 1) ...[
              _buildSectionHeader(
                title: 'TOUS LES MONUMENTS DU MALI',
                icon: Icons.account_balance_rounded,
                color: CultureTheme.accentOrange,
                borderCol: borderCol,
                count: monuments.length,
              ),
              const SizedBox(height: 14),
              _buildItemsGrid(
                items: monuments,
                categoryRoute: 'monument',
                categoryColor: CultureTheme.accentOrange,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
            ] else if (_selectedFilterIndex == 2) ...[
              _buildSectionHeader(
                title: 'CITÉS MILLÉNAIRES & TERROIRS',
                icon: Icons.location_city_rounded,
                color: CultureTheme.cyanTurquoise,
                borderCol: borderCol,
                count: villes.length,
              ),
              const SizedBox(height: 14),
              _buildItemsGrid(
                items: villes,
                categoryRoute: 'ville',
                categoryColor: CultureTheme.cyanTurquoise,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── CARTE VEDETTE D'EN-TÊTE DE CATÉGORIE ────────────────────────────────────
  Widget _buildCategoryHeroCard({
    required BuildContext context,
    required int categoryIndex,
    required Color categoryColor,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    String heroTitle;
    String heroSubtitle;
    String heroTag;
    String heroImage;
    String heroRoute;
    String heroDescription;

    switch (categoryIndex) {
      case 0:
        heroTitle = 'Soundiata Keïta';
        heroSubtitle = 'Fondateur de l\'Empire du Manden & Charte de 1236';
        heroTag = 'FIGURE MAJEURE';
        heroImage = 'assets/images/culture/personnages/soundiata.jpg';
        heroRoute = '/culture/personnage/perso_soundiata';
        heroDescription =
            'Découvrez l\'épopée légendaire du Lion du Manden, sa victoire historique à Kirina et la première constitution des droits humains.';
        break;
      case 1:
        heroTitle = 'Grande Mosquée de Djenné';
        heroSubtitle = 'Chef-d\'œuvre d\'architecture en banco du Sahel';
        heroTag = 'PATRIMOINE MONDIAL UNESCO';
        heroImage = 'assets/images/culture/monuments/djenne.jpg';
        heroRoute = '/culture/monument/monument_djenne';
        heroDescription =
            'Le plus grand édifice en terre crue au monde, symbole de la ferveur communautaire et du crépissage annuel.';
        break;
      case 2:
      default:
        heroTitle = 'Tombouctou la Mystique';
        heroSubtitle = 'La Cité aux 333 Saints & Manuscrits Anciens';
        heroTag = 'CITÉ ANCESTRALE';
        heroImage = 'assets/images/culture/villes/tombouctou.jpg';
        heroRoute = '/culture/ville/ville_tombouctou';
        heroDescription =
            'Carrefour saharien d\'or et de sel, foyer des plus prestigieuses universités islamiques d\'Afrique de l\'Ouest.';
        break;
    }

    return CulturalInteractiveCard(
      padding: EdgeInsets.zero,
      showSudaneseCorners: true,
      activeAccentColor: categoryColor,
      backgroundColor: cardBg,
      borderRadius: 20,
      onTap: () {
        context.push(heroRoute);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 135,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  heroImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: categoryColor.withValues(alpha: 0.15),
                    child: Center(
                      child: Icon(_categoryIcons[categoryIndex],
                          color: categoryColor, size: 40),
                    ),
                  ),
                ),
                Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      heroTag,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heroTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  heroSubtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  heroDescription,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: subtitleColor,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Explorer la fiche complète',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: categoryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: categoryColor,
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

  // ── EN-TÊTE DE SECTION AVEC COMPTEUR ────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required Color borderCol,
    int? count,
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
              if (count != null) ...[
                const SizedBox(width: 5),
                Text(
                  '($count)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: borderCol)),
      ],
    );
  }

  // ── GRILLE D'ITEMS CULTURELS AVEC CARTES INTERACTIVES ───────────────────────
  Widget _buildItemsGrid({
    required List<CultureItem> items,
    required String categoryRoute,
    required Color categoryColor,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.travel_explore_rounded,
                color: subtitleColor.withValues(alpha: 0.6), size: 36),
            const SizedBox(height: 10),
            Text(
              'Aucun élément trouvé pour cette région.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: subtitleColor,
              ),
            ),
          ],
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
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return AnimatedCulturalReveal(
          delay: Duration(milliseconds: 60 * index),
          child: CulturalInteractiveCard(
            padding: EdgeInsets.zero,
            showSudaneseCorners: true,
            activeAccentColor: categoryColor,
            backgroundColor: cardBg,
            borderRadius: 18,
            onTap: () {
              context.push('/culture/$categoryRoute/${item.id}');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photographie réelle avec badge
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
                            color: categoryColor.withValues(alpha: 0.12),
                            child: Icon(item.icon,
                                color: categoryColor, size: 28),
                          ),
                        )
                      else
                        Container(
                          color: categoryColor.withValues(alpha: 0.12),
                          child:
                              Icon(item.icon, color: categoryColor, size: 28),
                        ),
                      Container(
                        color: Colors.black.withValues(alpha: 0.28),
                      ),
                      // Badge région en haut à droite
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.regionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Textes descriptifs
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
                                color: categoryColor,
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
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: categoryColor,
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
        );
      },
    );
  }
}
