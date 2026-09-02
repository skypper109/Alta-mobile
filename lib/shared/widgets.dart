library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../presentation/common/widgets/custom_button.dart';
import '../presentation/common/widgets/custom_card.dart';

export '../presentation/common/widgets/alternia_logo.dart';
export '../presentation/common/widgets/alternia_top_header_bar.dart';
export '../presentation/common/widgets/custom_button.dart';
export '../presentation/common/widgets/custom_card.dart';

class DetShellScaffold extends StatelessWidget {
  const DetShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCultureTab = navigationShell.currentIndex == 3;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF121B2D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF23314D) : const Color(0xFFE2E8F0);

    final items = const [
      _NavItemData(
        branchIndex: 0,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Accueil',
      ),
      _NavItemData(
        branchIndex: 1,
        icon: Icons.forum_outlined,
        selectedIcon: Icons.forum_rounded,
        label: 'Discussions',
      ),
      _NavItemData(
        branchIndex: 2,
        icon: Icons.folder_open_outlined,
        selectedIcon: Icons.folder_rounded,
        label: 'Documents',
      ),
      _NavItemData(
        branchIndex: 4,
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: 'Profil',
      ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: isCultureTab
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(
                children: [
                  // ── Barre de navigation Éducation ──────────────────────────
                  Expanded(
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: navBg,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : AppColors.primary)
                                .withValues(alpha: isDark ? 0.45 : 0.12),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(items.length, (index) {
                          final item = items[index];
                          final isSelected =
                              navigationShell.currentIndex == item.branchIndex;

                          return GestureDetector(
                            onTap: () {
                              if (navigationShell.currentIndex != item.branchIndex) {
                                _onTabSelected(item.branchIndex);
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
                                gradient: isSelected ? AppColors.primaryGradient : null,
                                color: isSelected ? null : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: isDark ? 0.4 : 0.25),
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
                                    isSelected ? item.selectedIcon : item.icon,
                                    size: 20,
                                    color: isSelected
                                        ? AppColors.secondary
                                        : (isDark
                                            ? AppColors.textMuted
                                            : const Color(0xFF64748B)),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      item.label,
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

                  const SizedBox(width: 8),

                  // ── Bouton aller à la Culture (à droite) ───────────────────
                  _GoToCultureButton(
                    isDark: isDark,
                    onTap: () => _onTabSelected(3),
                  ),
                ],
              ),
            ),
    );
  }
}

class _GoToCultureButton extends StatelessWidget {
  const _GoToCultureButton({
    required this.isDark,
    required this.onTap,
  });

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF121B2D) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF23314D) : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
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
              Icons.public_rounded,
              size: 20,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
            ),
            const SizedBox(height: 2),
            Text(
              'Culture',
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

class _NavItemData {
  const _NavItemData({
    required this.branchIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
  final int branchIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class StatusBrick extends StatelessWidget {
  const StatusBrick({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.isPulsing = false,
  });

  final String label;
  final Color color;
  final bool isPulsing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class DetSectionHeader extends StatelessWidget {
  const DetSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onAction!();
            },
            child: Text(
              actionLabel!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ),
      ],
    );
  }
}

class DetLoading extends StatelessWidget {
  const DetLoading({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.secondary),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class DetErrorWidget extends StatelessWidget {
  const DetErrorWidget({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomCard(
          borderColor: AppColors.error.withValues(alpha: 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 36, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                CustomButton(
                  label: 'Réessayer',
                  icon: Icons.refresh_rounded,
                  variant: CustomButtonVariant.secondary,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DetEmptyState extends StatelessWidget {
  const DetEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Bouton stylisé d'accès à l'Avatar / Salon Live pour les TopBars
class AlterniaAvatarTopBarButton extends StatelessWidget {
  const AlterniaAvatarTopBarButton({
    super.key,
    this.showLabel = true,
  });

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceAlt : Colors.white;
    final borderColor = isDark
        ? AppColors.secondary.withValues(alpha: 0.4)
        : AppColors.secondary.withValues(alpha: 0.5);
    final textColor = isDark
        ? AppColors.secondary
        : const Color(0xFF0E7490);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/holo-salon');
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showLabel ? 10 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: isDark ? 0.25 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                gradient: AppColors.cyanGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                'Salon Live',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
