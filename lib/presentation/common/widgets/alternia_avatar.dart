import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

enum AvatarState { idle, listening, speaking, thinking }

class AlterniaAvatar extends StatefulWidget {
  const AlterniaAvatar({
    super.key,
    this.size = 180.0,
    this.state = AvatarState.idle,
    this.onTap,
  });

  final double size;
  final AvatarState state;
  final VoidCallback? onTap;

  @override
  State<AlterniaAvatar> createState() => _AlterniaAvatarState();
}

class _AlterniaAvatarState extends State<AlterniaAvatar> with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      // Ralenti pour réduire la charge CPU de rendu
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      // Ralenti : moins de repaints par seconde
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color get _glowColor => switch (widget.state) {
    AvatarState.idle      => AppColors.primary,
    AvatarState.listening => AppColors.secondary,
    AvatarState.speaking  => AppColors.primaryLight,
    AvatarState.thinking  => AppColors.accent,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      // RepaintBoundary isole le painter du reste du widget tree
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_animCtrl, _pulseCtrl]),
          builder: (context, child) {
            final scale = 1.0 + (_pulseCtrl.value * 0.05);

            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Glow Ring
                    Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _glowColor.withValues(alpha: 0.35 + (_pulseCtrl.value * 0.2)),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),

                    // Custom Painted Avatar Face & Core
                    CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _AvatarPainter(
                        progress: _animCtrl.value,
                        pulse: _pulseCtrl.value,
                        state: widget.state,
                        accentColor: _glowColor,
                      ),
                    ),

                    // Avatar Center Face (Holographic Eyes & Expression)
                    _buildFacialFeatures(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFacialFeatures() {
    final eyeColor = widget.state == AvatarState.listening
        ? AppColors.secondary
        : (widget.state == AvatarState.speaking ? AppColors.accent : Colors.white);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        // Eyes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Eye
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.state == AvatarState.thinking ? 8 : 12,
              height: widget.state == AvatarState.thinking ? 8 : 12,
              decoration: BoxDecoration(
                color: eyeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: eyeColor.withValues(alpha: 0.8), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right Eye
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.state == AvatarState.thinking ? 8 : 12,
              height: widget.state == AvatarState.thinking ? 8 : 12,
              decoration: BoxDecoration(
                color: eyeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: eyeColor.withValues(alpha: 0.8), blurRadius: 6),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Animated Mouth / Speech Wave
        if (widget.state == AvatarState.speaking)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final h = 6 + (math.sin((_animCtrl.value * math.pi * 4) + (i * 0.8)).abs() * 12);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: h,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          )
        else if (widget.state == AvatarState.listening)
          Container(
            width: 20,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else
          Container(
            width: 16,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter({
    required this.progress,
    required this.pulse,
    required this.state,
    required this.accentColor,
  });

  final double progress;
  final double pulse;
  final AvatarState state;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;

    // Base Sphere Gradient (Primary Marine + Accent Orange)
    final baseGradient = RadialGradient(
      colors: [
        accentColor,
        AppColors.primary,
        AppColors.background,
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = baseGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // Dynamic Orbital Rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = LinearGradient(
        colors: [accentColor, Colors.transparent, AppColors.secondary],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final angle = progress * 2 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 1.85, height: radius * 0.8),
      ringPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-angle * 1.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 1.6, height: radius * 0.9),
      ringPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.state != state;
  }

  @override
  bool shouldRebuildSemantics(covariant _AvatarPainter oldDelegate) => false;
}
