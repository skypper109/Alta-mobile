import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/vivienne_tts_service.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';

/// En-tête supérieur persistant (sticky / figé) pour les fiches de consultation Culture
/// (Monuments, Villes, Personnages historiques, Contes, Régions).
///
/// Fonctionnement UX :
/// - En haut de page : fond transparent, boutons ronds flottants avec voile sombre lisible sur l'image.
/// - Au défilement : transition fluide vers une barre d'en-tête opaque conforme à la charte,
///   avec affichage du titre de l'élément au centre.
/// - Les boutons Retour et Favori restent ACCESSIBLES À 100% quel que soit le défilement.
class CultureDetailStickyHeader extends StatefulWidget {
  final String title;
  final bool isScrolled;
  final VoidCallback? onBack;
  final Color accentColor;
  final bool showBookmark;
  final bool initialBookmarked;
  final ValueChanged<bool>? onBookmarkChanged;

  const CultureDetailStickyHeader({
    super.key,
    required this.title,
    required this.isScrolled,
    this.onBack,
    this.accentColor = CultureTheme.accentOrange,
    this.showBookmark = true,
    this.initialBookmarked = false,
    this.onBookmarkChanged,
  });

  @override
  State<CultureDetailStickyHeader> createState() =>
      _CultureDetailStickyHeaderState();
}

class _CultureDetailStickyHeaderState extends State<CultureDetailStickyHeader> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.initialBookmarked;
  }

  void _toggleBookmark() {
    final nextState = !_isBookmarked;
    CulturalHaptics.bookmarkToggle(nextState);
    setState(() {
      _isBookmarked = nextState;
    });
    widget.onBookmarkChanged?.call(nextState);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextState
              ? 'Ajouté à vos découvertes enregistrées'
              : 'Retiré des découvertes enregistrées',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: CultureTheme.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.only(
          top: topPadding > 0 ? topPadding + 6 : 14,
          bottom: 10,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: widget.isScrolled
              ? (isDark
                  ? CultureTheme.darkSurface.withValues(alpha: 0.96)
                  : Colors.white.withValues(alpha: 0.96))
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: widget.isScrolled ? borderCol : Colors.transparent,
              width: 1.0,
            ),
          ),
          boxShadow: widget.isScrolled
              ? [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: isDark ? 0.35 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Bouton Retour persistant
            _buildActionButton(
              icon: Icons.arrow_back_rounded,
              isDark: isDark,
              borderCol: borderCol,
              onTap: () {
                CulturalHaptics.cardRelease();
                VivienneTtsService.instance.stop();
                if (widget.onBack != null) {
                  widget.onBack!();
                } else if (context.canPop()) {
                  context.pop();
                }
              },
            ),
            const SizedBox(width: 12),

            // Titre compact visible uniquement lors du défilement
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isScrolled ? 1.0 : 0.0,
                child: Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Bouton Favori persistant
            if (widget.showBookmark)
              _buildActionButton(
                icon: _isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                iconColor: _isBookmarked
                    ? widget.accentColor
                    : (widget.isScrolled && !isDark
                        ? const Color(0xFF0F172A)
                        : Colors.white),
                isDark: isDark,
                borderCol: borderCol,
                onTap: _toggleBookmark,
              )
            else
              const SizedBox(width: 42),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color borderCol,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: widget.isScrolled
              ? (isDark
                  ? CultureTheme.darkSurfaceAlt
                  : const Color(0xFFF1F5F9))
              : Colors.black.withValues(alpha: 0.52),
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.isScrolled
                ? borderCol
                : Colors.white.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: widget.isScrolled ? 0.08 : 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ??
              (widget.isScrolled
                  ? (isDark ? Colors.white : const Color(0xFF0F172A))
                  : Colors.white),
          size: 20,
        ),
      ),
    );
  }
}
