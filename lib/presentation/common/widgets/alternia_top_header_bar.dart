import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/sync_queue_service.dart';
import '../../../features/culture/core/controllers/culture_filter_controller.dart';
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
  final VoidCallback? onSearchTap;
  final VoidCallback? onSageTap;
  final VoidCallback? onScannerTap;
  final VoidCallback? onContribuerTap;

  const AlterniaTopHeaderBar({
    super.key,
    this.variant = AlterniaHeaderVariant.education,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 16, 10),
    this.onLocationTap,
    this.onGuideAiTap,
    this.onSearchTap,
    this.onSageTap,
    this.onScannerTap,
    this.onContribuerTap,
  });

  const AlterniaTopHeaderBar.education({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 16, 10),
  })  : variant = AlterniaHeaderVariant.education,
        onLocationTap = null,
        onGuideAiTap = null,
        onSearchTap = null,
        onSageTap = null,
        onScannerTap = null,
        onContribuerTap = null;

  const AlterniaTopHeaderBar.culture({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 16, 10),
    this.onLocationTap,
    this.onGuideAiTap,
    this.onSearchTap,
    this.onSageTap,
    this.onScannerTap,
    this.onContribuerTap,
  }) : variant = AlterniaHeaderVariant.culture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCulture = variant == AlterniaHeaderVariant.culture;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    final logoSize = isTablet ? 42.0 : 34.0;
    final effectivePadding = isTablet
        ? const EdgeInsets.fromLTRB(28, 14, 28, 12)
        : padding;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: Padding(
          padding: effectivePadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── 1. LOGO ALTERNIA (Gauche - tap pour revenir au choix d'univers) ─
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/gateway');
                },
                behavior: HitTestBehavior.opaque,
                child: AlterniaLogo(
                  size: logoSize,
                  showText: true,
                  iaColor: isCulture ? CultureTheme.iaYellow : AppColors.secondary,
                ),
              ),

              const Spacer(),

              // ── 2. ACTIONS DU HEADER (Droite) ─────────────────────────────────
              if (isCulture) ...[
                _buildCultureActions(context, ref, isDark, isTablet),
              ] else ...[
                _buildEducationActions(context, ref, isDark, isTablet),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── ACTIONS POUR LA SECTION CULTURE ─────────────────────────────────────────
  Widget _buildCultureActions(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    bool isTablet,
  ) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final btnSize = isTablet ? 44.0 : 38.0;
    final iconSize = isTablet ? 22.0 : 20.0;
    final btnRadius = BorderRadius.circular(isTablet ? 14.0 : 12.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 0. Bouton Scanner IA de Monuments & Lieux
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onScannerTap ??
                () {
                  HapticFeedback.lightImpact();
                  context.push('/culture/scanner');
                },
            borderRadius: btnRadius,
            child: Container(
              width: btnSize,
              height: btnSize,
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(
                  alpha: isDark ? 0.22 : 0.14,
                ),
                borderRadius: btnRadius,
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.document_scanner_rounded,
                  size: iconSize,
                  color: CultureTheme.accentOrange,
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: isTablet ? 12 : 8),

        // 1. Bouton Recherche Culturelle IA (Icône Loupe Plein Écran)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSearchTap ??
                () {
                  HapticFeedback.lightImpact();
                  context.push('/culture/search');
                },
            borderRadius: btnRadius,
            child: Container(
              width: btnSize,
              height: btnSize,
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(
                  alpha: isDark ? 0.20 : 0.12,
                ),
                borderRadius: btnRadius,
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.search_rounded,
                  size: iconSize,
                  color: CultureTheme.accentOrange,
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: isTablet ? 12 : 8),

        // 2. Filtre Régional Transversal (Icône seule avec indicateur actif)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onLocationTap ??
                () {
                  HapticFeedback.lightImpact();
                  CultureRegionBottomSheet.show(context);
                },
            borderRadius: btnRadius,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: btnSize,
                  height: btnSize,
                  decoration: BoxDecoration(
                    color: filterState.hasActiveFilter
                        ? CultureTheme.primaryBlue.withValues(
                            alpha: isDark ? 0.20 : 0.12,
                          )
                        : (isDark
                            ? CultureTheme.darkSurfaceAlt
                            : CultureTheme.lightSurfaceAlt),
                    borderRadius: btnRadius,
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
                      size: iconSize,
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
                      width: isTablet ? 11 : 9,
                      height: isTablet ? 11 : 9,
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

        SizedBox(width: isTablet ? 12 : 8),

        // 3. Bouton Veillée au Coin du Feu & Grand-mère Mah (Chat Immersif avec Avatar & Voix)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSageTap ??
                () {
                  HapticFeedback.mediumImpact();
                  final activeReg = filterState.activeRegion;
                  context.push('/culture/sage', extra: activeReg);
                },
            borderRadius: btnRadius,
            child: Container(
              width: btnSize,
              height: btnSize,
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(
                  alpha: isDark ? 0.20 : 0.12,
                ),
                borderRadius: btnRadius,
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.45),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: iconSize,
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
  Widget _buildEducationActions(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    bool isTablet,
  ) {
    final syncState = ref.watch(syncQueueProvider);
    final btnPadding = EdgeInsets.all(isTablet ? 11.0 : 8.0);
    final iconSize = isTablet ? 22.0 : 18.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton Indicateur Store & Forward (Synchronisation Asynchrone)
        GestureDetector(
          onTap: () => showSyncStatusModalSheet(context),
          child: Container(
            padding: btnPadding,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: syncState.hasPending
                    ? AppColors.warning.withValues(alpha: 0.7)
                    : (isDark ? AppColors.border : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  syncState.isSyncing
                       ? Icons.sync_rounded
                      : (syncState.hasPending
                          ? Icons.cloud_queue_rounded
                          : Icons.cloud_done_rounded),
                  size: iconSize,
                  color: syncState.hasPending
                      ? AppColors.warning
                      : (syncState.isOnline
                          ? AppColors.secondary
                          : (isDark ? AppColors.textMuted : const Color(0xFF94A3B8))),
                ),
                if (syncState.hasPending)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: isTablet ? 9 : 7,
                      height: isTablet ? 9 : 7,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: isTablet ? 12 : 8),

        // Avatar Salon Live Action Button (Icône seule)
        const AlterniaAvatarTopBarButton(showLabel: false),
        SizedBox(width: isTablet ? 12 : 8),

        // Theme Mode Switcher (Sun ☀️ / Moon 🌙)
        GestureDetector(
          onTap: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
          child: Container(
            padding: btnPadding,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              size: iconSize,
              color: isDark ? AppColors.accent : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
