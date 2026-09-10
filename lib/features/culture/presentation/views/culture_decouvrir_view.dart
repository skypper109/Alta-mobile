import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_stage1_data.dart';
import '../../core/models/culture_item.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';
import '../widgets/culture_audio_listen_badge.dart';

/// Vue 2 : Découverte — Hub Central d'Exploration Culturelle du Mali
/// Grandes Figures, Monuments Historiques, Villes & Terroirs
/// Immersion culturelle complète avec écoute audio orale (Griot TTS)
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI Alta-mobile
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
    'Monuments',
    'Villes & Terroirs',
  ];

  static const List<IconData> _categoryIcons = [
    Icons.shield_rounded,
    Icons.account_balance_rounded,
    Icons.location_city_rounded,
  ];

  Color _getCategoryColor(int index) {
    switch (index) {
      case 0:
        return CultureTheme.accentOrange;
      case 1:
        return const Color.fromRGBO(241, 133, 31, 1);
      case 2:
        return CultureTheme.accentOrange;
      default:
        return CultureTheme.accentOrange;
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
    final allFigures = MockCultureStage1Data.personnages
        .where((i) => i.matchesRegion(regionId))
        .toList();
    final allMonuments = MockCultureStage1Data.monuments
        .where((i) => i.matchesRegion(regionId))
        .toList();
    final allVilles = MockCultureStage1Data.villes
        .where((i) => i.matchesRegion(regionId))
        .toList();

    final items = _selectedFilterIndex == 0
        ? allFigures
        : _selectedFilterIndex == 1
            ? allMonuments
            : allVilles;

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
            // ── COMPAS VIVANT DES TERROIRS DU MALI ────────────────────────────
            const AnimatedCulturalReveal(
              delay: Duration(milliseconds: 60),
              child: CulturalTerroirCompassWidget(),
            ),

            const SizedBox(height: 20),

            // ── 1. BARRE HORIZONTALE DE SÉLECTION DE CATÉGORIE ─────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  final activeCol = _getCategoryColor(index);
                  final int count = index == 0
                      ? allFigures.length
                      : index == 1
                          ? allMonuments.length
                          : allVilles.length;

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
                        scale: isSelected ? 1.03 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8.5),
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
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 18),

            // ── 2. CARTE VEDETTE DE LA CATÉGORIE AVEC ÉCOUTE AUDIO ────────────
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

            // ── 3. SECTION CONTENUS (GRILLE) ──────────────────────────────────
            _buildSectionHeader(
              title: _selectedFilterIndex == 0
                  ? 'TOUS LES HÉROS '
                  : _selectedFilterIndex == 1
                      ? 'TOUS LES MONUMENTS DU MALI'
                      : 'Villes & Villages',
              icon: _categoryIcons[_selectedFilterIndex],
              color: categoryColor,
              borderCol: borderCol,
              count: items.length,
            ),
            const SizedBox(height: 14),

            _buildItemsGrid(
              items: items,
              categoryRoute: _selectedFilterIndex == 0
                  ? 'personnage'
                  : _selectedFilterIndex == 1
                      ? 'monument'
                      : 'ville',
              categoryColor: categoryColor,
              isDark: isDark,
              cardBg: cardBg,
              borderCol: borderCol,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. CARTE VEDETTE D'EN-TÊTE DE CATÉGORIE ────────────────────────────────
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
    String heroSpeech;
    String heroContentId;

    switch (categoryIndex) {
      case 0:
        heroTitle = 'Soundiata Keïta';
        heroSubtitle = 'Fondateur de l\'Empire du Manden & Charte de 1236';
        heroTag = 'FIGURE MAJEURE DU MALI';
        heroImage = 'assets/images/culture/personnages/soundiata.jpg';
        heroRoute = '/culture/personnage/perso_soundiata';
        heroSpeech =
            'Soundiata Keïta, le Lion du Manden. Né paralysé mais guidé par la parole sacrée, il se relève pour unir les douze royaumes alliés. Après avoir terrassé Soumaoro Kanté à la bataille de Kirina en 1235, il proclame en 1236 la Charte de Kouroukan Fouga, garantissant la dignité humaine, la paix sociale et la protection de la nature.';
        heroContentId = 'hero_soundiata';
        break;
      case 1:
        heroTitle = 'Grande Mosquée de Djenné';
        heroSubtitle = 'Chef-d\'œuvre universel en banco du Sahel';
        heroTag = 'PATRIMOINE MONDIAL UNESCO';
        heroImage = 'assets/images/culture/monuments/mosquee_djenne.jpg';
        heroRoute = '/culture/monument/monument_djenne';
        heroSpeech =
            'La Grande Mosquée de Djenné, plus grand monument en terre crue du monde et joyau classé par l\'UNESCO. Chaque année, la ville entière se réunit pour la fête du crépissage, renouvelant l\'argile sacrée selon les secrets ancestraux des maîtres maçons du Bani.';
        heroContentId = 'hero_djenne';
        break;
      case 2:
      default:
        heroTitle = 'Tombouctou la Mystique';
        heroSubtitle = 'La Cité aux 333 Saints & Manuscrits Anciens';
        heroTag = 'CITÉ ANCESTRALE DU SAHARA';
        heroImage = 'assets/images/culture/villes/tombouctou_ville.jpg';
        heroRoute = '/culture/ville/ville_tombouctou';
        heroSpeech =
            'Tombouctou la Mystique, la cité aux trois cent trente-trois saints. Située au carrefour des caravanes du Sahara et du fleuve Niger, elle a rayonné sur le monde grâce à l\'Université de Sankoré et à ses milliers de manuscrits scientifiques et philosophiques.';
        heroContentId = 'hero_tombouctou';
        break;
    }

    return Cultural3DTiltCard(
      title: heroTitle,
      subtitle: heroSubtitle,
      region: categoryIndex == 0
          ? 'Mandé'
          : (categoryIndex == 1 ? 'Mopti' : 'Tombouctou'),
      tag: heroTag,
      photoUrl: heroImage,
      trailingBadge: CultureAudioListenBadge(
        contentId: heroContentId,
        speechText: heroSpeech,
        label: 'Griot',
        compact: true,
        activeColor: categoryColor,
      ),
      onTap: () {
        CulturalHaptics.cardPress();
        context.push(heroRoute, extra: 'decouvrir_hero_$heroContentId');
      },
    );
  }

  // ── EN-TÊTE DE SECTION ────────────────────────────────────────────────────
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

  // ── 2. GRILLE D'ITEMS AVEC ÉCOUTE AUDIO INTÉGRÉE ───────────────────────────
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
              'Aucun élément trouvé pour ces critères.',
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

    final narration = ref.watch(narrationCoordinatorProvider);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isPlayingItem = narration.isSpeaking &&
            narration.activeContentId == item.id;
        final speechText =
            '${item.title}. ${item.subtitle}. Région de ${item.regionName}. ${item.description}';

        final itemHeroTag = 'decouvrir_grid_${categoryRoute}_${item.id}';

        return AnimatedCulturalReveal(
          key: ValueKey('grid_${categoryRoute}_${item.id}'),
          delay: Duration(milliseconds: 35 * (index % 8)),
          child: CulturalInteractiveCard(
            padding: EdgeInsets.zero,
            showSudaneseCorners: true,
            activeAccentColor: categoryColor,
            backgroundColor: cardBg,
            borderRadius: 18,
            onTap: () {
              context.push('/culture/$categoryRoute/${item.id}', extra: itemHeroTag);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image réelle avec Hero transition fluide
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        Hero(
                          tag: itemHeroTag,
                          child: Image.asset(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: categoryColor.withValues(alpha: 0.12),
                              child: Icon(item.icon,
                                  color: categoryColor, size: 28),
                            ),
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
                      // Badge Écouter en bas à gauche de la photo
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: CultureAudioListenBadge(
                          contentId: item.id,
                          speechText: speechText,
                          label: 'Écouter',
                          compact: true,
                          activeColor: categoryColor,
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
                                color: isPlayingItem
                                    ? categoryColor
                                    : titleColor,
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
