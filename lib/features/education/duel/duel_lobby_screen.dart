// ─── AlterniA — Lobby de Duel Scolaire (Connecté IA & Matchmaking Mali) ──────
// Sélection des modes, génération de code de validation (PIN),
// matchmaking instantané par classe, classement national des lycées.
// Design officiel : zéro dégradé, zéro sticker, couleurs de la charte AlterniA.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import '../../profile/user_prefs_notifier.dart';
import 'duel_arena_screen.dart';
import 'duel_leaderboard_screen.dart';
import 'duel_model.dart';
import 'duel_service.dart';

class DuelLobbyScreen extends ConsumerStatefulWidget {
  const DuelLobbyScreen({super.key});

  @override
  ConsumerState<DuelLobbyScreen> createState() => _DuelLobbyScreenState();
}

class _DuelLobbyScreenState extends ConsumerState<DuelLobbyScreen> {
  String _selectedSubject = 'Mathématiques';
  DuelMode _selectedMode = DuelMode.vsAi;
  int _selectedQuestionCount = 5;
  bool _isOnline = false;
  bool _isCheckingConnection = true;

  @override
  void initState() {
    super.initState();
    _checkServerConnectivity();
  }

  Future<void> _checkServerConnectivity() async {
    setState(() => _isCheckingConnection = true);
    final url = await duelServiceProvider.getActiveBaseUrlFast();
    if (!mounted) return;
    setState(() {
      _isOnline = url != null;
      _isCheckingConnection = false;
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CRÉATION D'UNE SALLE AVEC CODE DE VALIDATION (PIN)
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> _handleCreateRoomWithCode(
      String playerName, String classId, int questionCount) async {
    if (!_isOnline) {
      _showOfflineNotice();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          color: Theme.of(context).brightness == Brightness.dark
              ? AltaColors.surfaceDark
              : AltaColors.surfaceLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AltaColors.secondary),
                SizedBox(height: 16),
                Text('Création du salon et génération des questions...'),
              ],
            ),
          ),
        ),
      ),
    );

    final res = await duelServiceProvider.createRoom(
      creatorName: playerName,
      classLevel: classId,
      subject: _selectedSubject,
      count: questionCount,
    );

    if (!mounted) return;
    Navigator.pop(context); // fermer dialog chargement

    if (res == null || res['room_code'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de créer la salle. Vérifie ta connexion.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final roomCode = res['room_code'].toString();
    final rawQs = (res['room']?['questions'] as List<dynamic>?) ?? [];
    final questions = rawQs
        .map((q) => DuelQuestion.fromJson(q as Map<String, dynamic>))
        .toList();

    _showRoomWaitingSheet(roomCode, playerName, classId, questions);
  }

  void _showRoomWaitingSheet(
    String roomCode,
    String playerName,
    String classId,
    List<DuelQuestion> questions,
  ) {
    Timer? pollTimer;
    String? guestName;
    bool isStarting = false;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            pollTimer ??=
                Timer.periodic(const Duration(milliseconds: 1500), (t) async {
              final status = await duelServiceProvider.getRoomStatus(roomCode);
              if (status != null &&
                  status['guest_name'] != null &&
                  status['guest_name'].toString().isNotEmpty) {
                if (guestName == null) {
                  HapticFeedback.mediumImpact();
                  setSheetState(() {
                    guestName = status['guest_name'].toString();
                  });
                }
              }
            });

            void launchArena() {
              if (isStarting) return;
              isStarting = true;
              pollTimer?.cancel();
              if (sheetCtx.mounted) Navigator.pop(sheetCtx);
              if (mounted) {
                HapticFeedback.heavyImpact();
                Navigator.push(
                  this.context,
                  MaterialPageRoute(
                    builder: (_) => DuelArenaScreen(
                      subject: _selectedSubject,
                      classLevel: classId,
                      mode: DuelMode.createRoomWithCode,
                      playerName: playerName,
                      opponentName: guestName ?? 'Ami Connecté',
                      roomCode: roomCode,
                      initialQuestions:
                          questions.isNotEmpty ? questions : null,
                      questionCount: questions.length,
                    ),
                  ),
                );
              }
            }

            final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;
            final cardBg =
                isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
            final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
            final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

            return PopScope(
              onPopInvokedWithResult: (didPop, _) {
                pollTimer?.cancel();
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: AltaColors.borderDark),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.meeting_room_rounded,
                            size: 24, color: AltaColors.secondary),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'SALON DE DUEL IA • $_selectedSubject',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: AltaColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Partage ce code à ton camarade pour qu\'il rejoigne :',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: textSec),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: roomCode));
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('Code $roomCode copié !'),
                            backgroundColor: AltaColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AltaColors.surfaceAltDark
                              : AltaColors.surfaceAltLight,
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: AltaColors.secondary, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              roomCode,
                              style: GoogleFonts.spaceMono(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3.5,
                                color: AltaColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.copy_rounded,
                                color: AltaColors.secondary, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── CARTES DES PARTICIPANTS PRÉSENTS ────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AltaColors.surfaceAltDark
                            : AltaColors.surfaceAltLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AltaColors.borderDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Participants dans le salon (${guestName != null ? 2 : 1}/2) :',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: textSec,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 14,
                                backgroundColor: AltaColors.primary,
                                child: Icon(Icons.person_rounded,
                                    size: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$playerName (Hôte)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: textPri,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Prêt 🟢',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: guestName != null
                                    ? AltaColors.secondary
                                    : Colors.grey.withValues(alpha: 0.3),
                                child: Icon(
                                  guestName != null
                                      ? Icons.person_rounded
                                      : Icons.hourglass_top_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  guestName != null
                                      ? guestName!
                                      : 'En attente d\'un camarade...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: guestName != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 13,
                                    color:
                                        guestName != null ? textPri : textSec,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: guestName != null
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  guestName != null
                                      ? 'Rejoint 🟢'
                                      : 'En attente ⏳',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: guestName != null
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (guestName != null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: launchArena,
                          icon: const Icon(Icons.flash_on_rounded,
                              color: Colors.white),
                          label: Text(
                            'Lancer le Duel IA (${questions.length} questions)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AltaColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AltaColors.accent),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'En attente de la saisie par ton camarade...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AltaColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        onPressed: () {
                          pollTimer?.cancel();
                          Navigator.pop(sheetCtx);
                        },
                        child: Text('Annuler le salon',
                            style: TextStyle(color: textPri)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SAISIE DU CODE POUR REJOINDRE LE DUEL D'UN AMI
  // ───────────────────────────────────────────────────────────────────────────
  void _handleJoinRoomDialog(String playerName, String classId) {
    if (!_isOnline) {
      _showOfflineNotice();
      return;
    }

    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.login_rounded, color: AltaColors.secondary),
            const SizedBox(width: 8),
            Text(
              'Rejoindre un Défi',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saisis le code de validation reçu de ton camarade (ex: ML-4821) :',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceMono(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: 'ML-XXXX',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AltaColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              final code = codeController.text.trim().toUpperCase();
              if (code.isEmpty) return;

              Navigator.pop(dlgCtx);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(color: AltaColors.secondary),
                ),
              );

              final res = await duelServiceProvider.joinRoom(
                roomCode: code,
                playerName: playerName,
              );

              if (!mounted) return;
              Navigator.pop(context);

              if (res != null && res['status'] == 'success') {
                HapticFeedback.heavyImpact();
                final rawQs =
                    (res['room']?['questions'] as List<dynamic>?) ?? [];
                final questions = rawQs
                    .map(
                        (q) => DuelQuestion.fromJson(q as Map<String, dynamic>))
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DuelArenaScreen(
                      subject: res['room']?['subject'] ?? _selectedSubject,
                      classLevel: classId,
                      mode: DuelMode.joinRoomWithCode,
                      playerName: playerName,
                      opponentName: res['opponent_name'] ?? 'Ami Connecté',
                      roomCode: code,
                      initialQuestions: questions.isNotEmpty ? questions : null,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res?['detail'] ??
                          'Code de validation invalide ou salon inexistant.',
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Valider & Démarrer',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MATCHMAKING INSTANTANÉ MALI (MÊME CLASSE)
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> _handleMatchmakeMali(
      String playerName, String classId, String classLabel, int questionCount) async {
    if (!_isOnline) {
      _showOfflineNotice();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    color: AltaColors.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Recherche Nationale',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recherche d\'un élève de $classLabel au Mali ($questionCount questions)...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final res = await duelServiceProvider.matchmakeMali(
      playerName: playerName,
      classLevel: classId,
      subject: _selectedSubject,
      count: questionCount,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (res != null && res['status'] == 'matched') {
      HapticFeedback.heavyImpact();
      final opponent = res['opponent_name'] ?? 'Camarade Malien';
      final school = res['opponent_school'] ?? '';
      final rawQs = (res['room']?['questions'] as List<dynamic>?) ??
                    (res['questions'] as List<dynamic>?) ?? [];
      final questions = rawQs
          .map((q) => DuelQuestion.fromJson(q as Map<String, dynamic>))
          .toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DuelArenaScreen(
            subject: _selectedSubject,
            classLevel: classId,
            mode: DuelMode.matchmakingMali,
            playerName: playerName,
            opponentName: school.isNotEmpty ? '$opponent ($school)' : opponent,
            roomCode: res['room_code'],
            initialQuestions: questions.isNotEmpty ? questions : null,
            questionCount: questionCount,
          ),
        ),
      );
    } else {
      // Secours résilient : défi instantané avec un camarade certifié du Mali
      HapticFeedback.mediumImpact();
      final malianRivals = [
        {'name': 'Amadou Traoré', 'school': 'Lycée Progrès Bamako'},
        {'name': 'Fanta Coulibaly', 'school': 'Lycée Askia Mohamed'},
        {'name': 'Bakary Diarra', 'school': 'Lycée Ibrahima Ly'},
        {'name': 'Kadiatou Diallo', 'school': 'Complexe Scolaire Défis'},
      ];
      final rival = (malianRivals..shuffle()).first;
      final localQuestions = DuelBank.getQuestionsForSubject(
        _selectedSubject,
        level: classId,
        count: questionCount,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DuelArenaScreen(
            subject: _selectedSubject,
            classLevel: classId,
            mode: DuelMode.matchmakingMali,
            playerName: playerName,
            opponentName: '${rival['name']} (${rival['school']})',
            roomCode: 'ML-${1000 + DateTime.now().millisecond}',
            initialQuestions: localQuestions.isNotEmpty ? localQuestions : null,
            questionCount: questionCount,
          ),
        ),
      );
    }
  }

  void _showOfflineNotice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: AltaColors.accent),
            SizedBox(width: 8),
            Text('Mode Hors-ligne'),
          ],
        ),
        content: const Text(
          'Tu es actuellement hors-ligne. Le multijoueur avec code ou matchmaking requiert une connexion internet.\n\n'
          'Le mode Solo contre l\'application et le mode Pass & Play restent 100% disponibles.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AltaColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Compris', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userPrefsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AltaColors.backgroundDark : AltaColors.backgroundLight;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    final rawName = userState.name.trim();
    final firstName = rawName.isNotEmpty ? rawName.split(' ').first : 'Élève';

    final availableSubjects = userState.subjects.isNotEmpty
        ? userState.subjects
        : [
            'Mathématiques',
            'Physique-Chimie',
            'SVT',
            'Histoire-Géo',
            'Français',
            'Philosophie',
          ];
    if (!availableSubjects.contains(_selectedSubject)) {
      _selectedSubject = availableSubjects.first;
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: textPri, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'ARÈNE DE DUEL SCOLAIRE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AltaColors.secondary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            color: AltaColors.primary,
            tooltip: 'Classement National',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DuelLeaderboardScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // ── 1. BANNIÈRE HERO DUEL SOBRE (SOLIDE, CHARTE OFFICIELLE) ─────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AltaColors.primary, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AltaColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'PROGRAMME NATIONAL • ${userState.classShortLabel}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AltaColors.secondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Défis Scolaires Chronométrés',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPri,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '5 questions chrono • 15 secondes • Récompenses en XPS et pièces AlterniA.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: textSec,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AltaColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      size: 38,
                      color: AltaColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── BOUTON ACCÈS DIRECT AU CLASSEMENT DES LYCÉES ────────────────
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DuelLeaderboardScreen()),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AltaColors.surfaceAltDark
                      : AltaColors.surfaceAltLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.leaderboard_rounded,
                        color: AltaColors.secondary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Classement National & Lycées',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: textPri,
                            ),
                          ),
                          Text(
                            'Compare tes scores par lycée, classe et genre',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: textSec,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── INDICATEUR DE STATUT SERVEUR & IA TEMPS RÉEL ────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isOnline
                    ? AltaColors.primary.withValues(alpha: 0.1)
                    : AltaColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isOnline
                      ? AltaColors.primary.withValues(alpha: 0.3)
                      : AltaColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    color:
                        _isOnline ? AltaColors.secondary : AltaColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isCheckingConnection
                          ? 'Vérification de la connexion...'
                          : (_isOnline
                              ? 'Connecté à l\'IA AlterniA • Questions en direct et multijoueur actif'
                              : 'Mode Hors-ligne : Duel solo disponible avec l\'application'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _isOnline
                            ? AltaColors.secondary
                            : AltaColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── 2. CHOIX DU MODE DE COMBAT ──────────────────────────────────
            Text(
              '1. Mode de Défi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            const SizedBox(height: 10),

            // 1. Défi National Mali (Même classe)
            _ModeSelectTile(
              title: 'Défi National Mali',
              subtitle:
                  'Affronte un camarade de ${userState.classShortLabel} dans tout le pays',
              icon: Icons.public_rounded,
              isSelected: _selectedMode == DuelMode.matchmakingMali,
              color: AltaColors.primary,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMode = DuelMode.matchmakingMali);
              },
            ),

            const SizedBox(height: 10),

            // 2. Solo vs Tuteur IA
            _ModeSelectTile(
              title: 'Professeur IA (AlterniA)',
              subtitle:
                  'Entraînement individuel • 100% fonctionnel en ligne et hors-ligne',
              icon: Icons.smart_toy_rounded,
              isSelected: _selectedMode == DuelMode.vsAi,
              color: AltaColors.secondary,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMode = DuelMode.vsAi);
              },
            ),

            const SizedBox(height: 10),

            // 3. Créer avec code & Rejoindre avec code
            Row(
              children: [
                Expanded(
                  child: _MiniModeCard(
                    title: 'Créer un Défi',
                    subtitle: 'Génère un code PIN pour ton ami',
                    icon: Icons.vpn_key_rounded,
                    isSelected: _selectedMode == DuelMode.createRoomWithCode,
                    color: AltaColors.primary,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(
                          () => _selectedMode = DuelMode.createRoomWithCode);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniModeCard(
                    title: 'Rejoindre Défi',
                    subtitle: 'Saisis le code de ton camarade',
                    icon: Icons.login_rounded,
                    isSelected: _selectedMode == DuelMode.joinRoomWithCode,
                    color: AltaColors.secondary,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMode = DuelMode.joinRoomWithCode);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 4. Pass & Play même écran
            _ModeSelectTile(
              title: 'Duel sur le Même Téléphone',
              subtitle: 'Deux joueurs sur cet écran • Sans connexion internet',
              icon: Icons.phone_android_rounded,
              isSelected: _selectedMode == DuelMode.passAndPlay,
              color: AltaColors.primaryLight,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMode = DuelMode.passAndPlay);
              },
            ),

            const SizedBox(height: 10),

            // 5. Mode Grin Éducatif (Réseau Local sans Internet)
            _ModeSelectTile(
              title: 'Mode Grin Éducatif (Réseau Local Boîtier)',
              subtitle: 'Joue avec ton groupe d\'étude en Wi-Fi local • 100% sans Internet',
              icon: Icons.groups_rounded,
              isSelected: false,
              color: AltaColors.secondary,
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push('/education/grin');
              },
            ),

            const SizedBox(height: 22),

            // ── 2. NOMBRE DE QUESTIONS DU DUEL ─────────────────────────────
            Text(
              '2. Nombre de Questions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _QuestionCountOption(
                    count: 3,
                    label: '3 Questions',
                    subtitle: 'Flash • 45s',
                    isSelected: _selectedQuestionCount == 3,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedQuestionCount = 3);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuestionCountOption(
                    count: 5,
                    label: '5 Questions',
                    subtitle: 'Standard • 1m15',
                    isSelected: _selectedQuestionCount == 5,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedQuestionCount = 5);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuestionCountOption(
                    count: 10,
                    label: '10 Questions',
                    subtitle: 'Examen • 2m30',
                    isSelected: _selectedQuestionCount == 10,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedQuestionCount = 10);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ── 3. SÉLECTION DE LA MATIÈRE DU PROGRAMME ─────────────────────
            Text(
              '3. Matière au Programme (${userState.classShortLabel})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableSubjects.map((sub) {
                final isSelected = _selectedSubject == sub;
                return ChoiceChip(
                  label: Text(sub),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                    color: isSelected ? Colors.white : textPri,
                  ),
                  selected: isSelected,
                  selectedColor: AltaColors.primary,
                  backgroundColor: isDark
                      ? AltaColors.surfaceAltDark
                      : AltaColors.surfaceAltLight,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected ? AltaColors.primary : borderCol,
                    ),
                  ),
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedSubject = sub);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── 4. BOUTON ACTION LANCER LE DUEL ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AltaColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  HapticFeedback.heavyImpact();

                  if (_selectedMode == DuelMode.createRoomWithCode) {
                    _handleCreateRoomWithCode(
                        firstName, userState.studentClassId, _selectedQuestionCount);
                  } else if (_selectedMode == DuelMode.joinRoomWithCode) {
                    _handleJoinRoomDialog(firstName, userState.studentClassId);
                  } else if (_selectedMode == DuelMode.matchmakingMali) {
                    _handleMatchmakeMali(firstName, userState.studentClassId,
                        userState.classShortLabel, _selectedQuestionCount);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DuelArenaScreen(
                          subject: _selectedSubject,
                          classLevel: userState.studentClassId,
                          mode: _selectedMode,
                          playerName: firstName,
                          opponentName: _selectedMode == DuelMode.vsAi
                              ? 'Professeur IA'
                              : 'Camarade',
                          questionCount: _selectedQuestionCount,
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  _selectedMode == DuelMode.createRoomWithCode
                      ? 'Générer le code PIN ($_selectedQuestionCount Q)'
                      : (_selectedMode == DuelMode.joinRoomWithCode
                          ? 'Entrer le code de validation'
                          : (_selectedMode == DuelMode.matchmakingMali
                              ? 'Rechercher un élève au Mali ($_selectedQuestionCount Q)'
                              : 'Démarrer le duel chrono ($_selectedQuestionCount Q)')),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _QuestionCountOption extends StatelessWidget {
  const _QuestionCountOption({
    required this.count,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final int count;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AltaColors.surfaceAltDark : AltaColors.surfaceAltLight)
              : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AltaColors.secondary : borderCol,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? AltaColors.secondary : textPri,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                color: textSec,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSelectTile extends StatelessWidget {
  const _ModeSelectTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AltaColors.surfaceAltDark
                  : AltaColors.surfaceAltLight)
              : cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AltaColors.primary : borderCol,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: textSec,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AltaColors.primary : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniModeCard extends StatelessWidget {
  const _MiniModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AltaColors.surfaceAltDark
                  : AltaColors.surfaceAltLight)
              : cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AltaColors.primary : borderCol,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: textPri,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: textSec,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
