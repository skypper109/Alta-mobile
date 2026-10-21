import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../presentation/common/widgets/class_selection_required_sheet.dart';
import '../../../../presentation/common/widgets/universe_splash_transition.dart';
import '../../../profile/user_prefs_notifier.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';

/// Barre de navigation Culture premium — même design que DetShellScaffold
/// Floating pill, icônes outline/filled, label animé, couleur orange charte
/// + bouton de retour vers l'espace éducation (Accueil)
class CultureNavigationTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CultureNavigationTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const List<_TabItem> _tabs = [
    _TabItem(
      title: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _TabItem(
      title: 'Découverte',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
    ),
    _TabItem(
      title: 'Explorer+',
      icon: Icons.widgets_outlined,
      selectedIcon: Icons.widgets_rounded,
    ),
    _TabItem(
      title: 'Parcours',
      icon: Icons.timeline_outlined,
      selectedIcon: Icons.timeline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF121B2D) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF23314D) : const Color(0xFFE2E8F0);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmall = screenWidth < 360;
    final isCompact = screenWidth < 390;

    final outerHPad = isSmall ? 10.0 : (isCompact ? 12.0 : 16.0);
    final outerBPad = isSmall ? 18.0 : 22.0;
    final buttonHPad = isSmall ? 10.0 : 12.0;
    final gap = isSmall ? 6.0 : 8.0;

    final iconSize = isSmall ? 19.5 : 21.0;
    final fontSize = isSmall ? 11.0 : (isCompact ? 11.5 : 12.0);
    final selectedHPad = isSmall ? 9.0 : (isCompact ? 11.0 : 13.0);
    final unselectedHPad = isSmall ? 6.5 : (isCompact ? 8.0 : 9.5);
    final maxLabelWidth = isSmall ? 85.0 : (isCompact ? 100.0 : 125.0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: CultureResponsive.kMaxNavTabsWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(outerHPad, 0, outerHPad, outerBPad),
          child: Row(
        children: [
          // ── Bouton retour éducation Solide Opaque ─────────────────────────
          _BackToEducationButton(
            isDark: isDark,
            horizontalPadding: buttonHPad,
          ),

          SizedBox(width: gap),

          // ── Barre de navigation Culture Solide Opaque ─────────────────────
          Expanded(
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: navBg,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : CultureTheme.accentOrange)
                        .withValues(alpha: isDark ? 0.45 : 0.12),
                    blurRadius: 22,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      if (selectedIndex != index) {
                        CulturalHaptics.tabSwitch();
                        onTabSelected(index);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? selectedHPad : unselectedHPad,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CultureTheme.accentOrange
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: CultureTheme.accentOrange
                                      .withValues(alpha: isDark ? 0.4 : 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected ? tab.selectedIcon : tab.icon,
                            size: iconSize,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF64748B)),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 5),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxLabelWidth,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  tab.title,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}

// ── Bouton retour Éducation avec Splash Transition ───────────────────────────
class _BackToEducationButton extends ConsumerWidget {
  final bool isDark;
  final double horizontalPadding;

  const _BackToEducationButton({
    required this.isDark,
    this.horizontalPadding = 12.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = isDark ? const Color(0xFF121B2D) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF23314D) : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final userPrefs = ref.read(userPrefsProvider);
        if (!userPrefs.hasSelectedClass) {
          final chosen = await showClassSelectionRequiredSheet(context);
          if (!chosen || !context.mounted) {
            return;
          }
        }
        if (context.mounted) {
          UniverseSplashTransition.toEducation(
            context,
            onComplete: () => context.go('/home'),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey)
                  .withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 22,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
            ),
            const SizedBox(height: 3),
            Text(
              'Éduc.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Modèle d'onglet ──────────────────────────────────────────────────────────
class _TabItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  const _TabItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });
}
