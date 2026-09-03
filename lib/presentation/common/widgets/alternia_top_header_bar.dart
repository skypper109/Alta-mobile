import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/culture/core/controllers/culture_filter_controller.dart';
import '../../../features/culture/core/models/cultural_guide_models.dart';
import '../../../features/culture/core/theme/culture_theme.dart';
import '../../../features/culture/presentation/widgets/culture_region_bottom_sheet.dart';
import '../../../shared/widgets.dart';
import '../providers/theme_provider.dart';

/// Variante de l'en-tête selon l'univers (Éducation ou Culture)
enum AlterniaHeaderVariant {
  education,
  culture,
}

/// En-tête supérieur réutilisable et harmonisé pour AlterniA
/// Logo à gauche partout avec "AlterniA" ("iA" en bleu cyan pour Éducation, "iA" en orange pour Culture)
/// Côté droit :
/// - Éducation : Salon Live + Mode clair/sombre + Avatar profil
/// - Culture : Filtre régional (icône localisation) + Guide culturel IA (icône robot)
class AlterniaTopHeaderBar extends ConsumerWidget {
  final AlterniaHeaderVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onLocationTap;
  final VoidCallback? onGuideAiTap;

  const AlterniaTopHeaderBar({
    super.key,
    this.variant = AlterniaHeaderVariant.education,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 16, 10),
    this.onLocationTap,
    this.onGuideAiTap,
  });

  const AlterniaTopHeaderBar.education({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 16, 10),
  })  : variant = AlterniaHeaderVariant.education,
        onLocationTap = null,
        onGuideAiTap = null;

  const AlterniaTopHeaderBar.culture({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 16, 10),
    this.onLocationTap,
    this.onGuideAiTap,
  }) : variant = AlterniaHeaderVariant.culture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCulture = variant == AlterniaHeaderVariant.culture;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 1. LOGO ALTERNIA (Gauche) ─────────────────────────────────────
          // iA en bleu/cyan pour l'éducation, iA en jaune pour la culture
          AlterniaLogo(
            size: 34,
            showText: true,
            iaColor: isCulture ? CultureTheme.iaYellow : AppColors.secondary,
          ),

          const Spacer(),

          // ── 2. ACTIONS DU HEADER (Droite) ─────────────────────────────────
          if (isCulture) ...[
            _buildCultureActions(context, ref, isDark),
          ] else ...[
            _buildEducationActions(context, ref, isDark),
          ],
        ],
      ),
    );
  }

  // ── ACTIONS POUR LA SECTION CULTURE ─────────────────────────────────────────
  Widget _buildCultureActions(BuildContext context, WidgetRef ref, bool isDark) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Filtre Régional Transversal (Icône seule avec indicateur actif)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onLocationTap ??
                () {
                  HapticFeedback.lightImpact();
                  CultureRegionBottomSheet.show(context);
                },
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: filterState.hasActiveFilter
                        ? CultureTheme.primaryBlue.withValues(
                            alpha: isDark ? 0.20 : 0.12,
                          )
                        : (isDark
                            ? CultureTheme.darkSurfaceAlt
                            : CultureTheme.lightSurfaceAlt),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: filterState.hasActiveFilter
                          ? CultureTheme.primaryBlue
                          : borderCol,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 20,
                      color: filterState.hasActiveFilter
                          ? CultureTheme.primaryBlue
                          : subtitleColor,
                    ),
                  ),
                ),
                if (filterState.hasActiveFilter)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: CultureTheme.accentOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? CultureTheme.darkBackground
                              : Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 2. Bouton Guide Culturel IA (Icône Robot)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onGuideAiTap ??
                () {
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(
                  alpha: isDark ? 0.20 : 0.12,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 20,
                  color: CultureTheme.accentOrange,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── ACTIONS POUR LA SECTION ÉDUCATION ───────────────────────────────────────
  Widget _buildEducationActions(BuildContext context, WidgetRef ref, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar Salon Live Action Button (Icône seule)
        const AlterniaAvatarTopBarButton(showLabel: false),
        const SizedBox(width: 8),

        // Theme Mode Switcher (Sun ☀️ / Moon 🌙)
        GestureDetector(
          onTap: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              size: 18,
              color: isDark ? AppColors.accent : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
