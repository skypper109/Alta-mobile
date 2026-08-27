import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/datasources/mock_culture_challenges_data.dart';
import '../../core/models/culture_challenge_models.dart';
import '../../core/theme/culture_theme.dart';

/// Écran d'Expérience de Devinettes Traditionnelles (« N'Da ! »)
class RiddleScreen extends StatefulWidget {
  final String? riddleId;

  const RiddleScreen({super.key, this.riddleId});

  @override
  State<RiddleScreen> createState() => _RiddleScreenState();
}

class _RiddleScreenState extends State<RiddleScreen> {
  late List<TraditionalRiddle> _riddles;
  int _currentIndex = 0;
  int _revealedHintsCount = 0;
  String? _selectedOption;
  bool _isAnswered = false;
  bool _isCorrect = false;

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
    });
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
    });
  }

  void _nextRiddle() {
    HapticFeedback.mediumImpact();
    _flutterTts.stop();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _riddles.length;
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
                          'DEVINETTE TRADITIONNELLE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          'Énigme ${_currentIndex + 1} sur ${_riddles.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bouton Voix de l'Ancien (TTS)
                  GestureDetector(
                    onTap: _toggleTts,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: _isSpeaking
                            ? CultureTheme.accentOrange
                            : CultureTheme.accentOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
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
                            _isSpeaking ? 'En écoute' : 'Écouter',
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
                ],
              ),
            ),

            // ── CORPS DE LA DEVINETTE ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
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

                      ...riddle.options.map((option) {
                        final isSelected = _selectedOption == option;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => _selectOption(option),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? CultureTheme.accentOrange.withValues(alpha: 0.15)
                                    : cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? CultureTheme.accentOrange
                                      : borderCol,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? CultureTheme.accentOrange
                                            : subtitleColor.withValues(alpha: 0.5),
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? CultureTheme.accentOrange
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check,
                                            size: 14, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: isSelected
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
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFECFEFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CultureTheme.cyanTurquoise.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                riddle.hints[index],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF0E7490),
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
        // Bannière Victoire / Révélation
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _isCorrect
                ? Colors.green.withValues(alpha: 0.15)
                : CultureTheme.accentOrange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isCorrect ? Colors.green : CultureTheme.accentOrange,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isCorrect ? Colors.green : CultureTheme.accentOrange,
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
                        color: _isCorrect ? Colors.green : CultureTheme.accentOrange,
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

        // Bouton Devinette Suivante
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: CultureTheme.accentOrange,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _nextRiddle,
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            label: Text(
              'Devinette suivante',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
