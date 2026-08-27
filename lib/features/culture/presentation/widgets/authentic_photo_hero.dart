import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';

/// Hero photographique authentique grand format pour les fiches de consultation Culture.
/// Utilise des photographies réelles avec contraste optimisé, badges patrimoniaux et crédits.
class AuthenticPhotoHero extends StatefulWidget {
  final String photoUrl;
  final String photoCredits;
  final String tag;
  final String regionName;
  final String? subtitleInfo;
  final Color accentColor;
  final VoidCallback? onBack;

  const AuthenticPhotoHero({
    super.key,
    required this.photoUrl,
    required this.photoCredits,
    required this.tag,
    required this.regionName,
    this.subtitleInfo,
    this.accentColor = CultureTheme.accentOrange,
    this.onBack,
  });

  @override
  State<AuthenticPhotoHero> createState() => _AuthenticPhotoHeroState();
}

class _AuthenticPhotoHeroState extends State<AuthenticPhotoHero> {
  bool _isBookmarked = false;

  void _toggleBookmark() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked
              ? 'Ajouté à vos découvertes enregistrées'
              : 'Retiré des découvertes enregistrées',
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: CultureTheme.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.paddingOf(context).top;
    final heroHeight = (size.height * 0.42 + topPadding * 0.4).clamp(320.0, 400.0);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. PHOTOGRAPHIE RÉELLE AUTHENTIQUE ─────────────────────────────
          widget.photoUrl.startsWith('assets/')
              ? Image.asset(
                  widget.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildFallback(),
                )
              : Image.network(
                  widget.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildFallback(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: CultureTheme.darkSurface,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: widget.accentColor,
                        ),
                      ),
                    );
                  },
                ),

          // ── 2. VOILE NOIR ÉLÉGANT HAUT & BAS POUR LISIBILITÉ ──────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x99000000), // Sombre en haut pour les boutons
                    Colors.transparent,
                    Color(0xB3000000), // Sombre en bas pour les badges
                  ],
                  stops: [0.0, 0.45, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── 3. BOUTONS D'ACTION SUPÉRIEURS (RETOUR & FAVORIS) ───────────────
          Positioned(
            top: topPadding > 0 ? topPadding + 10 : 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Bouton Retour
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else if (context.canPop()) {
                      context.pop();
                    }
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const Spacer(),
                // Bouton Favori
                GestureDetector(
                  onTap: _toggleBookmark,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: _isBookmarked
                          ? widget.accentColor
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 4. BADGES BAS : STATUT & RÉGION ─────────────────────────────────
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // Badge Tag (UNESCO, Mansa...)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5.5),
                  decoration: BoxDecoration(
                    color: widget.accentColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.tag.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // Badge Région
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 5.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: CultureTheme.accentOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.regionName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge Info / Période
                if (widget.subtitleInfo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 5.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      widget.subtitleInfo!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: CultureTheme.primaryDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 40,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'Photographie Patrimoniale',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
