// ─── AlterniA — Écran Flashcards & Mémorisation Leitner (Spaced Repetition) ──
// Révision active par cartes mémo avec animation 3D de retournement,
// vocalisation TTS, méthode Leitner et zéro dégradé.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/vivienne_tts_service.dart';
import 'flashcard_model.dart';
import 'flashcard_service.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key, this.selectedSubject});

  final String? selectedSubject;

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  late String _activeSubject;
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  int _sessionXpGained = 0;

  @override
  void initState() {
    super.initState();
    _activeSubject = widget.selectedSubject ?? 'Toutes';

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    try {
      VivienneTtsService.instance.stop();
    } catch (_) {}
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _rateCard(Flashcard card, int rating) {
    HapticFeedback.mediumImpact();
    ref.read(flashcardDeckProvider.notifier).reviewCard(card, rating);

    setState(() {
      _sessionXpGained += 15;
      _isFlipped = false;
      _flipController.reset();
      _currentIndex++;
    });
  }

  void _speakContent(String text) {
    HapticFeedback.lightImpact();
    VivienneTtsService.instance.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final deckState = ref.watch(flashcardDeckProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);
    final cardBg = isDark ? const Color(0xFF141C2E) : Colors.white;
    final borderCol = isDark ? const Color(0xFF23314D) : const Color(0xFFCBD5E1);

    if (deckState.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Flashcards Leitner',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Filtrage des cartes selon la matière sélectionnée
    final filteredCards = _activeSubject == 'Toutes'
        ? deckState.cards
        : deckState.cards.where((c) => c.subject == _activeSubject).toList();

    final isSessionFinished = _currentIndex >= filteredCards.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPri),
          onPressed: () {
            try {
              VivienneTtsService.instance.stop();
            } catch (_) {}
            context.pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flashcards de Révision',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            Text(
              'Méthode Spaced Repetition (DEF & Bac)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: textSec,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded,
                    size: 15, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(
                  '+$_sessionXpGained XP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.secondary : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── SÉLECTEUR DE MATIÈRE EN HORIZONTAL SCROLL ─────────────────
            Container(
              height: 44,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Toutes (${deckState.totalCount})',
                    isSelected: _activeSubject == 'Toutes',
                    onTap: () {
                      setState(() {
                        _activeSubject = 'Toutes';
                        _currentIndex = 0;
                        _isFlipped = false;
                        _flipController.reset();
                      });
                    },
                  ),
                  for (final sub in deckState.availableSubjects) ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: sub,
                      isSelected: _activeSubject == sub,
                      onTap: () {
                        setState(() {
                          _activeSubject = sub;
                          _currentIndex = 0;
                          _isFlipped = false;
                          _flipController.reset();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ── ZONE PRINCIPALE CARTE ─────────────────────────────────────
            Expanded(
              child: filteredCards.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune carte pour cette matière.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: textSec,
                        ),
                      ),
                    )
                  : isSessionFinished
                      ? _SessionFinishedView(
                          cardsReviewed: filteredCards.length,
                          totalXp: _sessionXpGained,
                          onRestart: () {
                            setState(() {
                              _currentIndex = 0;
                              _sessionXpGained = 0;
                              _isFlipped = false;
                              _flipController.reset();
                            });
                          },
                        )
                      : _buildActiveCardView(
                          context,
                          filteredCards[_currentIndex],
                          _currentIndex + 1,
                          filteredCards.length,
                          cardBg,
                          borderCol,
                          textPri,
                          textSec,
                          isDark,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCardView(
    BuildContext context,
    Flashcard card,
    int currentStep,
    int totalCards,
    Color cardBg,
    Color borderCol,
    Color textPri,
    Color textSec,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Indicateur de progression (ex: Carte 3 sur 10)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Carte $currentStep sur $totalCards',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.secondary : AppColors.primary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderCol),
                ),
                child: Text(
                  'Boîte Leitner ${card.box}/5',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textSec,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentStep / totalCards,
              minHeight: 5,
              backgroundColor:
                  isDark ? AppColors.surfaceAlt : const Color(0xFFE2E8F0),
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 18),

          // ── FLIP CARD ANIMÉE ──────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * pi;
                  final isBack = angle > pi / 2;

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isBack
                        ? Transform(
                            transform: Matrix4.identity()..rotateY(pi),
                            alignment: Alignment.center,
                            child: _CardSideView(
                              card: card,
                              isBack: true,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              textPri: textPri,
                              textSec: textSec,
                              isDark: isDark,
                              onAudioTap: () => _speakContent(card.back),
                            ),
                          )
                        : _CardSideView(
                            card: card,
                            isBack: false,
                            cardBg: cardBg,
                            borderCol: borderCol,
                            textPri: textPri,
                            textSec: textSec,
                            isDark: isDark,
                            onAudioTap: () => _speakContent(card.front),
                          ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── BOUTONS D'ÉVALUATION LEITNER ──────────────────────────────
          if (_isFlipped) ...[
            Text(
              'Comment avez-vous retenu cette notion ?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: textSec,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _LeitnerRateButton(
                    label: 'À revoir',
                    sublabel: 'J+1',
                    color: AppColors.error,
                    icon: Icons.refresh_rounded,
                    onTap: () => _rateCard(card, 1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _LeitnerRateButton(
                    label: 'Compris',
                    sublabel: 'J+3',
                    color: AppColors.accent,
                    icon: Icons.check_rounded,
                    onTap: () => _rateCard(card, 2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _LeitnerRateButton(
                    label: 'Maîtrisé',
                    sublabel: 'J+7',
                    color: AppColors.success,
                    icon: Icons.done_all_rounded,
                    onTap: () => _rateCard(card, 3),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _flipCard,
                icon: const Icon(Icons.touch_app_rounded, size: 18),
                label: Text(
                  'Toucher la carte pour afficher la réponse',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isDark ? AppColors.secondary : AppColors.primary,
                  side: BorderSide(
                    color: isDark ? AppColors.secondary : AppColors.primary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardSideView extends StatelessWidget {
  const _CardSideView({
    required this.card,
    required this.isBack,
    required this.cardBg,
    required this.borderCol,
    required this.textPri,
    required this.textSec,
    required this.isDark,
    required this.onAudioTap,
  });

  final Flashcard card;
  final bool isBack;
  final Color cardBg;
  final Color borderCol;
  final Color textPri;
  final Color textSec;
  final bool isDark;
  final VoidCallback onAudioTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isBack
              ? AppColors.secondary.withValues(alpha: 0.6)
              : borderCol,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte (Matière & Concept)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isBack ? AppColors.secondary : AppColors.primary)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  card.subject.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isBack ? AppColors.secondary : AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, size: 22),
                color: isBack ? AppColors.secondary : AppColors.primary,
                tooltip: 'Écouter vocalement',
                onPressed: onAudioTap,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              card.concept,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textSec,
              ),
            ),
          ),

          const Spacer(),

          // Contenu principal de la carte
          Center(
            child: Text(
              isBack ? card.back : card.front,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isBack ? 16 : 18,
                fontWeight: FontWeight.bold,
                height: 1.45,
                color: textPri,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          // Indication bas de carte
          Center(
            child: Text(
              isBack
                  ? 'Verso • Réponse & Méthode'
                  : 'Recto • Toucher pour révéler',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: textSec,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surface : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.border : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textPrimary : const Color(0xFF0F172A)),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeitnerRateButton extends StatelessWidget {
  const _LeitnerRateButton({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                sublabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionFinishedView extends StatelessWidget {
  const _SessionFinishedView({
    required this.cardsReviewed,
    required this.totalXp,
    required this.onRestart,
  });

  final int cardsReviewed;
  final int totalXp;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.military_tech_rounded,
              size: 54,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Session Terminée !',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous avez ancré $cardsReviewed notions clés dans votre mémoire à long terme.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: textSec,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded,
                    color: AppColors.secondary, size: 22),
                const SizedBox(width: 8),
                Text(
                  '+$totalXp XP Points Maîtrise Gagnés',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.secondary : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRestart,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Recommencer',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Terminer',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
