import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/culture_filter_controller.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/datasources/mock_mali_regions.dart';
import '../../data/models/mali_region.dart';
import '../widgets/mali_interactive_map.dart';

/// Écran d'exploration culturelle interactive par la carte premium du Mali
/// 100% conforme à la référence visuelle
class ExploreMaliScreen extends ConsumerStatefulWidget {
  final String? initialRegionId;

  const ExploreMaliScreen({super.key, this.initialRegionId});

  @override
  ConsumerState<ExploreMaliScreen> createState() => _ExploreMaliScreenState();
}

class _ExploreMaliScreenState extends ConsumerState<ExploreMaliScreen> {
  String? _selectedRegionId;

  @override
  void initState() {
    super.initState();
    _selectedRegionId = widget.initialRegionId ??
        ref.read(activeCultureRegionProvider).activeRegion?.id ??
        'tombouctou'; // Tombouctou sélectionnée par défaut comme sur l'image
  }

  void _onRegionSelected(String? regionId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRegionId = regionId;
    });
  }

  void _navigateToRegionDetail(MaliRegion region) {
    HapticFeedback.mediumImpact();
    // Applique le filtre global
    ref.read(activeCultureRegionProvider.notifier).selectRegion(region);
    // Navigue vers la fiche détaillée de la région
    context.push('/culture/region/${region.id}');
  }

  String _resolveRegionImage(String regionId) {
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
        return 'assets/images/culture/monuments/mosquee_sankore.jpg';
      case 'gao':
        return 'assets/images/culture/monuments/tombeau_askia.jpg';
      case 'kidal':
        return 'assets/images/culture/villes/gao_dune_rose.jpg';
      default:
        return 'assets/images/culture/villes/tombouctou_ville.jpg';
    }
  }

  // Icône personnalisée de chaque chip calquée sur la référence
  IconData _getRegionChipIcon(String regionId) {
    switch (regionId) {
      case 'kayes':
        return Icons.holiday_village_rounded;
      case 'koulikoro':
        return Icons.landscape_rounded;
      case 'sikasso':
        return Icons.eco_rounded;
      case 'segou':
        return Icons.palette_rounded;
      case 'mopti':
        return Icons.water_drop_rounded;
      case 'tombouctou':
        return Icons.menu_book_rounded;
      case 'gao':
        return Icons.auto_awesome_rounded;
      case 'kidal':
        return Icons.park_rounded;
      default:
        return Icons.explore_rounded;
    }
  }

  Color _getRegionChipColor(String regionId) {
    switch (regionId) {
      case 'kayes':
        return const Color(0xFFDF6E35);
      case 'koulikoro':
        return const Color(0xFFD9822B);
      case 'sikasso':
        return const Color(0xFFE0682B);
      case 'segou':
        return const Color(0xFFD97232);
      case 'mopti':
        return const Color(0xFF389BB7);
      case 'tombouctou':
        return const Color(0xFFD99B26);
      case 'gao':
        return const Color(0xFFC27835);
      case 'kidal':
        return const Color(0xFF8E9B68);
      default:
        return CultureTheme.accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    final titleColor = isDark ? Colors.white : const Color(0xFF1E284A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : const Color(0xFFE8ECF2);
    final bgColor =
        isDark ? CultureTheme.darkBackground : const Color(0xFFF9F6F0);

    // Les 8 grandes régions culturelles
    final allRegions = MockMaliRegions.regions.take(8).toList();

    final selectedRegion = _selectedRegionId != null
        ? allRegions.where((r) => r.id == _selectedRegionId).firstOrNull ??
            MockMaliRegions.regions.first
        : null;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // ── 1. EN-TÊTE ÉLÉGANT DU VOYAGE CULTUREL ────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 12),
              color: cardBg,
              child: Row(
                children: [
                  // Bouton Retour arrondi
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/culture');
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? CultureTheme.darkSurfaceAlt : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 28,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Titres
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXPLORER LE MALI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFDF6E21),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Carte Culturelle du Mali',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: titleColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Explorez les régions et découvrez la richesse culturelle du Mali',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Bouton Carte Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? CultureTheme.darkSurfaceAlt : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      size: 22,
                      color: Color(0xFF283B7E),
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. SÉLECTEUR HORIZONTAL DES RÉGIONS (CHIPS GÉLULES) ───────────
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(bottom: BorderSide(color: borderCol)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Option Toutes les régions
                  _buildRegionChip(
                    id: null,
                    label: 'Toutes les régions',
                    icon: Icons.temple_buddhist_rounded,
                    isSelected: _selectedRegionId == null,
                    iconColor: const Color(0xFFF08235),
                    isDark: isDark,
                    borderCol: borderCol,
                    titleColor: titleColor,
                  ),
                  const SizedBox(width: 8),

                  // Chips individuels des 8 régions
                  ...allRegions.map((reg) {
                    final isSelected = reg.id == _selectedRegionId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildRegionChip(
                        id: reg.id,
                        label: reg.nom,
                        icon: _getRegionChipIcon(reg.id),
                        isSelected: isSelected,
                        iconColor: _getRegionChipColor(reg.id),
                        isDark: isDark,
                        borderCol: borderCol,
                        titleColor: titleColor,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ── 3. CARTE INTERACTIVE ET PANNEAU DE SÉLECTION ─────────────────
            Expanded(
              child: Stack(
                children: [
                  // Carte vectorielle interactive
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        14,
                        10,
                        14,
                        selectedRegion != null ? 225 : 80,
                      ),
                      child: MaliInteractiveMap(
                        regions: allRegions,
                        selectedRegionId: _selectedRegionId,
                        onRegionSelected: _onRegionSelected,
                      ),
                    ),
                  ),

                  // Panneau Flottant de Région Sélectionnée
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: bottomPadding + 52,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: selectedRegion != null
                          ? _buildSelectedRegionCard(
                              region: selectedRegion,
                              context: context,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              titleColor: titleColor,
                              subtitleColor: subtitleColor,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  // Barre d'indication inférieure
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: bottomPadding + 8,
                    child: _buildBottomIndicator(isDark, subtitleColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CHIP DE SÉLECTION DE RÉGION ────────────────────────────────────────────
  Widget _buildRegionChip({
    required String? id,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color iconColor,
    required bool isDark,
    required Color borderCol,
    required Color titleColor,
  }) {
    return GestureDetector(
      onTap: () => _onRegionSelected(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF283B7E)
              : (isDark ? CultureTheme.darkSurfaceAlt : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF283B7E) : borderCol,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? const Color(0xFF283B7E) : Colors.black)
                  .withValues(alpha: isSelected ? 0.28 : 0.04),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? const Color(0xFFF08235) : iconColor,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: isSelected ? Colors.white : titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CARTE PREMIUM DE RÉGION SÉLECTIONNÉE (CONFORME À L'IMAGE) ──────────────
  Widget _buildSelectedRegionCard({
    required MaliRegion region,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final photoUrl = _resolveRegionImage(region.id);

    return Container(
      key: ValueKey<String>('card_${region.id}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photographie réelle haute qualité de la région
              Container(
                width: 105,
                height: 95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: CultureTheme.primaryBlue.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.image_rounded,
                        color: CultureTheme.primaryBlue,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Informations textuelles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicateur RÉGION SÉLECTIONNÉE
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF283B7E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'RÉGION SÉLECTIONNÉE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF283B7E),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Nom de la Région
                    Text(
                      region.nom,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Description courte et poétique
                    Text(
                      region.descriptionCourte,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Ligne inférieure : Stats de contenu + Bouton Explorer
          Row(
            children: [
              // 4 Statistiques précises
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('📖', '128', 'Contes', const Color(0xFFDF6E21), isDark),
                    _buildStatItem('🏛️', '48', 'Monuments', const Color(0xFF2E7D32), isDark),
                    _buildStatItem('👥', '32', 'Héros', const Color(0xFF1976D2), isDark),
                    _buildStatItem('🎮', '15', 'Défis', const Color(0xFFE65100), isDark),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Bouton Explorer la région
              ElevatedButton(
                onPressed: () => _navigateToRegionDetail(region),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF283B7E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explorer la région',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String emoji,
    String count,
    String label,
    Color emojiColor,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(
              count,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF1E284A),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  // ── BARRE D'INDICATION INFÉRIEURE (FOOTER) ─────────────────────────────────
  Widget _buildBottomIndicator(bool isDark, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D30) : const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? CultureTheme.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF283B7E).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: Color(0xFF283B7E),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Touchez une région pour découvrir ses trésors culturels',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E284A),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.people_outline_rounded,
                size: 16,
                color: Color(0xFF283B7E),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '56 témoignages',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E284A),
                    ),
                  ),
                  Text(
                    '120 contributions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
