import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';
import '../services/cultural_haptics.dart';

/// Carte cinématique avec vraie perspective spatiale 3D gyroscopique au toucher (Matrix4)
/// Réagit avec inertie physique fluide lors du drag/pan et revient au repos par ressort.
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI AlterniA.
class Cultural3DTiltCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String region;
  final String tag;
  final String photoUrl;
  final VoidCallback onTap;
  final Widget? trailingBadge;

  const Cultural3DTiltCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.region,
    required this.tag,
    required this.photoUrl,
    required this.onTap,
    this.trailingBadge,
  });

  @override
  State<Cultural3DTiltCard> createState() => _Cultural3DTiltCardState();
}

class _Cultural3DTiltCardState extends State<Cultural3DTiltCard>
    with SingleTickerProviderStateMixin {
  Offset _panOffset = Offset.zero;
  late final AnimationController _resetController;
  late Animation<Offset> _resetAnimation;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      _isInteracting = true;
      // Normaliser le déplacement entre -1 et 1
      final dx = (_panOffset.dx + details.delta.dx).clamp(-size.width * 0.45, size.width * 0.45);
      final dy = (_panOffset.dy + details.delta.dy).clamp(-size.height * 0.45, size.height * 0.45);
      _panOffset = Offset(dx, dy);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _resetAnimation = Tween<Offset>(
      begin: _panOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _resetController,
        curve: Curves.easeOutBack,
      ),
    )..addListener(() {
        setState(() {
          _panOffset = _resetAnimation.value;
        });
      });

    _resetController.forward(from: 0.0).then((_) {
      setState(() {
        _isInteracting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        const cardHeight = 220.0;

        // Calcul de la matrice 3D de perspective réelle
        final rotX = -(_panOffset.dy / cardHeight) * 0.28;
        final rotY = (_panOffset.dx / cardWidth) * 0.28;

        final transformMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0012) // Perspective 3D
          ..rotateX(rotX)
          ..rotateY(rotY);

        return GestureDetector(
          onPanUpdate: (details) => _onPanUpdate(details, Size(cardWidth, cardHeight)),
          onPanEnd: _onPanEnd,
          onTap: () {
            CulturalHaptics.cardPress();
            widget.onTap();
          },
          child: Transform(
            transform: transformMatrix,
            alignment: FractionalOffset.center,
            child: AnimatedContainer(
              duration: _isInteracting ? Duration.zero : const Duration(milliseconds: 200),
              height: cardHeight,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isInteracting
                      ? CultureTheme.accentOrange
                      : borderCol,
                  width: _isInteracting ? 1.8 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CultureTheme.accentOrange.withValues(
                      alpha: _isInteracting ? 0.25 : (isDark ? 0.15 : 0.08),
                    ),
                    blurRadius: _isInteracting ? 24 : 16,
                    offset: Offset(
                      _panOffset.dx * 0.12,
                      8 + _panOffset.dy * 0.12,
                    ),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Photographie du patrimoine
                    Image.asset(
                      widget.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: CultureTheme.primaryBlue,
                        child: const Icon(Icons.castle_rounded, color: Colors.white24, size: 48),
                      ),
                    ),

                    // 2. Filtre de contraste sombre plat (strictement sans dégradé)
                    Container(
                      color: Colors.black.withValues(alpha: 0.52),
                    ),

                    // 3. Ornements d'angle architecturaux soudanais
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: CultureTheme.accentOrange, width: 2),
                            left: BorderSide(color: CultureTheme.accentOrange, width: 2),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: CultureTheme.accentOrange, width: 2),
                            right: BorderSide(color: CultureTheme.accentOrange, width: 2),
                          ),
                        ),
                      ),
                    ),

                    // 4. Contenu informatif & badges
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Barre supérieure de badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                                decoration: BoxDecoration(
                                  color: CultureTheme.accentOrange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.tag.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              if (widget.trailingBadge != null)
                                widget.trailingBadge!
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 11,
                                        color: CultureTheme.cyanTurquoise,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.region,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          // Bloc textuel bas
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.subtitle,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: CultureTheme.cyanTurquoise,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: CultureTheme.primaryBlue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Entrer dans l\'Épopée',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 13,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Inclinez la carte',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: Colors.white54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
      },
    );
  }
}
