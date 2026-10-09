// ─── AlterniA — Lobby de Duel Scolaire (Connecté IA & Matchmaking Mali) ──────
// Sélection des modes, génération de code de validation (PIN),
// matchmaking instantané par classe malienne et vérification hors-ligne.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../profile/user_prefs_notifier.dart';
import 'duel_arena_screen.dart';
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
  bool _isOnline = false;
  bool _isCheckingConnection = true;

  final List<String> _subjects = [
    'Mathématiques',
    'Physique-Chimie',
    'SVT',
    'Histoire-Géo',
    'Philosophie',
  ];

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
  Future<void> _handleCreateRoomWithCode(String playerName, String classId) async {
    if (!_isOnline) {
      _showOfflineNotice();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.secondary),
                SizedBox(height: 16),
                Text('Création du salon et génération des questions IA...'),
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

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        // Polling pour détecter quand l'ami valide et rejoint le salon
        pollTimer = Timer.periodic(const Duration(milliseconds: 1500), (t) async {
          final status = await duelServiceProvider.getRoomStatus(roomCode);
          if (status != null && status['status'] == 'IN_PROGRESS') {
            t.cancel();
            if (sheetCtx.mounted) {
              Navigator.pop(sheetCtx);
            }
            if (mounted) {
              HapticFeedback.heavyImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DuelArenaScreen(
                    subject: _selectedSubject,
                    classLevel: classId,
                    mode: DuelMode.createRoomWithCode,
                    playerName: playerName,
                    opponentName: status['guest_name'] ?? 'Ami Connecté',
                    roomCode: roomCode,
                    initialQuestions: questions.isNotEmpty ? questions : null,
                  ),
                ),
              );
            }
          }
        });

        final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;

        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            pollTimer?.cancel();
          },
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.key_rounded, size: 44, color: AppColors.accent),
                const SizedBox(height: 12),
                Text(
                  'CODE DE VALIDATION DU DUEL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Donne ce code à ton ami pour qu\'il rejoigne ton duel :',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),
                // Conteneur du code géant
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: roomCode));
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code $roomCode copié dans le presse-papiers !'),
                        backgroundColor: AppColors.secondary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondary, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          roomCode,
                          style: GoogleFonts.spaceMono(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.copy_rounded, color: AppColors.secondary, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'En attente de la saisie du code par ton ami...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      pollTimer?.cancel();
                      Navigator.pop(sheetCtx);
                    },
                    child: const Text('Annuler le salon'),
                  ),
                ),
              ],
            ),
          ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.login_rounded, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              'Rejoindre un Défi',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entre le code de validation reçu de ton ami (ex: ML-4821) :',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceMono(
                fontSize: 22,
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
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              final code = codeController.text.trim().toUpperCase();
              if (code.isEmpty) return;

              Navigator.pop(dlgCtx); // fermer dialog

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
              );

              final res = await duelServiceProvider.joinRoom(
                roomCode: code,
                playerName: playerName,
              );

              if (!mounted) return;
              Navigator.pop(context); // fermer loading

              if (res != null && res['status'] == 'success') {
                HapticFeedback.heavyImpact();
                final rawQs = (res['room']?['questions'] as List<dynamic>?) ?? [];
                final questions = rawQs
                    .map((q) => DuelQuestion.fromJson(q as Map<String, dynamic>))
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
            child: const Text('Valider & Combattre ⚔️',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MATCHMAKING INSTANTANÉ MALI (MÊME CLASSE)
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> _handleMatchmakeMali(String playerName, String classId, String classLabel) async {
    if (!_isOnline) {
      _showOfflineNotice();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Color(0xFF10B981),
                    strokeWidth: 3.5,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Radar Matchmaking Mali 🇲🇱',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Recherche d\'un camarade de $classLabel connecté...',
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
    );

    if (!mounted) return;
    Navigator.pop(context); // Fermer dialog

    if (res != null && res['status'] == 'matched') {
      HapticFeedback.heavyImpact();
      final opponent = res['opponent_name'] ?? 'Camarade Malien';
      final school = res['opponent_school'] ?? '';
      final rawQs = (res['room']?['questions'] as List<dynamic>?) ?? [];
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
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matchmaking temporairement indisponible.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showOfflineNotice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('Mode Hors-ligne'),
          ],
        ),
        content: const Text(
          'Tu es actuellement hors-ligne. Le multijoueur avec code ou matchmaking nécessite internet.\n\n'
          'Tu peux toutefois jouer immédiatement en Solo contre l\'application ou en mode deux joueurs sur le même écran !',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);

    final rawName = userState.name.trim();
    final firstName = rawName.isNotEmpty ? rawName.split(' ').first : 'Élève';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1424) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPri, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'DUEL SCOLAIRE ALTERNIA',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: AppColors.secondary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 20,
            ),
            onPressed: _checkServerConnectivity,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // ── 1. BANNIÈRE HERO DUEL ÉPIQUE ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF283A7E), Color(0xFFE26D14)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE26D14).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ARÈNE DU BAC & DEF • ${userState.classShortLabel}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Défie le Mali ou un Ami ! ⚡',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Questions réelles IA • Gagne des XPS et des Pièces AlterniA à chaque victoire !',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      size: 42,
                      color: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── INDICATEUR DE STATUT SERVEUR & IA TEMPS RÉEL ────────────────
            GestureDetector(
              onTap: _checkServerConnectivity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isOnline
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.amber.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isOnline
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      color: _isOnline ? Colors.greenAccent : Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isCheckingConnection
                            ? 'Vérification de la connexion AlterniA...'
                            : (_isOnline
                                ? '🟢 Connecté à l\'IA AlterniA (Questions directes & Matchmaking actif)'
                                : '⚡ Mode Hors-ligne : Duel Solo disponible avec l\'application'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isOnline
                              ? (isDark ? Colors.greenAccent : Colors.green.shade800)
                              : (isDark ? Colors.amberAccent : Colors.amber.shade900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ── 2. CHOIX DU MODE DE COMBAT ──────────────────────────────────
            Text(
              '1. Choisis le Type de Défi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            const SizedBox(height: 12),

            // 1. Défi National Mali (Même classe)
            _ModeSelectTile(
              title: 'Défi Mali Instantané 🇲🇱',
              subtitle: 'Trouve un camarade de ${userState.classShortLabel} connecté dans tout le Mali',
              icon: Icons.public_rounded,
              isSelected: _selectedMode == DuelMode.matchmakingMali,
              color: const Color(0xFF10B981),
              isRecommended: true,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMode = DuelMode.matchmakingMali);
              },
            ),

            const SizedBox(height: 10),

            // 2. Solo vs Tuteur IA
            _ModeSelectTile(
              title: 'Professeur Henri (IA AlterniA)',
              subtitle: 'Entraînement Solo face à l\'IA • Fonctionne aussi 100% Hors-ligne',
              icon: Icons.smart_toy_rounded,
              isSelected: _selectedMode == DuelMode.vsAi,
              color: AppColors.secondary,
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
                    title: 'Créer Défi 🔑',
                    subtitle: 'Génère un Code PIN pour ton ami',
                    icon: Icons.vpn_key_rounded,
                    isSelected: _selectedMode == DuelMode.createRoomWithCode,
                    color: AppColors.accent,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMode = DuelMode.createRoomWithCode);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniModeCard(
                    title: 'Rejoindre Défi 📥',
                    subtitle: 'Saisis le Code de ton ami',
                    icon: Icons.login_rounded,
                    isSelected: _selectedMode == DuelMode.joinRoomWithCode,
                    color: const Color(0xFF8B5CF6),
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
              title: 'Duel Camarade (Même écran)',
              subtitle: 'À deux sur le même téléphone • Idéal en classe ou récréation sans réseau',
              icon: Icons.phone_android_rounded,
              isSelected: _selectedMode == DuelMode.passAndPlay,
              color: Colors.blueGrey,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedMode = DuelMode.passAndPlay);
              },
            ),

            const SizedBox(height: 24),

            // ── 3. SÉLECTION DE LA MATIÈRE DU PROGRAMME ─────────────────────
            Text(
              '2. Choisis la Matière (${userState.classShortLabel})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _subjects.map((sub) {
                final isSelected = _selectedSubject == sub;
                return ChoiceChip(
                  label: Text(sub),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : textPri,
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark
                      ? const Color(0xFF1E2844)
                      : const Color(0xFFE2E8F0),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppColors.secondary : Colors.transparent,
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

            const SizedBox(height: 32),

            // ── 4. BOUTON ACTION LANCER LE DUEL SELON LE MODE ───────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                  shadowColor: AppColors.accent.withValues(alpha: 0.4),
                ),
                onPressed: () {
                  HapticFeedback.heavyImpact();

                  if (_selectedMode == DuelMode.createRoomWithCode) {
                    _handleCreateRoomWithCode(firstName, userState.studentClassId);
                  } else if (_selectedMode == DuelMode.joinRoomWithCode) {
                    _handleJoinRoomDialog(firstName, userState.studentClassId);
                  } else if (_selectedMode == DuelMode.matchmakingMali) {
                    _handleMatchmakeMali(firstName, userState.studentClassId, userState.classShortLabel);
                  } else {
                    // Solo vs IA ou Pass & Play
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DuelArenaScreen(
                          subject: _selectedSubject,
                          classLevel: userState.studentClassId,
                          mode: _selectedMode,
                          playerName: firstName,
                          opponentName: _selectedMode == DuelMode.vsAi
                              ? 'Prof. Henri IA'
                              : 'Camarade',
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      _selectedMode == DuelMode.createRoomWithCode
                          ? 'GÉNÉRER LE CODE DE VALIDATION 🔑'
                          : (_selectedMode == DuelMode.joinRoomWithCode
                              ? 'ENTRER LE CODE DUEL 📥'
                              : (_selectedMode == DuelMode.matchmakingMali
                                  ? 'TROUVER UN ÉLÈVE AU MALI 🇲🇱'
                                  : 'LANCER LE DUEL CHRONO ⚔️')),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
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

class _ModeSelectTile extends StatelessWidget {
  const _ModeSelectTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
    this.isRecommended = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? const Color(0xFF141D33) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : (isDark ? const Color(0xFF222F4C) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'POPULAIRE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? color : Colors.grey,
              size: 22,
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? const Color(0xFF141D33) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : (isDark ? const Color(0xFF222F4C) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
