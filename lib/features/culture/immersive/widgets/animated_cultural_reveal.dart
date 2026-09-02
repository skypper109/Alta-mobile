import 'package:flutter/material.dart';

/// Composant d'apparition progressive et naturelle (Fade + Micro-Slide + Micro-Scale)
/// Utilisé pour faire entrer le contenu culturel avec fluidité sans rebond excessif.
class AnimatedCulturalReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset offset;
  final double beginScale;
  final Curve curve;
  final VoidCallback? onCompleted;

  const AnimatedCulturalReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 320),
    this.delay = Duration.zero,
    this.offset = const Offset(0.0, 0.06),
    this.beginScale = 0.98,
    this.curve = Curves.easeOutCubic,
    this.onCompleted,
  });

  @override
  State<AnimatedCulturalReveal> createState() => _AnimatedCulturalRevealState();
}

class _AnimatedCulturalRevealState extends State<AnimatedCulturalReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnimation = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(curved);
    _scaleAnimation = Tween<double>(begin: widget.beginScale, end: 1.0).animate(curved);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call();
      }
    });

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (!_isDisposed && mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect des préférences d'accessibilité (réduction des animations)
    final reduceMotion = MediaQuery.maybeOf(context)?.accessibleNavigation ?? false;
    if (reduceMotion) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
