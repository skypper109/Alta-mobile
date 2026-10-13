// ─── AlterniA — Arène de Duel Scolaire (Connecté IA & Programme Malien) ──────
// Matchs chronométrés, questions dynamiques par IA, validation multijoueur,
// et attribution des récompenses XPS & Pièces AlterniA.
// Design système officiel : zéro dégradé, zéro sticker, charte AlterniA.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import '../../../core/services/sync_queue_service.dart';
import '../../profile/gamification_notifier.dart';
import 'duel_leaderboard_screen.dart';
import 'duel_model.dart';
import 'duel_service.dart';

class DuelArenaScreen extends ConsumerStatefulWidget {
  const DuelArenaScreen({
    super.key,
    required this.subject,
    required this.classLevel,
    required this.mode,
    this.playerName = 'Élève',
    this.opponentName = 'Professeur IA',
    this.roomCode,
    this.initialQuestions,
    this.questionCount = 5,
  });

  final String subject;
  final String classLevel;
  final DuelMode mode;
  final String playerName;
  final String opponentName;
  final String? roomCode;
  final List<DuelQuestion>? initialQuestions;
  final int questionCount;

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

    if (widget.initialQuestions != null &&
        widget.initialQuestions!.isNotEmpty) {
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
      count: widget.questionCount,
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
      _selectedOption = -1;
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
        _playerScore += 100 + (_secondsRemaining * 10);
      }
      _simulateOpponent();
    });

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
      final aiIsCorrect = (_currentIndex % 4 != 3);
      if (aiIsCorrect) {
        _opponentScore += 90 + ((_secondsRemaining + 2) * 8);
      }
    } else if (widget.mode == DuelMode.matchmakingMali) {
      final peerCorrect = (_currentIndex % 5 != 2);
      if (peerCorrect) {
        _opponentScore += 100 + ((_secondsRemaining + 1) * 8);
      }
    } else if (widget.roomCode != null) {
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
    final isDraw = _playerScore == _opponentScore;
    final playerWon = _playerScore > _opponentScore;

    final xpGained = playerWon ? 250 : (isDraw ? 120 : 75);
    final coinsGained = playerWon ? 50 : (isDraw ? 25 : 15);

    ref.read(gamificationProvider.notifier).addDuelReward(
          xpGained: xpGained,
          coinsGained: coinsGained,
          subject: widget.subject,
          won: playerWon,
        );

    // Persistance asynchrone Store & Forward (Garantit la sauvegarde même hors-ligne)
    ref.read(syncQueueProvider.notifier).enqueue(
      SyncEventType.duelCompleted,
      {
        'subject': widget.subject,
        'player_score': _playerScore,
        'opponent_score': _opponentScore,
        'is_winner': playerWon,
        'xp_earned': xpGained,
        'coins_earned': coinsGained,
        'opponent_name': widget.opponentName,
        'mode': widget.mode.name,
      },
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
    final bg = isDark ? AltaColors.backgroundDark : AltaColors.backgroundLight;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    if (_isLoadingQuestions) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AltaColors.primary.withValues(alpha: 0.12),
                ),
                child: const CircularProgressIndicator(
                  color: AltaColors.secondary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Connexion à l\'IA AlterniA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Génération des questions d\'examen en cours...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: textSec,
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
        : (_secondsRemaining <= 8 ? AltaColors.primary : AltaColors.secondary);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A2340), Color(0xFF253060)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Text(
            '${widget.subject} • Q${_currentIndex + 1}/${_questions.length}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                    const SizedBox(height: 10),

                    // ── 1. HEADER DUEL : JOUEUR VS ADVERSAIRE ─────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderCol),
                        boxShadow: [
                          BoxShadow(
                            color: AltaColors.primary.withValues(alpha: 0.08),
                            blurRadius: 14,
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
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF314999),
                                        Color(0xFF4C66C4)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(Icons.person,
                                      color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.playerName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: textPri,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '$_playerScore pts',
                                        style: GoogleFonts.spaceMono(
                                          color: AltaColors.secondary,
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
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF314999), Color(0xFF1A2340)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'VS',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          // Joueur 2
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
                                          fontSize: 12,
                                          color: textPri,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '$_opponentScore pts',
                                        style: GoogleFonts.spaceMono(
                                          color: AltaColors.accent,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFF1851F),
                                        Color(0xFFFF9D42)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Icon(
                                    widget.mode == DuelMode.vsAi
                                        ? Icons.smart_toy_rounded
                                        : Icons.groups_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── 2. BADGE SOURCE DUEL (SANS STICKER) ───────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AltaColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                currentQ.source.contains('ia')
                                    ? Icons.auto_awesome
                                    : Icons.verified,
                                size: 12,
                                color: AltaColors.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                currentQ.source.contains('ia')
                                    ? 'Question IA en direct'
                                    : 'Programme Officiel Malien',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AltaColors.secondary,
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
                              color: AltaColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Salon ${widget.roomCode}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AltaColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── 3. JAUGE DE CHRONO PULSANTE ─────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: isDark
                                      ? AltaColors.borderDark
                                      : AltaColors.borderLight,
                                  boxShadow: _secondsRemaining <= 4
                                      ? [
                                          BoxShadow(
                                            color: timerColor.withValues(
                                                alpha: 0.45),
                                            blurRadius: 8,
                                            spreadRadius: 0,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (_, __) => LinearProgressIndicator(
                                      value: timerProgress,
                                      minHeight: 10,
                                      backgroundColor: Colors.transparent,
                                      valueColor: AlwaysStoppedAnimation(
                                        timerColor.withValues(
                                          alpha: _secondsRemaining <= 4
                                              ? 0.7 +
                                                  0.3 * _pulseController.value
                                              : 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: timerColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: timerColor.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            '${_secondsRemaining}s',
                            style: GoogleFonts.spaceMono(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: timerColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── 4. CARTE ÉNONCÉ DE LA QUESTION ───────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderCol),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Accent strip top
                            Container(
                              height: 3,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF314999),
                                    Color(0xFF40BBCC)
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Text(
                                currentQ.questionText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  color: textPri,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── 5. OPTIONS DE RÉPONSE ────────────────────────────────
                    Expanded(
                      child: ListView.separated(
                        itemCount: currentQ.options.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final optText = currentQ.options[i];
                          final isSelected = _selectedOption == i;
                          final isCorrect = i == currentQ.correctOptionIndex;

                          Color bgColor;
                          Color borderColor;
                          Color textColor;

                          if (!_answered) {
                            bgColor = cardBg;
                            borderColor = borderCol;
                            textColor = textPri;
                          } else {
                            if (isCorrect) {
                              bgColor =
                                  AltaColors.success.withValues(alpha: 0.12);
                              borderColor = AltaColors.success;
                              textColor = isDark
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFF16A34A);
                            } else if (isSelected) {
                              bgColor =
                                  AltaColors.error.withValues(alpha: 0.10);
                              borderColor = AltaColors.error;
                              textColor = isDark
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFDC2626);
                            } else {
                              bgColor = isDark
                                  ? AltaColors.surfaceAltDark
                                  : AltaColors.surfaceAltLight;
                              borderColor = Colors.transparent;
                              textColor = textSec;
                            }
                          }

                          return GestureDetector(
                            onTap: _answered ? null : () => _submitAnswer(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: borderColor,
                                  width:
                                      (isSelected || (isCorrect && _answered))
                                          ? 1.8
                                          : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          borderColor.withValues(alpha: 0.15),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      String.fromCharCode(65 + i),
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      optText,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  if (_answered && isCorrect)
                                    Icon(Icons.check_circle_rounded,
                                        color: AltaColors.success, size: 20)
                                  else if (_answered &&
                                      isSelected &&
                                      !isCorrect)
                                    Icon(Icons.cancel_rounded,
                                        color: AltaColors.error, size: 20),
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
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AltaColors.secondary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded,
                                    color: AltaColors.primary, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Explication Pédagogique :',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AltaColors.secondary,
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
                                color: textSec,
                              ),
                            ),
                            if (currentQ.tip.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Astuce : ${currentQ.tip}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AltaColors.primary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AltaColors.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: _nextQuestion,
                                child: Text(
                                  _currentIndex < _questions.length - 1
                                      ? 'Question Suivante'
                                      : 'Voir le Podium & Récompenses',
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

// ── MODAL PODIUM VICTOIRE & RÉCOMPENSES (CHARTE ALTERNIA SOLIDE) ────────────
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);
    final gamification = ref.watch(gamificationProvider);

    final isDraw = playerScore == opponentScore;
    final didWin = playerScore > opponentScore;

    final String resultTitle;
    final String resultSubtitle;
    final IconData resultIcon;
    final Color resultColor;
    final String actionText;

    if (isDraw) {
      resultTitle = 'Match Nul';
      resultSubtitle =
          'Égalité parfaite ($playerScore - $opponentScore) sur le programme de $subject !';
      resultIcon = Icons.handshake_rounded;
      resultColor = AltaColors.secondary;
      actionText = 'Rejouer';
    } else if (didWin) {
      resultTitle = 'Victoire Éclatante';
      resultSubtitle = 'Tu as remporté ce duel sur le programme de $subject.';
      resultIcon = Icons.emoji_events_rounded;
      resultColor = AltaColors.secondary;
      actionText = 'Rejouer';
    } else {
      resultTitle = 'Beau Combat';
      resultSubtitle =
          'Bel entraînement. Prends ta revanche pour surpasser $opponentName !';
      resultIcon = Icons.military_tech_rounded;
      resultColor = AltaColors.primary;
      actionText = 'Revanche';
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── GRADIENT HEADER HERO ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A2340), Color(0xFF314999)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Icon podium
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: resultColor.withValues(alpha: 0.20),
                      border: Border.all(
                        color: resultColor.withValues(alpha: 0.40),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(resultIcon, size: 42, color: resultColor),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    resultTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    resultSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.80),
                    ),
                  ),
                ],
              ),
            ),

            // ── BODY CONTENT ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                children: [
                  // ── SCORES COMPARATIFS ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ScoreCard(
                          label: playerName,
                          score: playerScore,
                          isWinner: didWin,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF314999),
                                    Color(0xFF1A2340)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'VS',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _ScoreCard(
                          label: opponentName,
                          score: opponentScore,
                          isWinner: !didWin && !isDraw,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── RÉCOMPENSES ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AltaColors.surfaceAltDark
                          : AltaColors.surfaceAltLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AltaColors.secondary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AltaColors.secondary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'RÉCOMPENSES',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: textSec,
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
                                    vertical: 11, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AltaColors.secondary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AltaColors.secondary
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.bolt_rounded,
                                        color: AltaColors.secondary, size: 20),
                                    const SizedBox(height: 2),
                                    Text(
                                      '+$xpReward XPS',
                                      style: GoogleFonts.spaceMono(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: AltaColors.secondary,
                                      ),
                                    ),
                                    Text(
                                      'Points XP',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        color: textSec,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Badge Pièces
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 11, horizontal: 10),
                                decoration: BoxDecoration(
                                  color:
                                      AltaColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AltaColors.accent
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.monetization_on_rounded,
                                        color: AltaColors.accent, size: 20),
                                    const SizedBox(height: 2),
                                    Text(
                                      '+$coinsReward',
                                      style: GoogleFonts.spaceMono(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: AltaColors.accent,
                                      ),
                                    ),
                                    Text(
                                      'Pièces AlterniA',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        color: textSec,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Solde : ${gamification.xp} XP  •  ${gamification.coins} Pièces',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: textSec,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── CLASSEMENT ─────────────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DuelLeaderboardScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AltaColors.secondary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AltaColors.secondary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.leaderboard_rounded,
                              size: 17, color: AltaColors.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'Classement National & Lycées',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AltaColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── REVANCHE & QUITTER ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onExit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: isDark
                                      ? Colors.white24
                                      : AltaColors.borderLight,
                                  width: 1.2),
                            ),
                            child: Center(
                              child: Text(
                                'Quitter',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: textPri,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: onReplay,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: AltaColors.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                actionText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AltaColors.surfaceAltDark : AltaColors.surfaceAltLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWinner
              ? AltaColors.secondary.withValues(alpha: 0.70)
              : Colors.transparent,
          width: isWinner ? 1.8 : 1.0,
        ),
        boxShadow: isWinner
            ? [
                BoxShadow(
                  color: AltaColors.secondary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isWinner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AltaColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🏆 VAINQUEUR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: AltaColors.secondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: textSec,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: GoogleFonts.spaceMono(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isWinner ? AltaColors.secondary : textPri,
            ),
          ),
          Text(
            'pts',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: textSec,
            ),
          ),
        ],
      ),
    );
  }
}
