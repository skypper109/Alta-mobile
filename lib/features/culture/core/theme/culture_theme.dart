import 'package:flutter/material.dart';

/// Palette culturelle officielle AlterniA & Mali
abstract final class CultureTheme {
  // ── Couleurs officielles de la charte AlterniA ──────────────────────────────
  static const Color primaryBlue    = Color(0xFF314999); // Bleu institutionnel AlterniA
  static const Color accentOrange   = Color(0xFFF1851F); // Orange vivant
  static const Color cyanTurquoise  = Color(0xFF40BBCC); // Cyan technologique

  // ── Palette culturelle & patrimoniale Malienne ──────────────────────────────
  static const Color ocreTerre      = Color(0xFFC67C2E); // Ocre / Terre cuite
  static const Color sable          = Color(0xFFF3E7D3); // Sable saharien
  static const Color sableDark      = Color(0xFF2C241B); // Fond sable sombre
  static const Color vertNaturel    = Color(0xFF4E7A4D); // Vert nature / Kénédougou
  static const Color orPatrimoine   = Color(0xFFD8A22A); // Or Mansa Moussa / Empire du Mali
  static const Color rougeKoulikoro = Color(0xFFB84A39); // Latérite mandingue
  static const Color fleuveNiger    = Color(0xFF48CAE4); // Eaux du Djoliba (Fleuve Niger)

  // ── Fonds et surfaces immersives Culture ────────────────────────────────────
  static const Color darkBackground = Color(0xFF090E18); // Fond nuit africaine profond
  static const Color darkSurface    = Color(0xFF131B2A); // Carte surface sombre
  static const Color darkSurfaceAlt = Color(0xFF1A263B); // Surface surélevée
  static const Color darkBorder     = Color(0xFF24334C); // Bordure subtile
  static const Color darkBorderGold = Color(0xFF5A4621); // Bordure dorée subtile

  static const Color lightBackground= Color(0xFFF7F5F0); // Fond beige chaleureux
  static const Color lightSurface   = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt= Color(0xFFECE6DB);
  static const Color lightBorder    = Color(0xFFDDD4C5);

  // ── Dégradés culturels ──────────────────────────────────────────────────────
  static const LinearGradient ocreGradient = LinearGradient(
    colors: [Color(0xFFC67C2E), Color(0xFFE09A4D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD8A22A), Color(0xFFF2C94C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vertGradient = LinearGradient(
    colors: [Color(0xFF3B643A), Color(0xFF5C915B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueRoyalGradient = LinearGradient(
    colors: [Color(0xFF314999), Color(0xFF4A6BC7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [
      Color(0xEE131B2A),
      Color(0xCC1A263B),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
