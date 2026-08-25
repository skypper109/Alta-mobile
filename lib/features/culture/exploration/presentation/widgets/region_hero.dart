import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/mali_region.dart';

/// Hero immersif pour la page régionale
class RegionHero extends StatelessWidget {
  final MaliRegion region;
  final String accroche;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onToggleBookmark;

  const RegionHero({
    super.key,
    required this.region,
    required this.accroche,
    required this.isBookmarked,
    required this.onBack,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final accent = region.couleurAccent;
    final size = MediaQuery.of(context).size;
    final heroHeight = (size.height * 0.38).clamp(280.0, 360.0);

    return Stack(
      children: [
        // ── Fond visuel avec dégradés riches et textures ────────────────────
        Container(
          height: heroHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.85),
                const Color(0xFF090E18),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Motif géométrique et rayonnement subtil
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.25),
                  ),
                ),
              ),

              // Grand symbole d'icône en filigrane discret
              Positioned(
                right: 16,
                bottom: 24,
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(
                    region.icone,
                    size: 140,
                    color: Colors.white,
                  ),
                ),
              ),

              // Voile d'assombrissement pour contraste parfait
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x80000000),
                      Colors.transparent,
                      Color(0xCC090E18),
                    ],
                    stops: [0.0, 0.45, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Barre d'action supérieure (Retour & Favori) ─────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton Retour
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onBack();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Bouton Favori / Signet
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onToggleBookmark();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? CultureTheme.orPatrimoine
                            : Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isBookmarked
                              ? CultureTheme.orPatrimoine
                              : Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 20,
                        color: isBookmarked ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Contenu textuel Hero (Bas du conteneur) ─────────────────────────
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Localisation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 13,
                      color: CultureTheme.orPatrimoine,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Mali · Région de ${region.nom}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Nom de la Région
              Text(
                region.nom.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 4),

              // Surnom / Accroche poétique
              Text(
                accroche,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFF1F5F9),
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
