import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/theme/culture_theme.dart';
import 'culture_region_bottom_sheet.dart';

/// Pilule de filtre régional réutilisable dans tous les écrans Culture.
/// Se connecte automatiquement à [activeCultureRegionProvider].
/// Un simple clic ouvre le [CultureRegionBottomSheet] de sélection.
class RegionFilterPill extends ConsumerWidget {
  /// Taille compacte (petits espaces) ou normale
  final bool compact;

  const RegionFilterPill({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final notifier = ref.read(activeCultureRegionProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasFilter = filterState.hasActiveFilter;
    final label = filterState.displayName;

    final activeBg = CultureTheme.accentOrange.withValues(alpha: 0.12);
    final activeBorder = CultureTheme.accentOrange;
    final inactiveBg =
        isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt;
    final inactiveBorder =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final hPad = compact ? 10.0 : 12.0;
    final vPad = compact ? 6.0 : 8.0;
    final fontSize = compact ? 11.5 : 12.5;
    final iconSize = compact ? 13.0 : 15.0;

    return GestureDetector(
      onTap: () => CultureRegionBottomSheet.show(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: hasFilter ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFilter ? activeBorder : inactiveBorder,
            width: hasFilter ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: iconSize,
              color: hasFilter
                  ? CultureTheme.accentOrange
                  : (isDark
                      ? const Color(0xFF64748B)
                      : CultureTheme.primaryBlue),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: hasFilter
                    ? CultureTheme.accentOrange
                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  notifier.clearFilter();
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.22),
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
                size: iconSize + 2,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
