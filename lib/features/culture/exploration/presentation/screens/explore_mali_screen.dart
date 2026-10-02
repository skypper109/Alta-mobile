import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/culture_filter_controller.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/datasources/mock_mali_regions.dart';
import '../../data/models/mali_historical_place_marker.dart';
import '../../data/models/mali_region.dart';
import '../widgets/mali_interactive_map.dart';

/// Écran d'exploration culturelle interactive par la carte premium du Mali
/// Style Google/Apple Maps avec zoom intérieur, points rouges interactifs et fiches détaillées.
class ExploreMaliScreen extends ConsumerStatefulWidget {
  final String? initialRegionId;

  const ExploreMaliScreen({super.key, this.initialRegionId});

  @override
  ConsumerState<ExploreMaliScreen> createState() => _ExploreMaliScreenState();
}

class _ExploreMaliScreenState extends ConsumerState<ExploreMaliScreen> {
  String? _selectedRegionId;
  MaliHistoricalPlaceMarker? _selectedPlace;

  @override
  void initState() {
    super.initState();
    // Par défaut, vue globale sur l'ensemble du Mali (Toutes les régions)
    _selectedRegionId = widget.initialRegionId;
  }

  void _onRegionSelected(String? regionId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRegionId = regionId;
      // Si la région change et ne correspond plus au lieu historique actif, on le désélectionne
      if (regionId != null &&
          _selectedPlace != null &&
          _selectedPlace!.regionId != regionId) {
        _selectedPlace = null;
      }
    });
  }

  void _onPlaceSelected(MaliHistoricalPlaceMarker? place) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedPlace = place;
      if (place != null) {
        _selectedRegionId = place.regionId;
      }
    });
  }

  void _navigateToRegionDetail(MaliRegion region) {
    HapticFeedback.mediumImpact();
    ref.read(activeCultureRegionProvider.notifier).selectRegion(region);
    context.push('/culture/region/${region.id}');
  }

  void _navigateToPlaceDetail(MaliHistoricalPlaceMarker place) {
    HapticFeedback.mediumImpact();
    context.push(place.routePath);
  }

  void _openScannerForPlace(MaliHistoricalPlaceMarker place) {
    HapticFeedback.mediumImpact();
    context.push('/culture/scanner');
  }

  void _openSageForPlace(MaliHistoricalPlaceMarker place) {
    HapticFeedback.mediumImpact();
    context.push('/culture/sage');
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

    final bottomCardSpacing = _selectedPlace != null
        ? 285.0
        : (selectedRegion != null ? 275.0 : 72.0);

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
                        color:
                            isDark ? CultureTheme.darkSurfaceAlt : Colors.white,
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
                          'Touchez les points rouges pour explorer les monuments',
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

                  // Bouton Scanner IA rapide
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push('/culture/scanner');
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            isDark ? CultureTheme.darkSurfaceAlt : Colors.white,
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
                        Icons.document_scanner_rounded,
                        size: 20,
                        color: Color(0xFFDF6E21),
                      ),
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
                  // Carte vectorielle interactive avec calque des points rouges
                  Positioned.fill(
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.fromLTRB(
                        14,
                        10,
                        14,
                        bottomCardSpacing,
                      ),
                      child: MaliInteractiveMap(
                        regions: allRegions,
                        selectedRegionId: _selectedRegionId,
                        selectedPlaceId: _selectedPlace?.id,
                        onRegionSelected: _onRegionSelected,
                        onPlaceSelected: _onPlaceSelected,
                      ),
                    ),
                  ),

                  // Panneau Flottant : Fiche Lieu Historique OU Fiche Région OU Barre d'indication
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: bottomPadding + 8,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _selectedPlace != null
                          ? _buildSelectedPlaceCard(
                              place: _selectedPlace!,
                              context: context,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              titleColor: titleColor,
                              subtitleColor: subtitleColor,
                            )
                          : (selectedRegion != null
                              ? _buildSelectedRegionCard(
                                  region: selectedRegion,
                                  context: context,
                                  isDark: isDark,
                                  cardBg: cardBg,
                                  borderCol: borderCol,
                                  titleColor: titleColor,
                                  subtitleColor: subtitleColor,
                                )
                              : _buildBottomIndicator(isDark, subtitleColor)),
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

  // ── CARTE PREMIUM DE LIEU HISTORIQUE SÉLECTIONNÉ (POINT ROUGE CLIQUE) ───────
  Widget _buildSelectedPlaceCard({
    required MaliHistoricalPlaceMarker place,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      key: ValueKey<String>('place_card_${place.id}'),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFF5252).withValues(alpha: 0.5),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withValues(alpha: isDark ? 0.25 : 0.12),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Rangée 1 : En-tête avec tag rouge et bouton fermer ────────────
          Row(
            children: [
              // Indicateur rouge animé
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF5252),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Tag de catégorie (prend l'espace disponible et s'elliptise)
              Expanded(
                child: Text(
                  'LIEU · ${place.tag.toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFE53935),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Badge Région
              Container(
                constraints: const BoxConstraints(maxWidth: 90),
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF283B7E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  place.regionName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF283B7E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Bouton Fermer (Retour à la vue générale)
              GestureDetector(
                onTap: () => _onPlaceSelected(null),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isDark
                        ? CultureTheme.darkSurfaceAlt
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: subtitleColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Rangée 2 : Photographie réelle + Titre & Descriptif ────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo du monument
              Container(
                width: 92,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: borderCol),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    place.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE53935).withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Color(0xFFE53935),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Contenu textuel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.fullName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        letterSpacing: -0.3,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: Color(0xFFDF6E21),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.era,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDF6E21),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      place.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Rangée 3 : Fait marquant (Bandeau clé) ─────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1B2338)
                  : const Color(0xFFFBF4ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFDF6E21).withValues(alpha: 0.25),
                width: 0.9,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  size: 14,
                  color: Color(0xFFDF6E21),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    place.keyFact,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFFFB74D)
                          : const Color(0xFF8C3E00),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Rangée 4 : Boutons d'action directs ───────────────────────────
          Row(
            children: [
              // Bouton 1 : Voir la fiche complète (Primaire)
              Expanded(
                flex: 5,
                child: ElevatedButton(
                  onPressed: () => _navigateToPlaceDetail(place),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF283B7E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Fiche complète',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Bouton 2 : Scanner IA
              Expanded(
                flex: 4,
                child: OutlinedButton(
                  onPressed: () => _openScannerForPlace(place),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDF6E21),
                    side: const BorderSide(color: Color(0xFFDF6E21), width: 1.2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.document_scanner_rounded,
                        size: 15,
                        color: Color(0xFFDF6E21),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Scanner IA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFDF6E21),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Bouton 3 : Voix du Griot / Sage IA
              GestureDetector(
                onTap: () => _openSageForPlace(place),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? CultureTheme.darkSurfaceAlt
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.smart_toy_outlined,
                      size: 18,
                      color: Color(0xFF283B7E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── CARTE PREMIUM DE RÉGION SÉLECTIONNÉE (AVEC CHIPS DES MONUMENTS) ───────
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
    final regionPlaces = MaliHistoricalPlacesRegistry.forRegion(region.id);

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

          const SizedBox(height: 10),

          // Chips horizontaux des lieux historiques de cette région (points rouges)
          if (regionPlaces.isNotEmpty) ...[
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: regionPlaces.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final p = regionPlaces[index];
                  return GestureDetector(
                    onTap: () => _onPlaceSelected(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.35),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            p.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFFFF8A80)
                                  : const Color(0xFFC62828),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Ligne 1 : 4 Statistiques de contenu réparties sur la largeur
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(Icons.auto_stories_rounded, '128', 'Contes',
                  const Color(0xFFDF6E21), isDark),
              _buildStatItem(Icons.account_balance_rounded, '48', 'Monuments',
                  const Color(0xFF2E7D32), isDark),
              _buildStatItem(Icons.people_rounded, '32', 'Héros',
                  const Color(0xFF1976D2), isDark),
              _buildStatItem(Icons.sports_esports_rounded, '15', 'Défis',
                  const Color(0xFFE65100), isDark),
            ],
          ),

          const SizedBox(height: 12),

          // Ligne 2 : Bouton Explorer la région pleine largeur
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToRegionDetail(region),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF283B7E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explorer la région',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String count,
    String label,
    Color iconColor,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: iconColor),
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
      key: const ValueKey<String>('bottom_indicator'),
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
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: Color(0xFFE53935),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pincez pour zoomer et touchez un point rouge pour inspecter un monument',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E284A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_rounded,
                size: 16,
                color: Color(0xFF283B7E),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '18 sites',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E284A),
                    ),
                  ),
                  Text(
                    'UNESCO & Mali',
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
