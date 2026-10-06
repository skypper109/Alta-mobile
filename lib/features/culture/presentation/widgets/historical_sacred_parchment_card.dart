import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../immersive/services/cultural_haptics.dart';

/// 📜 CARTE DU PARCHEMIN SACRÉ / DÉCRET HISTORIQUE
/// Présente le serment, la charte ou la parole mémorable fondatrice
/// propre à CHAQUE grand personnage de l'histoire du Mali avec
/// une esthétique de parchemin royal, ornementation calligraphique et reflet doré.
class HistoricalSacredParchmentCard extends StatefulWidget {
  final HistoricalFigureDetail figure;
  final bool isDark;

  const HistoricalSacredParchmentCard({
    super.key,
    required this.figure,
    required this.isDark,
  });

  @override
  State<HistoricalSacredParchmentCard> createState() =>
      _HistoricalSacredParchmentCardState();
}

class _HistoricalSacredParchmentCardState
    extends State<HistoricalSacredParchmentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final figId = widget.figure.id;

    String badgeText = 'HISTOIRE • MÉMOIRE';
    String titleText = 'DÉCLARATION HISTORIQUE';
    String quoteText = widget.figure.citationHistorique ??
        '« L\'histoire est le guide des générations futures. »';
    String subtitleText =
        '— Parole mémorable de ${widget.figure.name}, transmise par la tradition orale et les archives.';
    Color accentColor = const Color(0xFFF59E0B);
    IconData sealIcon = Icons.auto_stories_rounded;

    if (figId.contains('soundiata')) {
      badgeText = 'UNESCO • 1236';
      titleText = 'CHARTE DE KOUROUKAN FOUGA';
      quoteText =
          '« Toute vie humaine est une vie. Le tort fait à autrui demande réparation. Respectez l\'étranger, l\'aîné et la femme. »';
      subtitleText =
          '— Proclamée par Soundiata Keïta à Kangaba (1236). Première constitution des droits fondamentaux de l\'humanité.';
      accentColor = const Color(0xFFF59E0B);
      sealIcon = Icons.military_tech_rounded;
    } else if (figId.contains('mansa_moussa')) {
      badgeText = 'UNESCO • 1324';
      titleText = 'PARCHEMIN DE L\'ÂGE D\'OR • TOMBOUCTOU';
      quoteText =
          '« Le savoir est la lumière de l\'empire ; les savants sont les gardiens de notre avenir. »';
      subtitleText =
          '— Mansa Moussa lors de la fondation de la Mosquée Djingareyber et de l\'essor de l\'Université de Sankoré (1327).';
      accentColor = const Color(0xFFF59E0B);
      sealIcon = Icons.account_balance_rounded;
    } else if (figId.contains('babemba')) {
      badgeText = 'KÉNÉDOUGOU • 1898';
      titleText = 'SERMENT DU TATA DE SIKASSO';
      quoteText =
          '« Sayon te malo ye ! La mort plutôt que la honte ! Nul ennemi ne verra Babemba captif. »';
      subtitleText =
          '— Babemba Traoré lors du siège de Sikasso (1er Mai 1898). Symbole éternel de la dignité et du refus de la soumission.';
      accentColor = const Color(0xFFDC2626);
      sealIcon = Icons.shield_rounded;
    } else if (figId.contains('askia_mohammed')) {
      badgeText = 'SONGHOÏ • 1493';
      titleText = 'CODE DE JUSTICE & SAVOIR DE GAO';
      quoteText =
          '« L\'encre des savants est plus précieuse que le sang des martyrs. Protégez les manuscrits de nos sages. »';
      subtitleText =
          '— Proclamé par Askia le Grand à Gao. Apogée des sciences, du droit équitable et de la civilisation songhoï.';
      accentColor = const Color(0xFF0D9488);
      sealIcon = Icons.gavel_rounded;
    } else if (figId.contains('biton')) {
      badgeText = 'SÉGOU-KORO • 1712';
      titleText = 'PACTE DES 4 444 BALANZANS';
      quoteText =
          '« L\'union fait la vigueur du bras ; la loyauté partagée au Tôn brise toute division. »';
      subtitleText =
          '— Biton Mamary Coulibaly, fondateur du Royaume Bambara de Ségou et maître des flottes du Djoliba.';
      accentColor = const Color(0xFF059669);
      sealIcon = Icons.groups_rounded;
    } else if (figId.contains('modibo_keita')) {
      badgeText = 'BAMAKO • 1960';
      titleText = 'PROCLAMATION D\'INDÉPENDANCE DU MALI';
      quoteText =
          '« En ce jour mémorable du 22 septembre 1960, le Mali renaît à l\'histoire libre, fier et souverain ! »';
      subtitleText =
          '— Modibo Keïta, Père de la Nation et artisan visionnaire de l\'indépendance et du panafricanisme (OUA).';
      accentColor = const Color(0xFF10B981);
      sealIcon = Icons.flag_rounded;
    }

    return GestureDetector(
      onTap: () => CulturalHaptics.cardPress(),
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          final shimmerValue = _shimmerController.value;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1F1206),
                        const Color(0xFF170C03),
                        const Color(0xFF241508),
                      ]
                    : [
                        const Color(0xFFFFFBEB),
                        const Color(0xFFFEF3C7),
                        const Color(0xFFFFFBEB),
                      ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.65),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Reflet spéculaire traversant sur la bordure dorée
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment(-2.0 + shimmerValue * 4.0, -1.0),
                          end: Alignment(-1.0 + shimmerValue * 4.0, 1.0),
                          colors: [
                            Colors.transparent,
                            accentColor.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête : Badge de certification et Titre avec Sceau
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(sealIcon, size: 12, color: Colors.black),
                              const SizedBox(width: 4),
                              Text(
                                badgeText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            titleText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 0.7,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Parole Sacrée / Citation Historique en exergue
                    Text(
                      quoteText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFF78350F),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Contexte d'origine et proclamation
                    Text(
                      subtitleText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFF92400E),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
