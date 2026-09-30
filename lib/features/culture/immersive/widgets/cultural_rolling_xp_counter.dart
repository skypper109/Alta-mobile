import 'package:flutter/material.dart';
import '../../core/theme/culture_theme.dart';

/// Compteur d'XP à défilement fluide (Rolling Numbers)
/// Anime dynamiquement la montée des points de sagesse de 0 à la valeur cible.
class CulturalRollingXpCounter extends StatelessWidget {
  final int targetXp;
  final TextStyle style;
  final Duration duration;
  final String prefix;
  final String suffix;
  final TextStyle? suffixStyle;

  const CulturalRollingXpCounter({
    super.key,
    required this.targetXp,
    required this.style,
    this.duration = const Duration(milliseconds: 1100),
    this.prefix = '',
    this.suffix = '',
    this.suffixStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: targetXp.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final currentNumber = value.toInt();
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (prefix.isNotEmpty)
              Text(
                prefix,
                style: style,
              ),
            Text(
              '$currentNumber',
              style: style,
            ),
            if (suffix.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                suffix,
                style: suffixStyle ?? style,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Barre de progression élastique culturelle (Animation avec rebond subtil sans dégradé)
class CulturalSpringProgressBar extends StatelessWidget {
  final double progress; // 0.0 à 1.0
  final double height;
  final Color fillColor;
  final Color trackColor;
  final Duration duration;

  const CulturalSpringProgressBar({
    super.key,
    required this.progress,
    this.height = 6.0,
    this.fillColor = CultureTheme.accentOrange,
    this.trackColor = const Color(0xFFE2E8F0),
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Stack(
        children: [
          Container(
            height: height,
            width: double.infinity,
            color: trackColor,
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress.clamp(0.02, 1.0)),
            duration: duration,
            curve: Curves.easeOutBack,
            builder: (context, val, child) {
              return FractionallySizedBox(
                widthFactor: val,
                child: Container(
                  height: height,
                  color: fillColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
