import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/mali_region.dart';
import '../controllers/culture_exploration_controller.dart';
import '../widgets/culture_exploration_header.dart';
import '../widgets/mali_interactive_map.dart';
import '../widgets/region_chip_selector.dart';
import '../widgets/region_preview_card.dart';

/// Écran principal d'exploration du Mali (Porte d'entrée Univers Culture)
class CultureExplorationScreen extends ConsumerWidget {
  const CultureExplorationScreen({super.key});

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _onExploreRegion(BuildContext context, MaliRegion region) {
    HapticFeedback.mediumImpact();
    context.push('/culture/region/${region.id}', extra: region);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cultureExplorationProvider);
    final notifier = ref.read(cultureExplorationProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? CultureTheme.darkBackground
          : CultureTheme.lightBackground,
      body: SafeArea(
        child: state.regionsAsync.when(
          loading: () => _buildLoadingState(isDark),
          error: (error, _) => _buildErrorState(context, ref, isDark, error.toString()),
          data: (regions) {
            final selectedRegion = state.selectedRegion;

            return Stack(
              children: [
                // ── Contenu principal scrollable ────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    CultureExplorationHeader(
                      onBack: () => _onBack(context),
                      totalRegionsCount: regions.length,
                    ),

                    // Sélecteur rapide par puces
                    RegionChipSelector(
                      regions: regions,
                      selectedRegionId: selectedRegion?.id,
                      onRegionSelected: (id) => notifier.selectRegion(id),
                    ),

                    const SizedBox(height: 10),

                    // Carte interactive du Mali (occupe l'espace restant)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MaliInteractiveMap(
                          regions: regions,
                          selectedRegionId: selectedRegion?.id,
                          onRegionSelected: (id) => notifier.selectRegion(id),
                        ),
                      ),
                    ),

                    // Espace réservé pour la fiche du bas
                    SizedBox(
                      height: selectedRegion != null ? 220 : 70,
                    ),
                  ],
                ),

                // ── Bannière d'invitation ou Fiche Régionale flottante ────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: selectedRegion != null
                        ? RegionPreviewCard(
                            key: ValueKey(selectedRegion.id),
                            region: selectedRegion,
                            onExplore: () => _onExploreRegion(
                              context,
                              selectedRegion,
                            ),
                            onClose: () => notifier.clearSelection(),
                          )
                        : _buildDiscoveryHintBanner(isDark),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? CultureTheme.darkSurface : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CultureTheme.ocreTerre.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: CultureTheme.ocreTerre,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chargement de l\'espace Culture...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Préparation de la carte interactive du Mali',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: CultureTheme.rougeKoulikoro,
            ),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger la carte',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(cultureExplorationProvider.notifier).loadRegions();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CultureTheme.ocreTerre,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryHintBanner(bool isDark) {
    return Container(
      key: const ValueKey('hint_banner'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (isDark ? CultureTheme.darkSurface : Colors.white)
            .withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CultureTheme.ocreTerre.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              size: 20,
              color: CultureTheme.ocreTerre,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Touchez une région sur la carte ou dans la liste pour débuter l\'exploration.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
