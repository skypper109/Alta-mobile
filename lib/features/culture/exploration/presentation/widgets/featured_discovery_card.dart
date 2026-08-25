import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/cultural_discovery.dart';

/// Grande carte éditoriale « Featured » qui met en valeur la découverte principale
/// d'une région — visuellement dominante, façon magazine de voyage premium.
class FeaturedDiscoveryCard extends StatefulWidget {
  final CulturalDiscovery discovery;
  final Color accentColor;
  final VoidCallback? onTap;

  const FeaturedDiscoveryCard({
    super.key,
    required this.discovery,
    required this.accentColor,
    this.onTap,
  });

  @override
  State<FeaturedDiscoveryCard> createState() => _FeaturedDiscoveryCardState();
}

class _FeaturedDiscoveryCardState extends State<FeaturedDiscoveryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.reverse();
  void _onTapUp(TapUpDetails _) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accentColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.35 : 0.20),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // ── Fond visuel (image ou dégradé thématique) ────────────────
                _buildBackground(isDark, accent),

                // ── Overlay gradient bas → haut pour lisibilité du texte ─────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.42, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.80),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Badge catégorie (coin haut gauche) ───────────────────────
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.discovery.icone,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.90),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.discovery.categorie.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.90),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Badge "À la une" (coin haut droit) ──────────────────────
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'À LA UNE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                // ── Contenu éditorial (bas de la carte) ─────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.discovery.tag,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Titre principal
                        Text(
                          widget.discovery.titre,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Description courte
                        Text(
                          widget.discovery.description,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.82),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),

                        // Pied : Lieu + CTA
                        Row(
                          children: [
                            if (widget.discovery.lieu != null) ...[
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.70),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.discovery.lieu!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.70),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ] else
                              const Spacer(),
                            // Bouton Explorer
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.40),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Explorer',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(bool isDark, Color accent) {
    if (widget.discovery.imageUrl != null &&
        widget.discovery.imageUrl!.isNotEmpty) {
      // Si l'image est disponible dans les assets
      return SizedBox(
        height: 320,
        width: double.infinity,
        child: Image.asset(
          widget.discovery.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildGradientBackground(accent),
        ),
      );
    }
    return _buildGradientBackground(accent);
  }

  Widget _buildGradientBackground(Color accent) {
    // Dégradé riche à la teinte de la région — fallback si pas d'image
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _darken(accent, 0.35),
            accent,
            _lighten(accent, 0.20),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Motif décoratif en filigrane (icône agrandie)
          Positioned(
            right: -20,
            top: -10,
            child: Icon(
              widget.discovery.icone,
              size: 160,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          // Cercle décoratif
          Positioned(
            left: -30,
            bottom: 60,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
