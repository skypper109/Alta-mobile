// ─── AlterniA — Composants partagés des modules éducatifs ───────────────────
// Carte vedette, tuiles d'outils et filigrane du logo, conformes à la charte
// officielle : Bleu #314999 (primaire), Orange #F1851F, Cyan #40BBCC.
// Seul le dégradé officiel `AltaColors.heroBannerGradient` est utilisé.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';

/// Chemin du logo officiel AlterniA.
const String kAlterniaLogoAsset = 'assets/images/alternia_logo.png';

// ════════════════════════════════════════════════════════════════════
// FILIGRANE DU LOGO ALTERNIA
// ════════════════════════════════════════════════════════════════════
/// Superpose le logo AlterniA en filigrane derrière [child].
class AlterniaWatermark extends StatelessWidget {
  const AlterniaWatermark({
    super.key,
    required this.child,
    this.size = 170,
    this.opacity = 0.07,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final double size;
  final double opacity;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: alignment,
              child: Opacity(
                opacity: opacity,
                child: Image.asset(
                  kAlterniaLogoAsset,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Petite signature « logo + AlterniA » pour le pied des cartes générées.
class AlterniaSignature extends StatelessWidget {
  const AlterniaSignature({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          kAlterniaLogoAsset,
          width: 14,
          height: 14,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        const SizedBox(width: 5),
        Text(
          'AlterniA',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// PASTILLE (CHIP) SUR FOND BLEU
// ════════════════════════════════════════════════════════════════════
class EduHeroChip extends StatelessWidget {
  const EduHeroChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// CARTE VEDETTE (HERO) — dégradé officiel + logo en filigrane
// ════════════════════════════════════════════════════════════════════
class EduHeroCard extends StatelessWidget {
  const EduHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.icon,
    required this.onTap,
    this.chips = const [],
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final IconData icon;
  final VoidCallback onTap;
  final List<EduHeroChip> chips;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: AltaColors.heroBannerGradient,
            border: Border.all(
              color: AltaColors.primaryLight.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AltaColors.primary.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                // Logo AlterniA en filigrane (coin droit)
                Positioned(
                  right: -26,
                  bottom: -26,
                  child: Opacity(
                    opacity: 0.16,
                    child: Image.asset(
                      kAlterniaLogoAsset,
                      width: 150,
                      height: 150,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                // Icône du module en haut à droite
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (chips.isNotEmpty) ...[
                        Wrap(spacing: 6, runSpacing: 6, children: chips),
                        const SizedBox(height: 14),
                      ],
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(right: 70),
                        child: Text(
                          subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            height: 1.35,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: AltaColors.accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ctaLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// TUILE D'OUTIL (compacte verticale ou large horizontale)
// ════════════════════════════════════════════════════════════════════
class EduToolTile extends StatelessWidget {
  const EduToolTile({
    super.key,
    required this.icon,
    required this.title,
    required this.tag,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.horizontal = false,
  });

  final IconData icon;
  final String title;
  final String tag;
  final Color color;
  final VoidCallback onTap;

  /// Description affichée uniquement en mode [horizontal].
  final String? subtitle;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri =
        isDark ? AltaColors.textPrimaryDark : AltaColors.textPrimaryLight;
    final textSec =
        isDark ? AltaColors.textSecondaryDark : AltaColors.textSecondaryLight;
    final radius = BorderRadius.circular(18);

    final iconBox = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
    );

    final tagText = Text(
      tag,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
        color: color,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final content = horizontal
        ? Row(
            children: [
              iconBox,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: tagText,
                        ),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          height: 1.3,
                          color: textSec,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconBox,
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: textPri,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: tagText),
                  Icon(Icons.arrow_forward_rounded, size: 13, color: textSec),
                ],
              ),
            ],
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: horizontal
              ? const EdgeInsets.all(14)
              : const EdgeInsets.fromLTRB(12, 12, 12, 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: radius,
            border: Border.all(color: borderCol),
          ),
          child: content,
        ),
      ),
    );
  }
}
