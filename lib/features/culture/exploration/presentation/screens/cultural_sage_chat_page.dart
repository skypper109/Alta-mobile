// ─── AlterniA — Le Vieux Sage de la Culture (Assistant IA Malien) ──────────────
// Expérience de discussion immersive calquée sur la page de discussion éducation.
// Supporte à la fois :
// - Contexte culturel précis (CulturalGuideContext : personnage, monument, ville, conte, etc.)
// - Contexte régional (MaliRegion)
// - Discussion libre générale sur le Mali
// Intègre :
// - Avatar animé du Vieux Sage / Griot avec ondes vocales et états (idle, listening, thinking, speaking)
// - Moteur IA : CultureAiService (direct LLM Mali, sans RAG)
// - Suggestions contextuelles dynamiques (MockCulturalGuideKnowledge)
// - Écoute vocale TTS personnalisée (voix posée et sage)
// - Actions par message (Écouter TTS, Copier, Supprimer)
library;

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/culture_ai_service.dart';
import '../../../core/datasources/mock_cultural_guide_knowledge.dart';
import '../../../core/models/cultural_guide_models.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/mali_region.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MODÈLES
// ══════════════════════════════════════════════════════════════════════════════

enum _SageState { idle, listening, thinking, speaking }

class _SageMessage {
  _SageMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  }) : id = DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
}

// ══════════════════════════════════════════════════════════════════════════════
// THÈMES CULTURELS GÉNÉRAUX
// ══════════════════════════════════════════════════════════════════════════════

class _CultureTopic {
  final String label;
  final IconData icon;
  final String promptHint;

  const _CultureTopic({
    required this.label,
    required this.icon,
    required this.promptHint,
  });
}

const _generalTopics = <_CultureTopic>[
  _CultureTopic(
    label: 'Tout le Mali',
    icon: Icons.public_rounded,
    promptHint: 'Posez n\'importe quelle question sur le Mali',
  ),
  _CultureTopic(
    label: 'Contes & Légendes',
    icon: Icons.auto_stories_rounded,
    promptHint: 'Raconte-moi un conte traditionnel malien',
  ),
  _CultureTopic(
    label: 'Histoire des Rois',
    icon: Icons.history_edu_rounded,
    promptHint: 'Parle-moi des grands empereurs et souverains du Mali',
  ),
  _CultureTopic(
    label: 'Devinettes (N\'Da)',
    icon: Icons.quiz_rounded,
    promptHint: 'Pose-moi une devinette traditionnelle malienne',
  ),
  _CultureTopic(
    label: '19 Régions',
    icon: Icons.map_rounded,
    promptHint: 'Présente-moi les richesses des 19 régions du Mali',
  ),
  _CultureTopic(
    label: 'Traditions & Rites',
    icon: Icons.celebration_rounded,
    promptHint: 'Explique-moi les traditions et valeurs ancestrales du Mandé',
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
// PAGE PRINCIPALE DU VIEUX SAGE
// ══════════════════════════════════════════════════════════════════════════════

class CulturalSageChatPage extends StatefulWidget {
  final MaliRegion? contextRegion;
  final CulturalGuideContext? guideContext;

  const CulturalSageChatPage({
    super.key,
    this.contextRegion,
    this.guideContext,
  });

  @override
  State<CulturalSageChatPage> createState() => _CulturalSageChatPageState();
}

class _CulturalSageChatPageState extends State<CulturalSageChatPage>
    with TickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  final _promptCtrl = TextEditingController();
  final _cultureAi = CultureAiService();
  final _tts = FlutterTts();

  late final AnimationController _sageAnim;
  late final AnimationController _pulseAnim;
  late final AnimationController _thinkingAnim;

  _SageState _sageState = _SageState.idle;
  int _selectedTopicIndex = 0;
  bool _isLoading = false;
  String? _currentlySpeakingMessageId;

  final List<_SageMessage> _messages = [];
  final List<Map<String, String>> _history = [];
  List<GuideSuggestion> _contextualSuggestions = [];

  @override
  void initState() {
    super.initState();

    _sageAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _thinkingAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    if (widget.guideContext != null) {
      _contextualSuggestions =
          MockCulturalGuideKnowledge.getSuggestionsForContext(widget.guideContext!);
    }

    _initTts();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final guide = widget.guideContext;
    final reg = widget.contextRegion;

    final String text;
    if (guide != null) {
      final regionInfo = guide.regionName.isNotEmpty && guide.regionName != 'Tout le Mali'
          ? ' de ${guide.regionName}'
          : '';
      text = 'I ni ce, noble voyageur ! Parlons de « ${guide.contentTitle} »$regionInfo.\n\n'
          'Je suis le Vieux Sage et Griot de la mémoire ancestrale du Mali. '
          'Interrogez-moi sur ses batailles, sa gouvernance, ses légendes ou son héritage. '
          'La sagesse des anciens est à votre écoute.';
    } else if (reg != null) {
      text = 'I ni sôgôma, noble voyageur ! Je suis le Vieux Sage de la mémoire ancestrale.\n\n'
          'Vous visitez la terre de ${reg.nom} (« ${reg.surnom} »). '
          'Interrogez-moi sur son histoire, ses légendes, ses coutumes ou ses secrets. '
          'La parole des anciens est un trésor inépuisable.';
    } else {
      text = 'I ni ce, voyageur de la connaissance ! Je suis le Griot et Sage du Mali.\n\n'
          'Je garde la mémoire des 3 Empires, les récits de Soundiata et de Mansa Moussa, '
          'les secrets des 19 régions et les contes du clair de lune. '
          'Quelle sagesse souhaitez-vous explorer aujourd\'hui ?';
    }

    setState(() {
      _messages.add(_SageMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(0.88);
      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _sageState = _SageState.idle;
            _currentlySpeakingMessageId = null;
          });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _promptCtrl.dispose();
    _sageAnim.dispose();
    _pulseAnim.dispose();
    _thinkingAnim.dispose();
    _stopTts();
    super.dispose();
  }

  Future<void> _stopTts() async {
    try {
      await _tts.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _currentlySpeakingMessageId = null;
        if (_sageState == _SageState.speaking) {
          _sageState = _SageState.idle;
        }
      });
    }
  }

  Future<void> _speakMessage(_SageMessage msg) async {
    if (_currentlySpeakingMessageId == msg.id) {
      await _stopTts();
      return;
    }

    HapticFeedback.lightImpact();
    await _stopTts();

    setState(() {
      _currentlySpeakingMessageId = msg.id;
      _sageState = _SageState.speaking;
    });

    try {
      await _tts.speak(msg.text);
    } catch (_) {
      if (mounted) {
        setState(() {
          _currentlySpeakingMessageId = null;
          _sageState = _SageState.idle;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;
    HapticFeedback.mediumImpact();
    await _stopTts();

    final userMsg = _SageMessage(
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isLoading = true;
      _sageState = _SageState.thinking;
      _messages.add(userMsg);
      _history.add({'role': 'user', 'text': query});
    });
    _promptCtrl.clear();
    _scrollToBottom();

    // Construction du contexte pour le LLM
    final contextParts = <String>[];
    if (widget.guideContext != null) {
      final g = widget.guideContext!;
      contextParts.add('Sujet étudié : ${g.contentTitle} (type: ${g.contentType.name}, région: ${g.regionName})');
      if (g.subtitle != null && g.subtitle!.isNotEmpty) {
        contextParts.add('Détail : ${g.subtitle}');
      }
    } else if (widget.contextRegion != null) {
      final r = widget.contextRegion!;
      contextParts.add('Région de focus : ${r.nom} — ${r.surnom} (${r.descriptionCourte})');
    }

    if (widget.guideContext == null && _selectedTopicIndex > 0) {
      contextParts.add('Thème : ${_generalTopics[_selectedTopicIndex].label}');
    }

    final contextStr = contextParts.isNotEmpty ? contextParts.join(' | ') : null;

    try {
      final reply = await _cultureAi.culturalChat(
        userMessage: query,
        history: List.from(_history),
        additionalContext: contextStr,
      );

      _history.add({'role': 'assistant', 'text': reply});

      if (mounted) {
        final botMsg = _SageMessage(
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        );

        setState(() {
          _isLoading = false;
          _sageState = _SageState.speaking;
          _messages.add(botMsg);
          _currentlySpeakingMessageId = botMsg.id;
        });
        _scrollToBottom();
        try {
          await _tts.speak(reply);
        } catch (_) {}
      }
    } catch (_) {
      if (mounted) {
        const fallback = 'Les esprits de la mémoire sont momentanément silencieux. Posez-moi à nouveau votre question dans un instant.';
        setState(() {
          _isLoading = false;
          _sageState = _SageState.idle;
          _messages.add(_SageMessage(
            text: fallback,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  }

  void _onGeneralTopicSelected(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedTopicIndex = index);
    if (index > 0) {
      _sendMessage(_generalTopics[index].promptHint);
    }
  }

  void _deleteMessage(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      _messages.removeWhere((m) => m.id == id);
    });
  }

  void _copyMessage(String text) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Parole copiée dans le presse-papier',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: CultureTheme.ocreTerre,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _startNewDiscussion() {
    HapticFeedback.mediumImpact();
    _stopTts();
    setState(() {
      _messages.clear();
      _history.clear();
      _addWelcomeMessage();
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080D14) : const Color(0xFFFAF7F2),
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                _buildSuggestionsOrTopicBar(isDark),
                _buildSageAvatarHero(isDark),
                const SizedBox(height: 4),
                _buildDivider(isDark),
                Expanded(child: _buildTranscript(isDark)),
                _buildInputBar(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── EN-TÊTE HARMONISÉ ─────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1B1208);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final String displayTitle;
    final String contextSubtitle;

    if (widget.guideContext != null) {
      final g = widget.guideContext!;
      displayTitle = g.contentTitle;
      contextSubtitle = 'Contexte : ${g.contentTitle} (${g.regionName})';
    } else if (widget.contextRegion != null) {
      displayTitle = widget.contextRegion!.nom;
      contextSubtitle = 'Contexte : Région de ${widget.contextRegion!.nom}';
    } else {
      displayTitle = 'Le Vieux Sage du Mali';
      contextSubtitle = 'Contexte : Patrimoine & Histoire du Mali';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          // Bouton Retour
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
                color: isDark ? CultureTheme.darkSurface : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderCol),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: isDark ? Colors.white : CultureTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Titre & Sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'GUIDE CULTUREL IA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'En ligne',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                Text(
                  contextSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Bouton Nouveau
          GestureDetector(
            onTap: _startNewDiscussion,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? CultureTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderCol),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 14,
                    color: CultureTheme.accentOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Nouveau',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SUGGESTIONS CONTEXTUELLES OU THÈMES GÉNÉRAUX ───────────────────────────

  Widget _buildSuggestionsOrTopicBar(bool isDark) {
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final surface = isDark ? CultureTheme.darkSurface : Colors.white;

    // Si on a un contexte spécifique (ex: Soundiata Keïta, Monument, etc.)
    if (_contextualSuggestions.isNotEmpty) {
      return SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _contextualSuggestions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final sug = _contextualSuggestions[i];
            return GestureDetector(
              onTap: () => _sendMessage(sug.questionText),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(sug.icon, size: 13, color: CultureTheme.accentOrange),
                    const SizedBox(width: 6),
                    Text(
                      sug.questionText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    // Sinon, barre de thèmes généraux
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _generalTopics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = _generalTopics[i];
          final isSelected = _selectedTopicIndex == i;

          return GestureDetector(
            onTap: () => _onGeneralTopicSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? CultureTheme.ocreTerre : surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? CultureTheme.ocreTerre : borderCol,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    t.icon,
                    size: 13,
                    color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── HERO AVATAR VIEUX SAGE ────────────────────────────────────────────────

  Widget _buildSageAvatarHero(bool isDark) {
    final String statusText;
    final Color statusColor;

    switch (_sageState) {
      case _SageState.speaking:
        statusText = 'Le Vieux Sage s\'exprime...';
        statusColor = CultureTheme.accentOrange;
        break;
      case _SageState.thinking:
        statusText = 'Le Griot consulte la mémoire des anciens...';
        statusColor = CultureTheme.primaryBlue;
        break;
      case _SageState.listening:
        statusText = 'Je vous écoute, noble voyageur...';
        statusColor = CultureTheme.fleuveNiger;
        break;
      case _SageState.idle:
        statusText = 'Touchez l\'Avatar pour écouter une parole de sagesse';
        statusColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        children: [
          _SageAvatarWidget(
            sageAnim: _sageAnim,
            pulseAnim: _pulseAnim,
            thinkingAnim: _thinkingAnim,
            state: _sageState,
            isDark: isDark,
            onTap: () {
              if (widget.guideContext != null) {
                _sendMessage('Raconte-moi un récit marquant sur ${widget.guideContext!.contentTitle}.');
              } else {
                _sendMessage('Raconte-moi un conte ou une légende du Mali.');
              }
            },
          ),
          const SizedBox(height: 6),
          Text(
            statusText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: CultureTheme.ocreTerre.withValues(alpha: 0.2))),
          const SizedBox(width: 8),
          Icon(Icons.auto_stories_rounded, size: 12, color: CultureTheme.ocreTerre.withValues(alpha: 0.5)),
          const SizedBox(width: 6),
          Text(
            'PAROLES DU GRIOT',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: CultureTheme.ocreTerre.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.auto_stories_rounded, size: 12, color: CultureTheme.ocreTerre.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: CultureTheme.ocreTerre.withValues(alpha: 0.2))),
        ],
      ),
    );
  }

  // ── LISTE DES MESSAGES ────────────────────────────────────────────────────

  Widget _buildTranscript(bool isDark) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (_isLoading && i == _messages.length) {
          return _buildThinkingBubble(isDark);
        }
        return _buildMessageBubble(_messages[i], isDark);
      },
    );
  }

  Widget _buildThinkingBubble(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1208) : const Color(0xFFFFF8EE),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CultureTheme.ocreTerre.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CultureTheme.accentOrange,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Le Vieux Sage consulte les récits...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: CultureTheme.ocreTerre,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_SageMessage msg, bool isDark) {
    final isUser = msg.isUser;
    final isSpeaking = _currentlySpeakingMessageId == msg.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser
                ? CultureTheme.primaryBlue.withValues(alpha: isDark ? 0.35 : 0.12)
                : (isDark ? const Color(0xFF161007) : Colors.white),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isUser ? 18 : 4),
              topRight: Radius.circular(isUser ? 4 : 18),
              bottomLeft: const Radius.circular(18),
              bottomRight: const Radius.circular(18),
            ),
            border: Border.all(
              color: isUser
                  ? CultureTheme.primaryBlue.withValues(alpha: 0.35)
                  : (isSpeaking
                      ? CultureTheme.accentOrange
                      : CultureTheme.ocreTerre.withValues(alpha: 0.25)),
              width: isSpeaking ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header du message
              Row(
                children: [
                  Icon(
                    isUser ? Icons.person_rounded : Icons.auto_stories_rounded,
                    size: 13,
                    color: isUser ? CultureTheme.primaryBlue : CultureTheme.accentOrange,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isUser ? 'Vous' : 'Le Vieux Sage',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isUser ? CultureTheme.primaryBlue : CultureTheme.accentOrange,
                    ),
                  ),
                  const Spacer(),
                  // Actions pour le message du sage
                  if (!isUser) ...[
                    // Bouton Écouter TTS
                    GestureDetector(
                      onTap: () => _speakMessage(msg),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: (isSpeaking ? CultureTheme.accentOrange : CultureTheme.ocreTerre)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                          size: 15,
                          color: isSpeaking ? CultureTheme.accentOrange : CultureTheme.ocreTerre,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  // Bouton Copier
                  GestureDetector(
                    onTap: () => _copyMessage(msg.text),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 13,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Bouton Supprimer
                  GestureDetector(
                    onTap: () => _deleteMessage(msg.id),
                    child: Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Contenu du message
              Text(
                msg.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  height: 1.55,
                  color: isDark ? const Color(0xFFE2D5C3) : const Color(0xFF2C1A08),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BARRE DE SAISIE CULTURELLE ────────────────────────────────────────────

  Widget _buildInputBar(bool isDark) {
    final surface = isDark ? const Color(0xFF100B05) : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final hintText = widget.guideContext != null
        ? 'Posez une question sur ${widget.guideContext!.contentTitle}...'
        : 'Posez une question au Vieux Sage...';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: borderCol)),
      ),
      child: Row(
        children: [
          // Raccourci Conte
          GestureDetector(
            onTap: () {
              if (widget.guideContext != null) {
                _sendMessage('Raconte une anecdote ou un fait marquant sur ${widget.guideContext!.contentTitle}.');
              } else {
                _sendMessage('Raconte-moi un conte du Mali.');
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: CultureTheme.accentOrange.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 18,
                color: CultureTheme.accentOrange,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Champ de saisie
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 46, maxHeight: 110),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1208) : const Color(0xFFFFF8EE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CultureTheme.ocreTerre.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _promptCtrl,
                maxLines: null,
                onSubmitted: _sendMessage,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFE2D5C3) : const Color(0xFF2C1A08),
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                cursorColor: CultureTheme.accentOrange,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Bouton Envoyer
          GestureDetector(
            onTap: _isLoading ? null : () => _sendMessage(_promptCtrl.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isLoading
                    ? CultureTheme.ocreTerre.withValues(alpha: 0.3)
                    : CultureTheme.accentOrange,
                shape: BoxShape.circle,
                boxShadow: _isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FOND CULTUREL MANDÉ ───────────────────────────────────────────────────

  Widget _buildBackground(bool isDark) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _SageBackgroundPainter(
          progress: _sageAnim,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AVATAR VIEUX SAGE (Painter & Animation)
// ══════════════════════════════════════════════════════════════════════════════

class _SageAvatarWidget extends StatelessWidget {
  final AnimationController sageAnim;
  final AnimationController pulseAnim;
  final AnimationController thinkingAnim;
  final _SageState state;
  final bool isDark;
  final VoidCallback onTap;

  const _SageAvatarWidget({
    required this.sageAnim,
    required this.pulseAnim,
    required this.thinkingAnim,
    required this.state,
    required this.isDark,
    required this.onTap,
  });

  Color get _glowColor => switch (state) {
    _SageState.idle     => CultureTheme.ocreTerre,
    _SageState.listening => CultureTheme.fleuveNiger,
    _SageState.speaking => CultureTheme.accentOrange,
    _SageState.thinking => CultureTheme.primaryBlue,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([sageAnim, pulseAnim]),
          builder: (context, _) {
            final scale = 1.0 + (pulseAnim.value * 0.04);
            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Halo lumineux extérieur
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _glowColor.withValues(alpha: 0.35 + pulseAnim.value * 0.15),
                            blurRadius: 26,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    // Sphère et anneaux animés
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _SagePainter(
                        progress: sageAnim.value,
                        pulse: pulseAnim.value,
                        state: state,
                        coreColor: _glowColor,
                      ),
                    ),
                    // Traits du visage (Yeux + Bouche / Ondes vocales)
                    _buildFacialFeatures(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFacialFeatures() {
    return AnimatedBuilder(
      animation: thinkingAnim,
      builder: (context, _) {
        final eyeColor = state == _SageState.listening
            ? CultureTheme.fleuveNiger
            : (state == _SageState.speaking ? CultureTheme.accentOrange : Colors.white);

        final eyeH = state == _SageState.thinking
            ? 4.0 + thinkingAnim.value * 4
            : 10.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 9,
                  height: eyeH,
                  decoration: BoxDecoration(
                    color: eyeColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(color: eyeColor.withValues(alpha: 0.8), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Container(
                  width: 9,
                  height: eyeH,
                  decoration: BoxDecoration(
                    color: eyeColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(color: eyeColor.withValues(alpha: 0.8), blurRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (state == _SageState.speaking)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final h = 3.0 + (math.sin((sageAnim.value * math.pi * 6) + i * 1.0).abs() * 10);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 4,
                    height: h,
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              )
            else
              Container(
                width: 20,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SagePainter extends CustomPainter {
  final double progress;
  final double pulse;
  final _SageState state;
  final Color coreColor;

  const _SagePainter({
    required this.progress,
    required this.pulse,
    required this.state,
    required this.coreColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;

    final baseGradient = RadialGradient(
      colors: [
        coreColor.withValues(alpha: 0.95),
        const Color(0xFF5A2E0E),
        const Color(0xFF140802),
      ],
      stops: const [0.0, 0.65, 1.0],
    );

    final paint = Paint()
      ..shader = baseGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..shader = LinearGradient(
        colors: [coreColor, Colors.transparent, CultureTheme.iaYellow],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final angle = progress * 2 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 1.8, height: radius * 0.75),
      ringPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-angle * 0.8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 1.55, height: radius * 0.85),
      ringPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SagePainter old) =>
      old.progress != progress || old.state != state || old.pulse != pulse;
}

class _SageBackgroundPainter extends CustomPainter {
  final Animation<double> progress;
  final bool isDark;

  _SageBackgroundPainter({required this.progress, required this.isDark})
      : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = CultureTheme.ocreTerre.withValues(alpha: isDark ? 0.04 : 0.03);

    const step = 45.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SageBackgroundPainter old) => false;
}
