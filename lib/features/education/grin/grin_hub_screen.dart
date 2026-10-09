// ─── AlterniA — Écran Mode Grin Éducatif (Hub Local Hors-Ligne) ─────────────
// Salon de révision multijoueur local, détection de camarades sur le boîtier
// et partage de podcasts et fiches en P2P sans consommer d'Internet.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../device/device_notifier.dart';
import '../../device/device_page.dart';
import '../../profile/user_prefs_notifier.dart';
import '../duel/duel_arena_screen.dart';
import '../duel/duel_model.dart';
import 'grin_model.dart';
import 'grin_service.dart';

class GrinHubScreen extends ConsumerStatefulWidget {
  const GrinHubScreen({super.key});

  @override
  ConsumerState<GrinHubScreen> createState() => _GrinHubScreenState();
}

class _GrinHubScreenState extends ConsumerState<GrinHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateGrinRoomDialog(
      BuildContext context, String userName, String userClass) {
    final titleCtrl = TextEditingController(text: 'Grin Révision $userClass');
    String selectedSubject = 'Mathématiques';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderCol = isDark ? AppColors.border : const Color(0xFFCBD5E1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 22,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Créer un Grin Local',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Les camarades connectés au même Boîtier AlterniA pourront rejoindre sans Internet.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondary
                      : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textPri,
                ),
                decoration: InputDecoration(
                  labelText: 'Nom du Grin / Groupe',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderCol),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Matière du défi',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                  filled: true,
                  fillColor:
                      isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderCol),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Mathématiques', child: Text('Mathématiques')),
                  DropdownMenuItem(
                      value: 'Physique-Chimie', child: Text('Physique-Chimie')),
                  DropdownMenuItem(
                      value: 'Biologie', child: Text('Biologie (SVT)')),
                  DropdownMenuItem(
                      value: 'Histoire-Géographie',
                      child: Text('Histoire-Géographie')),
                  DropdownMenuItem(
                      value: 'Philosophie', child: Text('Philosophie')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedSubject = val);
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final t = titleCtrl.text.trim();
                    if (t.isNotEmpty) {
                      final newRoom = ref
                          .read(grinServiceProvider.notifier)
                          .createLocalRoom(
                            title: t,
                            hostName: userName,
                            hostClass: userClass,
                            subject: selectedSubject,
                          );
                      Navigator.pop(ctx);
                      _launchDuelForRoom(context, newRoom, userName);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Lancer le Salon de Grin',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchDuelForRoom(
      BuildContext context, GrinRoom room, String currentUserName) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DuelArenaScreen(
          subject: room.subject,
          classLevel: room.hostClass,
          mode: DuelMode.passAndPlay,
          playerName: currentUserName,
          opponentName: room.hostName != currentUserName
              ? room.hostName
              : 'Camarade du Grin',
          roomCode: room.pinCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grinState = ref.watch(grinServiceProvider);
    final userPrefs = ref.watch(userPrefsProvider);
    final deviceState = ref.watch(deviceNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);
    final cardBg = isDark ? const Color(0xFF141C2E) : Colors.white;
    final borderCol =
        isDark ? const Color(0xFF23314D) : const Color(0xFFCBD5E1);

    final rawName = userPrefs.name.trim();
    final userName = rawName.isNotEmpty ? rawName : 'Élève';
    final userClass = userPrefs.classShortLabel;
    final isConnectedToBox = deviceState.isConnected;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPri),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mode Grin Éducatif',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            Text(
              'Réseau Local & Boîtier AlterniA (Sans Internet)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: textSec,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: grinState.isScanning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Rescanner le Grin',
            onPressed: () =>
                ref.read(grinServiceProvider.notifier).scanLocalGrin(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.secondary : AppColors.primary,
          unselectedLabelColor: textSec,
          indicatorColor: isDark ? AppColors.secondary : AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'Salons & Duels'),
            Tab(text: 'Camarades'),
            Tab(text: 'Partage sans internet'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── BANNIÈRE STATUT RÉSEAU LOCAL ──────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConnectedToBox
                    ? AppColors.secondary.withValues(alpha: 0.12)
                    : (isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isConnectedToBox
                      ? AppColors.secondary.withValues(alpha: 0.4)
                      : borderCol,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isConnectedToBox
                        ? Icons.router_rounded
                        : Icons.wifi_tethering_rounded,
                    color: isConnectedToBox
                        ? AppColors.secondary
                        : AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConnectedToBox
                              ? 'Connecté au Boîtier AlterniA'
                              : 'Wi-Fi Local / Hotspot Actif',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: textPri,
                          ),
                        ),
                        Text(
                          'Les échanges fonctionnent à 100% sans consommer de data.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: textSec,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isConnectedToBox)
                    TextButton(
                      onPressed: () => showDeviceModalSheet(context),
                      child: Text(
                        'Associer',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── VUES DES ONGLETS ──────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── ONGLET 1 : SALONS & DUELS DE GRIN ──────────────────
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showCreateGrinRoomDialog(
                            context, userName, userClass),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          'Créer un Salon pour notre Grin',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Salons ouverts à proximité (${grinState.rooms.length})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPri,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final room in grinState.rooms) ...[
                        _GrinRoomCard(
                          room: room,
                          cardBg: cardBg,
                          borderCol: borderCol,
                          textPri: textPri,
                          textSec: textSec,
                          onJoin: () =>
                              _launchDuelForRoom(context, room, userName),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),

                  // ── ONGLET 2 : CAMARADES DÉTECTÉS À PROXIMITÉ ──────────
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Camarades connectés au Grin (${grinState.nearbyPeers.length})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPri,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final peer in grinState.nearbyPeers) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderCol),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    peer.name[0],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      peer.name,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textPri,
                                      ),
                                    ),
                                    Text(
                                      '${peer.className} • ${peer.deviceModel}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: textSec,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${peer.scoreSession} pts',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),

                  // ── ONGLET 3 : PARTAGE P2P DE RESSOURCES SANS DATA ─────
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Ressources partagées dans le Grin (${grinState.sharedResources.length})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPri,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Téléchargez directement depuis les téléphones voisins ou le boîtier.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: textSec,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final res in grinState.sharedResources) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderCol),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: res.type == 'podcast'
                                      ? AppColors.secondary
                                          .withValues(alpha: 0.15)
                                      : AppColors.primary
                                          .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  res.type == 'podcast'
                                      ? Icons.headphones_rounded
                                      : Icons.menu_book_rounded,
                                  size: 20,
                                  color: res.type == 'podcast'
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      res.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: textPri,
                                      ),
                                    ),
                                    Text(
                                      '${res.subject} • ${res.sizeMb} • Partagé par ${res.sharedBy}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        color: textSec,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.download_rounded),
                                color: isDark
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                tooltip: 'Télécharger en local',
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Fichier "${res.title}" téléchargé sur votre mémoire locale !'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrinRoomCard extends StatelessWidget {
  const _GrinRoomCard({
    required this.room,
    required this.cardBg,
    required this.borderCol,
    required this.textPri,
    required this.textSec,
    required this.onJoin,
  });

  final GrinRoom room;
  final Color cardBg;
  final Color borderCol;
  final Color textPri;
  final Color textSec;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  room.subject,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PIN: ${room.pinCode}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            room.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Hôte : ${room.hostName} (${room.hostClass}) • ${room.playerCount}/${room.maxPlayers} participants',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: textSec,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(
                'Rejoindre le duel du Grin',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
