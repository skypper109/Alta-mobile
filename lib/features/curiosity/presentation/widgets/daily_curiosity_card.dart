import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../profile/gamification_notifier.dart';
import '../../controllers/daily_curiosity_controller.dart';
import '../screens/curiosity_discovery_modal.dart';

/// Carte compacte & percutante « La Pépite du Jour & Défi Éclair »
/// Réinvente l'accueil d'AlterniA : Teaser compact (30s) invitant à la découverte
/// et au défi éclair sans surcharger l'espace visuel de l'écran.
class DailyCuriosityCard extends ConsumerStatefulWidget {
  const DailyCuriosityCard({super.key});

  @override
  ConsumerState<DailyCuriosityCard> createState() => _DailyCuriosityCardState();
}

class _DailyCuriosityCardState extends ConsumerState<DailyCuriosityCard> {
  @override
  Widget build(BuildContext context) {
    final curiosityState = ref.watch(dailyCuriosityProvider);
    final curiosityCtrl = ref.read(dailyCuriosityProvider.notifier);
    final gamification = ref.watch(gamificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final item = curiosityState.todayItem;
    final isCompleted = curiosityState.isCompletedToday;
    final cardAccent = item.collectorCard.accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            CuriosityDiscoveryModal.show(
              context,
              item: item,
              isCompleted: isCompleted,
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF131D31),
                        const Color(0xFF0F172A),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFF8FAFC),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF10B981).withValues(alpha: 0.5)
                    : cardAccent.withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isCompleted ? const Color(0xFF10B981) : cardAccent)
                      .withValues(alpha: isDark ? 0.14 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. EN-TÊTE COMPACT : BADGE PÉPITE + FLAMME STREAK + AUDIO ───
                  Row(
                    children: [
                      // Badge "Pépite du Jour"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: cardAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cardAccent.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 3.5),
                            Text(
                              'PÉPITE DU JOUR • ${item.readTime}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Streak Flamme 🔥
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 13,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              gamification.streak,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Bouton Audio Narration
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          curiosityCtrl.toggleAudioNarration();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: curiosityState.isSpeakingAudio
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.white10
                                    : Colors.black.withValues(alpha: 0.05)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            curiosityState.isSpeakingAudio
                                ? Icons.volume_up_rounded
                                : Icons.volume_mute_rounded,
                            size: 14,
                            color: curiosityState.isSpeakingAudio
                                ? Colors.white
                                : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── 2. CORPS : TITRE ACCROCHEUR + CTA + MINIATURE ────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Titre & Call to action
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.hookTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Bouton d'action compact
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 12,
                                      color: Color(0xFF10B981),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Défi réussi (+50 XP) • Carte n°01/30',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8B5CF6),
                                      Color(0xFF6366F1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.offline_bolt_rounded,
                                      size: 12,
                                      color: Color(0xFFFDE047),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Relever le défi (+50 XP)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 11,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Miniature Photo de collection
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: cardAccent.withValues(alpha: 0.45),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF1E293B),
                                  child: const Icon(
                                    Icons.image_rounded,
                                    size: 24,
                                    color: Colors.white38,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 3,
                                bottom: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.touch_app_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
