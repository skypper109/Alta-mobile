import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';

/// Animation physique d'Estampillage du Sceau Royal (Impact sec, onde de choc & haptique)
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI AlterniA.
class CulturalRoyalStampAnimation extends StatefulWidget {
  final double size;
  final IconData icon;
  final String? label;
  final Color color;
  final String? photoUrl;
  final VoidCallback? onStamped;

  const CulturalRoyalStampAnimation({
    super.key,
    this.size = 84.0,
    this.icon = Icons.stars_rounded,
    this.label = 'SCEAU GRAVÉ',
    this.color = CultureTheme.accentOrange,
    this.photoUrl,
    this.onStamped,
  });

  @override
  State<CulturalRoyalStampAnimation> createState() =>
      _CulturalRoyalStampAnimationState();
}

class _CulturalRoyalStampAnimationState extends State<CulturalRoyalStampAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _opacityAnim;
  late final Animation<double> _shockwaveScaleAnim;
  late final Animation<double> _shockwaveOpacityAnim;

  bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    // 1. Descente rapide et impact (0% à 45%)
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.3, end: 0.92)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 55,
      ),
    ]).animate(_controller);

    // 2. Légère rotation artisanale du tampon (-0.06 rad à l'atterrissage)
    _rotationAnim = Tween<double>(begin: 0.12, end: -0.04).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // 3. Apparition de l'opacité
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    // 4. Onde de choc circulaire (45% à 100%)
    _shockwaveScaleAnim = Tween<double>(begin: 1.0, end: 1.85).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.42, 1.0, curve: Curves.easeOutQuad),
      ),
    );

    _shockwaveOpacityAnim = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.42, 0.95, curve: Curves.easeOut),
      ),
    );

    _controller.addListener(() {
      // Déclenchement de la vibration physique au moment précis de l'impact (t ≈ 45%)
      if (_controller.value >= 0.42 && !_hasTriggeredHaptic) {
        _hasTriggeredHaptic = true;
        HapticFeedback.heavyImpact();
        widget.onStamped?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 1.9,
          height: widget.size * 1.9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── 1. Onde de choc circulaire (sans dégradé) ─────────────────
              if (_controller.value >= 0.42)
                Transform.scale(
                  scale: _shockwaveScaleAnim.value,
                  child: Opacity(
                    opacity: _shockwaveOpacityAnim.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.color,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── 2. Le Tampon Royal ─────────────────────────────────────────
              Transform.scale(
                scale: _scaleAnim.value,
                child: Transform.rotate(
                  angle: _rotationAnim.value,
                  child: Opacity(
                    opacity: _opacityAnim.value.clamp(0.0, 1.0),
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color.withValues(alpha: 0.12),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.85),
                          width: 2.2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Cercle intérieur stylisé
                          Container(
                            width: widget.size * 0.82,
                            height: widget.size * 0.82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.color.withValues(alpha: 0.35),
                                width: 1.0,
                              ),
                            ),
                          ),
                          // Image centrale ou Icône
                          if (widget.photoUrl != null)
                            ClipOval(
                              child: Image.asset(
                                widget.photoUrl!,
                                width: widget.size * 0.72,
                                height: widget.size * 0.72,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Icon(
                              widget.icon,
                              size: widget.size * 0.52,
                              color: widget.color,
                            ),
                          // Petit texte en arc ou badge inférieur
                          if (widget.label != null)
                            Positioned(
                              bottom: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.label!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
