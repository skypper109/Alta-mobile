import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/models/cultural_guide_models.dart';
import '../../core/theme/culture_theme.dart';
import 'culture_region_bottom_sheet.dart';

/// Barre supérieure minimaliste de Culture avec marque, filtre régional et Guide IA
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
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
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
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: CultureTheme.accentOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'CULTURE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Découvrez le Mali',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 1. Bouton Guide Culturel IA (Icône élégante avec effet lumineux)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                final activeReg = filterState.activeRegion;
                final guideContext = activeReg != null
                    ? CulturalGuideContext(
                        contentType: CulturalContentType.region,
                        contentId: activeReg.id,
                        contentTitle: activeReg.nom,
                        subtitle: activeReg.surnom,
                        regionId: activeReg.id,
                        regionName: activeReg.nom,
                      )
                    : CulturalGuideContext.general;
                context.push('/culture/guide', extra: guideContext);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: CultureTheme.accentOrange,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 2. Filtre Régional Transversal (Pilule cliquable compacte)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => CultureRegionBottomSheet.show(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: filterState.hasActiveFilter
                      ? CultureTheme.primaryBlue.withValues(alpha: 0.15)
                      : (isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: filterState.hasActiveFilter
                        ? CultureTheme.primaryBlue
                        : borderCol,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: filterState.hasActiveFilter
                          ? CultureTheme.primaryBlue
                          : subtitleColor,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 80),
                      child: Text(
                        filterState.displayName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: filterState.hasActiveFilter
                              ? CultureTheme.primaryBlue
                              : titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (filterState.hasActiveFilter) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.clearFilter();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: CultureTheme.primaryBlue.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 10,
                            color: CultureTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 15,
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
