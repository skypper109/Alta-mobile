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
    this.period = 'trimestre_1',
    this.durationSeconds = 15,
    this.isHost = true,
  });

  final String subject;
  final String classLevel;
  final DuelMode mode;
  final String playerName;
  final String opponentName;
  final String? roomCode;
  final List<DuelQuestion>? initialQuestions;
  final int questionCount;
  final String period;
  final int durationSeconds;
  final bool isHost;

  @override
  ConsumerState<DuelArenaScreen> createState() => _DuelArenaScreenState();
}

class _DuelArenaScreenState extends ConsumerState<DuelArenaScreen>
    with SingleTickerProviderStateMixin {
  List<DuelQuestion> _questions = [];
  bool _isLoadingQuestions = true;
  int _currentIndex = 0;

  // Scores & Réponses
  int _playerScore = 0;
  int _opponentScore = 0;
  int _opponentQuestionIndex = 0;
  bool _isWaitingForOpponentToFinish = false;
  final Map<int, int> _userAnswers = {};

  // Timers
  int get _questionDuration =>
      widget.durationSeconds > 0 ? widget.durationSeconds : 15;
  int _secondsRemaining = 15;
  int _waitingCountdownSeconds = 15;
  Timer? _timer;
  Timer? _opponentPollTimer;
  Timer? _waitingCountdownTimer;

  // State de sélection
  int? _selectedOption;
  bool _answered = false;
  bool _showingExplanation = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _questionDuration;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Synchronisation en temps réel du score adverse pour les salons multijoueurs
    if (widget.roomCode != null && widget.roomCode!.isNotEmpty) {
      _startOpponentScoreSync();
    }

    if (widget.initialQuestions != null &&
        widget.initialQuestions!.isNotEmpty) {
      _questions = widget.initialQuestions!;
      _isLoadingQuestions = false;
      _startTimer();
    } else {
      _loadQuestions();
    }
  }

  void _startOpponentScoreSync() {
    _opponentPollTimer?.cancel();
    _opponentPollTimer =
        Timer.periodic(const Duration(milliseconds: 900), (t) async {
      if (!mounted) return;
      final status = await duelServiceProvider.getRoomStatus(widget.roomCode!);
      if (status != null && mounted) {
        // Rôle fiable et garanti (indépendant du nom d'affichage de l'élève)
        final realOpponentScore = widget.isHost
            ? (status['guest_score'] as num?)?.toInt() ?? 0
            : (status['creator_score'] as num?)?.toInt() ?? 0;

        final isFinished = status['is_finished'] == true ||
            (widget.isHost
                ? status['guest_finished'] == true
                : status['creator_finished'] == true);

        final oppIndex = widget.isHost
            ? (status['guest_index'] as num?)?.toInt() ?? 0
            : (status['creator_index'] as num?)?.toInt() ?? 0;

        if (realOpponentScore != _opponentScore || oppIndex != _opponentQuestionIndex) {
          setState(() {
            _opponentScore = realOpponentScore;
            _opponentQuestionIndex = oppIndex;
          });
        }

        // Si on attendait la fin de l'adversaire et qu'il a terminé, afficher le verdict
        if (_isWaitingForOpponentToFinish && isFinished) {
          _waitingCountdownTimer?.cancel();
          _isWaitingForOpponentToFinish = false;
          _showFinalVerdict();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _opponentPollTimer?.cancel();
    _waitingCountdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoadingQuestions = true);
    final qs = await duelServiceProvider.fetchQuestions(
      subject: widget.subject,
      classLevel: widget.classLevel,
      count: widget.questionCount,
      period: widget.period,
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
      _userAnswers[_currentIndex] = -1;
      _simulateOpponent();
    });

    if (widget.roomCode != null && widget.roomCode!.isNotEmpty) {
      duelServiceProvider.updateScore(
        roomCode: widget.roomCode!,
        playerName: widget.playerName,
        score: _playerScore,
        questionIndex: _currentIndex,
        isHost: widget.isHost,
      );
    }

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
      _userAnswers[_currentIndex] = index;
      if (isCorrect) {
        _playerScore += 100 + (_secondsRemaining * 10);
      }
      _simulateOpponent();
    });

    if (widget.roomCode != null && widget.roomCode!.isNotEmpty) {
      duelServiceProvider.updateScore(
        roomCode: widget.roomCode!,
        playerName: widget.playerName,
        score: _playerScore,
        questionIndex: _currentIndex,
        isHost: widget.isHost,
      );
    }

    _showExplanationDialog();
  }

  void _simulateOpponent() {
    // Si nous sommes dans un salon multijoueur réel avec un camarade,
    // le vrai score adverse est mis à jour en direct via _opponentPollTimer !
    if (widget.roomCode != null && widget.roomCode!.isNotEmpty) {
      return;
    }

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

    // 1. Notifier immédiatement le serveur que nous avons terminé toutes nos questions
    if (widget.roomCode != null && widget.roomCode!.isNotEmpty) {
      duelServiceProvider.updateScore(
        roomCode: widget.roomCode!,
        playerName: widget.playerName,
        score: _playerScore,
        questionIndex: _questions.length,
        isHost: widget.isHost,
        isFinished: true,
      );
      _checkAndFinishMultiplayerDuel();
    } else {
      _showFinalVerdict();
    }
  }

  Future<void> _checkAndFinishMultiplayerDuel() async {
    final status = await duelServiceProvider.getRoomStatus(widget.roomCode!);
    if (!mounted) return;

    final opponentFinished = status != null &&
        (status['is_finished'] == true ||
            (widget.isHost
                ? status['guest_finished'] == true
                : status['creator_finished'] == true));

    if (opponentFinished) {
      final realOpponentScore = widget.isHost
          ? (status['guest_score'] as num?)?.toInt() ?? 0
          : (status['creator_score'] as num?)?.toInt() ?? 0;
      setState(() {
        _opponentScore = realOpponentScore;
      });
      _showFinalVerdict();
    } else {
      setState(() {
        _isWaitingForOpponentToFinish = true;
        _waitingCountdownSeconds = 15;
      });

      _waitingCountdownTimer?.cancel();
      _waitingCountdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted || !_isWaitingForOpponentToFinish) {
          t.cancel();
          return;
        }
        if (_waitingCountdownSeconds > 1) {
          setState(() {
            _waitingCountdownSeconds--;
          });
        } else {
          t.cancel();
          setState(() {
            _isWaitingForOpponentToFinish = false;
          });
          _showFinalVerdict();
        }
      });
    }
  }

  void _confirmExitDuel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Quitter le duel ?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tes réponses et ton score actuel ($_playerScore pts) sont déjà enregistrés en sécurité.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Rester'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              _waitingCountdownTimer?.cancel();
              _opponentPollTimer?.cancel();
              _timer?.cancel();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Quitter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReviewAnswersModal(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
        final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
        final textSec = isDark ? Colors.white70 : const Color(0xFF475569);
        final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (sCtx, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AltaColors.secondary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.menu_book_rounded, color: AltaColors.secondary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Corrigé & Explications du Défi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                      color: textPri,
                                    ),
                                  ),
                                  Text(
                                    '${widget.subject} • ${_questions.length} questions',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: textSec,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Questions List
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                      itemCount: _questions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (lCtx, index) {
                        final q = _questions[index];
                        final userAns = _userAnswers[index];
                        final isCorrect = userAns == q.correctOptionIndex;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AltaColors.surfaceAltDark : AltaColors.surfaceAltLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isCorrect
                                  ? AltaColors.secondary.withValues(alpha: 0.40)
                                  : Colors.redAccent.withValues(alpha: 0.40),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (isCorrect ? AltaColors.secondary : Colors.redAccent)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Question ${index + 1}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isCorrect ? AltaColors.secondary : Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                    size: 18,
                                    color: isCorrect ? AltaColors.secondary : Colors.redAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isCorrect ? 'Correct' : (userAns == -1 ? 'Temps écoulé' : 'Erreur'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: isCorrect ? AltaColors.secondary : Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                q.questionText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: textPri,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Options
                              ...List.generate(q.options.length, (optIdx) {
                                final optText = q.options[optIdx];
                                final isOptionCorrect = optIdx == q.correctOptionIndex;
                                final isUserChoice = optIdx == userAns;

                                Color optBg = isDark ? AltaColors.surfaceDark : Colors.white;
                                Color optBorder = borderCol;
                                Color optTextColor = textPri;
                                IconData? optIcon;
                                Color optIconColor = Colors.transparent;

                                if (isOptionCorrect) {
                                  optBg = AltaColors.secondary.withValues(alpha: 0.12);
                                  optBorder = AltaColors.secondary;
                                  optTextColor = isDark ? Colors.white : const Color(0xFF0F5132);
                                  optIcon = Icons.check_circle_rounded;
                                  optIconColor = AltaColors.secondary;
                                } else if (isUserChoice) {
                                  optBg = Colors.redAccent.withValues(alpha: 0.12);
                                  optBorder = Colors.redAccent;
                                  optTextColor = Colors.redAccent;
                                  optIcon = Icons.cancel_rounded;
                                  optIconColor = Colors.redAccent;
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: optBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: optBorder, width: isOptionCorrect || isUserChoice ? 1.5 : 1.0),
                                  ),
                                  child: Row(
                                    children: [
                                      if (optIcon != null) ...[
                                        Icon(optIcon, size: 16, color: optIconColor),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          optText,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: isOptionCorrect || isUserChoice ? FontWeight.bold : FontWeight.w500,
                                            color: optTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              if (q.explanation.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AltaColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AltaColors.primary.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.school_rounded, size: 16, color: AltaColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          q.explanation,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            color: textSec,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (q.tip.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AltaColors.accent.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AltaColors.accent.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.lightbulb_rounded, size: 16, color: AltaColors.accent),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          q.tip,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: textSec,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFinalVerdict() {
    _timer?.cancel();
    _opponentPollTimer?.cancel();
    _waitingCountdownTimer?.cancel();

    final isDraw = _playerScore == _opponentScore;
    final playerWon = _playerScore > _opponentScore;

    // Récompense conditionnée à la réussite réelle du défi (victoire ou égalité avec score > 0)
    final xpGained = (playerWon && _playerScore > 0)
        ? 120
        : (isDraw && _playerScore > 0 ? 50 : 0);
    final coinsGained = (playerWon && _playerScore > 0) ? 25 : 0;

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

    if (mounted) {
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
          onReviewAnswers: () => _showReviewAnswersModal(context),
          onReplay: () {
            Navigator.pop(ctx);
            setState(() {
              _playerScore = 0;
              _opponentScore = 0;
              _currentIndex = 0;
              _isWaitingForOpponentToFinish = false;
              _userAnswers.clear();
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

    // ── ÉCRAN D'ATTENTE SYNCHRONISÉ QUAND LE JOUEUR A TERMINÉ AVANT L'ADVERSAIRE ──
    if (_isWaitingForOpponentToFinish) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textPri),
            onPressed: _confirmExitDuel,
            tooltip: 'Quitter',
          ),
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AltaColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Défi #${widget.roomCode ?? "DUEL"}',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AltaColors.primary,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: borderCol),
                  boxShadow: [
                    BoxShadow(
                      color: AltaColors.primary.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AltaColors.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AltaColors.secondary,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Toutes tes questions terminées !',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ton score : $_playerScore pts',
                      style: GoogleFonts.spaceMono(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AltaColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AltaColors.surfaceAltDark : AltaColors.surfaceAltLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  color: AltaColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'En attente que ${widget.opponentName} finisse...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: textSec,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Progression adverse : Question ${(_opponentQuestionIndex + 1).clamp(1, _questions.length)} / ${_questions.length}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: textPri,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Clôture automatique dans ${_waitingCountdownSeconds}s',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AltaColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Action 1: Voir le résultat immédiatement
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AltaColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.military_tech_rounded,
                            color: Colors.white, size: 20),
                        label: Text(
                          'Voir mon résultat maintenant',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          _waitingCountdownTimer?.cancel();
                          setState(() {
                            _isWaitingForOpponentToFinish = false;
                          });
                          _showFinalVerdict();
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Action 2: Revoir les réponses & corrigé
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: isDark
                                ? AltaColors.borderDark
                                : AltaColors.borderLight,
                          ),
                        ),
                        icon: const Icon(Icons.menu_book_rounded,
                            color: AltaColors.secondary, size: 18),
                        label: Text(
                          'Revoir mes réponses & corrigé',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: textPri,
                          ),
                        ),
                        onPressed: () => _showReviewAnswersModal(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Action 3: Quitter
                    TextButton.icon(
                      icon: const Icon(Icons.exit_to_app_rounded,
                          size: 16, color: Colors.grey),
                      label: Text(
                        'Quitter le duel',
                        style: GoogleFonts.plusJakartaSans(
                          color: textSec,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _confirmExitDuel,
                    ),
                  ],
                ),
              ),
            ),
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
    required this.onReviewAnswers,
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
  final VoidCallback onReviewAnswers;
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

                  // ── REVOIR LES QUESTIONS & CORRIGÉS ──────────────────────
                  GestureDetector(
                    onTap: onReviewAnswers,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AltaColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AltaColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book_rounded,
                              size: 17, color: AltaColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Revoir les questions & corrigés',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AltaColors.primary,
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
