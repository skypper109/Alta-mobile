// ─── AlterniA — Veillée au Coin du Feu & La Doyenne Vivienne ─────────────────
// Interface immersive complète de veillée sous le baobab sacré.
// - En-tête : VillageCampfireWidget (Ciel étoilé, feu de camp 3D, Doyenne Vivienne conteuse)
// - Généalogie & Origine des Noms : Dictionnaire des patronymes (Jamu) et prénoms du Mali
// - Contes du clair de lune et devises des anciens
// - Couleurs harmonisées à 100% avec la charte officielle AlterniA (AppColors & CultureTheme)
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/culture_ai_service.dart';
import '../../../../../core/services/vivienne_tts_service.dart';
import '../../../core/datasources/malian_names_knowledge.dart';
import '../../../core/datasources/mock_cultural_guide_knowledge.dart';
import '../../../core/models/cultural_guide_models.dart';
import '../../../core/theme/culture_theme.dart';
import '../../../presentation/widgets/malian_name_share_sheet.dart';
import '../../data/models/mali_region.dart';
import '../widgets/village_campfire_widget.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MODÈLES
// ══════════════════════════════════════════════════════════════════════════════

enum _SageState { idle, thinking, speaking }

class _SageMessage {
  _SageMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.scenicAction,
    this.visionImagePath,
    this.visionCaption,
    this.nameHeritage,
  }) : id = DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? scenicAction;
  final String? visionImagePath;
  final String? visionCaption;
  final MalianNameInfo? nameHeritage;
}

// ══════════════════════════════════════════════════════════════════════════════
// PAGE PRINCIPALE : CulturalSageChatPage
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

  _SageState _sageState = _SageState.idle;
  bool _isLoading = false;
  bool _isVillageSoundActive = true;
  String? _currentlySpeakingMessageId;

  // ── Reconnaissance Vocale (Speech-To-Text) ──
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _liveSpokenWords = '';

  final List<_SageMessage> _messages = [];
  final List<Map<String, String>> _history = [];
  List<GuideSuggestion> _contextualSuggestions = [];

  static const List<String> _scenicActionsPool = [
    "Grand-mère Mah attise le feu de bois d'un geste tranquille et rajuste son moussor",
    "Grand-mère Mah jette une poignée de brindilles parfumées sur les braises rougeoyantes",
    "Grand-mère Mah esquisse un sourire bienveillant et incline doucement la tête vers les flammes",
    "Grand-mère Mah fait tinter discrètement ses perles d'ambre et pose sa main sur la calebasse",
    "Grand-mère Mah lève les yeux vers le ciel étoilé du Mandé avant de répondre avec douceur",
  ];

  @override
  void initState() {
    super.initState();

    if (widget.guideContext != null) {
      _contextualSuggestions =
          MockCulturalGuideKnowledge.getSuggestionsForContext(
              widget.guideContext!);
    }

    _initTts();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final guide = widget.guideContext;
    final reg = widget.contextRegion;

    final String text;
    if (guide != null) {
      final regionInfo =
          guide.regionName.isNotEmpty && guide.regionName != 'Tout le Mali'
              ? ' de ${guide.regionName}'
              : '';
      text =
          'I ni sou, noble voyageur ! Viens t\'asseoir près du feu pour parler de « ${guide.contentTitle} »$regionInfo.\n\n'
          'Je suis Grand-mère Mah, gardienne de la mémoire vivante. '
          'Interroge-moi sur son histoire ou donne-moi ton nom de famille pour découvrir ses secrets et sa devise !';
    } else if (reg != null) {
      text =
          'I ni sou, mon enfant ! Approche, assieds-toi près du feu. '
          'Tu visites la noble terre de ${reg.nom} (« ${reg.surnom} »).\n\n'
          'Donne-moi ton nom de famille ou ton prénom, et Grand-mère Mah te révélera son origine ancestrale, son clan et ses animaux totems !';
    } else {
      text =
          'I ni sou, mon enfant ! Approche, assieds-toi près du feu sous le grand baobab.\n\n'
          'Je suis Grand-mère Mah, mémoire vivante et conteuse du Mandé.\n\n'
          'Dis-moi quel est **ton nom de famille** (ex : *Keïta, Traoré, Coulibaly, Diakité, Diallo, Touré, Cissé, Diarra...*) ou **ton prénom** : je te révélerai d\'où il vient, ce qu\'il signifie, ton animal totem (*Tanan*) et ton cousinage à plaisanterie (*Senankouya*) !\n\n'
          'Tu peux aussi me demander un conte ou une légende de nos ancêtres.';
    }

    setState(() {
      _messages.add(_SageMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        scenicAction:
            "Grand-mère Mah attise le feu de bois d'un geste tranquille et rajuste son moussor",
      ));
    });
  }

  Future<void> _initTts() async {
    try {
      await VivienneTtsService.applyVivienneProfile(_tts);
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
  void deactivate() {
    _stopTts(updateState: false);
    VivienneTtsService.instance.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _promptCtrl.dispose();
    _stopTts(updateState: false);
    if (_isListening) {
      _speechToText.stop();
    }
    VivienneTtsService.instance.stop();
    super.dispose();
  }

  // ── Speech-To-Text : Touchez pour parler, touchez pour couper et envoyer ──
  Future<void> _toggleVocalRecording() async {
    HapticFeedback.heavyImpact();

    if (_isListening) {
      await _speechToText.stop();
      final spoken = _liveSpokenWords.trim().isNotEmpty
          ? _liveSpokenWords.trim()
          : _promptCtrl.text.trim();
      setState(() {
        _isListening = false;
        _liveSpokenWords = '';
      });
      if (spoken.isNotEmpty) {
        _promptCtrl.clear();
        _sendMessage(spoken);
      }
    } else {
      await _stopTts();
      bool available = false;
      try {
        available = await _speechToText.initialize(
          onError: (err) {
            if (mounted) setState(() => _isListening = false);
          },
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              if (mounted && _isListening) {
                final spoken = _liveSpokenWords.trim().isNotEmpty
                    ? _liveSpokenWords.trim()
                    : _promptCtrl.text.trim();
                setState(() {
                  _isListening = false;
                  _liveSpokenWords = '';
                });
                if (spoken.isNotEmpty) {
                  _promptCtrl.clear();
                  _sendMessage(spoken);
                }
              }
            }
          },
        );
      } catch (_) {}

      if (!mounted) return;

      if (available) {
        setState(() {
          _isListening = true;
          _liveSpokenWords = '';
        });
        _speechToText.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _liveSpokenWords = result.recognizedWords;
                _promptCtrl.text = result.recognizedWords;
              });
              if (result.finalResult &&
                  result.recognizedWords.trim().isNotEmpty) {
                _speechToText.stop();
                setState(() {
                  _isListening = false;
                  _liveSpokenWords = '';
                });
                _promptCtrl.clear();
                _sendMessage(result.recognizedWords.trim());
              }
            }
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Microphone non disponible ou permission requise. Vous pouvez taper directement votre message.',
              style: GoogleFonts.plusJakartaSans(color: AppColors.accentLight),
            ),
            backgroundColor: AppColors.surfaceAlt,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _stopTts({bool updateState = true}) async {
    try {
      await VivienneTtsService.instance.stop();
      await _tts.stop();
    } catch (_) {}
    _currentlySpeakingMessageId = null;
    if (_sageState == _SageState.speaking) {
      _sageState = _SageState.idle;
    }
    if (updateState && mounted) {
      setState(() {});
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
      await VivienneTtsService.instance.speak(
        msg.text,
        onComplete: () {
          if (mounted) {
            setState(() {
              _currentlySpeakingMessageId = null;
              _sageState = _SageState.idle;
            });
          }
        },
      );
    } catch (_) {
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
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
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

    final contextStr = widget.guideContext != null
        ? 'Guide: ${widget.guideContext!.contentTitle} (${widget.guideContext!.regionName})'
        : widget.contextRegion != null
            ? 'Région: ${widget.contextRegion!.nom}'
            : 'Tout le Mali';

    try {
      // 1. APPEL PRIORITAIRE DU BACKEND ALIA (Base de données des Noms & Grand-mère Mah)
      final sageResponse = await _cultureAi.chatWithGrandmereMah(
        userMessage: query,
        additionalContext: contextStr,
        history: _history,
      );

      if (mounted) {
        final vision = _detectVision(sageResponse.answer, query);
        final botMsg = _SageMessage(
          text: sageResponse.answer,
          isUser: false,
          timestamp: DateTime.now(),
          scenicAction: sageResponse.scenicAction,
          visionImagePath: vision?.path,
          visionCaption: vision?.caption,
          nameHeritage: sageResponse.matchedName,
        );

        setState(() {
          _isLoading = false;
          _sageState = _SageState.speaking;
          _messages.add(botMsg);
          _currentlySpeakingMessageId = botMsg.id;
        });
        _scrollToBottom();

        try {
          await VivienneTtsService.instance.speak(
            sageResponse.answer,
            onComplete: () {
              if (mounted) {
                setState(() {
                  _currentlySpeakingMessageId = null;
                  _sageState = _SageState.idle;
                });
              }
            },
          );
        } catch (_) {
          try {
            await _tts.speak(sageResponse.answer);
          } catch (_) {}
        }
      }
    } catch (_) {
      // 2. REPLI DE SECOURS EN CAS D'INDISPONIBILITÉ TOTALE DU RÉSEAU
      if (mounted) {
        final fallback = _cultureAi.generateLocalSageResponse(query, contextStr);
        final nameInfo = MalianNamesKnowledge.findNameInfo(query);
        final actionIndex = _messages.length % _scenicActionsPool.length;
        final vision = _detectVision(fallback, query);
        final botMsg = _SageMessage(
          text: fallback,
          isUser: false,
          timestamp: DateTime.now(),
          scenicAction: _scenicActionsPool[actionIndex],
          visionImagePath: vision?.path,
          visionCaption: vision?.caption,
          nameHeritage: nameInfo,
        );
        setState(() {
          _isLoading = false;
          _sageState = _SageState.speaking;
          _messages.add(botMsg);
          _currentlySpeakingMessageId = botMsg.id;
        });
        _scrollToBottom();
        try {
          await VivienneTtsService.instance.speak(
            fallback,
            onComplete: () {
              if (mounted) {
                setState(() {
                  _currentlySpeakingMessageId = null;
                  _sageState = _SageState.idle;
                });
              }
            },
          );
        } catch (_) {}
      }
    }
  }

  static ({String path, String caption})? _detectVision(
      String text, String query) {
    final t = ('$text $query').toLowerCase();
    if (t.contains('soundiata')) {
      return (
        path: 'assets/images/culture/personnages/soundiata_redressement_realiste.jpg',
        caption: 'Soundiata Keïta se redressant — Le Lion du Mandé',
      );
    }
    if (t.contains('mansa moussa') || t.contains('kankan moussa')) {
      return (
        path: 'assets/images/culture/personnages/mansa_moussa.jpg',
        caption: 'Kassa Mansa Moussa — La Renommée d\'Or du Mali',
      );
    }
    if (t.contains('babemba') || t.contains('sikasso') || t.contains('tata')) {
      return (
        path: 'assets/images/culture/personnages/babemba_traore.jpg',
        caption: 'Babemba Traoré au Tata de Sikasso — « Plutôt la mort que la honte »',
      );
    }
    if (t.contains('biton') || (t.contains('coulibaly') && t.contains('ségou'))) {
      return (
        path: 'assets/images/culture/personnages/biton_coulibaly.jpg',
        caption: 'Biton Mamary Coulibaly — Fondateur du Royaume de Ségou',
      );
    }
    if (t.contains('wagadou') || t.contains('bida')) {
      return (
        path: 'assets/images/culture/contes/wagadou_bida.jpg',
        caption: 'Wagadou Bida — Le Grand Serpent Sacré de Koumbi Saleh',
      );
    }
    if (t.contains('bouki') ||
        t.contains('leuk') ||
        t.contains('zoumana') ||
        t.contains('hyène') ||
        t.contains('lièvre')) {
      return (
        path: 'assets/images/culture/contes/zoumana_lievre.jpg',
        caption: 'Zoumana le Lièvre & Namori l\'Hyène au clair de lune',
      );
    }
    return null;
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Parole copiée dans le presse-papiers',
          style: GoogleFonts.plusJakartaSans(color: AppColors.accentLight),
        ),
        backgroundColor: AppColors.surfaceAlt,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteMessage(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      _messages.removeWhere((m) => m.id == id);
    });
  }

  void _toggleVillageSound() {
    HapticFeedback.lightImpact();
    setState(() {
      _isVillageSoundActive = !_isVillageSoundActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isVillageSoundActive
              ? 'Son du village activé : Crépitement du feu & brise sahélienne'
              : 'Son d\'ambiance mis en veille',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accentLight,
          ),
        ),
        backgroundColor: AppColors.surface,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAmbianceSettings() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppColors.border, width: 1.2),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune_rounded,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Ambiance de la Veillée',
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _isVillageSoundActive
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: AppColors.accent,
              ),
              title: Text(
                'Sons nocturnes du village',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Feu crépitant, grillons et chuchotements du vent',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: Switch(
                value: _isVillageSoundActive,
                activeThumbColor: AppColors.accent,
                activeTrackColor: AppColors.border,
                onChanged: (val) {
                  Navigator.pop(ctx);
                  _toggleVillageSound();
                },
              ),
            ),

            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.refresh_rounded,
                  color: AppColors.accent),
              title: Text(
                'Recommencer la veillée',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _startNewDiscussion();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNamesCatalogModal() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppColors.border, width: 1.2),
      ),
      builder: (ctx) => _NamesCatalogSheet(
        cultureAi: _cultureAi,
        onSelectName: (nameInfo) {
          Navigator.pop(ctx);
          _sendMessage(
            nameInfo.type == 'prenom'
                ? 'Grand-mère Mah, conte-moi la bénédiction et la signification du prénom « ${nameInfo.name} »'
                : 'Grand-mère Mah, conte-moi la véritable histoire, le clan et le totem du nom « ${nameInfo.name} »',
          );
        },
      ),
    );
  }

  void _startNewDiscussion() {
    HapticFeedback.mediumImpact();
    _stopTts();
    setState(() {
      _messages.clear();
      _history.clear();
    });
    _addWelcomeMessage();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD PRINCIPAL — CHARTE OFFICIELLE ALTERNIA (AppColors)
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final campfireHeight = isKeyboardOpen ? 140.0 : 275.0;

    return Theme(
      data: AppTheme.darkTheme,
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          _stopTts();
          VivienneTtsService.instance.stop();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // 1. EN-TÊTE : CAMPFIRE WIDGET (Feu 3D, Doyenne Vivienne)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: campfireHeight,
                child: VillageCampfireWidget(
                  height: campfireHeight,
                  isThinking: _sageState == _SageState.thinking ||
                      _sageState == _SageState.speaking ||
                      _isLoading,
                  visitorName: widget.guideContext?.contentTitle ??
                      widget.contextRegion?.nom ??
                      'Tênin Diakité',
                  isSoundActive: _isVillageSoundActive,
                  onSoundToggle: _toggleVillageSound,
                  onSettingsTap: _showAmbianceSettings,
                  onBackTap: () {
                    HapticFeedback.lightImpact();
                    _stopTts();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/culture');
                    }
                  },
                  onElderTap: () {
                    _sendMessage(
                        'Donne-moi une parole de sagesse sur l\'origine des familles du Mali.');
                  },
                  onFireStoked: () {
                    // Feu attisé avec étincelles dorées
                  },
                ),
              ),

              // 2. LISTE DES MESSAGES DU CHAT (MAXIMUM D'ESPACE ET DE CLARTÉ)
              Expanded(child: _buildTranscript()),

              // 3. BARRE FLUIDE DE SUJETS DE STORYTELLING (Puces d'exploration 1-clic)
              _buildUnifiedStorytellingTopicsBar(),

              // 4. BARRE DE SAISIE NOCTURNE
              _buildInputBar(),
            ],
          ),
        ),
      ),
    ),
    );
  }

  // ── 2. BARRE UNIQUE DE SUJETS DE STORYTELLING (Puces d'exploration 1-clic) ─

  Widget _buildUnifiedStorytellingTopicsBar() {
    final allTopics = <Map<String, String>>[
      if (_contextualSuggestions.isNotEmpty)
        ..._contextualSuggestions.map((s) => {
              'label': s.questionText,
              'prompt': s.questionText,
            }),
      {
        'label': 'Mon Nom de Famille',
        'prompt':
            'Dis-moi l\'origine sacrée, la signification et le clan historique de mon nom de famille.',
      },
      {
        'label': 'Mon Prénom',
        'prompt':
            'Que signifie mon prénom selon les traditions maliennes et quelle bénédiction porte-t-il ?',
      },
      {
        'label': 'Mon Totem (Tanan)',
        'prompt':
            'Quel est l\'animal totem (tanan) ou l\'interdit traditionnel associé à ma lignée ?',
      },
      {
        'label': 'Mon Senankouya',
        'prompt':
            'Quel est le cousinage à plaisanterie (senankouya) et les pactes de concorde liés à mon nom ?',
      },
      {
        'label': 'Soundiata Keïta',
        'prompt':
            'Raconte-moi la glorieuse épopée de Soundiata Keïta, le lion du Mandé, et la bataille de Kirina.',
      },
      {
        'label': 'Babemba à Sikasso',
        'prompt':
            'Raconte-moi la résistance héroïque de Babemba Traoré au Tata de Sikasso.',
      },
      {
        'label': 'Mansa Moussa',
        'prompt':
            'Conte-moi le fabuleux voyage de Mansa Moussa à travers le Sahara et la renommée d\'or du Mali.',
      },
      {
        'label': 'Bouki & Leuk le Lièvre',
        'prompt':
            'Conte-moi l\'histoire malicieuse de Bouki l\'Hyène et Leuk le Lièvre au clair de lune.',
      },
      {
        'label': 'Wagadou Bida',
        'prompt':
            'Raconte-moi la légende du serpent sacré Wagadou Bida de l\'ancien Empire du Ghana.',
      },
    ];

    return Container(
      height: 34,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: allTopics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          final t = allTopics[i];
          final isCatalog = t['prompt'] == 'catalog';

          return GestureDetector(
            onTap: () {
              if (isCatalog) {
                _showNamesCatalogModal();
              } else {
                _sendMessage(t['prompt']!);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: isCatalog ? const Color(0x33D97706) : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCatalog ? AppColors.accentLight : AppColors.border,
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCatalog) ...[
                    const Icon(Icons.menu_book_rounded,
                        size: 13, color: AppColors.accentLight),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    t['label']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isCatalog ? AppColors.accentLight : AppColors.textPrimary,
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

  // ── 5. LISTE DES MESSAGES ──────────────────────────────────────────────────

  Widget _buildTranscript() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (_isLoading && i == _messages.length) {
          return _buildThinkingCard();
        }
        return _buildMessageCard(_messages[i]);
      },
    );
  }

  Widget _buildThinkingCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 1.2),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome, size: 16, color: AppColors.accentLight),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Grand-mère Mah consulte les récits des anciens...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
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

  Widget _buildMessageCard(_SageMessage msg) {
    if (msg.isUser) {
      // Message Utilisateur (Bleu institutionnel AlterniA)
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.4),
                width: 1.1,
              ),
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.45,
              ),
            ),
          ),
        ),
      );
    }

    // Message de la Doyenne (Surface AlterniA & touches d'or)
    final isSpeaking = _currentlySpeakingMessageId == msg.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar étoile dorée de la Doyenne à gauche
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSpeaking
                    ? AppColors.accentLight
                    : AppColors.accent,
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.25),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: CultureTheme.orPatrimoine,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Carte principale du message
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSpeaking
                      ? AppColors.accent
                      : AppColors.border,
                  width: isSpeaking ? 1.4 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne supérieure : Titre + Bouton Écouter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grand-mère Mah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentLight,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _speakMessage(msg),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSpeaking
                                  ? AppColors.accentLight
                                  : AppColors.accent,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSpeaking) ...[
                                const _VoiceWaveIndicator(),
                                const SizedBox(width: 4),
                                Text(
                                  'En récitation...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentLight,
                                  ),
                                ),
                              ] else ...[
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 14,
                                  color: AppColors.accentLight,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Écouter',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Encadré scénique de narration épuré (zéro étoile, icône chaleureuse)
                  if (msg.scenicAction != null &&
                      msg.scenicAction!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.fireplace_rounded,
                            size: 14,
                            color: CultureTheme.accentOrange,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              _cleanScenicAction(msg.scenicAction!),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentLight,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 1. VISION DANS LES BRAISES (Si un héros ou conte est évoqué)
                  if (msg.visionImagePath != null)
                    _buildVisionCard(
                        msg.visionImagePath!, msg.visionCaption ?? ''),

                  const SizedBox(height: 8),

                  // 2. CONTENU DU RÉCIT DE GRAND-MÈRE MAH (Mise en page riche, zéro étoile)
                  _FormattedNarrativeText(text: msg.text),

                  // 3. PARCHEMIN ANCESTRAL DU CLAN (Si un patronyme est abordé)
                  if (msg.nameHeritage != null)
                    _buildAncestralParchment(msg.nameHeritage!),

                  const SizedBox(height: 8),

                  // Actions secondaires (Copier / Supprimer)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _copyMessage(msg.text),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _deleteMessage(msg.id),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── VISION DANS LES BRAISES : CARTE HISTORIQUE IMMERSIVE ──────────────────

  Widget _buildVisionCard(String imagePath, String caption) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E140C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF1E140C).withValues(alpha: 0.85),
                      ],
                      stops: const [0.55, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accent,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 10, color: AppColors.accentLight),
                      const SizedBox(width: 4),
                      Text(
                        'Vision dans les braises',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            child: Text(
              caption,
              style: GoogleFonts.cinzel(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.accentLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PARCHEMIN ANCESTRAL DU MANDÉ : FICHE TOTÉMIQUE & DANBÉ ───────────────

  Widget _buildAncestralParchment(MalianNameInfo info) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF20150B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD97706),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  size: 16, color: AppColors.accentLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'PARCHEMIN SACRÉ DU CLAN ${info.name.toUpperCase()}',
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentLight,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Divider(color: Color(0x33D97706), height: 1),
          const SizedBox(height: 7),
          _buildParchmentRow('Berceau :', info.origin),
          const SizedBox(height: 4),
          _buildParchmentRow('Signification :', info.meaning),
          if (info.totem.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildParchmentRow('Totem (Tanan) :', info.totem),
          ],
          if (info.senankouya.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildParchmentRow('Senankouya :', info.senankouya),
          ],
          if (info.deviseOuLouange != null && info.deviseOuLouange!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildParchmentRow('Devise :', info.deviseOuLouange!),
          ],
          const SizedBox(height: 12),
          // Boutons de Partage : WhatsApp Statut et Réseaux Sociaux
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              // Bouton Statut WhatsApp avec visuel haute définition
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  MalianNameShareSheet.show(
                    context: context,
                    info: info,
                    autoTriggerWhatsApp: true,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF25D366).withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_rounded,
                          size: 13, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        'Statut WhatsApp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton Partager la carte
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  MalianNameShareSheet.show(
                    context: context,
                    info: info,
                    autoTriggerWhatsApp: false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.accent,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.share_rounded,
                          size: 12, color: AppColors.accentLight),
                      const SizedBox(width: 5),
                      Text(
                        'Partager la carte',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParchmentRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.accentLight,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  // ── 7. BARRE DE SAISIE NOCTURNE HARMONISÉE & MICRO VOCAL ───────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      decoration: const BoxDecoration(
        color: Color(0xFF140F0C),
        border: Border(
          top: BorderSide(color: Color(0x29D97706), width: 1.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bannière d'écoute vocale en direct si le micro est actif
          if (_isListening)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.6),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFEF4444),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _liveSpokenWords.isNotEmpty
                          ? '« $_liveSpokenWords »'
                          : 'Parlez maintenant... (Touchez pour envoyer)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _toggleVocalRecording,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Envoyer',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Ligne principale : [Micro 40px] [Champ élégant 40px] [Envoyer 40px]
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Bouton Microphone (Squircle fin 40x40 / Bordure Orange Ambrée)
              GestureDetector(
                onTap: _toggleVocalRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isListening
                        ? const Color(0xFFEF4444).withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isListening
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFD97706),
                      width: 1.3,
                    ),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      _isListening
                          ? Icons.stop_rounded
                          : Icons.mic_none_rounded,
                      size: 20,
                      color: _isListening
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),

              // 2. Champ de saisie élégant (Exactement 40px, même taille que micro et envoi)
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isListening
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFD97706),
                      width: 1.3,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _promptCtrl,
                    maxLines: 1,
                    onSubmitted: _sendMessage,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      filled: false,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      hintText: _isListening
                          ? 'Écoute en cours... parlez'
                          : 'Posez une question, demandez un conte...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    cursorColor: const Color(0xFFD97706),
                    textInputAction: TextInputAction.send,
                  ),
                ),
              ),
              const SizedBox(width: 7),

              // 3. Bouton Envoyer élégant (40x40 / Squircle Marron Ambré)
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        if (_isListening) {
                          _toggleVocalRecording();
                        } else {
                          _sendMessage(_promptCtrl.text);
                        }
                      },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? const Color(0xFF45220B)
                        : const Color(0xFF7C3B0E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: Color(0xFFD1D5DB),
                            ),
                          )
                        : const Icon(
                            Icons.near_me_outlined,
                            color: Color(0xFFD1D5DB),
                            size: 19,
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

// ══════════════════════════════════════════════════════════════════════════════
// ONDE VOCALE ANIMÉE DE RÉCITATION (VOICE WAVE)
// ══════════════════════════════════════════════════════════════════════════════

class _VoiceWaveIndicator extends StatefulWidget {
  const _VoiceWaveIndicator();

  @override
  State<_VoiceWaveIndicator> createState() => _VoiceWaveIndicatorState();
}

class _VoiceWaveIndicatorState extends State<_VoiceWaveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final val = _ctrl.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _bar(3.5 + 8.5 * val),
            const SizedBox(width: 2),
            _bar(12.0 - 7.5 * val),
            const SizedBox(width: 2),
            _bar(5.5 + 6.5 * val),
          ],
        );
      },
    );
  }

  Widget _bar(double h) {
    return Container(
      width: 2.2,
      height: h.clamp(3.0, 14.0),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MODAL DU DICTIONNAIRE DES NOMS ET TOTEMS (CONNECTÉ BDD BACKEND)
// ══════════════════════════════════════════════════════════════════════════════

class _NamesCatalogSheet extends StatefulWidget {
  final CultureAiService cultureAi;
  final ValueChanged<MalianNameInfo> onSelectName;

  const _NamesCatalogSheet({
    required this.cultureAi,
    required this.onSelectName,
  });

  @override
  State<_NamesCatalogSheet> createState() => _NamesCatalogSheetState();
}

class _NamesCatalogSheetState extends State<_NamesCatalogSheet> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'nom', 'prenom'
  List<MalianNameInfo> _allNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNames() async {
    setState(() => _isLoading = true);
    try {
      final names = await widget.cultureAi.fetchNamesFromBackend();
      if (mounted) {
        setState(() {
          _allNames = names;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _allNames = MalianNamesKnowledge.allNames;
          _isLoading = false;
        });
      }
    }
  }

  List<MalianNameInfo> get _filteredNames {
    final query = _searchCtrl.text.trim().toLowerCase();
    return _allNames.where((n) {
      if (_selectedFilter != 'all' && n.type != _selectedFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      return n.name.toLowerCase().contains(query) ||
          n.origin.toLowerCase().contains(query) ||
          n.meaning.toLowerCase().contains(query) ||
          n.totem.toLowerCase().contains(query) ||
          n.clanRole.toLowerCase().contains(query) ||
          n.senankouya.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredNames;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poignée de glissement
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 1.2),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.accentLight,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mémoire Généalogique du Mali',
                        style: GoogleFonts.cinzel(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_allNames.length} Patronymes & Prénoms sacrés (BDD)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Champ de recherche
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un patronyme, totem ou terroir...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            size: 16, color: AppColors.textMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Filtres de sélection
            Row(
              children: [
                _buildFilterChip('Tous (${_allNames.length})', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Patronymes (${_allNames.where((n) => n.type == 'nom').length})',
                  'nom',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Prénoms (${_allNames.where((n) => n.type == 'prenom').length})',
                  'prenom',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Liste des noms
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  : items.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun nom ne correspond à votre recherche.',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final item = items[i];
                            return _buildNameCard(item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentLight : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildNameCard(MalianNameInfo item) {
    final isNom = item.type == 'nom';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.name,
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentLight,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isNom
                      ? const Color(0x33D97706)
                      : const Color(0x332563EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isNom ? 'Patronyme (Jamu)' : 'Prénom',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isNom ? const Color(0xFFFBBF24) : const Color(0xFF93C5FD),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  MalianNameShareSheet.show(
                    context: context,
                    info: item,
                    autoTriggerWhatsApp: false,
                  );
                },
                icon: const Icon(Icons.share_rounded,
                    size: 14, color: AppColors.accentLight),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Partager sur Statut WhatsApp',
              ),
              const SizedBox(width: 4),
              ElevatedButton.icon(
                onPressed: () => widget.onSelectName(item),
                icon: const Icon(Icons.forum_outlined, size: 12),
                label: Text(
                  'Conter',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            item.meaning,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.origin,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (item.totem.isNotEmpty) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.pets_outlined,
                    size: 12, color: AppColors.accentLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Totem : ${item.totem}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (item.senankouya.isNotEmpty) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.people_outline,
                    size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Senankouya : ${item.senankouya}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Nettoie les actions scéniques pour enlever les astérisques et crochets résiduels
String _cleanScenicAction(String action) {
  var cleaned = action.trim();
  while (cleaned.startsWith('*') ||
      cleaned.startsWith('[') ||
      cleaned.startsWith('(')) {
    cleaned = cleaned.substring(1).trim();
  }
  while (cleaned.endsWith('*') ||
      cleaned.endsWith(']') ||
      cleaned.endsWith(')')) {
    cleaned = cleaned.substring(0, cleaned.length - 1).trim();
  }
  return cleaned;
}

/// Widget de mise en page riche pour les paroles de Grand-mère Mah
/// Formate les mots clés en doré gras et termes traditionnels en italique
/// sans laisser apparaître d'étoiles parasites.
class _FormattedNarrativeText extends StatelessWidget {
  final String text;

  const _FormattedNarrativeText({required this.text});

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          height: 1.55,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        children: _buildSpans(text),
      ),
    );
  }

  List<InlineSpan> _buildSpans(String raw) {
    final List<InlineSpan> spans = [];
    final lines = raw.split('\n');

    for (int l = 0; l < lines.length; l++) {
      final line = lines[l];
      if (line.isEmpty) {
        if (l < lines.length - 1) {
          spans.add(const TextSpan(text: '\n'));
        }
        continue;
      }

      // Capture **gras**, *italique*, ou texte ordinaire
      final regex = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*|[^*]+)');
      final matches = regex.allMatches(line);

      for (final match in matches) {
        final segment = match.group(0) ?? '';
        if (segment.startsWith('**') &&
            segment.endsWith('**') &&
            segment.length >= 4) {
          final content = segment.substring(2, segment.length - 2);
          spans.add(
            TextSpan(
              text: content,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: CultureTheme.orPatrimoine,
                letterSpacing: 0.2,
              ),
            ),
          );
        } else if (segment.startsWith('*') &&
            segment.endsWith('*') &&
            segment.length >= 2) {
          final content = segment.substring(1, segment.length - 1);
          spans.add(
            TextSpan(
              text: content,
              style: GoogleFonts.plusJakartaSans(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFDE68A),
              ),
            ),
          );
        } else {
          // Texte ordinaire : on s'assure d'éliminer toute étoile isolée
          final clean = segment.replaceAll('*', '');
          if (clean.isNotEmpty) {
            spans.add(TextSpan(text: clean));
          }
        }
      }

      if (l < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }
}

