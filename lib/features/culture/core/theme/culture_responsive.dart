import 'package:flutter/material.dart';

/// Architecture Réactive Unifiée pour l'espace Culture d'AlterniA
/// Assure une expérience premium et harmonieuse sur smartphones, tablettes et grands écrans.
abstract final class CultureResponsive {
  // ── Points de rupture d'écran (Breakpoints) ────────────────────────────────
  static const double kMobileMax = 599.0;
  static const double kTabletMin = 600.0;
  static const double kTabletLarge = 900.0;
  static const double kDesktopMin = 1100.0;

  // ── Contraintes de largeur maximale pour confort de lecture & esthétique ───
  static const double kMaxContentWidth = 1140.0;
  static const double kMaxFormWidth = 780.0;
  static const double kMaxNavTabsWidth = 640.0;
  static const double kMaxDetailWidth = 920.0;
  static const double kMaxDialogWidth = 560.0;

  /// Indique si l'appareil est une tablette (largeur >= 600px)
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= kTabletMin;
  }

  /// Indique si l'appareil est une grande tablette ou bureau (largeur >= 900px)
  static bool isLargeTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= kTabletLarge;
  }

  /// Indique si l'appareil est un smartphone (largeur < 600px)
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < kTabletMin;
  }

  /// Marge horizontale adaptative : 12-20px sur mobile, 28-40px sur tablette
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= kDesktopMin) return 40.0;
    if (width >= kTabletMin) return 32.0;
    if (width < 360) return 12.0;
    return 20.0;
  }

  /// Nombre de colonnes de grille pour les catalogues d'exploration (Monuments, Personnages, Villes)
  static int catalogGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= kDesktopMin) return 4;
    if (width >= kTabletLarge) return 4;
    if (width >= kTabletMin) return 3;
    return 2;
  }

  /// Aspect ratio optimal pour les cartes de découverte
  static double catalogGridAspectRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= kDesktopMin) return 0.72;
    if (width >= kTabletMin) return 0.70;
    return 0.66;
  }

  /// Nombre de colonnes pour les sous-sections de listes (Contes, Devinettes, Proverbes, Quiz)
  static int listSectionColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= kTabletMin) return 2;
    return 1;
  }

  /// Conteneur centré avec largeur maximale sécurisée
  static Widget constrainedCentered({
    required Widget child,
    double maxWidth = kMaxContentWidth,
    EdgeInsetsGeometry? padding,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding, child: child) : child,
      ),
    );
  }
}
