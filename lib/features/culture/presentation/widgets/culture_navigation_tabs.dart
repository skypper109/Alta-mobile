import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';

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
      title: 'Découvrir',
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
    ),
    _TabItem(
      title: 'Contes',
      icon: Icons.record_voice_over_outlined,
      selectedIcon: Icons.record_voice_over_rounded,
    ),
    _TabItem(
      title: 'Défis',
      icon: Icons.quiz_outlined,
      selectedIcon: Icons.quiz_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF121B2D) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF23314D) : const Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          // ── Bouton retour éducation ──────────────────────────────────────
          _BackToEducationButton(isDark: isDark),

          const SizedBox(width: 8),

          // ── Barre de navigation Culture ──────────────────────────────────
          Expanded(
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: navBg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : CultureTheme.accentOrange)
                        .withValues(alpha: isDark ? 0.45 : 0.12),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
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
                        horizontal: isSelected ? 14 : 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CultureTheme.accentOrange
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
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
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF64748B)),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Text(
                              tab.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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

// ── Bouton retour éducation ──────────────────────────────────────────────────
class _BackToEducationButton extends StatelessWidget {
  const _BackToEducationButton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF121B2D) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF23314D) : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.go('/home');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey)
                  .withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 20,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
            ),
            const SizedBox(height: 2),
            Text(
              'Éduc.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
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
