import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import 'passport_stamp_toast.dart';

/// Carte rituelle interactive de la Fête du Crépissage
/// - Récit de la ferveur collective des maîtres maçons Barey Ton
/// - Geste participatif tactile : Maintien du doigt pour "Poser la motte d'argile sacrée"
/// - Attribution du titre honorifique et enregistrement au Passeport Culturel
class MonumentCrepissageRitualCard extends StatefulWidget {
  final MonumentDetail monument;

  const MonumentCrepissageRitualCard({
    super.key,
    required this.monument,
  });

  @override
  State<MonumentCrepissageRitualCard> createState() =>
      _MonumentCrepissageRitualCardState();
}

class _MonumentCrepissageRitualCardState
    extends State<MonumentCrepissageRitualCard>
    with SingleTickerProviderStateMixin {
  bool _isParticipated = false;
  double _pressProgress = 0.0;
  Timer? _progressTimer;

  void _startPress() {
    if (_isParticipated) return;
    CulturalHaptics.cardPress();
    _pressProgress = 0.0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _pressProgress += 0.025;
        if (_pressProgress >= 1.0) {
          _pressProgress = 1.0;
          timer.cancel();
          _completeParticipation();
        } else {
          // Vibration haptique continue cadencée
          if ((_pressProgress * 10).toInt() % 2 == 0) {
            HapticFeedback.selectionClick();
          }
        }
      });
    });
  }

  void _cancelPress() {
    if (_isParticipated) return;
    _progressTimer?.cancel();
    if (_pressProgress < 1.0) {
      setState(() {
        _pressProgress = 0.0;
      });
    }
  }

  void _completeParticipation() {
    CulturalHaptics.celebration();
    setState(() {
      _isParticipated = true;
    });

    if (mounted) {
      PassportStampToast.show(
        context,
        title: 'Bâtisseur Honoraire de Djenné',
        type: PassportItemType.monument,
      );
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final isDjenne = widget.monument.id.contains('djenne');

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isParticipated
              ? const Color(0xFFF59E0B)
              : borderCol,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── EN-TÊTE DU RITUEL ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB45309), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDjenne
                            ? 'La Fête Sacrée du Crépissage'
                            : 'La Mémoire Vivante des Bâtisseurs',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        isDjenne
                            ? 'Une cité unie pour préserver son sanctuaire'
                            : 'Transmission sacrée de génération en génération',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── CITATION DU MAÎTRE MAÇON ───────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                  : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 22,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '« Tant que les mains de Djenné pétrissent l\'argile dans la concorde, ce temple défiera les millénaires. »',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '— Doyen des Barey Ton (Corporation des Maçons de Djenné)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── RÉCIT VIVANT DU RITUEL ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isDjenne
                  ? 'Chaque année à l\'aube, des milliers d\'habitants se rassemblent au son des tambours. Les enfants puisent l\'eau du Bani, les femmes battent la boue avec la balle de riz et le beurre de karité, tandis que les jeunes gens grimpent prestement sur les torons pour crépir l\'édifice en moins de 3 heures.'
                  : 'Les corporations traditionnelles maliens perpétuent des savoirs d\'ingénierie et de solidarité communautaire reconnus comme chefs-d\'œuvre du patrimoine immatériel universel.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: subtitleColor,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── GESTE PARTICIPATIF INTERACTIF ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _isParticipated
                ? _buildCompletedBadge(isDark, titleColor)
                : _buildInteractiveButton(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveButton(bool isDark) {
    return GestureDetector(
      onTapDown: (_) => _startPress(),
      onTapUp: (_) => _cancelPress(),
      onTapCancel: () => _cancelPress(),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB45309), Color(0xFFD97706)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Barre de progression de maintien
            AnimatedContainer(
              duration: const Duration(milliseconds: 30),
              width: MediaQuery.of(context).size.width * _pressProgress,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            // Contenu du bouton
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.touch_app_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _pressProgress > 0
                        ? 'Scellement en cours... ${(_pressProgress * 100).toInt()}%'
                        : 'Maintiens pour poser ta motte de banco',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedBadge(bool isDark, Color titleColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF59E0B),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Titre Débloqué : Bâtisseur Honoraire',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                Text(
                  'Votre motte d\'argile est symboliquement gravée dans le sanctuaire.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
