import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';

/// États possibles d'une carte de choix interactive
enum ChoiceCardState {
  normal,
  pressed,
  selected,
  correct,
  incorrect,
  disabled,
}

/// Carte de décision interactive pour les contes, récits à embranchements et défis
class InteractiveChoiceCard extends StatefulWidget {
  final String label;
  final String? subtitle;
  final String? consequencePreview;
  final ChoiceCardState state;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final Color? accentColor;

  const InteractiveChoiceCard({
    super.key,
    required this.label,
    this.subtitle,
    this.consequencePreview,
    this.state = ChoiceCardState.normal,
    this.onTap,
    this.leading,
    this.trailing,
    this.accentColor,
  });

  @override
  State<InteractiveChoiceCard> createState() => _InteractiveChoiceCardState();
}

class _InteractiveChoiceCardState extends State<InteractiveChoiceCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    if (widget.state == ChoiceCardState.incorrect) {
      _triggerShake();
    }
  }

  @override
  void didUpdateWidget(covariant InteractiveChoiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == ChoiceCardState.incorrect &&
        oldWidget.state != ChoiceCardState.incorrect) {
      _triggerShake();
    }
  }

  void _triggerShake() {
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.state == ChoiceCardState.disabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.state == ChoiceCardState.disabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.state == ChoiceCardState.disabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (widget.state == ChoiceCardState.disabled) return;
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = widget.accentColor ?? CultureTheme.primaryBlue;

    // Détermination des couleurs selon l'état
    Color bgColor;
    Color borderColor;
    Color textColor;
    double borderWidth = 1.3;

    switch (widget.state) {
      case ChoiceCardState.correct:
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF2E7D32);
        textColor = const Color(0xFF1B5E20);
        borderWidth = 1.8;
        break;
      case ChoiceCardState.incorrect:
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFC62828);
        textColor = const Color(0xFFB71C1C);
        borderWidth = 1.8;
        break;
      case ChoiceCardState.selected:
        bgColor = primaryAccent.withValues(alpha: isDark ? 0.22 : 0.08);
        borderColor = primaryAccent;
        textColor = isDark ? Colors.white : primaryAccent;
        borderWidth = 1.8;
        break;
      case ChoiceCardState.disabled:
        bgColor = isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9);
        borderColor = isDark ? CultureTheme.darkBorder : const Color(0xFFE2E8F0);
        textColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
        break;
      case ChoiceCardState.pressed:
      case ChoiceCardState.normal:
        bgColor = isDark ? CultureTheme.darkSurface : Colors.white;
        borderColor = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
        textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        break;
    }

    final opacity = widget.state == ChoiceCardState.disabled ? 0.55 : 1.0;
    final scale = _isPressed || widget.state == ChoiceCardState.pressed ? 0.982 : 1.0;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset = math.sin(_shakeAnimation.value * math.pi * 4) * 6.0;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 180),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                boxShadow: [
                  if (widget.state != ChoiceCardState.disabled && !_isPressed)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            height: 1.3,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            widget.subtitle!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                        if (widget.consequencePreview != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.consequencePreview!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: CultureTheme.accentOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.trailing != null)
                    widget.trailing!
                  else
                    _buildDefaultTrailing(isDark, borderColor, textColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultTrailing(bool isDark, Color borderColor, Color textColor) {
    switch (widget.state) {
      case ChoiceCardState.correct:
        return const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF2E7D32),
          size: 22,
        );
      case ChoiceCardState.incorrect:
        return const Icon(
          Icons.cancel_rounded,
          color: Color(0xFFC62828),
          size: 22,
        );
      case ChoiceCardState.selected:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: widget.accentColor ?? CultureTheme.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 15,
            color: Colors.white,
          ),
        );
      default:
        return Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        );
    }
  }
}
