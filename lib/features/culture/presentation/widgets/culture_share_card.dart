import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../presentation/common/widgets/alternia_logo.dart';
import '../../core/models/culture_challenge_models.dart';
import '../../core/models/culture_proverb_models.dart';
import '../../core/theme/culture_theme.dart';

/// Carte de partage panoramique rectangulaire 16:9 au design soudano-sahélien d'AlterniA
/// Présentation épurée, noble et centrée sur le texte de sagesse/l'énigme et le logo officiel,
/// encadrée par les crochets d'angles traditionnels et le fond scénique du terroir.
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

    final cardContent = AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF131B2A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: CultureTheme.accentOrange.withValues(alpha: 0.6),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. FOND SCÉNIQUE DU TERROIR ──────────────────────────────────
              Image.asset(
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

              // Voile plat sombre pour lisibilité absolue (règle UX sans dégradé)
              Container(
                color: Colors.black.withValues(alpha: 0.54),
              ),

              // ── 2. CROCHETS D'ANGLES SOUDANO-SAHÉLIENS DORÉS ────────────────
              const Positioned.fill(
                child: _SudaneseCornerAccents(),
              ),

              // ── 3. CONTENU CENTRAL ÉPURÉ (PAROLE DE SAGESSE OU DEVINETTE) ──
              Positioned.fill(
                top: 22,
                bottom: 54,
                left: 32,
                right: 32,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: proverb != null
                        ? _buildProverbContent(proverb!)
                        : _buildRiddleContent(riddle!, showRiddleAnswer),
                  ),
                ),
              ),

              // ── 4. BAS DE CARTE : BRANDING ALTERNIA OFFICIEL CENTRÉ ─────────
              Positioned(
                bottom: 12,
                left: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const AlterniaLogo(
                      size: 22,
                      showText: true,
                      textColor: Colors.white,
                      iaColor: CultureTheme.iaYellow,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Savoirs & Patrimoine Vivant du Mali',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: cardContent);
    }
    return cardContent;
  }

  // Contenu Proverbe épuré & harmonieux
  Widget _buildProverbContent(CultureProverb item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Texte original en langue malienne (Bambara / Songhaï...)
        if (item.originalText != null && item.originalText!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFB347).withValues(alpha: 0.45),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Texte principal en français
        Text(
          '« ${item.text} »',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            height: 1.35,
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
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),

        // Morale / Sagesse condensée
        if (item.moral != null && item.moral!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
            decoration: BoxDecoration(
              color: CultureTheme.accentOrange.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.moral!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFD199),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  // Contenu Devinette épuré & centré
  Widget _buildRiddleContent(TraditionalRiddle item, bool showAnswer) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Formule rituelle d'introduction
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: CultureTheme.accentOrange.withValues(alpha: 0.55),
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
        const SizedBox(height: 8),

        // L'énigme posée
        Text(
          '« ${item.riddleText} »',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            height: 1.35,
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
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Réponse affichée ou invitation au défi
        if (showAnswer)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.8),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: Color(0xFF6EE7B7),
                ),
                const SizedBox(width: 5),
                Text(
                  'RÉPONSE : ${item.correctAnswer}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6EE7B7),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: CultureTheme.accentOrange.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  size: 12,
                  color: Color(0xFFFFD199),
                ),
                const SizedBox(width: 4),
                Text(
                  'Découvre la solution sur AlterniA !',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFD199),
                  ),
                ),
              ],
            ),
          ),
      ],
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
