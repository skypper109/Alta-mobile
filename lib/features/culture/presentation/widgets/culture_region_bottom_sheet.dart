import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/theme/culture_theme.dart';
import '../../exploration/data/datasources/mock_mali_regions.dart';

/// Modal bottom sheet pour sélectionner le filtre régional transversal
/// STRICTEMENT SANS DÉGRADÉS selon les règles d'architecture UX/UI
class CultureRegionBottomSheet extends ConsumerWidget {
  const CultureRegionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? CultureTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const CultureRegionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final notifier = ref.read(activeCultureRegionProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final regions = MockMaliRegions.regions;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF8FAFC);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.84,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poignée centrale
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? CultureTheme.darkBorder : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // En-tête du modal
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
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
                      'Filtre régional',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Contexte géographique transversal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (filterState.hasActiveFilter)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    notifier.clearFilter();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Tout le Mali'),
                  style: TextButton.styleFrom(
                    foregroundColor: CultureTheme.accentOrange,
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Option 1 : "Tout le Mali" (Vue globale)
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              notifier.clearFilter();
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: !filterState.hasActiveFilter
                    ? CultureTheme.primaryBlue.withValues(alpha: 0.12)
                    : cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: !filterState.hasActiveFilter
                      ? CultureTheme.primaryBlue
                      : borderCol,
                  width: !filterState.hasActiveFilter ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: !filterState.hasActiveFilter
                          ? CultureTheme.primaryBlue
                          : (isDark ? Colors.white10 : Colors.black12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.public_rounded,
                      size: 20,
                      color: !filterState.hasActiveFilter
                          ? Colors.white
                          : subtitleColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tout le Mali (Vue globale)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: !filterState.hasActiveFilter
                                ? CultureTheme.primaryBlue
                                : titleColor,
                          ),
                        ),
                        Text(
                          'Afficher tous les contenus sans filtre géographique',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!filterState.hasActiveFilter)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: CultureTheme.primaryBlue,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Option 2 : Bouton passerelle vers la carte du Mali
          InkWell(
            onTap: () {
              Navigator.pop(context);
              context.push('/culture/map');
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CultureTheme.vertNaturel.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CultureTheme.vertNaturel.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: CultureTheme.vertNaturel.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      size: 20,
                      color: CultureTheme.vertNaturel,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choisir sur la carte du Mali',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : CultureTheme.vertNaturel,
                          ),
                        ),
                        Text(
                          'Ouvrir la carte interactive pour sélectionner un terroir',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: CultureTheme.vertNaturel,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'OU SÉLECTIONNER DIRECTEMENT UNE RÉGION',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: subtitleColor,
            ),
          ),

          const SizedBox(height: 10),

          // Liste des régions
          Expanded(
            child: ListView.separated(
              itemCount: regions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) {
                final r = regions[index];
                final isSelected = filterState.activeRegion?.id == r.id;

                return InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    notifier.selectRegion(r);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CultureTheme.accentOrange.withValues(alpha: 0.12)
                          : cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? CultureTheme.accentOrange
                            : borderCol,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? CultureTheme.accentOrange
                                : CultureTheme.ocreTerre,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.nom,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? CultureTheme.accentOrange
                                      : titleColor,
                                ),
                              ),
                              Text(
                                '${r.surnom} • ${r.chefLieu}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: CultureTheme.accentOrange,
                            size: 18,
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
}
