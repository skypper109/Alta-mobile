import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/culture_theme.dart';

/// Carte culturelle épurée, réactive et sans animation de rebond
class CulturalInteractiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color activeAccentColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool showSudaneseCorners;
  final double? width;
  final double? height;

  const CulturalInteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.activeAccentColor = CultureTheme.accentOrange,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.showSudaneseCorners = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final defaultBorder =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final cardContent = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.22 : 0.05,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: padding,
            child: child,
          ),
          if (showSudaneseCorners)
            Positioned(
              top: 0,
              right: 18,
              child: Container(
                width: 14,
                height: 4,
                decoration: BoxDecoration(
                  color: activeAccentColor.withValues(alpha: 0.45),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return cardContent;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap!();
      },
      behavior: HitTestBehavior.opaque,
      child: cardContent,
    );
  }
}
