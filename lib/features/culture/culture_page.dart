// ─── AlterniA — Feature: Culture Immersive (Avatar Interactif & Savoir) ────────
// Mode immersif avec Avatar Interactif AlterniA (expressions du visage & onde vocale),
// charte graphique officielle (#314999, #F1851F Orange, #40BBCC, #0B111E),
// bouton constant de fermeture [X] et navigation sub-bar propre et adaptative aux thèmes.
library;

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/constants/app_colors.dart';
import '../../core/culture_ai_service.dart';
import '../../core/culture_simli_service.dart';
import '../../core/gemini_service.dart';
import '../../core/services/vivienne_tts_service.dart';
import '../../presentation/common/widgets/alternia_avatar.dart';
import '../../presentation/common/widgets/alternia_video_player.dart';
import '../../shared/widgets.dart';
import '../profile/user_prefs_notifier.dart';
import 'core/theme/culture_theme.dart';

class CulturePage extends ConsumerStatefulWidget {
  const CulturePage({super.key});

  @override
  ConsumerState<CulturePage> createState() => _CulturePageState();
}

class _CulturePageState extends ConsumerState<CulturePage> {
  int _subTabIndex =
      0; // 0: Avatar Live, 1: Histoire, 2: Inventions, 3: Sagesse
  AvatarState _avatarState = AvatarState.speaking;
  String _liveSpeechText =
      'Bonjour ! Je suis le Vieux Sage du Mali. Pose-moi n\'importe quelle question sur l\'Histoire, les Rois et les Inventions de notre terre !';
  String? _currentVideoUrl;

  final CultureAlternIAService _cultureService = CultureAlternIAService();
  final GeminiService _geminiService = GeminiService();
  final CultureAiService _cultureAiService = CultureAiService();
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final TextEditingController _sageInputCtrl = TextEditingController();

  bool _isListening = false;
  String _liveSpokenWords = '';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('fr-FR');
      await _flutterTts.setSpeechRate(0.48);
      // Pitch masculin plus grave et posé pour le Vieux Sage Henri
      await _flutterTts.setPitch(0.80);

      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        for (final v in voices) {
          if (v is Map) {
            final name = (v['name'] ?? '').toString().toLowerCase();
            final locale = (v['locale'] ?? '').toString().toLowerCase();
            if (locale.contains('fr') &&
                (name.contains('henri') ||
                    name.contains('male') ||
                    name.contains('homme') ||
                    name.contains('thomas') ||
                    name.contains('nicolas') ||
                    name.contains('paul') ||
                    name.contains('antoine'))) {
              await _flutterTts
                  .setVoice({'name': v['name'], 'locale': v['locale']});
              break;
            }
          }
        }
      }

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() => _avatarState = AvatarState.idle);
        }
      });
    } catch (_) {}
  }

  @override
  void deactivate() {
    _stopAudio();
    super.deactivate();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _sageInputCtrl.dispose();
    _stopAudio();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _stopAudio() async {
    try {
      await VivienneTtsService.instance.stop();
      await _flutterTts.stop();
    } catch (_) {}
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  // ── Speech-To-Text : 1 Clic Enregistre, 1 Clic Coupe et Envoie Directement ─
  Future<void> _toggleVocalRecording() async {
    HapticFeedback.heavyImpact();

    if (_isListening) {
      await _speechToText.stop();
      final spoken = _liveSpokenWords.trim().isNotEmpty
          ? _liveSpokenWords.trim()
          : _sageInputCtrl.text.trim();
      setState(() {
        _isListening = false;
        _liveSpokenWords = '';
      });
      if (spoken.isNotEmpty) {
        _sageInputCtrl.clear();
        _askSageQuestion(spoken);
      }
    } else {
      await _stopAudio();
      bool available = false;
      try {
        available = await _speechToText.initialize(
          onError: (_) {
            if (mounted) setState(() => _isListening = false);
          },
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              if (mounted && _isListening) {
                final spoken = _liveSpokenWords.trim().isNotEmpty
                    ? _liveSpokenWords.trim()
                    : _sageInputCtrl.text.trim();
                setState(() {
                  _isListening = false;
                  _liveSpokenWords = '';
                });
                if (spoken.isNotEmpty) {
                  _sageInputCtrl.clear();
                  _askSageQuestion(spoken);
                }
              }
            }
          },
        );
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _isListening = true;
        _liveSpokenWords = '';
      });

      if (available) {
        _speechToText.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _liveSpokenWords = result.recognizedWords;
                _sageInputCtrl.text = result.recognizedWords;
              });
              if (result.finalResult &&
                  result.recognizedWords.trim().isNotEmpty) {
                _speechToText.stop();
                setState(() {
                  _isListening = false;
                  _liveSpokenWords = '';
                });
                _sageInputCtrl.clear();
                _askSageQuestion(result.recognizedWords.trim());
              }
            }
          },
        );
      } else {
        Timer(const Duration(seconds: 3), () {
          if (mounted && _isListening) {
            setState(() {
              _isListening = false;
              _liveSpokenWords = '';
            });
            _sageInputCtrl.clear();
            _askSageQuestion(
                'Raconte-moi l\'histoire de Mansa Moussa et son héritage.');
          }
        });
      }
    }
  }

  /// Charge la réponse vidéo Simli et ne l'affiche qu'une fois le rendu terminé
  Future<void> _loadSageResponse(String replyText, {String? subject}) async {
    await _stopAudio();

    // 1. Appel du backend pour générer la vidéo Simli
    // Tant que Simli n'a pas fini et renvoyé la vidéo, on n'affiche rien sur le téléphone
    final videoUrl = await _cultureService.generateSageVideo(
      text: replyText,
      subject: subject,
    );

    if (!mounted) return;

    if (videoUrl != null && videoUrl.isNotEmpty) {
      // Vidéo et audio Henri prêts : affichage simultané du texte et de la vidéo
      setState(() {
        _currentVideoUrl = videoUrl;
        _liveSpeechText = replyText;
        _avatarState = AvatarState.speaking;
      });
    } else {
      // Fallback si la vidéo échoue : attendre le flux TTS Henri avant d'afficher la réponse
      Uint8List? audioBytes;
      try {
        audioBytes = await _geminiService.fetchBackendTtsAudio(
          text: replyText,
          voice: 'henri',
        );
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _liveSpeechText = replyText;
        _avatarState = AvatarState.speaking;
      });

      if (audioBytes != null && audioBytes.isNotEmpty) {
        try {
          await GeminiService.playAudioBytes(_audioPlayer, audioBytes);
        } catch (_) {
          await _flutterTts.speak(replyText);
        }
      } else {
        await _flutterTts.speak(replyText);
      }
    }
  }

  void _enterProtagonistMode(String title) {
    HapticFeedback.heavyImpact();
    String speech;
    if (title.contains('Mansa Moussa')) {
      speech =
          'Je suis Mansa Moussa, l\'Empereur du Mali ! En 1324, j\'ai accompli mon pèlerinage avec des tonnes d\'or pour faire rayonner notre savoir.';
    } else if (title.contains('Sundiata') || title.contains('Manden')) {
      speech =
          'Je suis Sundiata Keïta, le Lion du Manden ! En 1236, nous avons proclamé la Charte du Manden pour la paix et les droits de tous.';
    } else if (title.contains('Dogon') || title.contains('Astronomie')) {
      speech =
          'Nous sommes les astronomes Dogons de Bandiagara ! Interroge-nous sur l\'étoile Sirius B et les secrets célestes de nos ancêtres.';
    } else if (title.contains('Djenné') || title.contains('Banco')) {
      speech =
          'Je suis le Maître Architecte de Djenné ! L\'art du banco est un prodige d\'ingénierie durable et de fierté malienne.';
    } else {
      speech =
          'Je me mets dans la peau du protagoniste de : "$title" ! Écoute ma parole ancestrale.';
    }

    setState(() {
      _subTabIndex = 0; // Basculer sur l'onglet Avatar Live
      _avatarState = AvatarState.thinking;
      _liveSpeechText = 'Le Vieux Sage prépare sa réponse vidéo et vocale...';
    });

    _loadSageResponse(speech, subject: title);
  }

  void _onExitCultureMode() {
    HapticFeedback.mediumImpact();
    _stopAudio();
    context.go('/home');
  }

  void _onAvatarTapped() {
    HapticFeedback.heavyImpact();
    if (_avatarState == AvatarState.thinking) return;

    if (_avatarState == AvatarState.speaking) {
      _stopAudio();
      setState(() {
        _avatarState = AvatarState.listening;
        _liveSpeechText =
            'J\'écoute attentivement ta question ! Parle maintenant ou sélectionne un thème de sagesse ci-dessous...';
      });
    } else {
      const replyText =
          'Savais-tu que Mansa Moussa a fait rayonner le Mali dans le monde entier en 1324 lors de son grand pèlerinage ?';

      setState(() {
        _avatarState = AvatarState.thinking;
        _liveSpeechText = 'Le Vieux Sage prépare sa réponse vidéo et vocale...';
      });

      _loadSageResponse(replyText, subject: 'Histoire du Mali');
    }
  }

  Future<void> _askSageQuestion(String query) async {
    HapticFeedback.mediumImpact();
    await _stopAudio();

    setState(() {
      _avatarState = AvatarState.thinking;
      _liveSpeechText = 'Le Vieux Sage prépare sa réponse vidéo et vocale...';
    });

    try {
      final result = await _cultureAiService.culturalSearch(query);
      final text = result.aiNarrative.isNotEmpty
          ? result.aiNarrative
          : 'La culture et les traditions du Mali sont riches d\'enseignements pour toutes les générations.';
      await _loadSageResponse(text, subject: query);
    } catch (_) {
      await _loadSageResponse(
        'La sagesse des anciens nous enseigne la paix, la solidarité et le respect des traditions.',
        subject: query,
      );
    }
  }

  void _showStoryModal(String title, String category, String fullText,
      IconData icon, Color color) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modalBg = isDark ? AppColors.surface : Colors.white;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: modalBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPri,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(
                  color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                  height: 1),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    fullText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      height: 1.6,
                      color: textSec,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Incarner ce personnage avec l\'Avatar',
                variant: CustomButtonVariant.accent,
                icon: Icons.theater_comedy_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  _enterProtagonistMode(title);
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: 'Fermer la découverte',
                variant: CustomButtonVariant.outline,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = ref.watch(userPrefsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. BARRE SUPERIEURE AVEC BOUTON FERMETURE [X] CONSTANT ───────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const AlterniaLogo(
                    size: 28,
                    showText: true,
                    iaColor: CultureTheme.iaYellow,
                  ),
                  const Spacer(),

                  // CONSTANT CLOSE BUTTON [X] WITH ACCENT ORANGE
                  GestureDetector(
                    onTap: _onExitCultureMode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Quitter',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.close_rounded,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.border
                    : const Color(0xFFCBD5E1),
                height: 1),

            // ── 2. SOUS-PAGES DE L'ESPACE CULTURE ───────────────────────────
            Expanded(
              child: IndexedStack(
                index: _subTabIndex,
                children: [
                  _buildInteractiveAvatarMode(),
                  _buildHistoryTab(userPrefs.classShortLabel),
                  _buildInventionsTab(),
                  _buildWisdomTab(),
                ],
              ),
            ),

            // ── 3. BOTTOM NAVBAR PROPRE À LA CULTURE ─────────────────────────
            _buildCultureBottomNavBar(),
          ],
        ),
      ),
    );
  }

  // ── SUB-PAGE 0 : AVATAR INTERACTIF ALTERNIA ──────────────────────────────
  Widget _buildInteractiveAvatarMode() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final speechBg = isDark ? AppColors.surface : Colors.white;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);

    return Column(
      children: [
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          ),
          child: Text(
            'AVATAR INTERACTIF ALTERNIA',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              letterSpacing: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Touche l\'Avatar pour interagir',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: textSec,
          ),
        ),

        const Spacer(),

        // ── AVATAR INTERACTIF ANIMÉ ─────────────────────────────────────────
        if (_currentVideoUrl != null && _currentVideoUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: AlterniaVideoPlayer(
              videoUrl: _currentVideoUrl!,
              onTap: _onAvatarTapped,
            ),
          )
        else
          AlterniaAvatar(
            size: 190,
            state: _avatarState,
            onTap: _onAvatarTapped,
          ),

        const Spacer(),

        // ── BULLE DE PAROLE DE L'AVATAR ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: speechBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _avatarState == AvatarState.speaking
                    ? AppColors.accent
                    : (isDark ? AppColors.secondary : AppColors.primary),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _avatarState == AvatarState.speaking
                            ? AppColors.accent
                            : AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _avatarState == AvatarState.speaking
                          ? 'LE VIEUX SAGE PARLE…'
                          : (_avatarState == AvatarState.listening
                              ? 'ÉCOUTE ACTIVE…'
                              : 'PRÉPARATION VIDÉO & SAGESSE…'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _avatarState == AvatarState.speaking
                            ? AppColors.accent
                            : AppColors.secondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _liveSpeechText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.5,
                    color: textPri,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ── THÈMES RAPIDES POUR INTERROGER LE VIEUX SAGE ───────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildQuickTopicChip(
                label: 'Mansa Moussa',
                icon: Icons.account_balance_rounded,
                query: 'Raconte-moi le voyage légendaire de Mansa Moussa et ses réserves d\'or.',
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildQuickTopicChip(
                label: 'Sundiata Keïta',
                icon: Icons.gavel_rounded,
                query: 'Raconte-moi l\'épopée de Sundiata Keïta et la Charte du Manden de 1236.',
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildQuickTopicChip(
                label: 'Mosquée de Djenné',
                icon: Icons.apartment_rounded,
                query: 'Quels sont les secrets d\'architecture de la Grande Mosquée de Djenné ?',
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildQuickTopicChip(
                label: 'Manuscrits Tombouctou',
                icon: Icons.auto_stories_rounded,
                query: 'Que contiennent les célèbres manuscrits anciens de Tombouctou ?',
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── BARRE DE PAROLE ET MICROPHONE 1-CLIC (VIEUX SAGE) ──────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isListening)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 8,
                        height: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _liveSpokenWords.isNotEmpty
                              ? '« $_liveSpokenWords »'
                              : 'Écoute en direct... Parlez au Vieux Sage, touchez pour envoyer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _isListening
                              ? Colors.redAccent
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: TextField(
                        controller: _sageInputCtrl,
                        cursorColor:
                            isDark ? Colors.white : const Color(0xFF0F172A),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? 'Transcription en direct...'
                              : 'Pose une question au Vieux Sage...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMuted
                                : const Color(0xFF64748B),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            _sageInputCtrl.clear();
                            _askSageQuestion(val.trim());
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton Microphone 1-clic direct
                  GestureDetector(
                    onTap: _toggleVocalRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? Colors.redAccent
                            : AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color:
                                      Colors.redAccent.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          _isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton Envoyer
                  GestureDetector(
                    onTap: () {
                      final val = _sageInputCtrl.text.trim();
                      if (val.isNotEmpty) {
                        _sageInputCtrl.clear();
                        _askSageQuestion(val);
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF314999),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuickTopicChip({
    required String label,
    required IconData icon,
    required String query,
    required bool isDark,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.accent),
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      backgroundColor: isDark
          ? const Color(0xFF1E293B)
          : AppColors.accent.withValues(alpha: 0.08),
      side: BorderSide(
        color: AppColors.accent.withValues(alpha: 0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: _avatarState == AvatarState.thinking
          ? null
          : () => _askSageQuestion(query),
    );
  }

  // ── SUB-PAGE 1 : HISTOIRE DU MALI ────────────────────────────────────────
  Widget _buildHistoryTab(String classLabel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Histoire & Empires du Mali',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
        ),
        const SizedBox(height: 14),
        _CultureSubCard(
          title: 'L\'Empire du Mali & Mansa Moussa',
          subtitle: 'Le souverain le plus riche de l\'histoire humaine',
          category: 'Empire du Mali (XIIIe-XVe)',
          icon: Icons.account_balance_rounded,
          color: AppColors.accent,
          onTap: () => _showStoryModal(
            'L\'Empire du Mali & Mansa Moussa',
            'Histoire Impériale',
            'Au XIVème siècle, l\'Empire du Mali s\'étendait du fleuve Sénégal jusqu\'à la boucle du Niger. Son empereur le plus célèbre, Mansa Moussa, accomplit en 1324 un pèlerinage légendaire vers La Mecque avec une caravane de 60 000 hommes et des tonnes d\'or pure. Sa générosité à Le Caire provoqua une inflation de l\'or pendant plus de 10 ans ! Tombouctou devint alors la capitale mondiale du savoir africain.',
            Icons.account_balance_rounded,
            AppColors.accent,
          ),
        ),
        const SizedBox(height: 12),
        _CultureSubCard(
          title: 'Les Manuscrits Anciens de Tombouctou',
          subtitle:
              'Des dizaines de milliers de traités scientifiques et philosophiques',
          category: 'Patrimoine Écrit',
          icon: Icons.auto_stories_rounded,
          color: AppColors.secondary,
          onTap: () => _showStoryModal(
            'Les Manuscrits Anciens de Tombouctou',
            'Savoir & Écriture',
            'Bien avant l\'ère moderne, Tombouctou abritait l\'Université de Sankoré et plus de 25 000 étudiants venus de toute l\'Afrique et du Moyen-Orient. Des familles maliennes ont préservé de génération en génération plus de 700 000 manuscrits rédigés en arabe et en langues africaines, portant sur l\'astronomie, la médecine, le droit et les mathématiques.',
            Icons.auto_stories_rounded,
            AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        _CultureSubCard(
          title: 'Sundiata Keïta & la Charte du Manden',
          subtitle:
              'La première Déclaration universelle des Droits de l\'Homme (1236)',
          category: 'Histoire & Droit',
          icon: Icons.gavel_rounded,
          color: AppColors.primaryLight,
          onTap: () => _showStoryModal(
            'Sundiata Keïta & la Charte du Manden',
            'Droits Humains',
            'Proclamée en 1236 après la bataille de Kirina, la Charte du Manden (ou Kouroukan Fouga) est reconnue par l\'UNESCO comme l\'une des plus anciennes constitutions du monde. Elle abolit l\'esclavage, affirme le respect de la vie humaine, le droit à l\'éducation et l\'égalité des femmes bien avant les déclarations occidentales.',
            Icons.gavel_rounded,
            AppColors.primaryLight,
          ),
        ),
      ],
    );
  }

  // ── SUB-PAGE 2 : INVENTIONS & SAVOIR ─────────────────────────────────────
  Widget _buildInventionsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Inventions & Sciences au Mali',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
        ),
        const SizedBox(height: 14),
        _CultureSubCard(
          title: 'L\'Astronomie Ancestrale des Dogons',
          subtitle: 'La connaissance de Sirius B sans télescope moderne',
          category: 'Astrophysique',
          icon: Icons.wb_twilight_rounded,
          color: AppColors.secondary,
          onTap: () => _showStoryModal(
            'L\'Astronomie des Dogons',
            'Science des Étoiles',
            'Le peuple Dogon de la falaise de Bandiagara possédait des connaissances étonnantes sur le système stellaire de Sirius. Des décennies avant les télescopes modernes, ils savaient que Sirius avait une étoile compagnon invisible à l\'œil nu (Sirius B) qui tournait en 50 ans sur une orbite elliptique.',
            Icons.wb_twilight_rounded,
            AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        _CultureSubCard(
          title: 'L\'Architecture Bio-Climatique en Terre (Banco)',
          subtitle:
              'La Grande Mosquée de Djenné, chef-d\'œuvre d\'ingénierie durable',
          category: 'Génie Civil',
          icon: Icons.architecture_rounded,
          color: AppColors.accent,
          onTap: () => _showStoryModal(
            'L\'Architecture en Banco',
            'Ingénierie & Matériaux',
            'La Grande Mosquée de Djenné est le plus grand bâtiment en terre crue au monde. Les bâtisseurs maliens ont mis au point un matériau composite à base d\'argile, de balle de riz et de beurre de karité qui régule naturellement la température intérieure à 22°C même pendant les fortes chaleurs sahéliennes.',
            Icons.architecture_rounded,
            AppColors.accent,
          ),
        ),
      ],
    );
  }

  // ── SUB-PAGE 3 : SAGESSE & TRADITIONS ────────────────────────────────────
  Widget _buildWisdomTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Sagesse, Griots & Proverbes Bambaras',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
        ),
        const SizedBox(height: 14),
        _CultureSubCard(
          title: 'La Kora & la Parole des Griots',
          subtitle: 'L\'instrument à 21 cordes et la mémoire orale',
          category: 'Musique & Art',
          icon: Icons.music_note_rounded,
          color: AppColors.success,
          onTap: () => _showStoryModal(
            'La Kora & la Parole des Griots',
            'Art Oratoire',
            'La Kora est une harpe-luth traditionnelle à 21 cordes faite d\'une demi-calebasse recouverte de peau de vache. Les Griots (Djéli) conservent et chantent les généalogies, les poèmes et les leçons de morale depuis plus de 800 ans.',
            Icons.music_note_rounded,
            AppColors.success,
          ),
        ),
        const SizedBox(height: 12),
        _CultureSubCard(
          title: 'Proverbe Bambara : le trésor du savoir',
          subtitle:
              '« Le savoir est un trésor qui suit son possesseur partout »',
          category: 'Philosophie Africaine',
          icon: Icons.psychology_alt_rounded,
          color: AppColors.accentViolet,
          onTap: () => _showStoryModal(
            'La Sagesse des Proverbes Bambaras',
            'Philosophie',
            'Dans la culture orale malienne, les proverbes sont les clés de la réflexion. Ce proverbe enseigne que la véritable richesse d\'un jeune  est ni l\'argent ni les possessions matérielles, mais les connaissances acquises et la bienveillance.',
            Icons.psychology_alt_rounded,
            AppColors.accentViolet,
          ),
        ),
      ],
    );
  }

  // ── BARRE DE NAVIGATION CULTURE DYNAMIQUE THÈME ─────────────────────────
  Widget _buildCultureBottomNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.background : Colors.white;
    final navBorder = isDark ? AppColors.borderDark : const Color(0xFFCBD5E1);
    final unselectedColor = isDark
        ? const Color.fromARGB(255, 98, 114, 134)
        : const Color(0xFF64748B);

    final subItems = const [
      _CultureSubNavItem(icon: Icons.smart_toy_rounded, label: 'Avatar Live'),
      _CultureSubNavItem(icon: Icons.public_rounded, label: 'Histoire'),
      _CultureSubNavItem(icon: Icons.lightbulb_rounded, label: 'Inventions'),
      _CultureSubNavItem(icon: Icons.auto_stories_rounded, label: 'Sagesse'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      height: 58,
      decoration: BoxDecoration(
        color: navBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: navBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary)
                .withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(subItems.length, (index) {
          final isSelected = _subTabIndex == index;
          final item = subItems[index];

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _subTabIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 12 : 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.accentGradient : null,
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 18,
                    color: isSelected ? Colors.white : unselectedColor,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CultureSubNavItem {
  const _CultureSubNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

// ── Culture Sub Card Widget Dynamic Theme ───────────────────────────────────
class _CultureSubCard extends StatelessWidget {
  const _CultureSubCard({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surface : Colors.white;
    final cardBorder =
        isDark ? color.withValues(alpha: 0.3) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? AppColors.textSecondary : const Color(0xFF475569);

    return CustomCard(
      onTap: onTap,
      backgroundColor: cardBg,
      borderColor: cardBorder,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: subtitleColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
              size: 20),
        ],
      ),
    );
  }
}
