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
import '../../../shared/edu_feature_widgets.dart';
import '../../../core/services/vivienne_tts_service.dart';
import '../../profile/user_prefs_notifier.dart';
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

  void _showGenerateAiCardsSheet(
    BuildContext context,
    List<String> subjects,
    String userClass,
  ) {
    String selectedSubject =
        subjects.contains(_activeSubject) && _activeSubject != 'Toutes'
            ? _activeSubject
            : (subjects.isNotEmpty ? subjects.first : 'Mathématiques');
    int selectedCount = 5;
    final topicCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderCol = isDark ? AppColors.border : const Color(0xFFCBD5E1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 22,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.school_rounded,
                      color: AppColors.secondary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Nouvelles Cartes Mémo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPri,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Création de cartes pédagogiques conformes au programme de $userClass.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondary
                      : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Matière du programme ($userClass)',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderCol),
                  ),
                ),
                items: subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedSubject = val);
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: topicCtrl,
                style:
                    GoogleFonts.plusJakartaSans(fontSize: 13, color: textPri),
                decoration: InputDecoration(
                  labelText: 'Chapitre ou notion clé (optionnel)',
                  hintText:
                      'ex: Stratification sociale, Séparation des pouvoirs...',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderCol),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Nombre de flashcards :',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [3, 5, 10].map((c) {
                  final isSel = selectedCount == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$c Cartes',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSel
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setModalState(() => selectedCount = c),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: Text(
                    'Générer $selectedCount Cartes Mémo ($userClass)',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                  'Génération des cartes mémo officielles pour $selectedSubject...'),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 4),
                        backgroundColor: AppColors.primary,
                      ),
                    );

                    final ok = await ref
                        .read(flashcardDeckProvider.notifier)
                        .fetchAiFlashcardsFromBackend(
                          subject: selectedSubject,
                          topic: topicCtrl.text.trim().isNotEmpty
                              ? topicCtrl.text.trim()
                              : null,
                          count: selectedCount,
                        );

                    if (context.mounted) {
                      if (ok) {
                        setState(() {
                          _activeSubject = selectedSubject;
                          _currentIndex = 0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '$selectedCount nouvelles cartes mémo ajoutées au deck !'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Le deck certifié officiel a été actualisé.'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckState = ref.watch(flashcardDeckProvider);
    final userPrefs = ref.watch(userPrefsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);
    final cardBg = isDark ? const Color(0xFF141C2E) : Colors.white;
    final borderCol =
        isDark ? const Color(0xFF23314D) : const Color(0xFFCBD5E1);

    final userClass = userPrefs.classShortLabel;

    // Dérivation dynamique stricte des matières basées sur la classe de l'élève
    final displaySubjects = <String>[];
    if (userPrefs.subjects.isNotEmpty) {
      displaySubjects.addAll(userPrefs.subjects);
    } else {
      displaySubjects.addAll([
        'Mathématiques',
        'Physique-Chimie',
        'Histoire-Géo',
        'Français',
        'Philosophie',
      ]);
    }

    if (deckState.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Cartes Revisions',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Filtrage strict : seules les cartes correspondant aux matières de la classe sont retenues
    final rawClassCards = deckState.cards.where((c) {
      if (userPrefs.subjects.isNotEmpty) {
        return userPrefs.subjects.any(
          (s) => s.toLowerCase() == c.subject.toLowerCase(),
        );
      }
      return true;
    }).toList();

    final classCards = rawClassCards.isNotEmpty
        ? rawClassCards
        : FlashcardBank.getInitialCards(
            level: userPrefs.studentClassId.isNotEmpty
                ? userPrefs.studentClassId
                : 'tss',
          );

    // Si la matière active n'appartient pas aux matières de la classe, réinitialiser à 'Toutes'
    if (_activeSubject != 'Toutes' &&
        !displaySubjects
            .any((s) => s.toLowerCase() == _activeSubject.toLowerCase())) {
      _activeSubject = 'Toutes';
    }

    // Filtrage des cartes selon la matière sélectionnée
    final filteredCards = _activeSubject == 'Toutes'
        ? classCards
        : classCards
            .where(
                (c) => c.subject.toLowerCase() == _activeSubject.toLowerCase())
            .toList();

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
              'Cartes Revisions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            Text(
              'Programme $userClass • Mémorisation active',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: textSec,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: deckState.isGeneratingAi
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.secondary,
                    ),
                  )
                : const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.secondary),
            tooltip: "Ajouter de nouvelles cartes mémo",
            onPressed: deckState.isGeneratingAi
                ? null
                : () => _showGenerateAiCardsSheet(
                    context, displaySubjects, userClass),
          ),
          if (_sessionXpGained > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
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
                    label: 'Toutes (${classCards.length})',
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
                  for (final sub in displaySubjects) ...[
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
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune carte pour $_activeSubject ($userClass)',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textPri,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Générez instantanément des cartes mémo certifiées conformes au programme officiel malien.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: textSec,
                              ),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: deckState.isGeneratingAi
                                  ? null
                                  : () async {
                                      final targetSub =
                                          _activeSubject == 'Toutes'
                                              ? (displaySubjects.isNotEmpty
                                                  ? displaySubjects.first
                                                  : 'Mathématiques')
                                              : _activeSubject;
                                      final ok = await ref
                                          .read(flashcardDeckProvider.notifier)
                                          .fetchAiFlashcardsFromBackend(
                                            subject: targetSub,
                                            count: 5,
                                          );
                                      if (ok && mounted) {
                                        setState(() => _currentIndex = 0);
                                      }
                                    },
                              icon: deckState.isGeneratingAi
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.bolt_rounded, size: 18),
                              label: Text(
                                deckState.isGeneratingAi
                                    ? 'Génération en cours...'
                                    : 'Générer 5 cartes avec l\'IA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ],
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
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
    final sideColor = isBack ? AppColors.secondary : AppColors.primary;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isBack ? sideColor.withValues(alpha: 0.6) : borderCol,
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
      child: AlterniaWatermark(
        size: 190,
        opacity: isDark ? 0.06 : 0.07,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau de couleur charte (recto bleu / verso cyan)
            Container(height: 4, color: sideColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête de la carte (Matière & Concept)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isBack
                                    ? AppColors.secondary
                                    : AppColors.primary)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            card.subject.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isBack
                                  ? AppColors.secondary
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, size: 22),
                          color:
                              isBack ? AppColors.secondary : AppColors.primary,
                          tooltip: 'Écouter vocalement',
                          onPressed: onAudioTap,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceAlt
                            : const Color(0xFFF1F5F9),
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

                    // Pied de carte : indication + signature AlterniA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            isBack
                                ? 'Verso • Réponse & Méthode'
                                : 'Recto • Toucher pour révéler',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: textSec,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AlterniaSignature(color: sideColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
