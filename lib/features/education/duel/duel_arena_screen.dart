// ─── AlterniA — Arène de Duel Scolaire (Connecté IA & Programme Malien) ──────
// Matchs chronométrés, questions dynamiques par IA, validation multijoueur,
// et attribution des récompenses XPS & Pièces AlterniA.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../profile/gamification_notifier.dart';
import 'duel_model.dart';
import 'duel_service.dart';

class DuelArenaScreen extends ConsumerStatefulWidget {
  const DuelArenaScreen({
    super.key,
    required this.subject,
    required this.classLevel,
    required this.mode,
    this.playerName = 'Élève',
    this.opponentName = 'Professeur Henri IA',
    this.roomCode,
    this.initialQuestions,
  });

  final String subject;
  final String classLevel;
  final DuelMode mode;
  final String playerName;
  final String opponentName;
  final String? roomCode;
  final List<DuelQuestion>? initialQuestions;

  @override
  ConsumerState<DuelArenaScreen> createState() => _DuelArenaScreenState();
}

class _DuelArenaScreenState extends ConsumerState<DuelArenaScreen>
    with SingleTickerProviderStateMixin {
  List<DuelQuestion> _questions = [];
  bool _isLoadingQuestions = true;
  int _currentIndex = 0;

  // Scores
  int _playerScore = 0;
  int _opponentScore = 0;

  // Timer
  static const int _questionDuration = 15;
  int _secondsRemaining = _questionDuration;
  Timer? _timer;
  Timer? _opponentPollTimer;

  // State de sélection
  int? _selectedOption;
  bool _answered = false;
  bool _showingExplanation = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    if (widget.initialQuestions != null && widget.initialQuestions!.isNotEmpty) {
      _questions = widget.initialQuestions!;
      _isLoadingQuestions = false;
      _startTimer();
    } else {
      _loadQuestions();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _opponentPollTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoadingQuestions = true);
    final qs = await duelServiceProvider.fetchQuestions(
      subject: widget.subject,
      classLevel: widget.classLevel,
      count: 5,
    );
    if (!mounted) return;
    setState(() {
      _questions = qs;
      _isLoadingQuestions = false;
      _currentIndex = 0;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = _questionDuration;
      _answered = false;
      _selectedOption = null;
      _showingExplanation = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining <= 4) {
          HapticFeedback.selectionClick();
        }
      } else {
        _timer?.cancel();
        _onTimeExpired();
      }
    });
  }

  void _onTimeExpired() {
    if (_answered) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _answered = true;
      _selectedOption = -1; // Expiré
      _simulateOpponent();
    });
    _showExplanationDialog();
  }

  void _submitAnswer(int index) {
    if (_answered) return;
    _timer?.cancel();
    HapticFeedback.mediumImpact();

    final currentQ = _questions[_currentIndex];
    final isCorrect = index == currentQ.correctOptionIndex;

    setState(() {
      _answered = true;
      _selectedOption = index;
      if (isCorrect) {
        // Points calculés selon la vitesse restante
        _playerScore += 100 + (_secondsRemaining * 10);
      }
      _simulateOpponent();
    });

    // Envoi du score au salon serveur si mode en ligne avec code
    if (widget.roomCode != null) {
      duelServiceProvider.updateScore(
        roomCode: widget.roomCode!,
        playerName: widget.playerName,
        score: _playerScore,
        questionIndex: _currentIndex,
      );
    }

    _showExplanationDialog();
  }

  void _simulateOpponent() {
    if (widget.mode == DuelMode.vsAi) {
      // L'IA a 75% de chance de trouver la bonne réponse
      final aiIsCorrect = (_currentIndex % 4 != 3);
      if (aiIsCorrect) {
        _opponentScore += 90 + ((_secondsRemaining + 2) * 8);
      }
    } else if (widget.mode == DuelMode.matchmakingMali) {
      // Camarade malien : réagit avec vivacité (80% de réussite)
      final peerCorrect = (_currentIndex % 5 != 2);
      if (peerCorrect) {
        _opponentScore += 100 + ((_secondsRemaining + 1) * 8);
      }
    } else if (widget.roomCode != null) {
      // Mode salon avec code : synchroniser ou faire progresser
      _opponentScore += 95 + (_secondsRemaining * 6);
    }
  }

  void _showExplanationDialog() {
    setState(() {
      _showingExplanation = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startTimer();
    } else {
      _finishDuel();
    }
  }

  void _finishDuel() {
    _timer?.cancel();
    _opponentPollTimer?.cancel();
    final playerWon = _playerScore >= _opponentScore;

    // Calcul des récompenses officielles XPS et Pièces
    final xpGained = playerWon ? 250 : 75;
    final coinsGained = playerWon ? 50 : 15;

    // Attribution et persistance immédiate dans le State
    ref.read(gamificationProvider.notifier).addDuelReward(
      xpGained: xpGained,
      coinsGained: coinsGained,
      subject: widget.subject,
      won: playerWon,
    );

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DuelVictoryModal(
        playerScore: _playerScore,
        opponentScore: _opponentScore,
        playerWon: playerWon,
        playerName: widget.playerName,
        opponentName: widget.opponentName,
        subject: widget.subject,
        xpReward: xpGained,
        coinsReward: coinsGained,
        onReplay: () {
          Navigator.pop(ctx);
          setState(() {
            _playerScore = 0;
            _opponentScore = 0;
            _currentIndex = 0;
          });
          _loadQuestions();
        },
        onExit: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoadingQuestions) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF1F5F9),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.15),
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 3.5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Connexion à l\'IA AlterniA 🧠✨',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Génération des questions d\'élite sur le programme malien...',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQ = _questions.isNotEmpty ? _questions[_currentIndex] : null;
    final timerProgress = _secondsRemaining / _questionDuration;
    final timerColor = _secondsRemaining <= 4
        ? Colors.redAccent
        : (_secondsRemaining <= 8 ? Colors.amber : AppColors.secondary);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Text(
            '${widget.subject} • Question ${_currentIndex + 1}/${_questions.length}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ),
      ),
      body: currentQ == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // ── 1. HEADER DUEL : JOUEUR VS ADVERSAIRE ─────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141D33) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF233256)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Joueur 1
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primary,
                                  child: const Icon(Icons.person,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.playerName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '$_playerScore pts',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // VS Badge central
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'VS',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Joueur 2 / IA / Camarade Mali
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        widget.opponentName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '$_opponentScore pts',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.accent,
                                  child: Icon(
                                    widget.mode == DuelMode.vsAi
                                        ? Icons.smart_toy_rounded
                                        : Icons.groups_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── 2. BADGE SOURCE DUEL (IA TEMPS RÉEL VS HORS-LIGNE) ─────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (currentQ.source.contains('ia')
                                    ? AppColors.secondary
                                    : Colors.amber)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (currentQ.source.contains('ia')
                                      ? AppColors.secondary
                                      : Colors.amber)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                currentQ.source.contains('ia')
                                    ? Icons.auto_awesome_rounded
                                    : Icons.verified_rounded,
                                size: 13,
                                color: currentQ.source.contains('ia')
                                    ? AppColors.secondary
                                    : Colors.amber,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                currentQ.source.contains('ia')
                                    ? 'Généré par l\'IA AlterniA 🧠✨'
                                    : 'Programme Officiel Malien 🇲🇱',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: currentQ.source.contains('ia')
                                      ? AppColors.secondary
                                      : Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.roomCode != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.accent.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              'SALLE ${widget.roomCode}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── 3. JAUGE DE CHRONO PULSANTE ─────────────────────────
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: timerProgress,
                            minHeight: 10,
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFCBD5E1),
                            valueColor: AlwaysStoppedAnimation(timerColor),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(top: 24),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: timerColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_secondsRemaining}s',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: timerColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── 4. CARTE ÉNONCÉ DE LA QUESTION ───────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF1E2846),
                                  const Color(0xFF141B33),
                                ]
                              : [
                                  Colors.white,
                                  const Color(0xFFF8FAFC),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : const Color(0xFFCBD5E1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        currentQ.questionText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── 5. OPTIONS DE RÉPONSE CLICABLES ──────────────────────
                    Expanded(
                      child: ListView.separated(
                        itemCount: currentQ.options.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final optText = currentQ.options[i];
                          final isSelected = _selectedOption == i;
                          final isCorrect = i == currentQ.correctOptionIndex;

                          Color bgColor;
                          Color borderColor;
                          Color textColor;

                          if (!_answered) {
                            bgColor = isDark
                                ? const Color(0xFF141D33)
                                : Colors.white;
                            borderColor = isDark
                                ? const Color(0xFF222F4C)
                                : const Color(0xFFE2E8F0);
                            textColor = isDark ? Colors.white : Colors.black87;
                          } else {
                            if (isCorrect) {
                              bgColor = Colors.green.withValues(alpha: 0.15);
                              borderColor = Colors.green;
                              textColor = Colors.greenAccent;
                            } else if (isSelected) {
                              bgColor = Colors.red.withValues(alpha: 0.15);
                              borderColor = Colors.redAccent;
                              textColor = Colors.redAccent;
                            } else {
                              bgColor = isDark
                                  ? const Color(0xFF101728)
                                  : const Color(0xFFF1F5F9);
                              borderColor = Colors.transparent;
                              textColor = isDark ? Colors.white38 : Colors.black38;
                            }
                          }

                          return GestureDetector(
                            onTap: _answered ? null : () => _submitAnswer(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: borderColor,
                                  width: (isSelected || (isCorrect && _answered))
                                      ? 2.0
                                      : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: borderColor.withValues(alpha: 0.15),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      String.fromCharCode(65 + i),
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      optText,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  if (_answered && isCorrect)
                                    const Icon(Icons.check_circle_rounded,
                                        color: Colors.green, size: 22)
                                  else if (_answered && isSelected && !isCorrect)
                                    const Icon(Icons.cancel_rounded,
                                        color: Colors.redAccent, size: 22),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ── 6. CARTE EXPLICATION & ASTUCE DU TUTEUR IA ────────────
                    if (_showingExplanation)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF16223D)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb_rounded,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'Explication & Astuce BAC :',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentQ.explanation,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                height: 1.4,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            if (currentQ.tip.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                '💡 ${currentQ.tip}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade400,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                ),
                                onPressed: _nextQuestion,
                                child: Text(
                                  _currentIndex < _questions.length - 1
                                      ? 'Question Suivante →'
                                      : 'Voir le Podium & Récompenses 🏆',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
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
  }
}

// ── MODAL PODIUM VICTOIRE & RÉCOMPENSES XPS / PIÈCES ────────────────────────
class _DuelVictoryModal extends ConsumerWidget {
  const _DuelVictoryModal({
    required this.playerScore,
    required this.opponentScore,
    required this.playerWon,
    required this.playerName,
    required this.opponentName,
    required this.subject,
    required this.xpReward,
    required this.coinsReward,
    required this.onReplay,
    required this.onExit,
  });

  final int playerScore;
  final int opponentScore;
  final bool playerWon;
  final String playerName;
  final String opponentName;
  final String subject;
  final int xpReward;
  final int coinsReward;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1424),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── ICÔNE GLOWING PODIUM ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: playerWon
                  ? Colors.amber.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: (playerWon ? Colors.amber : Colors.orange)
                      .withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              playerWon ? Icons.emoji_events_rounded : Icons.military_tech_rounded,
              size: 50,
              color: playerWon ? Colors.amber : Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            playerWon ? 'VICTOIRE ÉCLATANTE ! 🏆' : 'BEAU COMBAT ! ⚔️',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            playerWon
                ? 'Tu as triomphé sur le programme officiel de $subject !'
                : 'Bel engagement ! Recommence pour dominer le sujet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 20),

          // ── SCORES COMPARATIFS ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ScoreCard(label: playerName, score: playerScore, isWinner: playerWon),
              _ScoreCard(label: opponentName, score: opponentScore, isWinner: !playerWon),
            ],
          ),

          const SizedBox(height: 20),

          // ── CARTES DE RÉCOMPENSES XPS ET PIÈCES ALTERNIA ─────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E294A),
                  const Color(0xFF121B30),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'RÉCOMPENSES DE FIN DE DUEL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Badge XP
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: AppColors.secondary, size: 22),
                            const SizedBox(width: 6),
                            Text(
                              '+$xpReward XPS',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Badge Pièces AlterniA
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.monetization_on_rounded,
                                color: Colors.amber, size: 22),
                            const SizedBox(width: 6),
                            Text(
                              '+$coinsReward PIÈCES',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Portefeuille AlterniA : ${gamification.xp} XP • ${gamification.coins} Pièces 🪙',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── BOUTONS REVANCHE ET QUITTER ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onExit,
                  child: const Text('Quitter', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onReplay,
                  child: const Text('Revanche ⚔️',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.score,
    required this.isWinner,
  });

  final String label;
  final int score;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isWinner
            ? AppColors.primary.withValues(alpha: 0.25)
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWinner ? AppColors.secondary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('$score pts',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? AppColors.secondary : Colors.white)),
        ],
      ),
    );
  }
}
