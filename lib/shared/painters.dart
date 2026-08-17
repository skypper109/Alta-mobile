// ─── DetAI — CustomPainters Futuristes ───────────────────────────────────────
// WaveformPainter, RadarChartPainter, ScanningPainter, HolographicCorePainter
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants.dart';

// ══════════════════════════════════════════════════════════════════════════════
// WAVEFORM PAINTER — Ondes sonores en temps réel avec Glow & Effet Miroir
// ══════════════════════════════════════════════════════════════════════════════

class WaveformPainter extends CustomPainter {
  const WaveformPainter({
    required this.samples,
    this.color      = DetColors.accentGreen,
    this.barWidth   = 3.5,
    this.barGap     = 2.0,
    this.isActive   = true,
    this.cornerRadius = 2.0,
  });

  final List<double> samples;
  final Color  color;
  final double barWidth;
  final double barGap;
  final bool   isActive;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive || samples.isEmpty) {
      _drawIdleLine(canvas, size);
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final dimPaint = Paint()
      ..color = color.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    final step       = barWidth + barGap;
    final barCount   = math.min(samples.length, (size.width / step).floor());
    final startX     = (size.width - barCount * step) / 2;
    final centerY    = size.height / 2;
    final maxBarH    = size.height * 0.85;

    for (int i = 0; i < barCount; i++) {
      final amplitude = samples[i % samples.length].clamp(0.0, 1.0);
      final barHeight = math.max(3.0, amplitude * maxBarH);
      final x         = startX + i * step;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY),
          width:  barWidth,
          height: barHeight,
        ),
        Radius.circular(cornerRadius),
      );

      // Miroir atténué
      final mirrorH    = barHeight * 0.45;
      final mirrorRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY + barHeight / 2 + mirrorH / 2 + 3),
          width:  barWidth * 0.75,
          height: mirrorH,
        ),
        Radius.circular(cornerRadius),
      );

      if (amplitude > 0.05) {
        canvas.drawRRect(rect, glowPaint);
        canvas.drawRRect(rect, paint);
      } else {
        canvas.drawRRect(rect, dimPaint);
      }
      canvas.drawRRect(mirrorRect, dimPaint);
    }
  }

  void _drawIdleLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const padding = 24.0;
    canvas.drawLine(
      Offset(padding, size.height / 2),
      Offset(size.width - padding, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.isActive != isActive ||
        oldDelegate.color != color;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HOLOGRAPHIC CORE PAINTER — Cœur IA Holo/Quantum Interactif
// ══════════════════════════════════════════════════════════════════════════════

/// Dessine un Orbe / HUD Holo-quantique tournant pour l'état IA.
class HolographicCorePainter extends CustomPainter {
  const HolographicCorePainter({
    required this.progress,
    this.pulseValue = 1.0,
    this.color = DetColors.primary,
    this.isThinking = false,
  });

  final double progress;
  final double pulseValue;
  final Color  color;
  final bool   isThinking;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    // 1. Aura de fond lumineuse
    final glowShader = RadialGradient(
      colors: [
        color.withValues(alpha: 0.25 * pulseValue),
        color.withValues(alpha: 0.05 * pulseValue),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));

    canvas.drawCircle(center, radius * 1.2, Paint()..shader = glowShader);

    // 2. Anneau extérieur fixe avec crans
    final ticksPaint = Paint()
      ..color = DetColors.border.withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, ticksPaint);

    // 3. Arc tournant principal (Hologramme)
    final sweepAngle = math.pi * 0.7;
    final startAngle = 2 * math.pi * progress;

    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arcGlowPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final rect = Rect.fromCircle(center: center, radius: radius - 6);
    canvas.drawArc(rect, startAngle, sweepAngle, false, arcGlowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

    // 4. Arc secondaire en sens inverse
    final reverseStartAngle = -2 * math.pi * progress * 1.3;
    final reverseRect = Rect.fromCircle(center: center, radius: radius - 16);
    final arc2Paint = Paint()
      ..color = (isThinking ? DetColors.accentCyan : color).withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(reverseRect, reverseStartAngle, math.pi * 0.4, false, arc2Paint);

    // 5. Particules orbitales
    final particleCount = isThinking ? 6 : 3;
    for (int i = 0; i < particleCount; i++) {
      final pAngle = startAngle + (i * 2 * math.pi / particleCount);
      final pRadius = radius - 11;
      final px = center.dx + pRadius * math.cos(pAngle);
      final py = center.dy + pRadius * math.sin(pAngle);

      final pPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(px, py), 2.5, pPaint);
    }
  }

  @override
  bool shouldRepaint(HolographicCorePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.color != color ||
        oldDelegate.isThinking != isThinking;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RADAR CHART PAINTER — Graphique radar de compétences
// ══════════════════════════════════════════════════════════════════════════════

class RadarEntry {
  const RadarEntry({required this.label, required this.value});
  final String label;
  final double value;
}

class RadarChartPainter extends CustomPainter {
  const RadarChartPainter({
    required this.entries,
    this.levels       = 5,
    this.fillColor    = const Color(0x3300FF9D),
    this.strokeColor  = DetColors.accentGreen,
    this.gridColor    = DetColors.border,
    this.labelColor   = DetColors.textSecondary,
  });

  final List<RadarEntry> entries;
  final int    levels;
  final Color  fillColor;
  final Color  strokeColor;
  final Color  gridColor;
  final Color  labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 3) return;

    final center  = Offset(size.width / 2, size.height / 2);
    final radius  = math.min(size.width, size.height) / 2 - 32;
    final count   = entries.length;
    final angle   = (2 * math.pi) / count;

    // Grilles
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int l = 1; l <= levels; l++) {
      final r = radius * l / levels;
      final path = Path();
      for (int i = 0; i < count; i++) {
        final a = -math.pi / 2 + i * angle;
        final pt = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Axes
    final axisPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    for (int i = 0; i < count; i++) {
      final a = -math.pi / 2 + i * angle;
      canvas.drawLine(
        center,
        Offset(center.dx + radius * math.cos(a), center.dy + radius * math.sin(a)),
        axisPaint,
      );
    }

    // Données
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dataPath = Path();
    for (int i = 0; i < count; i++) {
      final a = -math.pi / 2 + i * angle;
      final r = radius * entries[i].value.clamp(0.0, 1.0);
      final pt = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      if (i == 0) {
        dataPath.moveTo(pt.dx, pt.dy);
      } else {
        dataPath.lineTo(pt.dx, pt.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // Points
    final dotPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final a = -math.pi / 2 + i * angle;
      final r = radius * entries[i].value.clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a)),
        4.0,
        dotPaint,
      );
    }

    // Labels
    for (int i = 0; i < count; i++) {
      final a       = -math.pi / 2 + i * angle;
      final labelR  = radius + 24.0;
      final pt      = Offset(
        center.dx + labelR * math.cos(a),
        center.dy + labelR * math.sin(a),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: entries[i].label,
          style: DetTextStyles.caption.copyWith(color: labelColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(pt.dx - tp.width / 2, pt.dy - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SCANNING PAINTER — Radar de découverte réseau
// ══════════════════════════════════════════════════════════════════════════════

class ScanningPainter extends CustomPainter {
  const ScanningPainter({
    required this.progress,
    this.color = DetColors.accentGreen,
  });

  final double progress;
  final Color  color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    for (int i = 3; i >= 1; i--) {
      final r     = radius * i / 3;
      final alpha = (0.08 * i).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    final sweepAngle = math.pi / 2.5;
    final startAngle = 2 * math.pi * progress - math.pi / 2;

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle:   startAngle + sweepAngle,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.35),
        ],
        transform: GradientRotation(startAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      sweepPaint,
    );

    final lineAngle = startAngle + sweepAngle;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * math.cos(lineAngle),
        center.dy + radius * math.sin(lineAngle),
      ),
      Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(ScanningPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
