import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import 'national_challenge_service.dart';

class NationalChallengeScreen extends ConsumerStatefulWidget {
  const NationalChallengeScreen({super.key});

  @override
  ConsumerState<NationalChallengeScreen> createState() =>
      _NationalChallengeScreenState();
}

class _NationalChallengeScreenState
    extends ConsumerState<NationalChallengeScreen> {
  bool _isPlaying = false;
  int _currentQuestionIndex = 0;
  final Map<String, int> _reponses = {};
  int _secondsElapsed = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _startChallenge() {
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() {
      _isPlaying = true;
      _currentQuestionIndex = 0;
      _reponses.clear();
      _secondsElapsed = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  Future<void> _submitAnswers(NationalChallengeItem defi) async {
    _timer?.cancel();
    _timer = null;
    HapticFeedback.heavyImpact();

    await ref.read(nationalChallengeProvider.notifier).soumettre(
          defiId: defi.id,
          reponses: _reponses,
          tempsSec: _secondsElapsed,
        );

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nationalChallengeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final cardBg = isDark ? AppColors.surface : Colors.white;
    final borderCol = isDark ? AppColors.border : const Color(0xFFE2E8F0);

    final defi = state.defiCourant;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Défi National Scolaire',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textPri,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            tooltip: 'Classement',
            onPressed: () => context.push('/education/duel/leaderboard'),
          ),
        ],
      ),
      body: defi == null
          ? Center(
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : Text('Aucun défi national actif.',
                      style: GoogleFonts.plusJakartaSans(color: textSec)),
            )
          : _isPlaying
              ? _buildQuizView(defi, textPri, textSec, cardBg, borderCol, isDark)
              : state.dernierResultat != null
                  ? _buildResultView(
                      state.dernierResultat!, textPri, textSec, cardBg, borderCol)
                  : _buildLobbyView(
                      defi, textPri, textSec, cardBg, borderCol, isDark),
    );
  }

  Widget _buildLobbyView(
    NationalChallengeItem defi,
    Color textPri,
    Color textSec,
    Color cardBg,
    Color borderCol,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Hero Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF314999), Color(0xFF1E2D64)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.military_tech_rounded,
                        color: Color(0xFFF1851F), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SESSION OFFICIELLE DU MALI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                defi.titre,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                defi.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoPill(
                      label: '${defi.questions.length} Questions',
                      icon: Icons.quiz_rounded),
                  const SizedBox(width: 8),
                  _InfoPill(
                      label: '${defi.dureeMinutes} Minutes max',
                      icon: Icons.timer_rounded),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Récompenses en Pièces
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BARÈME DE PIÈCES & RÉCOMPENSES',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: textSec,
                ),
              ),
              const SizedBox(height: 12),
              _RewardRow(
                rank: '1er National',
                coins: '+${defi.recompensePremier} Pièces',
                color: const Color(0xFFF1851F),
                icon: Icons.emoji_events_rounded,
              ),
              const SizedBox(height: 8),
              _RewardRow(
                rank: 'Top 10 National',
                coins: '+${defi.recompenseTop10} Pièces',
                color: AppColors.primary,
                icon: Icons.stars_rounded,
              ),
              const SizedBox(height: 8),
              _RewardRow(
                rank: 'Participation validée',
                coins: '+${defi.recompenseParticipation} Pièces',
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startChallenge,
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: Text(
              'Commencer l\'Épreuve Chronométrée',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizView(
    NationalChallengeItem defi,
    Color textPri,
    Color textSec,
    Color cardBg,
    Color borderCol,
    bool isDark,
  ) {
    final q = defi.questions[_currentQuestionIndex];
    final total = defi.questions.length;
    final selectedOption = _reponses[q.id];

    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} / $total',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded,
                        size: 15, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      '$minutes:$seconds',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / total,
              minHeight: 6,
              backgroundColor:
                  isDark ? AppColors.surfaceAlt : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),

          // Intitulé de la question
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderCol),
            ),
            child: Text(
              q.question,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: textPri,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Options de réponse
          Expanded(
            child: ListView.separated(
              itemCount: q.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final opt = q.options[idx];
                final isSelected = selectedOption == idx;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _reponses[q.id] = idx;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : borderCol,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + idx),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isSelected ? Colors.white : textPri,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            opt,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: textPri,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Boutons Suivant / Terminer
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _currentQuestionIndex--);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Précédent'),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedOption == null
                      ? null
                      : () {
                          if (_currentQuestionIndex < total - 1) {
                            setState(() => _currentQuestionIndex++);
                          } else {
                            _submitAnswers(defi);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentQuestionIndex < total - 1
                        ? 'Suivant'
                        : 'Terminer l\'Épreuve',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(
    ChallengeResultItem res,
    Color textPri,
    Color textSec,
    Color cardBg,
    Color borderCol,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  size: 50, color: Color(0xFFF1851F)),
              const SizedBox(height: 10),
              Text(
                'Épreuve Terminée !',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Score officiel validé par le serveur AlterniA',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSec),
              ),
              const SizedBox(height: 18),
              Text(
                '${res.score} / ${res.totalQuestions}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '(${res.pourcentage}% de réussite)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: res.pourcentage >= 50
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1851F).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded,
                        color: Color(0xFFF1851F), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+${res.piecesGagnees} Pièces créditées',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: const Color(0xFFF1851F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => context.push('/education/duel/leaderboard'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Voir le Classement National des Lycées'),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final String rank;
  final String coins;
  final Color color;
  final IconData icon;

  const _RewardRow({
    required this.rank,
    required this.coins,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              rank,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          coins,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
