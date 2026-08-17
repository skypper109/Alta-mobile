import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Official AlterniA Brand Palette ─────────────────────────────────────────
  static const Color primary        = Color(0xFF314999); // Bleu Marine Profond
  static const Color primaryLight   = Color(0xFF4C66C4);
  static const Color primaryBg      = Color(0xFF101B36);

  static const Color accent         = Color(0xFFF1851F); // Orange Vif
  static const Color accentLight    = Color(0xFFFF9D42);
  static const Color accentBg       = Color(0xFF2E1908);

  static const Color secondary      = Color(0xFF40BBCC); // Cyan Turquoise
  static const Color secondaryLight = Color(0xFF67D8E6);
  static const Color secondaryBg    = Color(0xFF092830);

  // ── Unified Dark Background & Surfaces ─────────────────────────────────────
  static const Color background     = Color(0xFF0B111E); // Deep Dark Navy
  static const Color surface        = Color(0xFF141C2E); // Dark Card Surface
  static const Color surfaceAlt     = Color(0xFF1B253B); // Dark Elevated Surface
  static const Color border         = Color(0xFF23314D); // Subtle Border 1px
  static const Color borderFocus    = Color(0xFF40BBCC); // Active Input Focus

  // ── Typography Colors ──────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted     = Color(0xFF64748B);

  // ── Status & Feedback ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF314999), Color(0xFF1B2A5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF1851F), Color(0xFFFF9D42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF40BBCC), Color(0xFF67D8E6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Retro-compat properties
  static const Color backgroundDark = background;
  static const Color surfaceDark = surface;
  static const Color surfaceAltDark = surfaceAlt;
  static const Color borderDark = border;
  static const Color textPrimaryDark = textPrimary;
  static const Color textSecondaryDark = textSecondary;
  static const Color textMutedDark = textMuted;
  static const Color accentGreen = success;
  static const Color accentAmber = warning;
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentVioletBg = Color(0xFF1A1035);
  static const Color accentOrange = accent;
  static const Color accentOrangeBg = accentBg;
  static const Color accentCyan = secondary;
  static const Color accentCyanBg = secondaryBg;
  static const Color borderFocusDark = borderFocus;
}

typedef AltaColors = AppColors;
typedef DetColors = AppColors;
