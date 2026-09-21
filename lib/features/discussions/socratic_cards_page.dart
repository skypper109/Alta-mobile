library;

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/constants.dart';
import '../../core/gemini_service.dart';
import '../../shared/widgets.dart';
import '../profile/user_prefs_notifier.dart';
import 'subject_chat_provider.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MODÈLES DE MESSAGES & SESSIONS
// ══════════════════════════════════════════════════════════════════════════════

class ChatMessage {
  ChatMessage({
    required this.isUser,
    required this.text,
    required this.timestamp,
  }) : id = DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;
}

class DiscussionSession {
  DiscussionSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
  });

  final String id;
  String title;
  final List<ChatMessage> messages;
  DateTime updatedAt;
}

// ══════════════════════════════════════════════════════════════════════════════
// PAGE PRINCIPALE (DISCUSSIONS)
// ══════════════════════════════════════════════════════════════════════════════

class SocraticCardsPage extends ConsumerStatefulWidget {
  const SocraticCardsPage({super.key});

  @override
  ConsumerState<SocraticCardsPage> createState() => _SocraticCardsPageState();
}

class _SocraticCardsPageState extends ConsumerState<SocraticCardsPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _promptCtrl = TextEditingController();
  late final AnimationController _avatarCtrl;
  late final AnimationController _waveCtrl;
  late final AnimationController _recordPulseCtrl; // cercles pulsants micro

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isLoading = false;
  bool _isRecording = false;
  String? _currentlySpeakingText;
  String? _regeneratingMsgId; // id du message en cours de régénération

  late DiscussionSession _currentSession;
  List<DiscussionSession> _sessionsHistory = [];
  String? _loadedSubject;

  @override
  void initState() {
    super.initState();
    _avatarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _recordPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _initAudioServices();

    _promptCtrl.addListener(() {
      if (mounted) setState(() {});
    });

    _createNewDiscussionSession(
      initialTopic: 'Nouvelle discussion avec AlterniA',
      autoFetch: false,
    );
  }

  Future<void> _initAudioServices() async {
    try {
      await _flutterTts.setLanguage('fr-FR');
      await _flutterTts.setSpeechRate(0.5);
      _flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => _currentlySpeakingText = null);
      });
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _currentlySpeakingText = null);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _promptCtrl.dispose();
    _avatarCtrl.dispose();
    _waveCtrl.dispose();
    _recordPulseCtrl.dispose();
    _safeStopTts();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _safeStopTts() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  Future<void> _switchSubject(String? subject) async {
    final sessions = await SubjectChatHistoryManager.loadSessions(subject);
    if (mounted) {
      if (sessions.isNotEmpty) {
        setState(() {
          _sessionsHistory = sessions;
          _currentSession = sessions.first;
        });
      } else {
        final title = subject != null ? 'Discussion en $subject' : 'Nouvelle discussion avec AlterniA';
        final fresh = DiscussionSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          messages: [],
          updatedAt: DateTime.now(),
        );
        setState(() {
          _sessionsHistory = [fresh];
          _currentSession = fresh;
        });
      }
    }
  }

  void _createNewDiscussionSession(
      {String? initialTopic, bool autoFetch = false}) {
    final activeSubject = ref.read(activeSubjectProvider);
    final title = initialTopic ?? (activeSubject != null ? 'Discussion en $activeSubject' : 'Nouvelle discussion avec AlterniA');
    final session = DiscussionSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      messages: [],
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentSession = session;
      _sessionsHistory.insert(0, session);
    });

    if (autoFetch && initialTopic != null) {
      _sendMessageToProf(initialTopic);
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

  // ── Speech-To-Text (Reconnaissance Vocale Directe) ─────────────────────────
  Future<void> _toggleVocalRecording() async {
    HapticFeedback.heavyImpact();

    if (_isRecording) {
      _speechToText.stop();
      setState(() => _isRecording = false);
      if (_promptCtrl.text.isNotEmpty) {
        _sendMessageToProf(_promptCtrl.text);
      }
    } else {
      bool available = false;
      try {
        available = await _speechToText.initialize();
      } catch (_) {}

      setState(() => _isRecording = true);

      if (available) {
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _promptCtrl.text = result.recognizedWords;
            });
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              setState(() => _isRecording = false);
              _sendMessageToProf(result.recognizedWords);
            }
          },
        );
      } else {
        // Simulation si speech_to_text non supporté sur émulateur
        Timer(const Duration(seconds: 3), () {
          if (mounted && _isRecording) {
            setState(() => _isRecording = false);
            _sendMessageToProf(
                'Explique-moi une notion importante de mon programme');
          }
        });
      }
    }
  }

  // ── Text-To-Speech (Lecture Vocale de la réponse du Professeur via Backend AlternIA) ────
  Future<void> _toggleSpeakMessage(String text) async {
    HapticFeedback.lightImpact();
    if (_currentlySpeakingText == text) {
      await _safeStopTts();
      setState(() => _currentlySpeakingText = null);
    } else {
      await _safeStopTts();
      setState(() => _currentlySpeakingText = text);
      final cleanText = _cleanMarkdownFormatting(text);

      try {
        // 1. Tenter la synthèse vocale neurale haute fidélité du serveur AlternIA (/api/tts)
        final gemini = GeminiService();
        final audioBytes = await gemini.fetchBackendTtsAudio(text: cleanText);
        if (audioBytes != null && audioBytes.isNotEmpty) {
          await _audioPlayer.play(BytesSource(audioBytes));
          return;
        }
      } catch (_) {}

      // 2. Fallback transparent sur le moteur TTS local si serveur hors-ligne
      try {
        await _flutterTts.speak(cleanText);
      } catch (_) {
        if (mounted) setState(() => _currentlySpeakingText = null);
      }
    }
  }

  Future<void> _sendMessageToProf(String userText) async {
    if (userText.trim().isEmpty) return;

    if (mounted) {
      try {
        FocusScope.of(context).unfocus();
      } catch (_) {}
    }
    HapticFeedback.mediumImpact();

    final query = userText.trim();
    _promptCtrl.clear();

    setState(() {
      _currentSession.messages.add(ChatMessage(
        isUser: true,
        text: query,
        timestamp: DateTime.now(),
      ));
      if (_currentSession.messages.length == 1) {
        _currentSession.title = query;
      }
      _currentSession.updatedAt = DateTime.now();
      _isLoading = true;
    });

    _scrollToBottom();

    final geminiHistory = _currentSession.messages.map((m) {
      return {
        'role': m.isUser ? 'user' : 'model',
        'text': m.text,
      };
    }).toList();

    final activeSubject = ref.read(activeSubjectProvider);
    final userPrefs = ref.read(userPrefsProvider);

    try {
      final gemini = GeminiService();
      final responseText = await gemini.generateTeacherChatResponse(
        geminiHistory,
        subject: activeSubject,
        studentName: userPrefs.name,
        studentClass: userPrefs.studentClassId,
      );

      setState(() {
        _currentSession.messages.add(ChatMessage(
          isUser: false,
          text: responseText,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _scrollToBottom();
      await SubjectChatHistoryManager.saveSingleSession(activeSubject, _currentSession);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _loadSession(DiscussionSession session) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();

    setState(() {
      _currentSession = session;
    });

    _scrollToBottom();
  }

  // ── Supprimer une session d'historique ───────────────────────────────────────
  Future<void> _deleteSession(DiscussionSession session, [StateSetter? setSheetState]) async {
    HapticFeedback.mediumImpact();
    final activeSubject = ref.read(activeSubjectProvider);
    await SubjectChatHistoryManager.deleteSession(activeSubject, session.id);

    setState(() {
      _sessionsHistory.removeWhere((s) => s.id == session.id);
      if (_currentSession.id == session.id) {
        if (_sessionsHistory.isNotEmpty) {
          _currentSession = _sessionsHistory.first;
        } else {
          final title = activeSubject != null
              ? 'Discussion en $activeSubject'
              : 'Nouvelle discussion avec AlterniA';
          final fresh = DiscussionSession(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            messages: [],
            updatedAt: DateTime.now(),
          );
          _sessionsHistory = [fresh];
          _currentSession = fresh;
        }
      }
    });

    if (setSheetState != null) {
      setSheetState(() {});
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Discussion supprimée',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: DetColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _confirmDeleteSession(DiscussionSession session, [StateSetter? setSheetState]) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Supprimer la conversation ?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Cette action supprimera définitivement cette discussion de votre historique.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: Text(
              'Annuler',
              style: GoogleFonts.plusJakartaSans(color: DetColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dlgCtx).pop();
              _deleteSession(session, setSheetState);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DetColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Supprimer',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Supprimer un message du fil ─────────────────────────────────────────────
  void _deleteMessage(ChatMessage msg) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentSession.messages.removeWhere((m) => m.id == msg.id);
    });
  }

  // ── Régénérer la réponse du Professeur pour une question utilisateur ─────────
  Future<void> _regenerateResponseFor(ChatMessage userMsg) async {
    final idx = _currentSession.messages.indexOf(userMsg);
    if (idx < 0) return;

    HapticFeedback.mediumImpact();

    // Supprime tous les messages après cette question (réponses précédentes)
    setState(() {
      _regeneratingMsgId = userMsg.id;
      _isLoading = true;
      _currentSession.messages
          .removeRange(idx + 1, _currentSession.messages.length);
    });

    final geminiHistory = _currentSession.messages
        .take(idx + 1)
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.text,
            })
        .toList();

    final activeSubject = ref.read(activeSubjectProvider);
    final userPrefs = ref.read(userPrefsProvider);

    try {
      final gemini = GeminiService();
      final responseText = await gemini.generateTeacherChatResponse(
        geminiHistory,
        subject: activeSubject,
        studentName: userPrefs.name,
        studentClass: userPrefs.studentClassId,
      );

      setState(() {
        _currentSession.messages.add(ChatMessage(
          isUser: false,
          text: responseText,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
        _regeneratingMsgId = null;
      });

      _scrollToBottom();
      await SubjectChatHistoryManager.saveSingleSession(activeSubject, _currentSession);
    } catch (_) {
      setState(() {
        _isLoading = false;
        _regeneratingMsgId = null;
      });
    }
  }

  // ── Renvoyer un message utilisateur ──────────────────────────────────────────
  void _resendMessage(ChatMessage msg) {
    if (!msg.isUser) return;
    _regenerateResponseFor(msg);
  }

  void _showHistoryModal() {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modalBg = isDark ? DetColors.surface : Colors.white;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? DetColors.textSecondary : const Color(0xFF475569);
    final borderCol = isDark ? DetColors.border : const Color(0xFFE2E8F0);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: modalBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderCol,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(DetSizes.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Historique des Discussions',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPri,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ref.read(activeSubjectProvider) != null
                                    ? 'Matière : ${ref.read(activeSubjectProvider)}'
                                    : 'Toutes les matières (Général)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: textSec,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: DetSizes.sm),
                        DetButton(
                          label: 'Nouveau',
                          icon: Icons.add_rounded,
                          isFullWidth: false,
                          variant: DetButtonVariant.secondary,
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _createNewDiscussionSession();
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(color: borderCol, height: 1),
                  Expanded(
                    child: _sessionsHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.forum_outlined,
                                  size: 48,
                                  color: textSec.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Aucune discussion enregistrée',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textSec,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(DetSizes.lg),
                            itemCount: _sessionsHistory.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: DetSizes.md),
                            itemBuilder: (context, idx) {
                              final sess = _sessionsHistory[idx];
                              final isSelected = sess.id == _currentSession.id;
                              final lastMsg = sess.messages.isNotEmpty
                                  ? _cleanMarkdownFormatting(
                                      sess.messages.last.text)
                                  : 'Nouvelle discussion';

                              return Dismissible(
                                key: ValueKey(sess.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) async {
                                  _confirmDeleteSession(sess, setSheetState);
                                  return false;
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: DetColors.error.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete_forever_rounded,
                                    color: DetColors.error,
                                    size: 24,
                                  ),
                                ),
                                child: DetCard(
                                  onTap: () => _loadSession(sess),
                                  backgroundColor: isSelected
                                      ? (isDark
                                          ? DetColors.surfaceAlt
                                          : const Color(0xFFF1F5F9))
                                      : (isDark
                                          ? DetColors.surface
                                          : Colors.white),
                                  borderColor: isSelected
                                      ? DetColors.primary
                                      : borderCol,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${sess.messages.length} message(s)',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: DetColors.primary,
                                                ),
                                              ),
                                              if (isSelected) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: DetColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    'EN COURS',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          // Bouton de suppression directe de la conversation
                                          GestureDetector(
                                            onTap: () => _confirmDeleteSession(
                                                sess, setSheetState),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: DetColors.error
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 16,
                                                color: DetColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        sess.title,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textPri,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lastMsg,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: textSec,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userPrefs = ref.watch(userPrefsProvider);
    final activeSubject = ref.watch(activeSubjectProvider);

    // Synchronisation automatique de l'historique lors du changement de matière
    if (_loadedSubject != activeSubject) {
      _loadedSubject = activeSubject;
      Future.microtask(() => _switchSubject(activeSubject));
    }

    final malianClass = userPrefs.malianClass;
    final suggestedQuestions = malianClass?.suggestedQuestions ??
        [
          'Explique-moi une notion de mon programme.',
          'Comment résoudre cet exercice step by step ?',
        ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Sous-titre Discussions & Boutons Actions ───────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'TUTEUR PÉDAGOGIQUE IA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AltaColors.secondary : AltaColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _showHistoryModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? DetColors.surfaceAlt : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? DetColors.border : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: isDark ? AltaColors.secondary : const Color(0xFF0E7490),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Historique',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AltaColors.secondary : const Color(0xFF0E7490),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _createNewDiscussionSession(
                    initialTopic: 'Nouvelle discussion avec AlterniA',
                    autoFetch: false,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isDark ? DetColors.surfaceAlt : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? DetColors.border : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 15,
                      color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),

            // ── 2. SÉLECTEUR HORIZONTAL DES MATIÈRES (FILTRE STRICT) ────────
            Container(
              height: 44,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Option Toutes les matières
                  _buildSubjectChip(
                    label: 'Toutes',
                    icon: Icons.all_inclusive_rounded,
                    isSelected: activeSubject == null,
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(activeSubjectProvider.notifier).state = null;
                    },
                  ),
                  const SizedBox(width: 8),
                  // Matières de la classe de l'élève
                  ...userPrefs.subjects.map((sub) {
                    final isSel = activeSubject == sub;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildSubjectChip(
                        label: sub,
                        icon: _getSubjectIcon(sub),
                        isSelected: isSel,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(activeSubjectProvider.notifier).state = sub;
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Indicateur compact de session active (si messages présents)
            if (_currentSession.messages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 12,
                      color: isDark ? AltaColors.secondary : AltaColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _currentSession.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'EN LIGNE',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── 2. FIL DE DISCUSSION CONTINU OU EMPTY STATE AÉRÉ ─────────────
            Expanded(
              child: _currentSession.messages.isEmpty && !_isLoading
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // Orbe lumineux AlterniA IA
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF314999), Color(0xFF40BBCC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF314999).withValues(alpha: 0.35),
                                  blurRadius: 22,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Bonjour ! Que révisons-nous ?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Pose une question ou choisis une suggestion ci-dessous :',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          // Cartes de suggestions élégantes et aérées
                          for (int i = 0; i < suggestedQuestions.take(4).length; i++) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _sendMessageToProf(suggestedQuestions[i]),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? DetColors.surfaceAlt : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark ? DetColors.border : const Color(0xFFE2E8F0),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: (i % 2 == 0 ? AltaColors.primary : AltaColors.accent).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            i % 2 == 0 ? Icons.lightbulb_outline_rounded : Icons.help_outline_rounded,
                                            size: 16,
                                            color: i % 2 == 0 ? AltaColors.primary : AltaColors.accent,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            suggestedQuestions[i],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 12,
                                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: _currentSession.messages.length +
                          (_isLoading ? 1 : 0),
                      itemBuilder: (context, idx) {
                        if (idx == _currentSession.messages.length &&
                            _isLoading) {
                          return const Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: DetSizes.md),
                              child: DetLoading(
                                message:
                                    'AlterniA formule sa réponse…',
                              ),
                          );
                        }

                        final msg = _currentSession.messages[idx];
                        final isSpeaking = _currentlySpeakingText == msg.text;
                        final isRegenerating = _regeneratingMsgId == msg.id;

                        return _ChatMessageWidget(
                          message: msg,
                          isSpeaking: isSpeaking,
                          isRegenerating: isRegenerating,
                          onSpeakTap: () => _toggleSpeakMessage(msg.text),
                          onDelete: () => _deleteMessage(msg),
                          onResend:
                              msg.isUser ? () => _resendMessage(msg) : null,
                          onRegenerate: !msg.isUser
                              ? () => _regenerateResponseFor(
                                    _currentSession.messages
                                            .where((m) => m.isUser)
                                            .lastOrNull ??
                                        msg,
                                  )
                              : null,
                        );
                      },
                    ),
            ),

            // ── 3. CONSOLE DE SAISIE STYLÉE & ÉPURÉE ───────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Suggestions de relance uniquement pendant une discussion active
                  if (_currentSession.messages.isNotEmpty) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: suggestedQuestions.take(3).map((q) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8),
                            child: _QuickQuestionChip(
                              label: q,
                              onTap: () => _sendMessageToProf(q),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // Boîte de saisie IA moderne style ChatGPT
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? DetColors.error.withValues(alpha: 0.1)
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _isRecording
                            ? DetColors.error
                            : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0)),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : const Color(0xFF314999))
                              .withValues(alpha: isDark ? 0.35 : 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isRecording
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _recordPulseCtrl,
                                builder: (_, __) {
                                  final pulse = _recordPulseCtrl.value;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 3),
                                          width: 5,
                                          height: 8 + ((pulse + i * 0.2) % 1.0) * 16,
                                          decoration: BoxDecoration(
                                            color: DetColors.error.withValues(
                                              alpha: 0.4 + ((pulse + i * 0.15) % 1.0) * 0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.graphic_eq_rounded, color: DetColors.error, size: 20),
                                      const SizedBox(width: 8),
                                      for (int i = 4; i >= 0; i--)
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 3),
                                          width: 5,
                                          height: 8 + ((pulse + i * 0.2) % 1.0) * 16,
                                          decoration: BoxDecoration(
                                            color: DetColors.error.withValues(
                                              alpha: 0.4 + ((pulse + i * 0.15) % 1.0) * 0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'En écoute… Parle maintenant',
                                    style: DetTextStyles.caption.copyWith(
                                      color: DetColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: _toggleVocalRecording,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: DetColors.error,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'STOP',
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promptCtrl,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    height: 1.3,
                                  ),
                                  maxLines: 4,
                                  minLines: 1,
                                  textCapitalization: TextCapitalization.sentences,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: 'Pose ta question à AlterniA…',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: _toggleVocalRecording,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.mic_rounded,
                                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                    size: 21,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  if (_promptCtrl.text.trim().isNotEmpty) {
                                    _sendMessageToProf(_promptCtrl.text);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: _promptCtrl.text.trim().isNotEmpty
                                        ? const LinearGradient(
                                            colors: [AltaColors.primary, AltaColors.secondary],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: _promptCtrl.text.trim().isNotEmpty
                                        ? null
                                        : (isDark ? const Color(0xFF23314D) : const Color(0xFFF1F5F9)),
                                    boxShadow: _promptCtrl.text.trim().isNotEmpty
                                        ? [
                                            BoxShadow(
                                              color: AltaColors.primary.withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    Icons.arrow_upward_rounded,
                                    color: _promptCtrl.text.trim().isNotEmpty
                                        ? Colors.white
                                        : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildSubjectChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? DetColors.primary
              : (isDark ? DetColors.surfaceAlt : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? DetColors.primary
                : (isDark ? DetColors.border : const Color(0xFFE2E8F0)),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DetColors.primary.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AltaColors.secondary : const Color(0xFF0E7490)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return Icons.calculate_rounded;
    if (s.contains('phys') || s.contains('chim')) return Icons.science_rounded;
    if (s.contains('bio') || s.contains('svt') || s.contains('scien')) return Icons.biotech_rounded;
    if (s.contains('franc') || s.contains('litt')) return Icons.auto_stories_rounded;
    if (s.contains('hist') || s.contains('geo')) return Icons.history_edu_rounded;
    if (s.contains('angl') || s.contains('lang')) return Icons.language_rounded;
    if (s.contains('philo')) return Icons.psychology_rounded;
    if (s.contains('eco')) return Icons.balance_rounded;
    return Icons.school_rounded;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NETTOYAGE FORMATTAGE MARKDOWN (AUCUNE ÉTOILE **, HASHTAG # BRUT)
// ══════════════════════════════════════════════════════════════════════════════

String _cleanMarkdownFormatting(String rawText) {
  return rawText
      .replaceAll('**', '')
      .replaceAll('*', '')
      .replaceAll('###', '')
      .replaceAll('##', '')
      .replaceAll('#', '')
      .replaceAll('`', '')
      .trim();
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPOSANT BULLE DE MESSAGE AVEC LECTURE VOCALE (TTS) & FORMATTAGE CLEAN
// ══════════════════════════════════════════════════════════════════════════════

class _ChatMessageWidget extends StatelessWidget {
  const _ChatMessageWidget({
    required this.message,
    required this.isSpeaking,
    required this.isRegenerating,
    required this.onSpeakTap,
    required this.onDelete,
    this.onResend,
    this.onRegenerate,
  });

  final ChatMessage message;
  final bool isSpeaking;
  final bool isRegenerating;
  final VoidCallback onSpeakTap;
  final VoidCallback onDelete;
  final VoidCallback? onResend;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;
    final time =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // ── Badge auteur + heure ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Icon(
                  isUser ? Icons.person_rounded : Icons.auto_awesome_rounded,
                  size: 12,
                  color: isUser ? AltaColors.primary : AltaColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  isUser ? 'VOUS' : 'PROF. ALTERNIA',
                  style: DetTextStyles.caption.copyWith(
                    color: isUser ? AltaColors.primary : AltaColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: DetTextStyles.caption.copyWith(
                    color: DetColors.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          // ── Bulle de message ──────────────────────────────────────────────
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.86),
            padding: const EdgeInsets.symmetric(
                horizontal: DetSizes.md, vertical: DetSizes.md),
            decoration: BoxDecoration(
              color: isUser
                  ? AltaColors.primary.withValues(alpha: isDark ? 0.18 : 0.12)
                  : (isDark ? DetColors.surfaceAlt : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
              border: Border.all(
                color: isUser
                    ? AltaColors.primary.withValues(alpha: isDark ? 0.4 : 0.25)
                    : (isDark ? DetColors.border : const Color(0xFFE2E8F0)),
                width: 1,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: _FormattedResponseView(
              text: message.text,
              isUser: isUser,
            ),
          ),

          // ── Barre d'actions contextuelle ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                // Écouter TTS (réponse prof uniquement)
                if (!isUser) ...[
                  _ActionPill(
                    icon: isSpeaking
                        ? Icons.stop_rounded
                        : Icons.volume_up_rounded,
                    label: isSpeaking ? 'STOP' : 'ÉCOUTER',
                    color:
                        isSpeaking ? DetColors.accentGreen : DetColors.primary,
                    onTap: onSpeakTap,
                  ),
                  const SizedBox(width: 6),
                ],

                // Renvoyer/Régénérer
                if (isUser && onResend != null) ...[
                  _ActionPill(
                    icon: Icons.refresh_rounded,
                    label: 'RENVOYER',
                    color: DetColors.accentAmber,
                    onTap: onResend!,
                  ),
                  const SizedBox(width: 6),
                ],

                if (!isUser && onRegenerate != null) ...[
                  _ActionPill(
                    icon: Icons.autorenew_rounded,
                    label: isRegenerating ? 'EN COURS…' : 'RÉGÉNÉRER',
                    color: DetColors.accentAmber,
                    onTap: isRegenerating ? () {} : onRegenerate!,
                  ),
                  const SizedBox(width: 6),
                ],

                // Supprimer
                _ActionPill(
                  icon: Icons.delete_outline_rounded,
                  label: 'SUPPR.',
                  color: DetColors.error,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pilule d'action contextuelle réutilisable ────────────────────────────────
class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: DetTextStyles.caption.copyWith(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickQuestionChip extends StatelessWidget {
  const _QuickQuestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? DetColors.surfaceAlt : const Color(0xFFF1F5F9),
          borderRadius: DetSizes.borderRadiusSm,
          border: Border.all(
            color: isDark ? DetColors.border : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? DetColors.textSecondary : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPOSANT D'AFFICHAGE ET COLORATION DES PARTIES IMPORTANTES & GRAS
// ══════════════════════════════════════════════════════════════════════════════

class _FormattedResponseView extends StatelessWidget {
  const _FormattedResponseView({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);

    if (isUser) {
      final cleanText = _cleanMarkdownFormatting(text);
      return Text(
        cleanText,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14.5,
          height: 1.65,
          fontWeight: FontWeight.w500,
          color: textPri,
        ),
      );
    }

    final lines = text.split('\n');
    final List<Widget> children = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final upper = line.toUpperCase();

      // 1. BLOC ENCADRÉ ET COLORÉ POUR RÈGLE CLÉ / FORMULE / À RETENIR / CONSEIL
      if (upper.contains('RÈGLE CLÉ') ||
          upper.contains('REGLE CLE') ||
          upper.contains('FORMULE') ||
          upper.contains('À RETENIR') ||
          upper.contains('A RETENIR') ||
          upper.contains('CONSEIL PRATIQUE')) {
        final cleanLine = _cleanMarkdownFormatting(line);
        children.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DetColors.accentAmber.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DetColors.accentAmber, width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.star_rounded,
                    color: DetColors.accentAmber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cleanLine,
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? DetColors.accentAmber : const Color(0xFFB45309),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // 2. BLOC ENCADRÉ ET COLORÉ POUR EXEMPLE CONCRET / EXEMPLE
      else if (upper.contains('EXEMPLE CONCRET') ||
          upper.contains('EXEMPLE') ||
          upper.contains('DANS LA VIE COURANTE')) {
        final cleanLine = _cleanMarkdownFormatting(line);
        children.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DetColors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: DetColors.primary.withValues(alpha: isDark ? 0.8 : 0.4), width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: DetColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cleanLine,
                    style: GoogleFonts.plusJakartaSans(
                      color: textPri,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // 3. BLOC DE REFUS POLI HORS PROGRAMME / DÉSOLÉ
      else if (upper.contains('DÉSOLÉ') ||
          upper.contains('DESOLE') ||
          upper.contains('HORS-PROGRAMME') ||
          upper.contains('HORS PROGRAMME')) {
        final cleanLine = _cleanMarkdownFormatting(line);
        children.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DetColors.error.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DetColors.error, width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_rounded,
                    color: DetColors.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cleanLine,
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? DetColors.error : const Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // 4. LIGNE COURANTE AVEC PARSING DE TOUS LES MOTS EN GRAS EN AMBRÉ/OR BRILLANT
      else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _buildRichTextSpan(line, textPri, isDark),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildRichTextSpan(String rawLine, Color textPri, bool isDark) {
    // Nettoyer les dièses de titre s'il y en a
    String cleanStr = rawLine.replaceAll(RegExp(r'^#+\s*'), '');

    Widget? leadingIconWidget;

    // Remplacement des symboles/émojis bruts par des icônes vectorielles nettes
    if (cleanStr.startsWith('•') || cleanStr.startsWith('- ') || cleanStr.startsWith('* ')) {
      leadingIconWidget = Container(
        margin: const EdgeInsets.only(top: 8, right: 8),
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AltaColors.secondary : AltaColors.primary,
        ),
      );
      cleanStr = cleanStr.replaceFirst(RegExp(r'^[•\-\*]\s*'), '');
    } else if (cleanStr.startsWith('💡') || cleanStr.contains('Conseil Pédagogique') || cleanStr.contains('Conseil AlterniA')) {
      leadingIconWidget = const Padding(
        padding: EdgeInsets.only(top: 2, right: 6),
        child: Icon(Icons.lightbulb_rounded, color: Color(0xFFF1851F), size: 16),
      );
      cleanStr = cleanStr.replaceAll('💡', '').trim();
    } else if (cleanStr.startsWith('⚠️') || cleanStr.startsWith('Attention')) {
      leadingIconWidget = const Padding(
        padding: EdgeInsets.only(top: 2, right: 6),
        child: Icon(Icons.warning_amber_rounded, color: DetColors.accentAmber, size: 16),
      );
      cleanStr = cleanStr.replaceAll('⚠️', '').trim();
    } else if (cleanStr.startsWith('📌') || cleanStr.startsWith('Remarque')) {
      leadingIconWidget = const Padding(
        padding: EdgeInsets.only(top: 2, right: 6),
        child: Icon(Icons.push_pin_rounded, color: AltaColors.primary, size: 15),
      );
      cleanStr = cleanStr.replaceAll('📌', '').trim();
    } else if (cleanStr.startsWith('✦') || cleanStr.startsWith('✨')) {
      leadingIconWidget = const Padding(
        padding: EdgeInsets.only(top: 2, right: 6),
        child: Icon(Icons.auto_awesome_rounded, color: AltaColors.secondary, size: 15),
      );
      cleanStr = cleanStr.replaceAll(RegExp(r'[✦✨]\s*'), '').trim();
    }

    final regex = RegExp(r'\*\*(.*?)\*\*');
    final matches = regex.allMatches(cleanStr);
    final accentColor = isDark ? DetColors.accentAmber : const Color(0xFFD97706);
    const emojiFallback = ['Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji'];

    Widget textWidget;
    if (matches.isEmpty) {
      textWidget = Text(
        cleanStr,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          height: 1.55,
          color: textPri,
        ).copyWith(fontFamilyFallback: emojiFallback),
      );
    } else {
      final spans = <TextSpan>[];
      int lastEnd = 0;

      for (final m in matches) {
        if (m.start > lastEnd) {
          spans.add(TextSpan(
            text: cleanStr.substring(lastEnd, m.start),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              height: 1.55,
              color: textPri,
            ).copyWith(fontFamilyFallback: emojiFallback),
          ));
        }

        final boldWord = m.group(1) ?? '';
        spans.add(TextSpan(
          text: boldWord,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.55,
            fontWeight: FontWeight.w800,
            color: accentColor,
          ).copyWith(fontFamilyFallback: emojiFallback),
        ));

        lastEnd = m.end;
      }

      if (lastEnd < cleanStr.length) {
        spans.add(TextSpan(
          text: cleanStr.substring(lastEnd),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.55,
            color: textPri,
          ).copyWith(fontFamilyFallback: emojiFallback),
        ));
      }

      textWidget = RichText(
        text: TextSpan(children: spans),
      );
    }

    if (leadingIconWidget != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leadingIconWidget,
          Expanded(child: textWidget),
        ],
      );
    }

    return textWidget;
  }
}

