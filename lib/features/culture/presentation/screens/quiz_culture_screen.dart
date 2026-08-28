import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/datasources/mock_culture_challenges_data.dart';
import '../../core/models/culture_challenge_models.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../widgets/passport_stamp_toast.dart';

/// Écran de Quiz Culturel dynamique à choix multiples
class QuizCultureScreen extends ConsumerStatefulWidget {
  const QuizCultureScreen({super.key});

  @override
  ConsumerState<QuizCultureScreen> createState() => _QuizCultureScreenState();
}

class _QuizCultureScreenState extends ConsumerState<QuizCultureScreen> {
  late List<CultureQuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  int _score = 0;
  int _totalXpEarned = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _questions = MockCultureChallengesData.quizQuestions;
  }

  CultureQuizQuestion get _currentQuestion => _questions[_currentIndex];

  void _onSelectOption(int index) {
    if (_isAnswered) return;
    HapticFeedback.mediumImpact();
    final isCorrect = index == _currentQuestion.correctIndex;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
        _totalXpEarned += _currentQuestion.xp;
      }
    });
  }

  void _nextQuestion() {
    HapticFeedback.lightImpact();
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      setState(() {
        _isCompleted = true;
      });

      final added = ref.read(culturePassportProvider.notifier).recordDiscovery(
            id: 'quiz_culture_general',
            type: PassportItemType.defi,
            title: 'Grand Quiz du Patrimoine Malien',
            subtitle: 'Score de réussite : $_score/${_questions.length}',
            regionId: null,
            regionName: 'Tout le Mali',
            photoUrl: 'assets/images/culture/villes/djenne_ville.jpg',
            tag: 'Quiz Culturel',
            culturalQuote: '« La connaissance du passé est la boussole de l\'avenir. »',
            targetRoute: '/culture/defis/quiz',
          );
      if (added && mounted) {
        PassportStampToast.show(
          context,
          title: 'Grand Quiz du Patrimoine Malien',
          type: PassportItemType.defi,
        );
      }
    }
  }

  void _restartQuiz() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentIndex = 0;
      _selectedAnswerIndex = null;
      _isAnswered = false;
      _score = 0;
      _totalXpEarned = 0;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    final bgColor = isDark ? CultureTheme.darkBackground : const Color(0xFFFAF7F2);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── BARRE SUPÉRIEURE ─────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 12),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(bottom: BorderSide(color: borderCol)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (context.canPop()) context.pop();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back_rounded, size: 20, color: titleColor),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QUIZ CULTURE MALI',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: CultureTheme.primaryBlue,
                                letterSpacing: 0.6,
                              ),
                            ),
                            Text(
                              _isCompleted
                                  ? 'Résultats & Bilan'
                                  : 'Question ${_currentIndex + 1} sur ${_questions.length}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Score : $_score/${_questions.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!_isCompleted) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _questions.length,
                        minHeight: 4,
                        backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(CultureTheme.primaryBlue),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── CORPS DU QUIZ ───────────────────────────────────────────────
            Expanded(
              child: _isCompleted
                  ? _buildCompletedView(isDark, cardBg, borderCol, titleColor, subtitleColor)
                  : _buildQuestionView(isDark, cardBg, borderCol, titleColor, subtitleColor),
            ),
          ],
        ),
      ),
    );
  }

  // ── VUE QUESTION EN COURS ──────────────────────────────────────────────────
  Widget _buildQuestionView(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    final question = _currentQuestion;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte de la Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderCol, width: 1.2),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        question.category.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      question.regionName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  question.question,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Options de réponse
          ...List.generate(question.options.length, (index) {
            final option = question.options[index];
            final isSelected = _selectedAnswerIndex == index;
            final isCorrect = index == question.correctIndex;

            Color optionBg = cardBg;
            Color optionBorder = borderCol;
            Color iconBg = isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9);
            Color iconColor = subtitleColor;
            IconData iconData = Icons.circle_outlined;

            if (_isAnswered) {
              if (isCorrect) {
                optionBg = Colors.green.withValues(alpha: 0.15);
                optionBorder = Colors.green;
                iconBg = Colors.green;
                iconColor = Colors.white;
                iconData = Icons.check_rounded;
              } else if (isSelected && !isCorrect) {
                optionBg = Colors.red.withValues(alpha: 0.15);
                optionBorder = Colors.red;
                iconBg = Colors.red;
                iconColor = Colors.white;
                iconData = Icons.close_rounded;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _onSelectOption(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: optionBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: optionBorder, width: isSelected ? 1.8 : 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(iconData, size: 16, color: iconColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: isSelected || (_isAnswered && isCorrect)
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Explication pédagogique
          if (_isAnswered) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedAnswerIndex == question.correctIndex
                      ? Colors.green.withValues(alpha: 0.4)
                      : CultureTheme.accentOrange.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedAnswerIndex == question.correctIndex
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        size: 16,
                        color: _selectedAnswerIndex == question.correctIndex
                            ? Colors.green
                            : CultureTheme.accentOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedAnswerIndex == question.correctIndex
                            ? 'Bonne réponse ! (+${question.xp} XP)'
                            : 'Explication culturelle',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: _selectedAnswerIndex == question.correctIndex
                              ? Colors.green
                              : CultureTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    question.explanation,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: subtitleColor,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CultureTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                label: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Question suivante'
                      : 'Voir mon score final',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── VUE BILAN DU QUIZ ──────────────────────────────────────────────────────
  Widget _buildCompletedView(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    final percentage = ((_score / _questions.length) * 100).toInt();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CultureTheme.primaryBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: CultureTheme.primaryBlue,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            percentage >= 70 ? 'Félicitations Initié !' : 'Bel apprentissage !',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vous avez obtenu $_score sur ${_questions.length} bonnes réponses ($percentage%)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 24),

          // Carte XP
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt_rounded, color: CultureTheme.accentOrange, size: 28),
                const SizedBox(width: 10),
                Text(
                  '+$_totalXpEarned XP de Sagesse Gagnés !',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: CultureTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Boutons Rejouer / Quitter
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: borderCol),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _restartQuiz,
                  child: Text(
                    'Rejouer le quiz',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: subtitleColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CultureTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (context.canPop()) context.pop();
                  },
                  child: Text(
                    'Retour aux Défis',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
