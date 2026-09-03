import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/culture_theme.dart';

/// Carte culturelle interactive avec motion design tactile
///
/// Fonctionnalités :
/// - Effet ressort tactile naturel (Scale 0.982 lors de la pression)
/// - Éclairage de bordure réactif au toucher (sans dégradé)
/// - Ornementation architecturale soudanaise (témoins de banco aux angles)
/// - Retour haptique doux
/// - STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class CulturalInteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color activeAccentColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool showSudaneseCorners;
  final double? width;
  final double? height;

  const CulturalInteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.activeAccentColor = CultureTheme.accentOrange,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.showSudaneseCorners = true,
    this.width,
    this.height,
  });

  @override
  State<CulturalInteractiveCard> createState() =>
      _CulturalInteractiveCardState();
}

class _CulturalInteractiveCardState extends State<CulturalInteractiveCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 240),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.982).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final defaultBorder =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final currentBorder = _isPressed
        ? widget.activeAccentColor
        : (widget.borderColor ?? defaultBorder);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? defaultBg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: currentBorder,
              width: _isPressed ? 1.6 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? (_isPressed ? 0.35 : 0.22) : 0.05,
                ),
                blurRadius: _isPressed ? 8 : 14,
                offset: Offset(0, _isPressed ? 2 : 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Contenu principal de la carte
              Padding(
                padding: widget.padding,
                child: widget.child,
              ),

              // ── MOTIF D'ANGLE SOUDANAIS (PILIER BANCO TRADITIONNEL) ───────
              if (widget.showSudaneseCorners) ...[
                // Angle supérieur droit
                Positioned(
                  top: 0,
                  right: 18,
                  child: Container(
                    width: 14,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.activeAccentColor.withValues(
                        alpha: _isPressed ? 0.9 : 0.45,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(3),
                      ),
                    ),
                  ),
                ),
                // Angle supérieur gauche
                Positioned(
                  top: 0,
                  left: 18,
                  child: Container(
                    width: 14,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.activeAccentColor.withValues(
                        alpha: _isPressed ? 0.9 : 0.45,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
