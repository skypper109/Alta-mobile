import 'package:flutter/material.dart';

/// Composant d'affichage direct et fluide sans animation intrusive ni retard d'apparition
class AnimatedCulturalReveal extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset offset;
  final double beginScale;
  final Curve curve;
  final VoidCallback? onCompleted;

  const AnimatedCulturalReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 320),
    this.delay = Duration.zero,
    this.offset = const Offset(0.0, 0.06),
    this.beginScale = 0.98,
    this.curve = Curves.easeOutCubic,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (onCompleted != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onCompleted?.call());
    }
    return child;
  }
}
