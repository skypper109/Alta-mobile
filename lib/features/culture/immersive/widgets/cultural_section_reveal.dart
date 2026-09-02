import 'package:flutter/material.dart';
import 'animated_cultural_reveal.dart';

/// Conteneur d'apparition échelonnée (Staggered animation) pour les sections culturelles.
/// Révèle successivement le titre, puis chaque carte/élément avec un décalage temporel fluide.
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
    this.itemDelay = const Duration(milliseconds: 55),
    this.itemDuration = const Duration(milliseconds: 300),
    this.offset = const Offset(0.0, 0.05),
    this.beginScale = 0.98,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: List.generate(children.length, (index) {
        final delay = baseDelay + (itemDelay * index);
        return AnimatedCulturalReveal(
          delay: delay,
          duration: itemDuration,
          offset: offset,
          beginScale: beginScale,
          child: children[index],
        );
      }),
    );
  }
}
