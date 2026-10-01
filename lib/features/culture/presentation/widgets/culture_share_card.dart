import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../presentation/common/widgets/alternia_logo.dart';
import '../../core/models/culture_challenge_models.dart';
import '../../core/models/culture_proverb_models.dart';
import '../../core/theme/culture_theme.dart';

/// Carte de partage complète au design soudano-sahélien d'AlterniA
/// Affiche l'intégralité des informations (texte complet, signification, réponse,
/// explication culturelle) avec une hauteur adaptative pour ne rien tronquer.
class CultureShareCard extends StatelessWidget {
  final CultureProverb? proverb;
  final TraditionalRiddle? riddle;
  final bool showRiddleAnswer;
  final double? width;

  const CultureShareCard({
    super.key,
    this.proverb,
    this.riddle,
    this.showRiddleAnswer = false,
    this.width,
  }) : assert(proverb != null || riddle != null,
            'Au moins un proverbe ou une devinette doit être fourni');

  @override
  Widget build(BuildContext context) {
    // Choix de l'image scénique de fond
    final String stageImagePath = proverb?.stageImagePath ??
        (riddle?.photoUrl?.isNotEmpty == true
            ? riddle!.photoUrl!
            : 'assets/images/culture/contes/manden_baobab_stage.jpg');

    final cardWidget = Container(
      width: width,
      constraints: const BoxConstraints(maxWidth: 440),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: 0.65),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // ── 1. FOND SCÉNIQUE DU TERROIR ──────────────────────────────────
            Positioned.fill(
              child: Image.asset(
                stageImagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/culture/contes/manden_baobab_stage.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF131B2A),
                  ),
                ),
              ),
            ),

            // Voile sombre pour lisibilité absolue du texte
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F172A).withValues(alpha: 0.84),
                      const Color(0xFF0B1120).withValues(alpha: 0.90),
                    ],
                  ),
                ),
              ),
            ),

            // ── 2. CROCHETS D'ANGLES SOUDANO-SAHÉLIENS DORÉS ────────────────
            const Positioned.fill(
              child: _SudaneseCornerAccents(),
            ),

            // ── 3. CONTENU COMPLET ADAPTATIF EN HAUTEUR ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (proverb != null)
                    _buildProverbContent(proverb!)
                  else
                    _buildRiddleContent(riddle!, showRiddleAnswer),
                  const SizedBox(height: 16),
                  _buildBranding(),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return cardWidget;
  }

  // ── Contenu Proverbe intégral (Texte, Origine, Signification, Morale) ─────
  Widget _buildProverbContent(CultureProverb item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Texte original en langue malienne (Bambara / Songhaï...)
        if (item.originalText != null && item.originalText!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFFB347).withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                '« ${item.originalText} »',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFB347),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],

        // Texte principal en français (complet, sans troncature)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '« ${item.text} »',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              height: 1.4,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 8,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Boîte explicative : Signification transmise par les aînés
        if (item.meaning.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      size: 13,
                      color: CultureTheme.accentOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SIGNIFICATION & SAGESSE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.meaning,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.42,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Morale condensée
        if (item.moral != null && item.moral!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '✨ ${item.moral}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFD199),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Contenu Devinette intégral (Formule, Énigme, Réponse & Explication) ───
  Widget _buildRiddleContent(TraditionalRiddle item, bool showAnswer) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Formule rituelle d'introduction
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              item.formulaIntro.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: const Color(0xFFFFB347),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Texte intégral de l'énigme (complet, sans coupure)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '« ${item.riddleText} »',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              height: 1.4,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 8,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Réponse affichée ou invitation au défi
        if (showAnswer)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.7),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 15,
                      color: Color(0xFF6EE7B7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'RÉPONSE : ${item.correctAnswer.toUpperCase()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: const Color(0xFF6EE7B7),
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.culturalExplanation.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    item.culturalExplanation,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: const Color(0xFFD1FAE5),
                    ),
                  ),
                ],
                if (item.proverb != null && item.proverb!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '📜 Proverbe associé : « ${item.proverb} »',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA7F3D0),
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: CultureTheme.accentOrange.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  size: 14,
                  color: Color(0xFFFFD199),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'Sauras-tu trouver la solution ? Défie tes amis !',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFD199),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Branding AlterniA officiel ────────────────────────────────────────────
  Widget _buildBranding() {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
            width: 0.8,
          ),
        ),
      ),
      child: const Center(
        child: AlterniaLogo(
          size: 20,
          showText: true,
          textColor: Colors.white,
          iaColor: CultureTheme.iaYellow,
        ),
      ),
    );
  }
}

/// Crochets d'angles traditionnels soudano-sahéliens
class _SudaneseCornerAccents extends StatelessWidget {
  const _SudaneseCornerAccents();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerPainter(
        color: CultureTheme.accentOrange,
        strokeWidth: 2.2,
        cornerSize: 16.0,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerSize;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const pad = 9.0;

    // Haut-Gauche
    canvas.drawLine(
        Offset(pad, pad + cornerSize), const Offset(pad, pad), paint);
    canvas.drawLine(
        const Offset(pad, pad), Offset(pad + cornerSize, pad), paint);

    // Haut-Droite
    canvas.drawLine(Offset(size.width - pad - cornerSize, pad),
        Offset(size.width - pad, pad), paint);
    canvas.drawLine(Offset(size.width - pad, pad),
        Offset(size.width - pad, pad + cornerSize), paint);

    // Bas-Gauche
    canvas.drawLine(Offset(pad, size.height - pad - cornerSize),
        Offset(pad, size.height - pad), paint);
    canvas.drawLine(Offset(pad, size.height - pad),
        Offset(pad + cornerSize, size.height - pad), paint);

    // Bas-Droite
    canvas.drawLine(Offset(size.width - pad - cornerSize, size.height - pad),
        Offset(size.width - pad, size.height - pad), paint);
    canvas.drawLine(Offset(size.width - pad, size.height - pad),
        Offset(size.width - pad, size.height - pad - cornerSize), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      cornerSize != oldDelegate.cornerSize;
}
