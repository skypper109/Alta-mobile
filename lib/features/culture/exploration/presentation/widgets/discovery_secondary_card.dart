import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/cultural_discovery.dart';

/// Carte secondaire compacte (disposition verticale ou horizontale)
/// pour les découvertes non-featured dans la grille éditoriale.
class DiscoverySecondaryCard extends StatefulWidget {
  final CulturalDiscovery discovery;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool isHorizontal; // true = carte paysage (image à gauche)

  const DiscoverySecondaryCard({
    super.key,
    required this.discovery,
    required this.accentColor,
    this.onTap,
    this.isHorizontal = false,
  });

  @override
  State<DiscoverySecondaryCard> createState() =>
      _DiscoverySecondaryCardState();
}

class _DiscoverySecondaryCardState extends State<DiscoverySecondaryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) => _controller.forward(),
      onTapCancel: () => _controller.forward(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) =>
            Transform.scale(scale: _controller.value, child: child),
        child: widget.isHorizontal
            ? _buildHorizontalCard(isDark)
            : _buildVerticalCard(isDark),
      ),
    );
  }

  // ── Carte verticale (portrait) ─────────────────────────────────────────────
  Widget _buildVerticalCard(bool isDark) {
    final accent = widget.accentColor;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? CultureTheme.darkSurface : CultureTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : accent)
                .withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone image / dégradé
            _buildCardImageZone(accent, isDark, height: 110),

            // Contenu texte
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.discovery.tag,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Titre
                  Text(
                    widget.discovery.titre,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.discovery.lieu != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            widget.discovery.lieu!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Carte horizontale (paysage) ────────────────────────────────────────────
  Widget _buildHorizontalCard(bool isDark) {
    final accent = widget.accentColor;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? CultureTheme.darkSurface : CultureTheme.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : accent)
                .withValues(alpha: isDark ? 0.20 : 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // Image carrée à gauche
            SizedBox(
              width: 100,
              child: _buildCardImageZone(accent, isDark, height: 100),
            ),

            // Contenu à droite
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.discovery.icone,
                          size: 14,
                          color: accent,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            widget.discovery.categorie,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.discovery.titre,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.discovery.lieu != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.discovery.lieu!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Flèche explore
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImageZone(Color accent, bool isDark, {required double height}) {
    if (widget.discovery.imageUrl != null &&
        widget.discovery.imageUrl!.isNotEmpty) {
      return SizedBox(
        height: height,
        child: Image.asset(
          widget.discovery.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) =>
              _buildGradientZone(accent, isDark, height),
        ),
      );
    }
    return _buildGradientZone(accent, isDark, height);
  }

  Widget _buildGradientZone(Color accent, bool isDark, double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: isDark ? 0.55 : 0.70),
            accent.withValues(alpha: isDark ? 0.30 : 0.45),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          widget.discovery.icone,
          size: height * 0.42,
          color: Colors.white.withValues(alpha: 0.80),
        ),
      ),
    );
  }
}
