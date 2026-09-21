import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/datasources/mock_culture_challenges_data.dart';
import '../../core/models/culture_challenge_models.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';
import '../widgets/passport_stamp_toast.dart';

/// Écran d'Expérience de Défi & Quiz Culturel Haute Fidélité
/// Architecture 100% conforme à la charte : Orange Culture (#F1851F), Bleu Marine (#314999), Cyan (#40BBCC)
/// Strictement SANS dégradés, avec narration audio du Griot (TTS), haptique physique et sceau Passeport.
class QuizCultureScreen extends ConsumerStatefulWidget {
  final String? quizId;

  const QuizCultureScreen({super.key, this.quizId});

  @override
  ConsumerState<QuizCultureScreen> createState() => _QuizCultureScreenState();
}

class _QuizCultureScreenState extends ConsumerState<QuizCultureScreen> {
  late CultureQuizPack _pack;
  late List<CultureQuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  int _score = 0;
  int _totalXpEarned = 0;
  bool _isCompleted = false;

  // Historique des réponses pour le bilan d'apprentissage
  final List<int?> _userAnswers = [];

  // Narration vocale du Griot (TTS)
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _loadQuizPack();
    _initTts();
  }

  void _loadQuizPack() {
    _pack = MockCultureChallengesData.getQuizPackById(widget.quizId);
    _questions = _pack.questions;
    _currentIndex = 0;
    _selectedAnswerIndex = null;
    _isAnswered = false;
    _score = 0;
    _totalXpEarned = 0;
    _isCompleted = false;
    _userAnswers.clear();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('fr-FR');
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(0.96);
      _flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  CultureQuizQuestion get _currentQuestion => _questions[_currentIndex];

  Future<void> _toggleTts() async {
    CulturalHaptics.audioToggle();
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      final q = _currentQuestion;
      final optionsBuffer = StringBuffer();
      for (int i = 0; i < q.options.length; i++) {
        optionsBuffer.write('Option ${String.fromCharCode(65 + i)} : ${q.options[i]}. ');
      }
      final speech = '${q.category}. ${q.question}. $optionsBuffer';
      await _flutterTts.speak(speech);
    }
  }

  void _onSelectOption(int index) {
    if (_isAnswered) return;
    _flutterTts.stop();
    setState(() => _isSpeaking = false);

    CulturalHaptics.cardPress();
    final isCorrect = index == _currentQuestion.correctIndex;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      _userAnswers.add(index);
      if (isCorrect) {
        _score++;
        _totalXpEarned += _currentQuestion.xp;
        CulturalHaptics.stamp();
      } else {
        CulturalHaptics.cardRelease();
      }
    });
  }

  void _nextQuestion() {
    CulturalHaptics.tabSwitch();
    _flutterTts.stop();
    setState(() => _isSpeaking = false);

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      // Fin du Quiz & Bilan
      setState(() {
        _isCompleted = true;
      });
      CulturalHaptics.celebration();

      final calculatedXp = (_questions.isNotEmpty
              ? ((_pack.xpReward * _score) ~/ _questions.length)
              : _pack.xpReward)
          .clamp(40, 500);

      // Enregistrement officiel dans le Passeport Culturel (Trésors Gravés)
      final added = ref.read(culturePassportProvider.notifier).recordDiscovery(
            id: _pack.id,
            type: PassportItemType.defi,
            title: _pack.title,
            subtitle: '${_pack.stampBadgeTitle} • Score: $_score/${_questions.length}',
            regionId: _pack.regionId,
            regionName: _pack.regionName,
            photoUrl: _pack.photoUrl,
            tag: 'Défi du Savoir',
            culturalQuote:
                '« L\'ignorant marche dans l\'obscurité, mais celui qui apprend allume une lampe pour son peuple. »',
            targetRoute: '/culture/quiz/${_pack.id}',
            xpEarned: calculatedXp,
          );

      if (added && mounted) {
        PassportStampToast.show(
          context,
          title: _pack.stampBadgeTitle,
          type: PassportItemType.defi,
        );
      }
    }
  }

  void _restartQuiz() {
    CulturalHaptics.tabSwitch();
    _flutterTts.stop();
    setState(() {
      _loadQuizPack();
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
            // ── 1. BARRE D'EN-TÊTE ÉLÉGANTE & MINIMALISTE ─────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 12),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(bottom: BorderSide(color: borderCol, width: 1.0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Bouton Retour
                      GestureDetector(
                        onTap: () {
                          CulturalHaptics.cardRelease();
                          _flutterTts.stop();
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/culture');
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? CultureTheme.darkSurfaceAlt
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderCol),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 19,
                            color: titleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Titre & Progression
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _pack.themeColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _pack.category.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: _pack.themeColor,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _pack.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _isCompleted
                                  ? 'Bilan & Sceau du Savoir'
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

                      // Bouton Audio Griot (TTS)
                      if (!_isCompleted) ...[
                        GestureDetector(
                          onTap: _toggleTts,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 7),
                            decoration: BoxDecoration(
                              color: _isSpeaking
                                  ? CultureTheme.accentOrange
                                  : CultureTheme.accentOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: CultureTheme.accentOrange,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isSpeaking
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  size: 15,
                                  color: _isSpeaking
                                      ? Colors.white
                                      : CultureTheme.accentOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isSpeaking ? 'Arrêter' : 'Voix',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: _isSpeaking
                                        ? Colors.white
                                        : CultureTheme.accentOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Badge Score Live
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: CultureTheme.primaryBlue.withValues(alpha: 0.3),
                            width: 1.0,
                          ),
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

                  // Barre de progression fluide
                  if (!_isCompleted) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _questions.length,
                        minHeight: 4.5,
                        backgroundColor:
                            isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(_pack.themeColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── 2. CORPS PRINCIPAL DU DÉFI ────────────────────────────────────
            Expanded(
              child: _isCompleted
                  ? _buildCompletedView(
                      isDark, cardBg, borderCol, titleColor, subtitleColor)
                  : _buildQuestionView(
                      isDark, cardBg, borderCol, titleColor, subtitleColor),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. VUE DE LA QUESTION EN COURS ──────────────────────────────────────────
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte de la Question avec Motifs Soudanais
          AnimatedCulturalReveal(
            key: ValueKey('q_card_$_currentIndex'),
            delay: const Duration(milliseconds: 40),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? borderCol : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: _pack.themeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _pack.themeColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_pack.icon, size: 12, color: _pack.themeColor),
                            const SizedBox(width: 5),
                            Text(
                              question.category.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: _pack.themeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (question.regionName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? CultureTheme.darkSurfaceAlt
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            question.regionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.question,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.bolt_rounded,
                          size: 15, color: CultureTheme.accentOrange),
                      const SizedBox(width: 4),
                      Text(
                        '+${question.xp} XP de sagesse',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Options de Réponse Interactives (A, B, C, D)
          ...List.generate(question.options.length, (index) {
            final option = question.options[index];
            final isSelected = _selectedAnswerIndex == index;
            final isCorrect = index == question.correctIndex;
            final charLabel = String.fromCharCode(65 + index); // A, B, C, D

            Color optionBg = cardBg;
            Color optionBorder = borderCol;
            Color badgeBg = isDark
                ? CultureTheme.darkSurfaceAlt
                : const Color(0xFFF1F5F9);
            Color badgeTextColor = subtitleColor;
            Widget badgeWidget = Text(
              charLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: badgeTextColor,
              ),
            );

            if (_isAnswered) {
              if (isCorrect) {
                // Validation réussie : Cyan Turquoise officiel de la charte (#40BBCC)
                optionBg = CultureTheme.cyanTurquoise.withValues(alpha: 0.14);
                optionBorder = CultureTheme.cyanTurquoise;
                badgeBg = CultureTheme.cyanTurquoise;
                badgeTextColor = Colors.white;
                badgeWidget =
                    const Icon(Icons.check_rounded, size: 16, color: Colors.white);
              } else if (isSelected && !isCorrect) {
                // Mauvaise réponse : Gris foncé/Ardoise sobre sans rouge hors-charte
                optionBg = isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0);
                optionBorder = isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8);
                badgeBg = isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8);
                badgeTextColor = Colors.white;
                badgeWidget =
                    const Icon(Icons.close_rounded, size: 16, color: Colors.white);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: CulturalInteractiveCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                showSudaneseCorners: false,
                borderColor: optionBorder,
                activeAccentColor: _isAnswered ? optionBorder : _pack.themeColor,
                backgroundColor: optionBg,
                borderRadius: 16,
                onTap: () => _onSelectOption(index),
                child: Row(
                  children: [
                    // Puce Lettre ou Icône
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: badgeWidget),
                    ),
                    const SizedBox(width: 14),

                    // Texte de l'option
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
            );
          }),

          // ── Explication Pédagogique Immédiate ──────────────────────────────
          if (_isAnswered) ...[
            const SizedBox(height: 16),
            AnimatedCulturalReveal(
              key: ValueKey('explanation_$_currentIndex'),
              delay: const Duration(milliseconds: 60),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? CultureTheme.darkSurfaceAlt
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _selectedAnswerIndex == question.correctIndex
                        ? CultureTheme.cyanTurquoise.withValues(alpha: 0.5)
                        : CultureTheme.accentOrange.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedAnswerIndex == question.correctIndex
                              ? Icons.verified_rounded
                              : Icons.lightbulb_rounded,
                          size: 18,
                          color: _selectedAnswerIndex == question.correctIndex
                              ? CultureTheme.cyanTurquoise
                              : CultureTheme.accentOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedAnswerIndex == question.correctIndex
                              ? 'Excellente réponse ! (+${question.xp} XP)'
                              : 'Savoir transmis par les anciens',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: _selectedAnswerIndex == question.correctIndex
                                ? CultureTheme.cyanTurquoise
                                : CultureTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: subtitleColor,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bouton de Navigation Suivante
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CultureTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 19),
                label: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Question suivante'
                      : 'Découvrir mon Sceau & Score',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
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

  // ── 4. VUE BILAN, SCEAU DU SAVOIR & RÉCOMPENSES ─────────────────────────────
  Widget _buildCompletedView(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    final percentage = ((_score / _questions.length) * 100).toInt();
    final isMastery = percentage >= 70;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        children: [
          // ── Sceau Royal Animé avec Impact Physique & Onde de Choc ─────────
          Center(
            child: CulturalRoyalStampAnimation(
              size: 88,
              icon: Icons.auto_awesome_rounded,
              label: _pack.stampBadgeTitle,
              color: _pack.themeColor,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            isMastery ? 'Sceau du Savoir Obtenu !' : 'Bel Apprentissage !',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '$_score bonnes réponses sur ${_questions.length} ($percentage% de maîtrise)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 22),

          // Carte Récompenses & XP
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderCol, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: CultureTheme.accentOrange,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CulturalRollingXpCounter(
                        targetXp: _totalXpEarned,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.accentOrange,
                        ),
                        suffix: 'XP de Sagesse Gagnés',
                        suffixStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gravé dans le Passeport Culturel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: CultureTheme.cyanTurquoise,
                  size: 22,
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // Récapitulatif Pédagogique (Revue des questions)
          Row(
            children: [
              Text(
                'LEÇONS DE LA VEILLÉE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: CultureTheme.primaryBlue,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '${_questions.length} questions analysées',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...List.generate(_questions.length, (idx) {
            final q = _questions[idx];
            final userAns = idx < _userAnswers.length ? _userAnswers[idx] : null;
            final isCorrect = userAns == q.correctIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCorrect
                      ? CultureTheme.cyanTurquoise.withValues(alpha: 0.4)
                      : borderCol,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        size: 16,
                        color: isCorrect
                            ? CultureTheme.cyanTurquoise
                            : subtitleColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          q.question,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Réponse exacte : ${q.options[q.correctIndex]}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: CultureTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Boutons d'Action : Rejouer / Retour aux Défis / Consulter Passeport
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: borderCol),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _restartQuiz,
                  icon: Icon(Icons.replay_rounded, size: 17, color: titleColor),
                  label: Text(
                    'Rejouer',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CultureTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    CulturalHaptics.cardRelease();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/culture');
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded,
                      size: 17, color: Colors.white),
                  label: Text(
                    'Défis',
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
          const SizedBox(height: 12),

          // Bouton direct pour voir le Passeport
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                CulturalHaptics.cardPress();
                context.push('/culture/passport');
              },
              icon: const Icon(Icons.auto_awesome_rounded,
                  color: CultureTheme.accentOrange, size: 16),
              label: Text(
                'Voir mon Passeport & mes Trésors Gravés',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: CultureTheme.accentOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
