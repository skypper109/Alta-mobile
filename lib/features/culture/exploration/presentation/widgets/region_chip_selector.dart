import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/mali_region.dart';

/// Sélecteur horizontal tactile des régions du Mali
class RegionChipSelector extends StatelessWidget {
  final List<MaliRegion> regions;
  final String? selectedRegionId;
  final ValueChanged<String> onRegionSelected;

  const RegionChipSelector({
    super.key,
    required this.regions,
    required this.selectedRegionId,
    required this.onRegionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: regions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final region = regions[index];
          final isSelected = region.id == selectedRegionId;
          final accent = region.couleurAccent;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onRegionSelected(region.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent
                    : (isDark ? CultureTheme.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? accent
                      : (isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(
                      Icons.place_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    region.nom,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
