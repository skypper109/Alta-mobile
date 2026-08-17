// ─── AlterniA — Feature: Salon Holographique Live (Avatar & Fil de Conversation) ──
// Mode Interactif Vocal & Visuel avec l'Avatar AlterniA, transcript de conversation en direct,
// mimiques réelles (parole, écoute, réflexion) et retour tactile.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/gemini_service.dart';
import '../../presentation/common/widgets/alternia_avatar.dart';

class HolographicSalonPage extends StatefulWidget {
  const HolographicSalonPage({super.key});

  @override
  State<HolographicSalonPage> createState() => _HolographicSalonPageState();
}

class _HolographicSalonPageState extends State<HolographicSalonPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final ScrollController _scrollCtrl = ScrollController();
  final GeminiService _geminiService = GeminiService();

  AvatarState _avatarState = AvatarState.speaking;

  final List<_SalonMessage> _transcript = [
    const _SalonMessage(
      sender: 'AlterniA',
      text: 'Bonjour ! Je suis AlterniA, ton Tuteur Interactif. Pose-moi tes questions de cours !',
      isUser: false,
      timestamp: 'Direct',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('fr-FR');
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() => _avatarState = AvatarState.idle);
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _stopTts();
    super.dispose();
  }

  Future<void> _stopTts() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
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
    setState(() {
      _avatarState = AvatarState.speaking;
      _transcript.add(_SalonMessage(
        sender: 'AlterniA',
        text: text,
        isUser: false,
        timestamp: 'Maintenant',
      ));
    });
    _scrollToBottom();

    try {
      await _flutterTts.speak(text);
    } catch (_) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _avatarState = AvatarState.idle);
      });
    }
  }

  Future<void> _triggerVoiceInteraction() async {
    HapticFeedback.heavyImpact();
    await _stopTts();

    setState(() {
      _avatarState = AvatarState.listening;
    });

    // Simulation d'une question d'élève pour la démo interactive
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      const userQuery = 'Explique-moi les trois lois de Newton en Physique.';

      setState(() {
        _avatarState = AvatarState.thinking;
        _transcript.add(const _SalonMessage(
          sender: 'Élève',
          text: userQuery,
          isUser: true,
          timestamp: 'Maintenant',
        ));
      });
      _scrollToBottom();

      try {
        final reply = await _geminiService.generateTeacherChatResponse(
          [
            {'role': 'user', 'content': userQuery}
          ],
          studentName: 'Élève',
          studentClass: 'tse',
        );

        if (mounted) {
          final cleanReply = reply.replaceAll('*', '');
          _speakText(cleanReply);
        }
      } catch (_) {
        if (mounted) {
          _speakText('La première loi de Newton stipule que tout corps reste au repos ou en mouvement rectiligne uniforme si aucune force extérieure ne s\'exerce sur lui.');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SALON HOLOGRAPHIQUE LIVE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'Interaction Vocale & Transcriptions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
            ),
            child: Text(
              _avatarState == AvatarState.speaking
                  ? 'PAROLE'
                  : (_avatarState == AvatarState.listening ? 'ÉCOUTE' : 'PRÊT'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ── 1. AVATAR INTERACTIF ALTERNIA ───────────────────────────────
            AlterniaAvatar(
              size: 160,
              state: _avatarState,
              onTap: _triggerVoiceInteraction,
            ),

            const SizedBox(height: 14),

            Text(
              'Touche l\'Avatar ou le Micro pour parler',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 14),
            const Divider(color: AppColors.border, height: 1),

            // ── 2. TRANSCRIPTION DE LA CONVERSATION EN DIRECT ────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.subtitles_rounded, color: AppColors.secondary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'TRANSCRIPTION DE LA DISCUSSION',
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _transcript.length,
                itemBuilder: (context, i) {
                  final msg = _transcript[i];
                  return _TranscriptBubble(message: msg);
                },
              ),
            ),

            // ── 3. BOUTON VOCAL DU MICROPHONE (GRAND ICONE CIRCULAIRE PROPRE) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: GestureDetector(
                onTap: _triggerVoiceInteraction,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _avatarState == AvatarState.listening
                          ? Icons.graphic_eq_rounded
                          : Icons.mic_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: message.isUser ? AppColors.primary.withValues(alpha: 0.25) : AppColors.surface,
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
                    message.isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
                    size: 14,
                    color: message.isUser ? AppColors.secondary : AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    message.sender,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: message.isUser ? AppColors.secondary : AppColors.accent,
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
