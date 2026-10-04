import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/mali_historical_place_marker.dart';

/// Widget du point rouge interactif représentant un lieu historique sur la carte.
/// Design compact type Google Maps : impulsion radar vivante, point rouge contrasté
/// et micro-étiquette lisible sans encombrement visuel.
class HistoricalPlaceRedPin extends StatefulWidget {
  final MaliHistoricalPlaceMarker marker;
  final bool isSelected;
  final bool isDimmed;
  final bool showLabel;
  final VoidCallback onTap;

  const HistoricalPlaceRedPin({
    super.key,
    required this.marker,
    required this.isSelected,
    this.isDimmed = false,
    this.showLabel = true,
    required this.onTap,
  });

  @override
  State<HistoricalPlaceRedPin> createState() => _HistoricalPlaceRedPinState();
}

class _HistoricalPlaceRedPinState extends State<HistoricalPlaceRedPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.85, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );

    _opacityAnimation = Tween<double>(begin: 0.70, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );

    if (widget.isSelected) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HistoricalPlaceRedPin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isDimmed = widget.isDimmed;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDimmed ? 0.30 : 1.0,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 90,
          height: 44,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              // ── 1. Ondulation radar animée ────────────────────────────────
              Positioned(
                top: 0,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected
                          ? _pulseAnimation.value * 1.3
                          : _pulseAnimation.value,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE53935).withValues(
                            alpha: isDimmed ? 0.0 : _opacityAnimation.value,
                          ),
                          border: Border.all(
                            color: const Color(0xFFFF5252).withValues(
                              alpha: isDimmed ? 0.0 : _opacityAnimation.value,
                            ),
                            width: 1.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── 2. Le point rouge interactif (Style Google Maps) ──────────
              Positioned(
                top: 0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.25 : 1.0,
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFFF5252),
                          Color(0xFFD32F2F),
                          Color(0xFF9A0007),
                        ],
                        stops: [0.0, 0.7, 1.0],
                      ),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFD54F)
                            : Colors.white,
                        width: isSelected ? 2.2 : 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F)
                              .withValues(alpha: isSelected ? 0.6 : 0.35),
                          blurRadius: isSelected ? 8 : 4,
                          spreadRadius: isSelected ? 1.5 : 0,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isSelected
                          ? const Icon(
                              Icons.location_on_rounded,
                              size: 11,
                              color: Colors.white,
                            )
                          : Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              // ── 3. Micro-étiquette nominative sous le pin ─────────────────
              if (widget.showLabel || isSelected)
                Positioned(
                  top: 22,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 88),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E284A)
                          : Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF5252)
                            : Colors.white.withValues(alpha: 0.2),
                        width: 0.7,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.marker.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
