import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/vivienne_tts_service.dart';
import '../../core/models/culture_detail_models.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/models/monument_guided_tour_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import 'culture_audio_listen_badge.dart';
import 'passport_stamp_toast.dart';

/// Composant d'exploration pas-à-pas d'un monument historique
/// Guide l'utilisateur à travers les stations physiques du monument avec photos dédiées,
/// narration du guide conférencier et secrets d'observation.
class MonumentGuidedTourView extends StatefulWidget {
  final MonumentDetail monument;

  const MonumentGuidedTourView({
    super.key,
    required this.monument,
  });

  @override
  State<MonumentGuidedTourView> createState() => _MonumentGuidedTourViewState();
}

class _MonumentGuidedTourViewState extends State<MonumentGuidedTourView> {
  late final MonumentGuidedTour _tour;
  int _currentStepIndex = 0;
  final Set<int> _visitedSteps = {0};
  bool _tourCompleted = false;

  @override
  void initState() {
    super.initState();
    _tour = MonumentGuidedTourRegistry.getTourForMonument(widget.monument);
  }

  void _goToStep(int index) {
    if (index < 0 || index >= _tour.steps.length) return;
    CulturalHaptics.tabSwitch();
    VivienneTtsService.instance.stop();
    setState(() {
      _currentStepIndex = index;
      _visitedSteps.add(index);
    });
  }

  void _nextStep() {
    if (_currentStepIndex < _tour.steps.length - 1) {
      _goToStep(_currentStepIndex + 1);
    } else {
      _completeTour();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      _goToStep(_currentStepIndex - 1);
    }
  }

  void _completeTour() {
    CulturalHaptics.celebration();
    setState(() {
      _tourCompleted = true;
    });

    if (mounted) {
      PassportStampToast.show(
        context,
        title: 'Visite guidée : ${_tour.monumentName}',
        type: PassportItemType.monument,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final currentStep = _tour.steps[_currentStepIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.4 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. EN-TÊTE DU PARCOURS & GUIDE ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [CultureTheme.accentOrange, CultureTheme.accentLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_walk_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Visite Guidée Pas-à-Pas',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: titleColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: CultureTheme.accentOrange
                                  .withValues(alpha: isDark ? 0.2 : 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Étape ${_currentStepIndex + 1}/${_tour.steps.length}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: CultureTheme.accentOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_tour.guideName} • ${_tour.guideRole}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: CultureTheme.accentOrange,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 2. FIL D'ARIANE / STEPPER DES STATIONS ─────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_tour.steps.length, (idx) {
                final step = _tour.steps[idx];
                final isSelected = idx == _currentStepIndex;
                final isVisited = _visitedSteps.contains(idx);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _goToStep(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CultureTheme.accentOrange
                            : (isVisited
                                ? CultureTheme.accentOrange
                                    .withValues(alpha: isDark ? 0.18 : 0.08)
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9))),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? CultureTheme.accentOrange
                              : (isVisited
                                  ? CultureTheme.accentOrange
                                      .withValues(alpha: 0.35)
                                  : borderCol),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVisited && !isSelected
                                ? Icons.check_circle_rounded
                                : step.stepIcon,
                            size: 13,
                            color: isSelected
                                ? Colors.white
                                : (isVisited
                                    ? CultureTheme.accentOrange
                                    : subtitleColor),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${step.stepNumber}. ${step.title.split('&').first.trim()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isVisited ? titleColor : subtitleColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          // ── 3. GRANDE PHOTOGRAPHIE DÉDIÉE À L'ÉTAPE ────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.asset(
                      currentStep.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1E293B),
                        child: const Center(
                          child: Icon(
                            Icons.museum_rounded,
                            size: 48,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Dégradé pour lisibilité du badge
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.6, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Badge de localisation de la station
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.pin_drop_rounded,
                          size: 13,
                          color: Color(0xFFFCD34D),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            currentStep.locationBadge,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── 4. PAROLE DU GUIDE (RÉCIT DU CONFÉRENCIER) ──────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                    : CultureTheme.accentOrange.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.record_voice_over_rounded,
                        size: 16,
                        color: CultureTheme.accentOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'La parole du guide',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFF92400E),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      // Badge d'écoute audio Vivienne TTS
                      CultureAudioListenBadge(
                        contentId:
                            'tour_${widget.monument.id}_step_${currentStep.stepNumber}',
                        speechText:
                            '${currentStep.title}. ${currentStep.guideSpeech} '
                            '${currentStep.observationClue}',
                        label: 'Écouter',
                        compact: true,
                        activeColor: CultureTheme.accentOrange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentStep.guideSpeech,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.6,
                      color: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── 5. CE QU'IL FAUT OBSERVER (LE SECRET DU GUIDE) ─────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.remove_red_eye_rounded,
                      size: 15,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'À observer à cette étape :',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          currentStep.observationClue,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            height: 1.45,
                            color: subtitleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ── 6. COMMANDES DE NAVIGATION PAS-À-PAS ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Bouton Précédent
                if (_currentStepIndex > 0) ...[
                  GestureDetector(
                    onTap: _previousStep,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: titleColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Précédent',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // Bouton Suivant / Terminer
                Expanded(
                  child: GestureDetector(
                    onTap: _nextStep,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [CultureTheme.accentOrange, CultureTheme.accentLight],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: CultureTheme.accentOrange
                                .withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentStepIndex < _tour.steps.length - 1
                                  ? 'Étape suivante : ${_tour.steps[_currentStepIndex + 1].stepNumber}'
                                  : 'Terminer la visite guidée',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _currentStepIndex < _tour.steps.length - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.check_circle_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message de fin de visite débloqué
          if (_tourCompleted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.military_tech_rounded,
                      size: 20,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Visite guidée validée et tamponnée dans votre Passeport Culturel !',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
