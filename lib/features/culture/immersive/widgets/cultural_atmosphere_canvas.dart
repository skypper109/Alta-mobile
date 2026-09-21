import 'package:flutter/material.dart';

/// Canvas d'ambiance culturelle malienne épuré sans motifs intrusifs ni animations de fond
class CulturalAtmosphereCanvas extends StatelessWidget {
  final Widget child;

  /// Activer ou désactiver les micro-particules dorées (désactivé pour un affichage net)
  final bool enableParticles;

  /// Activer ou désactiver les motifs géométriques Bogolan (désactivé pour un fond épuré)
  final bool enableBogolanMotifs;

  /// Opacité des motifs Bogolan
  final double motifOpacity;

  const CulturalAtmosphereCanvas({
    super.key,
    required this.child,
    this.enableParticles = false,
    this.enableBogolanMotifs = false,
    this.motifOpacity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
