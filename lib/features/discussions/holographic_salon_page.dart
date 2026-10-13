// ─── AlterniA — Feature: Salon Holographique Live (Avatar AlternIA & Mode Premium) ──
// Accès conditionné à la validation d'un code de compte premium côté backend AlternIA.
// Conversation en direct avec l'avatar AlternIA AI, synchronisation labiale et réponses vocales.
library;

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/constants/app_colors.dart';
import '../../core/gemini_service.dart';
import '../../core/services/vivienne_tts_service.dart';
import '../../presentation/common/widgets/alternia_avatar.dart';
import '../../presentation/common/widgets/alternia_video_player.dart';

class HolographicSalonPage extends StatefulWidget {
  const HolographicSalonPage({super.key});

  @override
  State<HolographicSalonPage> createState() => _HolographicSalonPageState();
}

class _HolographicSalonPageState extends State<HolographicSalonPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _promptCtrl = TextEditingController();
  final TextEditingController _codeCtrl = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  AvatarState _avatarState = AvatarState.idle;
  String? _currentVideoUrl;
  bool _isListening = false;
  String _liveSpokenWords = '';

  // ── État de vérification Premium ──────────────────────────────────────────
  bool _isLoadingAuth = true;
  bool _isPremiumUnlocked = false;
  bool _isVerifyingCode = false;
  String? _authErrorMessage;
  String? _activePlanName;
  String? _activeCode;

  final List<_SalonMessage> _transcript = [
    const _SalonMessage(
      sender: 'Professeur Henri (AlternIA Live)',
      text:
          'Bonjour ! Je suis ton professeur particulier Henri animé par AlternIA. Pose-moi tes questions à l\'oral ou à l\'écrit !',
      isUser: false,
      timestamp: 'Direct',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _checkSavedPremiumStatus();
  }

  Future<void> _checkSavedPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('alternia_premium_code');
      final isUnlocked = prefs.getBool('alternia_premium_unlocked') ?? false;
      final plan =
          prefs.getString('alternia_premium_plan') ?? 'AlterniA Live Pro';

      if (mounted) {
        setState(() {
          _activeCode = savedCode;
          _isPremiumUnlocked =
              isUnlocked && savedCode != null && savedCode.isNotEmpty;
          _activePlanName = plan;
          _isLoadingAuth = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAuth = false);
    }
  }

  Future<void> _verifyEnteredCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _authErrorMessage = 'Veuillez saisir votre code premium.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isVerifyingCode = true;
      _authErrorMessage = null;
    });

    try {
      final result = await _geminiService.verifyPremiumCode(code);
      final isValide = result['valide'] as bool? ?? false;

      if (!mounted) return;

      if (isValide) {
        final plan = result['plan'] as String? ?? 'AlterniA Live Pro';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('alternia_premium_code', code);
        await prefs.setBool('alternia_premium_unlocked', true);
        await prefs.setString('alternia_premium_plan', plan);

        setState(() {
          _isPremiumUnlocked = true;
          _activeCode = code;
          _activePlanName = plan;
          _isVerifyingCode = false;
        });

        _speakText(
            'Code premium validé avec succès. Bienvenue dans ton salon live AlternIA AI !');
      } else {
        setState(() {
          _isVerifyingCode = false;
          _authErrorMessage = result['message'] as String? ??
              'Code premium invalide. Vérifiez vos identifiants.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
          _authErrorMessage =
              'Erreur de connexion au serveur backend AlternIA.';
        });
      }
    }
  }

  Future<void> _lockPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alternia_premium_code');
    await prefs.remove('alternia_premium_unlocked');
    await prefs.remove('alternia_premium_plan');
    if (mounted) {
      setState(() {
        _isPremiumUnlocked = false;
        _activeCode = null;
        _activePlanName = null;
        _codeCtrl.clear();
      });
    }
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('fr-FR');
      await _flutterTts.setSpeechRate(0.48);
      // Pitch masculin plus posé et grave pour le professeur Henri
      await _flutterTts.setPitch(0.82);

      // Tenter de sélectionner une voix masculine française si présente sur le système
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
    _stopTts();
    super.deactivate();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _scrollCtrl.dispose();
    _promptCtrl.dispose();
    _codeCtrl.dispose();
    _stopTts();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _stopTts() async {
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
          : _promptCtrl.text.trim();
      setState(() {
        _isListening = false;
        _liveSpokenWords = '';
      });
      if (spoken.isNotEmpty) {
        _sendLiveQuestion(spoken);
      }
    } else {
      await _stopTts();
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
                    : _promptCtrl.text.trim();
                setState(() {
                  _isListening = false;
                  _liveSpokenWords = '';
                });
                if (spoken.isNotEmpty) {
                  _sendLiveQuestion(spoken);
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
                _promptCtrl.text = result.recognizedWords;
              });
              if (result.finalResult &&
                  result.recognizedWords.trim().isNotEmpty) {
                _speechToText.stop();
                setState(() {
                  _isListening = false;
                  _liveSpokenWords = '';
                });
                _sendLiveQuestion(result.recognizedWords.trim());
              }
            }
          },
        );
      } else {
        // Fallback simulation si microphone/reconnaissance non supporté sur émulateur
        Timer(const Duration(seconds: 3), () {
          if (mounted && _isListening) {
            setState(() {
              _isListening = false;
              _liveSpokenWords = '';
            });
            _sendLiveQuestion(
                'Explique-moi le théorème de Pythagore avec un exemple concret.');
          }
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

  Future<void> _speakText(String text) async {
    // 1. Récupération préalable de l'audio TTS Henri haute fidélité
    Uint8List? audioBytes;
    try {
      audioBytes = await _geminiService.fetchBackendTtsAudio(
        text: text,
        voice: 'henri',
      );
    } catch (_) {}

    if (!mounted) return;

    // 2. Affichage simultané de la réponse textuelle et démarrage de la voix
    setState(() {
      _avatarState = AvatarState.speaking;
      _transcript.add(_SalonMessage(
        sender: 'Professeur Henri (AlternIA)',
        text: text,
        isUser: false,
        timestamp: 'Maintenant',
      ));
    });
    _scrollToBottom();

    if (audioBytes != null && audioBytes.isNotEmpty) {
      try {
        await GeminiService.playAudioBytes(_audioPlayer, audioBytes);
        return;
      } catch (_) {}
    }

    try {
      await _flutterTts.speak(text);
    } catch (_) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _avatarState = AvatarState.idle);
      });
    }
  }

  Future<void> _sendLiveQuestion(String userQuery) async {
    if (userQuery.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    await _stopTts();

    setState(() {
      _avatarState = AvatarState.thinking;
      _transcript.add(_SalonMessage(
        sender: 'Élève',
        text: userQuery.trim(),
        isUser: true,
        timestamp: 'Maintenant',
      ));
    });
    _promptCtrl.clear();
    _scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentName = prefs.getString('det_user_name') ?? 'Élève';
      final studentClass = prefs.getString('det_user_class_id') ?? '11eme';

      // 1. Calcul du texte didactique de réponse (non affiché tant que la vidéo n'est pas prête)
      final reply = await _geminiService.generateTeacherChatResponse(
        [
          {'role': 'user', 'text': userQuery.trim()}
        ],
        studentName: studentName,
        studentClass: studentClass,
      );

      final cleanReply = reply.replaceAll('*', '');

      // 2. Affichage immédiat du texte et animation vocale de l'avatar photoréaliste
      setState(() {
        _currentVideoUrl = null;
        _avatarState = AvatarState.speaking;
        _transcript.add(_SalonMessage(
          sender: 'Professeur Henri (AlternIA)',
          text: cleanReply,
          isUser: false,
          timestamp: 'Maintenant',
        ));
      });
      _scrollToBottom();

      // 3. Audio instantané (TTS Henri serveur ou FlutterTTS local si hors-ligne)
      bool audioStarted = false;
      try {
        final audioBytes = await _geminiService.fetchBackendTtsAudio(
          text: cleanReply,
          voice: 'henri',
        );
        if (audioBytes != null && audioBytes.isNotEmpty && mounted) {
          await GeminiService.playAudioBytes(_audioPlayer, audioBytes);
          audioStarted = true;
        }
      } catch (_) {}

      if (!audioStarted && mounted) {
        try {
          await _flutterTts.speak(cleanReply);
        } catch (_) {}
      }

      // 4. Génération vidéo Simli en tâche de fond (non bloquante)
      _geminiService.generateAlternIAAvatarVideo(
        text: cleanReply,
        voice: 'henri',
      ).then((videoUrl) {
        if (mounted && videoUrl != null && videoUrl.isNotEmpty) {
          setState(() {
            _currentVideoUrl = videoUrl;
          });
        }
      }).catchError((_) {});
    } catch (_) {
      if (mounted) {
        setState(() {
          _avatarState = AvatarState.speaking;
          _transcript.add(const _SalonMessage(
            sender: 'Professeur Henri (AlternIA)',
            text:
                'Je suis à ton écoute. Pose-moi une question sur le programme malien pour que je puisse t\'aider !',
            isUser: false,
            timestamp: 'Maintenant',
          ));
        });
        _scrollToBottom();
        await _flutterTts.speak(
            'Je suis à ton écoute. Pose-moi une question sur le programme malien pour que je puisse t\'aider !');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: textPri, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'SALON LIVE AlternIA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 1.0,
                  ),
                ),
                if (_isPremiumUnlocked) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PREMIUM ACTIF',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              'Professeur Particulier en Direct',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
          ],
        ),
        actions: [
          if (_isPremiumUnlocked)
            IconButton(
              tooltip: 'Verrouiller / Changer de code',
              icon: const Icon(Icons.lock_open_rounded,
                  color: AppColors.secondary, size: 20),
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showAccountStatusDialog(context);
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF080D1A),
                    Color(0xFF0F172A),
                    Color(0xFF131D33),
                  ]
                : const [
                    Color(0xFFF0F4FF),
                    Color(0xFFF8FAFC),
                    Color(0xFFEEF2F9),
                  ],
          ),
        ),
        child: SafeArea(
          child: _isLoadingAuth
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary))
              : (!_isPremiumUnlocked
                  ? _buildPremiumGateView(isDark)
                  : _buildLiveSalonView(isDark)),
        ),
      ),
    );
  }

  // ── 1. ÉCRAN DE VERROUILLAGE / CODE PREMIUM (ADAPTATIF LIGHT & DARK) ──────
  Widget _buildPremiumGateView(bool isDark) {
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderCol =
        isDark ? const Color(0xFF263554) : const Color(0xFFCBD5E1);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône bouclier doré holographique avec halo lumineux
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFF1851F), Color(0xFF314999)],
                  center: Alignment(-0.2, -0.2),
                  radius: 0.9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF1851F)
                        .withValues(alpha: isDark ? 0.45 : 0.35),
                    blurRadius: 36,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.3 : 0.6),
                  width: 2.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 46,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'Activation du Salon Live AlternIA',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textPri,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'La conversation live avec l\'Avatar AlternIA HD requiert un code de compte premium validé par votre établissement ou votre boîtier AlterniA.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: textSec,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 26),

            // Carte formulaire avec dégradé et élévation premium
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [
                          Color(0xFF162035),
                          Color(0xFF0D1527),
                        ]
                      : const [
                          Colors.white,
                          Color(0xFFF8FAFC),
                        ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderCol, width: 1.3),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.45)
                        : const Color(0xFF314999).withValues(alpha: 0.09),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.vpn_key_rounded,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CODE DE COMPTE OU ÉTABLISSEMENT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textPri,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ex: ML-BKO-0042, ALT-BOX-2026-001',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: textSec.withValues(alpha: 0.65),
                      ),
                      prefixIcon: const Icon(
                        Icons.key_rounded,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0B1120)
                          : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderCol),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderCol),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.secondary, width: 1.8),
                      ),
                    ),
                    onSubmitted: (_) => _verifyEnteredCode(),
                  ),
                  if (_authErrorMessage != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Colors.redAccent, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _authErrorMessage!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Bouton avec dégradé officiel AlterniA
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF314999), Color(0xFF223675)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF314999).withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isVerifyingCode ? null : _verifyEnteredCode,
                        child: Center(
                          child: _isVerifyingCode
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.2),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Vérifier et Débloquer AlternIA Live',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded,
                                        color: Colors.white, size: 17),
                                  ],
                                ),
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
    );
  }

  // ── 2. ÉCRAN PRINCIPAL DU SALON LIVE DÉBLOQUÉ ─────────────────────────────
  Widget _buildLiveSalonView(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 12),

        // Avatar Interactif AlterniA (ou Vidéo Photoréaliste si disponible)
        if (_currentVideoUrl != null && _currentVideoUrl!.isNotEmpty)
          AlterniaVideoPlayer(
            videoUrl: _currentVideoUrl!,
            fallbackImagePath: 'assets/images/avatar_prof.png',
            onTap: () => _sendLiveQuestion('Explique-moi les principes essentiels du cours.'),
            onError: () {
              if (mounted) setState(() => _currentVideoUrl = null);
            },
            onCompleted: () {
              if (mounted) {
                setState(() {
                  _currentVideoUrl = null;
                  _avatarState = AvatarState.idle;
                });
              }
            },
          )
        else
          AlterniaAvatar(
            size: 150,
            state: _avatarState,
            imagePath: 'assets/images/avatar_prof.png',
            onTap: () => _sendLiveQuestion(
                'Explique-moi les principes essentiels du cours.'),
          ),

        const SizedBox(height: 10),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _avatarState == AvatarState.thinking
              ? Container(
                  key: const ValueKey('thinking_badge'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Le Professeur prépare sa réponse...',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  key: ValueKey(_avatarState),
                  _avatarState == AvatarState.speaking
                      ? 'Le Professeur Henri s\'exprime...'
                      : 'Touche l\'Avatar ou écris ta question ci-dessous',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),

        const SizedBox(height: 10),
        const Divider(color: AppColors.border, height: 1),

        // Transcription de la discussion
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.subtitles_rounded,
                  color: AppColors.secondary, size: 16),
              const SizedBox(width: 6),
              Text(
                'TRANSCRIPTION DE LA DISCUSSION LIVE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _transcript.length,
            itemBuilder: (context, i) {
              final msg = _transcript[i];
              return _TranscriptBubble(message: msg);
            },
          ),
        ),

        // Barre de saisie question live & Microphone 1-clic
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
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
                              : 'Écoute en direct... Parlez maintenant, touchez pour envoyer',
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
                        color: isDark ? const Color(0xFF141B2D) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _isListening
                              ? Colors.redAccent
                              : (isDark
                                  ? AppColors.border
                                  : const Color(0xFFCBD5E1)),
                          width: 1.2,
                        ),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      child: TextField(
                        controller: _promptCtrl,
                        cursorColor: isDark ? Colors.white : Colors.black,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? 'Transcription en direct...'
                              : 'Pose une question à ton professeur...',
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
                        onSubmitted: (val) => _sendLiveQuestion(val),
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
                            : const Color(0xFF314999),
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
                  // Bouton Envoi
                  GestureDetector(
                    onTap: () => _sendLiveQuestion(_promptCtrl.text),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
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
      ],
    );
  }

  void _showAccountStatusDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Statut de votre compte',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code actif : ${_activeCode ?? "N/A"}'),
            const SizedBox(height: 6),
            Text('Offre : ${_activePlanName ?? "AlterniA Live Pro"}'),
            const SizedBox(height: 6),
            const Text('Accès AlternIA AI : Illimité'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              _lockPremium();
            },
            child: const Text('Déconnecter le code',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SalonMessage {
  const _SalonMessage({
    required this.sender,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String sender;
  final String text;
  final bool isUser;
  final String timestamp;
}

class _TranscriptBubble extends StatelessWidget {
  const _TranscriptBubble({required this.message});

  final _SalonMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment:
            message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: message.isUser
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: message.isUser ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    message.isUser
                        ? Icons.person_rounded
                        : Icons.smart_toy_rounded,
                    size: 14,
                    color:
                        message.isUser ? AppColors.secondary : AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    message.sender,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: message.isUser
                          ? AppColors.secondary
                          : AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message.timestamp,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                message.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
