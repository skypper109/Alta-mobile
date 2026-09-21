import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Écran d'Expérience de Devinettes Traditionnelles (« N'Da ! »)
class RiddleScreen extends ConsumerStatefulWidget {
  final String? riddleId;

  const RiddleScreen({super.key, this.riddleId});

  @override
  ConsumerState<RiddleScreen> createState() => _RiddleScreenState();
}

class _RiddleScreenState extends ConsumerState<RiddleScreen> {
  late List<TraditionalRiddle> _riddles;
  int _currentIndex = 0;
  int _revealedHintsCount = 0;
  String? _selectedOption;
  bool _isAnswered = false;
  bool _isCorrect = false;

  // Gestion de session & Bilan
  bool _isCompleted = false;
  int _score = 0;
  int _totalXpEarned = 0;
  final Map<int, bool> _answeredResults = {};

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _riddles = MockCultureChallengesData.riddles;
    if (widget.riddleId != null) {
      final index = _riddles.indexWhere((r) => r.id == widget.riddleId);
      if (index != -1) _currentIndex = index;
    }
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('fr-FR');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(0.95);
      _flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  TraditionalRiddle get _currentRiddle => _riddles[_currentIndex];

  Future<void> _toggleTts() async {
    HapticFeedback.lightImpact();
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      final text =
          '${_currentRiddle.formulaIntro}. ${_currentRiddle.riddleText}';
      await _flutterTts.speak(text);
    }
  }

  void _revealNextHint() {
    HapticFeedback.selectionClick();
    if (_revealedHintsCount < _currentRiddle.hints.length) {
      setState(() {
        _revealedHintsCount++;
      });
    }
  }

  void _selectOption(String option) {
    if (_isAnswered) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedOption = option;
    });
  }

  void _validateAnswer() {
    if (_selectedOption == null || _isAnswered) return;
    HapticFeedback.mediumImpact();
    _flutterTts.stop();
    final correct = _selectedOption == _currentRiddle.correctAnswer;
    setState(() {
      _isAnswered = true;
      _isCorrect = correct;
      _isSpeaking = false;
      _answeredResults[_currentIndex] = correct;
      if (correct) {
        _score++;
        _totalXpEarned += _currentRiddle.xpReward;
      }
    });

    if (correct) {
      final added = ref.read(culturePassportProvider.notifier).recordDiscovery(
            id: _currentRiddle.id,
            type: PassportItemType.defi,
            title: 'Devinette : ${_currentRiddle.correctAnswer}',
            subtitle: _currentRiddle.category,
            regionId: _currentRiddle.regionId,
            regionName: _currentRiddle.regionName,
            photoUrl: _currentRiddle.photoUrl ?? 'assets/images/culture/villes/bandiagara_falaise.jpg',
            tag: 'Devinette',
            culturalQuote: _currentRiddle.proverb,
            targetRoute: '/culture/defis/devinettes?id=${_currentRiddle.id}',
            xpEarned: _currentRiddle.xpReward,
          );
      if (added && mounted) {
        PassportStampToast.show(
          context,
          title: 'Devinette : ${_currentRiddle.correctAnswer}',
          type: PassportItemType.defi,
        );
      }
    }
  }

  void _giveUpAndReveal() {
    HapticFeedback.mediumImpact();
    _flutterTts.stop();
    setState(() {
      _isAnswered = true;
      _isCorrect = false;
      _selectedOption = _currentRiddle.correctAnswer;
      _isSpeaking = false;
      _revealedHintsCount = _currentRiddle.hints.length;
      _answeredResults[_currentIndex] = false;
    });
  }

  void _nextRiddle() {
    HapticFeedback.mediumImpact();
    _flutterTts.stop();

    if (_currentIndex >= _riddles.length - 1) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isCompleted = true;
      });

      // Enregistrement final du sceau de la veillée dans le Passeport
      final added = ref.read(culturePassportProvider.notifier).recordDiscovery(
            id: 'riddles_session_complete',
            type: PassportItemType.defi,
            title: 'Veillée des Devinettes',
            subtitle: 'Sceau des Sagesses • Score : $_score/${_riddles.length}',
            regionName: 'Tout le Mali',
            photoUrl: 'assets/images/culture/villes/bandiagara_falaise.jpg',
            tag: 'Défi Devinettes',
            culturalQuote: '« La parole est une énigme que seul le cœur attentif peut délier. »',
            targetRoute: '/culture/defis/devinettes',
            xpEarned: _totalXpEarned > 0 ? _totalXpEarned : 50,
          );

      if (added && mounted) {
        PassportStampToast.show(
          context,
          title: 'Sceau des Devinettes',
          type: PassportItemType.defi,
        );
      }
      return;
    }

    setState(() {
      _currentIndex = _currentIndex + 1;
      _revealedHintsCount = 0;
      _selectedOption = null;
      _isAnswered = false;
      _isCorrect = false;
      _isSpeaking = false;
    });
  }

  void _restartSession() {
    HapticFeedback.mediumImpact();
    _flutterTts.stop();
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _totalXpEarned = 0;
      _answeredResults.clear();
      _isCompleted = false;
      _revealedHintsCount = 0;
      _selectedOption = null;
      _isAnswered = false;
      _isCorrect = false;
      _isSpeaking = false;
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riddle = _currentRiddle;
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
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
                          _isCompleted ? 'BILAN DE LA VEILLÉE' : 'DEVINETTE TRADITIONNELLE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          _isCompleted
                              ? 'Sceau & Sagesses'
                              : 'Énigme ${_currentIndex + 1} sur ${_riddles.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isCompleted) ...[
                    // Bouton Voix de l'Ancien (TTS) animé
                    GestureDetector(
                      onTap: _toggleTts,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: _isSpeaking
                              ? CultureTheme.accentOrange
                              : CultureTheme.accentOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isSpeaking
                                ? CultureTheme.cyanTurquoise
                                : CultureTheme.accentOrange.withValues(alpha: 0.25),
                            width: _isSpeaking ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                              size: 16,
                              color: _isSpeaking ? Colors.white : CultureTheme.accentOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isSpeaking ? 'Le Griot parle...' : 'Écouter',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _isSpeaking ? Colors.white : CultureTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Pastille score en mode complété
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: CultureTheme.primaryBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Score : $_score/${_riddles.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── CORPS DE LA DEVINETTE OU BILAN DE FIN ───────────────────────
            Expanded(
              child: _isCompleted
                  ? _buildCompletionView(context, isDark, cardBg, titleColor, subtitleColor, borderCol)
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    // Formule rituelle des anciens
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          riddle.formulaIntro,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Carte de l'Énigme
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: CultureTheme.cyanTurquoise.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  riddle.category.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: CultureTheme.cyanTurquoise,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${riddle.xpReward} XP',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: CultureTheme.accentOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            riddle.riddleText,
                            style: GoogleFonts.merriweather(
                              fontSize: 16,
                              height: 1.7,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── SECTION DES INDICES PROGRESSIFS ──────────────────────
                    _buildHintsSection(riddle, isDark, cardBg, borderCol, titleColor, subtitleColor),

                    const SizedBox(height: 20),

                    // ── SECTION DE RÉPONSE / OPTIONS ─────────────────────────
                    if (!_isAnswered) ...[
                      Text(
                        'QUELLE EST VOTRE RÉPONSE ?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ...List.generate(riddle.options.length, (index) {
                        final option = riddle.options[index];
                        final isSelected = _selectedOption == option;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AnimatedCulturalReveal(
                            key: ValueKey('option_${riddle.id}_$index'),
                            delay: Duration(milliseconds: index * 45),
                            offset: const Offset(0.0, 0.05),
                            child: _RiddleOptionTile(
                              option: option,
                              isSelected: isSelected,
                              cardBg: cardBg,
                              borderCol: borderCol,
                              titleColor: titleColor,
                              subtitleColor: subtitleColor,
                              onTap: () => _selectOption(option),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 14),

                      // Boutons Valider / Donner sa langue au chat
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
                              onPressed: _giveUpAndReveal,
                              child: Text(
                                'Révéler la solution',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
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
                                backgroundColor: CultureTheme.accentOrange,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _selectedOption != null
                                  ? _validateAnswer
                                  : null,
                              child: Text(
                                'Valider ma réponse',
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
                    ] else ...[
                      // ── RÉVÉLATION ENRICHIE & EXPLICATION CULTURELLE ─────────
                      _buildRevelationCard(riddle, isDark, cardBg, borderCol, titleColor, subtitleColor),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION INDICES ────────────────────────────────────────────────────────
  Widget _buildHintsSection(
    TraditionalRiddle riddle,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'INDICES DES ANCIENS ($_revealedHintsCount/${riddle.hints.length})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: CultureTheme.cyanTurquoise,
              ),
            ),
            const Spacer(),
            if (_revealedHintsCount < riddle.hints.length && !_isAnswered)
              GestureDetector(
                onTap: _revealNextHint,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CultureTheme.cyanTurquoise.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lightbulb_rounded,
                          size: 13, color: CultureTheme.cyanTurquoise),
                      const SizedBox(width: 4),
                      Text(
                        'Débloquer un indice',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CultureTheme.cyanTurquoise,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (_revealedHintsCount == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: subtitleColor),
                const SizedBox(width: 8),
                Text(
                  'Besoin d\'aide ? Touchez « Débloquer un indice »',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(_revealedHintsCount, (index) {
            return AnimatedCulturalReveal(
              key: ValueKey('hint_${riddle.id}_$index'),
              duration: const Duration(milliseconds: 350),
              offset: const Offset(0.0, 0.08),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFECFEFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CultureTheme.cyanTurquoise.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CultureTheme.cyanTurquoise.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        size: 13,
                        color: CultureTheme.cyanTurquoise,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        riddle.hints[index],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF0E7490),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ── CARTE DE RÉVÉLATION ENRICHIE ───────────────────────────────────────────
  Widget _buildRevelationCard(
    TraditionalRiddle riddle,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bannière Victoire / Révélation aux couleurs officielles AlterniA
        AnimatedCulturalReveal(
          duration: const Duration(milliseconds: 360),
          beginScale: 0.95,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? CultureTheme.cyanTurquoise.withValues(alpha: 0.15)
                  : CultureTheme.accentOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isCorrect ? CultureTheme.cyanTurquoise : CultureTheme.accentOrange,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isCorrect ? CultureTheme.cyanTurquoise : CultureTheme.accentOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isCorrect ? Icons.check_rounded : Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCorrect ? 'Excellente déduction !' : 'La sagesse révélée',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _isCorrect ? CultureTheme.cyanTurquoise : CultureTheme.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Réponse : ${riddle.correctAnswer}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
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

        // Explication culturelle & contexte
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 18,
                    color: CultureTheme.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TRANSMISSION CULTURELLE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: CultureTheme.primaryBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                riddle.culturalExplanation,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  height: 1.55,
                  color: subtitleColor,
                ),
              ),
              if (riddle.proverb != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CultureTheme.orPatrimoine.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    riddle.proverb!,
                    style: GoogleFonts.merriweather(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Bouton Devinette Suivante / Clôture
        Builder(
          builder: (context) {
            final isLast = _currentIndex >= _riddles.length - 1;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast ? CultureTheme.primaryBlue : CultureTheme.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _nextRiddle,
                icon: Icon(
                  isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  isLast ? 'Clôturer la veillée & Voir le Bilan' : 'Devinette suivante',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── ÉCRAN DE BILAN & SCEAU DES ÉNIGMES ─────────────────────────────────────
  Widget _buildCompletionView(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color titleColor,
    Color subtitleColor,
    Color borderCol,
  ) {
    final percentage =
        _riddles.isNotEmpty ? ((_score / _riddles.length) * 100).toInt() : 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
      child: Column(
        children: [
          // Sceau Royal Animé avec Impact & Onde de Choc
          const Center(
            child: CulturalRoyalStampAnimation(
              size: 80,
              icon: Icons.stars_rounded,
              label: "SCEAU GRAVÉ",
              color: CultureTheme.accentOrange,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Bilan & Sceau des Énigmes',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: percentage.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return Text(
                '$_score énigmes résolues sur ${_riddles.length} (${val.toInt()}% de perspicacité)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: subtitleColor,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 12),
          CulturalSpringProgressBar(
            progress: _riddles.isNotEmpty ? _score / _riddles.length : 0.0,
            fillColor: CultureTheme.accentOrange,
            trackColor: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFE2E8F0),
            height: 6.0,
          ),
          const SizedBox(height: 20),

          // Carte Récompenses & XP
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderCol, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: CultureTheme.accentOrange,
                    size: 24,
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

          const SizedBox(height: 24),

          // Récapitulatif des Énigmes
          Row(
            children: [
              Text(
                'SAGESSES RÉVÉLÉES',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: CultureTheme.primaryBlue,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '${_riddles.length} énigmes analysées',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...List.generate(_riddles.length, (idx) {
            final r = _riddles[idx];
            final wasCorrect = _answeredResults[idx] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: wasCorrect
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
                        wasCorrect
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        size: 16,
                        color: wasCorrect
                            ? CultureTheme.cyanTurquoise
                            : subtitleColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.riddleText.split('\n').first,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Réponse : ${r.correctAnswer}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CultureTheme.primaryBlue,
                    ),
                  ),
                  if (r.proverb != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      r.proverb!,
                      style: GoogleFonts.merriweather(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Boutons d'Action : Rejouer / Retour aux Défis
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
                  onPressed: _restartSession,
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
                    HapticFeedback.lightImpact();
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
                HapticFeedback.lightImpact();
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

/// ── TUILE D'OPTION DE RÉPONSE INTERACTIVE & ÉLASTIQUE ───────────────────────
class _RiddleOptionTile extends StatefulWidget {
  final String option;
  final bool isSelected;
  final Color cardBg;
  final Color borderCol;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _RiddleOptionTile({
    required this.option,
    required this.isSelected,
    required this.cardBg,
    required this.borderCol,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  State<_RiddleOptionTile> createState() => _RiddleOptionTileState();
}

class _RiddleOptionTileState extends State<_RiddleOptionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.975 : (widget.isSelected ? 1.012 : 1.0),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? CultureTheme.accentOrange.withValues(alpha: 0.12)
                : widget.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? CultureTheme.accentOrange
                  : widget.borderCol,
              width: widget.isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected
                        ? CultureTheme.accentOrange
                        : widget.subtitleColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  color: widget.isSelected
                      ? CultureTheme.accentOrange
                      : Colors.transparent,
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.option,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: widget.isSelected
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: widget.titleColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
