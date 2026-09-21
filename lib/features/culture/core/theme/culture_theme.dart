import 'package:flutter/material.dart';

/// Palette culturelle officielle AlterniA & Mali
/// STRICTEMENT SANS DÉGRADÉS selon les règles d'architecture UX/UI
abstract final class CultureTheme {
  // ── Couleurs officielles de la charte AlterniA ──────────────────────────────
  static const Color primaryBlue =
      Color(0xFF314999); // Bleu institutionnel AlterniA
  static const Color primaryDark = Color(0xFF1B2A5A); // Bleu foncé profond
  static const Color primaryLight = Color(0xFF4A66C7); // Bleu éclairé
  static const Color accentOrange = Color(0xFFF1851F); // Orange culturel vivant
  static const Color accentLight = Color(0xFFFF9D42); // Orange pastel
  static const Color cyanTurquoise =
      Color(0xFF40BBCC); // Cyan technologique ponctuel
  static const Color iaYellow =
      Color(0xFFF1851F); // Jaune or vibrant pour "iA" côté Culture
  static const Color jauneMali =
      Color(0xFFFF9D42); // Jaune or du drapeau du Mali

  // ── Palette culturelle & patrimoniale Malienne (Aplats & Tons unis) ─────────
  static const Color ocreTerre = Color(0xFFC67C2E); // Ocre / Terre cuite
  static const Color sable = Color(0xFFF3E7D3); // Sable saharien
  static const Color sableDark = Color(0xFF2C241B); // Fond sable sombre
  static const Color vertNaturel = Color(0xFF4E7A4D); // Vert nature
  static const Color orPatrimoine = Color(0xFFD8A22A); // Or Mansa Moussa
  static const Color rougeKoulikoro = Color(0xFFB84A39); // Latérite mandingue
  static const Color fleuveNiger =
      Color(0xFF48CAE4); // Eaux du Djoliba (Fleuve Niger)

  // ── Fonds et surfaces immersives Culture ────────────────────────────────────
  static const Color darkBackground = Color(0xFF090E18); // Fond nuit profond
  static const Color darkSurface = Color(0xFF131B2A); // Carte surface sombre
  static const Color darkSurfaceAlt = Color(0xFF1A263B); // Surface surélevée
  static const Color darkBorder = Color(0xFF24334C); // Bordure subtile

  static const Color lightBackground =
      Color(0xFFFFFFFF); // Fond blanc lumineux & épuré
  static const Color lightSurface = Color(0xFFFFFFFF); // Carte blanche pure
  static const Color lightSurfaceAlt =
      Color(0xFFF8FAFC); // Surface surélevée subtile
  static const Color lightBorder =
      Color(0xFFE2E8F0); // Bordure discrète et élégante

  // ── Textes ──────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
}
