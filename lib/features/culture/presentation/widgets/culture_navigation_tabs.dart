import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/culture_theme.dart';
import '../../../../presentation/common/widgets/universe_splash_transition.dart';

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
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
    ),
    _TabItem(
      title: 'Jeux & Contes',
      icon: Icons.auto_stories_outlined,
      selectedIcon: Icons.auto_stories_rounded,
    ),
    _TabItem(
      title: 'Passeport',
      icon: Icons.badge_outlined,
      selectedIcon: Icons.badge_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF121B2D) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF23314D) : const Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
      child: Row(
        children: [
          // ── Bouton retour éducation Solide Opaque ─────────────────────────
          _BackToEducationButton(isDark: isDark),

          const SizedBox(width: 8),

          // ── Barre de navigation Culture Solide Opaque ─────────────────────
          Expanded(
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: navBg,
                borderRadius: BorderRadius.circular(33),
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
                        HapticFeedback.selectionClick();
                        onTabSelected(index);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 14 : 9,
                        vertical: 9,
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
                        children: [
                          Icon(
                            isSelected ? tab.selectedIcon : tab.icon,
                            size: 21,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF64748B)),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                tab.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
    );
  }
}

// ── Bouton retour Éducation avec Splash Transition ───────────────────────────
class _BackToEducationButton extends StatelessWidget {
  final bool isDark;

  const _BackToEducationButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF121B2D) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF23314D) : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        UniverseSplashTransition.toEducation(
          context,
          onComplete: () => context.go('/home'),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
