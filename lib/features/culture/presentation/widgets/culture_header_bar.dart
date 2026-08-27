import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/theme/culture_theme.dart';
import 'culture_region_bottom_sheet.dart';

/// Barre supérieure minimaliste de Culture avec marque et filtre régional transversal
/// STRICTEMENT SANS DÉGRADÉS selon les règles d'architecture UX/UI
class CultureHeaderBar extends ConsumerWidget {
  const CultureHeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final notifier = ref.read(activeCultureRegionProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Titre et baseline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: CultureTheme.accentOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CULTURE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Découvrez le Mali',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),

          // Filtre Régional Transversal (Pilule cliquable)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => CultureRegionBottomSheet.show(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: filterState.hasActiveFilter
                      ? CultureTheme.accentOrange.withValues(alpha: 0.15)
                      : (isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: filterState.hasActiveFilter
                        ? CultureTheme.accentOrange
                        : borderCol,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: filterState.hasActiveFilter
                          ? CultureTheme.accentOrange
                          : CultureTheme.primaryBlue,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      filterState.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: filterState.hasActiveFilter
                            ? CultureTheme.accentOrange
                            : titleColor,
                      ),
                    ),
                    if (filterState.hasActiveFilter) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.clearFilter();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: CultureTheme.accentOrange.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 11,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: subtitleColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
