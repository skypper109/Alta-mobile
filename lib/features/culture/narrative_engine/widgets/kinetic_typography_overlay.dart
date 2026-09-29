import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Overlay de typographie cinématique progressive
/// Affiche la narration avec une élégance littéraire de grand documentaire
class KineticTypographyOverlay extends StatefulWidget {
  final String text;
  final String? sceneTitle;
  final String? culturalSecret;
  final double progress;

  const KineticTypographyOverlay({
    super.key,
    required this.text,
    this.sceneTitle,
    this.culturalSecret,
    required this.progress,
  });

  @override
  State<KineticTypographyOverlay> createState() =>
      _KineticTypographyOverlayState();
}

class _KineticTypographyOverlayState extends State<KineticTypographyOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant KineticTypographyOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _fadeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF1851F).withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de scène discret
            if (widget.sceneTitle != null) ...[
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1851F),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.sceneTitle!.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFF1851F),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Texte narratif cinématique
            Text(
              widget.text,
              style: GoogleFonts.merriweather(
                fontSize: 15.5,
                height: 1.65,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFF8FAFC),
              ),
            ),

            // Clé de sagesse / Secret culturel
            if (widget.culturalSecret != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1851F).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF1851F).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      size: 16,
                      color: Color(0xFFF1851F),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.culturalSecret!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFD8A8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
