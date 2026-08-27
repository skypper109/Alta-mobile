import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/culture_filter_controller.dart';
import '../../../core/datasources/mock_culture_challenges_data.dart';
import '../../../core/datasources/mock_culture_stage1_data.dart';
import '../../../core/datasources/mock_culture_stories_data.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/datasources/mock_mali_regions.dart';
import '../../data/models/mali_region.dart';
import '../widgets/mali_interactive_map.dart';

/// Écran principal d'exploration culturelle interactive par la carte du Mali
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
        ref.read(activeCultureRegionProvider).activeRegion?.id;
  }

  void _onRegionSelected(String? regionId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRegionId = regionId;
    });
  }

  void _applyGlobalFilter(MaliRegion region) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final bgColor = isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground;

    final allRegions = MockMaliRegions.regions;
    final selectedRegion = _selectedRegionId != null
        ? allRegions.firstWhere(
            (r) => r.id == _selectedRegionId,
            orElse: () => allRegions.first,
          )
        : null;

    final activeGlobalRegion = ref.watch(activeCultureRegionProvider).activeRegion;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── 1. EN-TÊTE FIXE DU VOYAGE CULTUREL ───────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 12),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(bottom: BorderSide(color: borderCol)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_rounded, size: 20, color: titleColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXPLORER LE MALI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.primaryBlue,
                            letterSpacing: 0.7,
                          ),
                        ),
                        Text(
                          'Carte Culturelle & Terroirs',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedRegionId != null)
                    GestureDetector(
                      onTap: () => _onRegionSelected(null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.public_rounded, size: 14, color: CultureTheme.primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              'Tout le Mali',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: CultureTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── 2. SÉLECTEUR RAPIDE DE RÉGIONS (DÉFILEMENT HORIZONTAL) ───────
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF8FAFC),
                border: Border(bottom: BorderSide(color: borderCol)),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allRegions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) {
                  final reg = allRegions[index];
                  final isSelected = reg.id == _selectedRegionId;

                  return GestureDetector(
                    onTap: () => _onRegionSelected(reg.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CultureTheme.primaryBlue
                            : (isDark ? CultureTheme.darkSurface : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? CultureTheme.primaryBlue : borderCol,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: CultureTheme.primaryBlue.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            reg.icone,
                            size: 13,
                            color: isSelected ? Colors.white : CultureTheme.accentOrange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            reg.nom,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : titleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── 3. CARTE INTERACTIVE & PANNEAU CONTEXTUEL ───────────────────
            Expanded(
              child: Stack(
                children: [
                  // Carte vectorielle
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 260),
                      child: MaliInteractiveMap(
                        regions: allRegions,
                        selectedRegionId: _selectedRegionId,
                        onRegionSelected: _onRegionSelected,
                      ),
                    ),
                  ),

                  // Panneau Culturel contextuel déployé en bas
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: selectedRegion != null
                          ? _buildRegionalContextPanel(
                              region: selectedRegion,
                              isActiveGlobal: activeGlobalRegion?.id == selectedRegion.id,
                              context: context,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              titleColor: titleColor,
                              subtitleColor: subtitleColor,
                            )
                          : _buildOverviewPanel(
                              context: context,
                              isDark: isDark,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              titleColor: titleColor,
                              subtitleColor: subtitleColor,
                            ),
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

  // ── PANNEAU D'APERÇU GLOBAL QUAND AUCUNE RÉGION N'EST SÉLECTIONNÉE ─────────
  Widget _buildOverviewPanel({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      key: const ValueKey<String>('overview_panel'),
      padding: EdgeInsets.fromLTRB(
        18,
        14,
        18,
        MediaQuery.paddingOf(context).bottom + 14,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: borderCol)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: subtitleColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.touch_app_rounded,
                  color: CultureTheme.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Touchez une région sur la carte',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      'Découvrez ses monuments, contes, héros et défis du jour.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: subtitleColor,
                      ),
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

  // ── PANNEAU CULTUREL RÉGIONAL CONTEXTUEL ──────────────────────────────────
  Widget _buildRegionalContextPanel({
    required MaliRegion region,
    required bool isActiveGlobal,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final photoUrl = _resolveRegionImage(region.id);

    // Récupération des trésors associés
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

    return Container(
      key: ValueKey<String>('panel_${region.id}'),
      constraints: const BoxConstraints(maxHeight: 340),
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: borderCol)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée supérieure
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: subtitleColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // En-tête de Région avec vignette photo & Titre
            Row(
              children: [
                // Vignette photo authentique
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CultureTheme.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.asset(
                      photoUrl,
                      fit: BoxFit.cover,
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
                            region.nom,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: titleColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              region.code,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: CultureTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        region.surnom,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CultureTheme.accentOrange,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Bouton filtre global
                GestureDetector(
                  onTap: () => _applyGlobalFilter(region),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActiveGlobal
                          ? Colors.green
                          : CultureTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (isActiveGlobal ? Colors.green : CultureTheme.primaryBlue)
                              .withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActiveGlobal ? Icons.check_circle_rounded : Icons.filter_alt_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActiveGlobal ? 'Filtre Actif' : 'Filtrer Culture',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
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

            const SizedBox(height: 12),

            // Description courte
            Text(
              region.descriptionCourte,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: subtitleColor,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),
            Divider(color: borderCol, height: 1),
            const SizedBox(height: 12),

            // ── TRÉSORS DU TERROIR (ACCÈS DIRECT AUX FICHES) ─────────────────
            Text(
              'À DÉCOUVRIR DANS LE TERROIR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 8),

            // Liste horizontale des trésors culturels
            SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Monuments
                  if (monuments.isNotEmpty)
                    _buildTreasureChip(
                      context: context,
                      title: monuments.first.title,
                      category: 'Monument',
                      icon: Icons.account_balance_rounded,
                      accentColor: CultureTheme.rougeKoulikoro,
                      isDark: isDark,
                      borderCol: borderCol,
                      titleColor: titleColor,
                      onTap: () => context.push('/culture/monument/${monuments.first.id}'),
                    ),

                  // 2. Personnages
                  if (figures.isNotEmpty)
                    _buildTreasureChip(
                      context: context,
                      title: figures.first.title,
                      category: 'Personnage',
                      icon: Icons.person_rounded,
                      accentColor: CultureTheme.accentOrange,
                      isDark: isDark,
                      borderCol: borderCol,
                      titleColor: titleColor,
                      onTap: () => context.push('/culture/personnage/${figures.first.id}'),
                    ),

                  // 3. Contes
                  if (stories.isNotEmpty)
                    _buildTreasureChip(
                      context: context,
                      title: stories.first.title,
                      category: 'Conte',
                      icon: Icons.auto_stories_rounded,
                      accentColor: CultureTheme.primaryBlue,
                      isDark: isDark,
                      borderCol: borderCol,
                      titleColor: titleColor,
                      onTap: () => context.push('/culture/conte/${stories.first.id}'),
                    ),

                  // 4. Devinettes / Défi du jour
                  if (riddles.isNotEmpty)
                    _buildTreasureChip(
                      context: context,
                      title: riddles.first.category,
                      category: 'Défi N\'Da',
                      icon: Icons.psychology_rounded,
                      accentColor: CultureTheme.cyanTurquoise,
                      isDark: isDark,
                      borderCol: borderCol,
                      titleColor: titleColor,
                      onTap: () => context.push('/culture/defis/devinettes?id=${riddles.first.id}'),
                    ),

                  // 5. Villes
                  if (villes.isNotEmpty)
                    _buildTreasureChip(
                      context: context,
                      title: villes.first.title,
                      category: 'Cité Royale',
                      icon: Icons.location_city_rounded,
                      accentColor: CultureTheme.orPatrimoine,
                      isDark: isDark,
                      borderCol: borderCol,
                      titleColor: titleColor,
                      onTap: () => context.push('/culture/ville/${villes.first.id}'),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Bouton vers la fiche de région complète
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: BorderSide(color: borderCol),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/culture/region/${region.id}', extra: region);
                },
                icon: const Icon(Icons.explore_rounded, size: 15, color: CultureTheme.primaryBlue),
                label: Text(
                  'Consulter la fiche complète de ${region.nom}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CultureTheme.primaryBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreasureChip({
    required BuildContext context,
    required String title,
    required String category,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required Color borderCol,
    required Color titleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: accentColor),
                const SizedBox(width: 4),
                Text(
                  category.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              title,
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
}
