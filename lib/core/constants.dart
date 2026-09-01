// ─── AlterniA — Constantes Globales (Design System Charte Officielle) ──────────
// Palette officielle AlterniA : Bleu #314999 (primaire), Orange #F1851F, Cyan #40BBCC.
library;

import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
// CONFIGURATION SERVEUR ALTERNIA (BACKEND IA & RAG)
// ══════════════════════════════════════════════════════════════════════════════
abstract final class AltaApiConfig {
  static const String serverBaseUrl = 'https://nation-institutional-freeware-representations.trycloudflare.com';
}

// ══════════════════════════════════════════════════════════════════════════════
// COULEURS (CHARTE OFFICIELLE ALTERNIA)
// ══════════════════════════════════════════════════════════════════════════════
abstract final class AltaColors {
  // ── Couleur Primaire Dominante : Bleu Marine #314999 ──────────────────────
  static const Color primary       = Color(0xFF314999);
  static const Color primaryLight  = Color(0xFF4A6BC7); // variante claire
  static const Color primaryBg     = Color(0xFF0D1833); // fond sombre primaire

  // ── Couleur Secondaire Orange : #F1851F ───────────────────────────────────
  static const Color accent        = Color(0xFFF1851F);
  static const Color accentLight   = Color(0xFFFF9D45);
  static const Color accentBg      = Color(0xFF2A1A08);

  // ── Couleur Secondaire Cyan / Turquoise : #40BBCC ─────────────────────────
  static const Color secondary     = Color(0xFF40BBCC);
  static const Color secondaryLight= Color(0xFF62D0DF);
  static const Color secondaryBg   = Color(0xFF072830);

  // ── Fonds Dark Mode ────────────────────────────────────────────────────────
  static const Color backgroundDark  = Color(0xFF0D1525); // bleu très sombre
  static const Color surfaceDark     = Color(0xFF141B2D);
  static const Color surfaceAltDark  = Color(0xFF1A2340);
  static const Color borderDark      = Color(0xFF253050);
  static const Color borderFocusDark = Color(0xFF314999);

  // ── Fonds Light Mode ───────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF4F6FB);
  static const Color surfaceLight    = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFEEF2FA);
  static const Color borderLight     = Color(0xFFD0D9EE);
  static const Color borderFocusLight= Color(0xFF314999);

  // ── Textes Dark ────────────────────────────────────────────────────────────
  static const Color textPrimaryDark   = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0BEDA);
  static const Color textMutedDark     = Color(0xFF6A7DAA);

  // ── Textes Light ───────────────────────────────────────────────────────────
  static const Color textPrimaryLight   = Color(0xFF0D1525);
  static const Color textSecondaryLight = Color(0xFF4A5878);
  static const Color textMutedLight     = Color(0xFF8A9ABB);

  // ── Sémantiques ────────────────────────────────────────────────────────────
  static const Color success   = Color(0xFF10B981);
  static const Color successBg = Color(0xFF0D2820);
  static const Color warning   = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFF2B2110);
  static const Color error     = Color(0xFFEF4444);
  static const Color errorBg   = Color(0xFF2B1214);
  static const Color info      = Color(0xFF40BBCC);

  // ── Accents Violets (rétro-compat) ────────────────────────────────────────
  static const Color accentViolet   = Color(0xFF8B5CF6);
  static const Color accentVioletBg = Color(0xFF1A1035);
  static const Color accentGreen    = Color(0xFF10B981);
  static const Color accentGreenDim = Color(0xFF059669);
  static const Color accentGreenBg  = Color(0xFF0D2820);
  static const Color accentAmber    = Color(0xFFF59E0B);
  static const Color accentAmberBg  = Color(0xFF2B2110);
  static const Color accentOrange   = Color(0xFFF1851F);
  static const Color accentOrangeBg = Color(0xFF2A1A08);
  static const Color accentCyan     = Color(0xFF40BBCC);
  static const Color accentCyanBg   = Color(0xFF072830);

  // ── Divers ─────────────────────────────────────────────────────────────────
  static const Color transparent = Colors.transparent;

  // ── Aliases thème courant (dark par défaut, résolu via Theme.of(context)) ─
  /// Accès direct (dark) — à utiliser dans les widgets statiques
  static const Color background = backgroundDark;
  static const Color surface    = surfaceDark;
  static const Color surfaceAlt = surfaceAltDark;
  static const Color border     = borderDark;
  static const Color borderFocus= borderFocusDark;
  static const Color textPrimary   = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textMuted     = textMutedDark;
  static const Color divider    = borderDark;
  static const Color overlay    = Color(0xEB0D1525);
  static const Color shimmerBase     = surfaceDark;
  static const Color shimmerHighlight = surfaceAltDark;

  // ── Gradients Officiels ────────────────────────────────────────────────────
  static const LinearGradient heroBannerGradient = LinearGradient(
    colors: [Color(0xFF314999), Color(0xFF1A2340)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF1851F), Color(0xFFFF9D45)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF40BBCC), Color(0xFF62D0DF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Alias pour rétro-compat
  static const Color primaryLight2 = Color(0xFF4A6BC7);
  static const Color accentViolet2 = accentViolet;
}

// Alias global pour rétro-compatibilité (widgets utilisant DetColors)
typedef DetColors = AltaColors;

// ══════════════════════════════════════════════════════════════════════════════
// TAILLES & ESPACEMENTS
// ══════════════════════════════════════════════════════════════════════════════
abstract final class DetSizes {
  // ── Espacements ──────────────────────────────────────────────────────────
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // ── Rayons ────────────────────────────────────────────────────────────────
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;

  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));

  // ── Bordures ─────────────────────────────────────────────────────────────
  static const double borderWidth      = 1.5;
  static const double borderWidthFocus = 2.0;

  // ── Boutons & Composants ─────────────────────────────────────────────────
  static const double buttonHeight    = 52.0;
  static const double buttonHeightSm  = 42.0;
  static const double appBarHeight    = 64.0;

  // ── Icônes ────────────────────────────────────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
}

// ══════════════════════════════════════════════════════════════════════════════
// TYPOGRAPHIES
// ══════════════════════════════════════════════════════════════════════════════
abstract final class DetTextStyles {
  static const String fontUI   = 'PlusJakartaSans';
  static const String fontMono = 'JetBrainsMono';

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontUI,
    fontSize: 30.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: fontUI,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static const TextStyle headingLg = TextStyle(
    fontFamily: fontUI,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headingMd = TextStyle(
    fontFamily: fontUI,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle headingSm = TextStyle(
    fontFamily: fontUI,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.4,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontUI,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontUI,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontUI,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: fontUI,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: fontUI,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontUI,
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle codeMd = TextStyle(
    fontFamily: fontMono,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle codeSm = TextStyle(
    fontFamily: fontMono,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// CHAÎNES OFFICIELLES AlterniA
// ══════════════════════════════════════════════════════════════════════════════
abstract final class DetStrings {
  static const String appName          = 'AlterniA';
  static const String appTagline       = 'Ton compagnon pédagogique intelligent';
  static const String navHome          = 'Accueil';
  static const String navDiscussions   = 'Discussions';
  static const String navDocuments     = 'Documents';
  static const String navCulture       = 'Culture';
  static const String navProfile       = 'Profil';

  // Rétro-compat
  static const String navExercises     = 'Documents';

  static const String deviceConnected    = 'Boîtier Connecté';
  static const String deviceDisconnected = 'Boîtier Hors-Ligne';
  static const String deviceScanning    = 'Recherche des boîtiers…';
  static const String deviceScan        = 'Scanner les boîtiers';
  static const String deviceConnect     = 'Se connecter';

  static const String exerciseScan    = 'Scanner un exercice';
  static const String exerciseCapture = 'Prendre une photo';
  static const String exerciseHints   = 'Indices Socratiques';

  static const String progressTitle  = 'Carnet de compétences';
  static const String levels         = 'Niveaux scolaires';

  static const String errUnknown = 'Une erreur inattendue est survenue.';

  // Nom de l'IA
  static const String aiName     = 'AlterniA';
  static const String aiNameFull = 'Professeur AlterniA';
  static const String aiTagline  = 'Ton Professeur IA Personnel';
}

abstract final class DetDurations {
  static const Duration fast     = Duration(milliseconds: 150);
  static const Duration normal   = Duration(milliseconds: 250);
  static const Duration slow     = Duration(milliseconds: 400);
  static const Duration pulse    = Duration(milliseconds: 1200);
  static const Duration waveform = Duration(milliseconds: 1000);
}

// ══════════════════════════════════════════════════════════════════════════════
// HELPER — Résolution des couleurs selon le thème courant
// ══════════════════════════════════════════════════════════════════════════════
extension AltaThemeExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg         => isDark ? AltaColors.backgroundDark  : AltaColors.backgroundLight;
  Color get surf       => isDark ? AltaColors.surfaceDark      : AltaColors.surfaceLight;
  Color get surfAlt    => isDark ? AltaColors.surfaceAltDark   : AltaColors.surfaceAltLight;
  Color get bdColor    => isDark ? AltaColors.borderDark       : AltaColors.borderLight;
  Color get textPri    => isDark ? AltaColors.textPrimaryDark  : AltaColors.textPrimaryLight;
  Color get textSec    => isDark ? AltaColors.textSecondaryDark: AltaColors.textSecondaryLight;
  Color get textMut    => isDark ? AltaColors.textMutedDark    : AltaColors.textMutedLight;
}
