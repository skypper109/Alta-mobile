import 'package:flutter/material.dart';

/// Conteneur de section culturelle à affichage direct sans délai échelonné
class CulturalSectionReveal extends StatelessWidget {
  final List<Widget> children;
  final Duration baseDelay;
  final Duration itemDelay;
  final Duration itemDuration;
  final Offset offset;
  final double beginScale;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const CulturalSectionReveal({
    super.key,
    required this.children,
    this.baseDelay = Duration.zero,
    this.itemDelay = Duration.zero,
    this.itemDuration = Duration.zero,
    this.offset = Offset.zero,
    this.beginScale = 1.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}
