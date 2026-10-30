import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/controllers/culture_passport_controller.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';

/// Carte de validation de maîtrise liant un contenu culturel (Monument, Personnage,
/// Ville/Terroir ou Conte) à son Défi Quiz dédié pour débloquer XP, Pièces Culturelles
/// et graver le Sceau dans le Passeport Culturel.
class ContentMasteryQuizCard extends ConsumerWidget {
  final String contentId;
  final PassportItemType contentType;
  final String contentTitle;
  final int xpReward;
  final int coinsReward;

  const ContentMasteryQuizCard({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.contentTitle,
    this.xpReward = 60,
    this.coinsReward = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final passport = ref.watch(culturePassportProvider);
    final isMastered = passport.isDiscovered(contentType, contentId);

    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final accentColor =
        isMastered ? const Color(0xFF10B981) : CultureTheme.accentOrange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.45 : 0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête : Badge de maîtrise ou de récompense ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMastered
                          ? Icons.verified_rounded
                          : Icons.military_tech_rounded,
                      size: 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMastered
                          ? 'CONTENU MAÎTRISÉ & GRAVÉ'
                          : 'DÉFI DE MAÎTRISE LIÉ AU CONTENU',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMastered)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$xpReward XP • +$coinsReward Pièces',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: CultureTheme.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Titre ──
          Text(
            isMastered
                ? 'Sceau débloqué : « $contentTitle »'
                : 'Valider votre lecture par le Défi Quiz',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: titleColor,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 6),

          // ── Description explicative ──
          Text(
            isMastered
                ? 'Vous avez terminé ce contenu et réussi son défi culturel (≥ 60%). Vos XP et pièces culturelles sont inscrits dans votre Passeport.'
                : 'Après avoir parcouru « $contentTitle », relevez le quiz associé et obtenez au moins 60% de bonnes réponses pour gagner vos XP, vos pièces culturelles et graver ce sceau.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 16),

          // ── Bouton d'action vers le Quiz dédié ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                CulturalHaptics.cardPress();
                context.push('/culture/quiz/$contentId');
              },
              icon: Icon(
                isMastered ? Icons.replay_rounded : Icons.quiz_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                isMastered
                    ? 'Rejouer le Défi Quiz de ce contenu'
                    : 'Relever le Défi Quiz (+$xpReward XP & +$coinsReward Pièces)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isMastered
                    ? CultureTheme.primaryBlue
                    : CultureTheme.accentOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

