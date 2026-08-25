import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/datasources/mock_mali_regions.dart';
import '../../data/models/mali_region.dart';

/// Section de fin de page invitant à continuer l'exploration vers des régions voisines
class ContinueJourneySection extends StatelessWidget {
  final List<String> neighborRegionIds;
  final ValueChanged<MaliRegion> onSelectNeighbor;

  const ContinueJourneySection({
    super.key,
    required this.neighborRegionIds,
    required this.onSelectNeighbor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final neighborRegions = MockMaliRegions.regions
        .where((r) => neighborRegionIds.contains(r.id))
        .toList();

    if (neighborRegions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: CultureTheme.orPatrimoine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Continuez votre voyage',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Liste des suggestions
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: neighborRegions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final neighbor = neighborRegions[index];
                final accent = neighbor.couleurAccent;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onSelectNeighbor(neighbor);
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? CultureTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : CultureTheme.primaryBlue)
                              .withValues(alpha: isDark ? 0.20 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            neighbor.icone,
                            size: 20,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                neighbor.nom,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Explorer →',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
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
