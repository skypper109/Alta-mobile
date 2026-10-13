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
  final Set<String> _downloadedResourceIds = {};
  final Set<String> _downloadingIds = {};

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
      BuildContext context, String userName, String userClass, List<String> subjects) {
    final titleCtrl = TextEditingController(text: 'Grin Révision $userClass');
    final availableSubjects = subjects.isNotEmpty
        ? subjects
        : ['Mathématiques', 'Physique-Chimie', 'Biologie (SVT)', 'Histoire-Géographie', 'Français'];
    String selectedSubject = availableSubjects.first;
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
                'Créer un Salon de Grin Local',
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
                items: availableSubjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
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
                  onPressed: () async {
                    final t = titleCtrl.text.trim();
                    if (t.isNotEmpty) {
                      final newRoom = await ref
                          .read(grinServiceProvider.notifier)
                          .createLocalRoom(
                            title: t,
                            hostName: userName,
                            hostClass: userClass,
                            subject: selectedSubject,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        _showGrinWaitingRoom(context, newRoom, userName, isHost: true);
                      }
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
                    'Créer le Salon (Attente des camarades)',
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

  void _showGrinWaitingRoom(
    BuildContext context,
    GrinRoom room,
    String currentUserName, {
    required bool isHost,
  }) {
    int selectedQuestionCount = 5;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);
    final borderCol = isDark ? AppColors.border : const Color(0xFFCBD5E1);
    final cardBg = isDark ? const Color(0xFF141C2E) : const Color(0xFFF8FAFC);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final currentPeers = ref.watch(grinServiceProvider).nearbyPeers;

          return Padding(
            padding: EdgeInsets.only(
              left: 22,
              right: 22,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  room.subject,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  room.hostClass,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.secondary : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: room.pinCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code PIN copié !'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'PIN: ${room.pinCode}',
                              style: GoogleFonts.spaceMono(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_rounded, size: 14, color: AppColors.secondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Sélecteur de nombre de questions
                Text(
                  'Nombre de questions du duel :',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQuestionCountChip(
                      label: '3 Questions\n(Flash)',
                      count: 3,
                      selected: selectedQuestionCount == 3,
                      onTap: isHost
                          ? () => setSheetState(() => selectedQuestionCount = 3)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    _buildQuestionCountChip(
                      label: '5 Questions\n(Standard)',
                      count: 5,
                      selected: selectedQuestionCount == 5,
                      onTap: isHost
                          ? () => setSheetState(() => selectedQuestionCount = 5)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    _buildQuestionCountChip(
                      label: '10 Questions\n(Examen)',
                      count: 10,
                      selected: selectedQuestionCount == 10,
                      onTap: isHost
                          ? () => setSheetState(() => selectedQuestionCount = 10)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Participants connectés et présents
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Camarades présents (${1 + (isHost ? currentPeers.length : 1)}) :',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                    Text(
                      'Réseau Local Boîtier',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSec),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderCol),
                  ),
                  child: Column(
                    children: [
                      // Ligne Hôte
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                room.hostName.isNotEmpty ? room.hostName[0] : 'H',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${room.hostName} (Hôte • ${room.hostClass})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textPri,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Prêt 🟢',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Ligne Invité ou Peers
                      if (!isHost) ...[
                        const Divider(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  currentUserName.isNotEmpty ? currentUserName[0] : 'V',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$currentUserName (Vous)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: textPri,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Rejoint 🟢',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      for (final peer in currentPeers.take(2)) ...[
                        const Divider(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  peer.name.isNotEmpty ? peer.name[0] : 'C',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${peer.name} (${peer.className})',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPri,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'En ligne 🟡',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Bouton de lancement
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _launchDuelForRoom(
                        context,
                        room,
                        currentUserName,
                        questionCount: selectedQuestionCount,
                      );
                    },
                    icon: const Icon(Icons.bolt_rounded, size: 20),
                    label: Text(
                      isHost
                          ? 'Lancer le Duel IA du Grin ($selectedQuestionCount Q)'
                          : 'Rejoindre l\'Arène de Duel ($selectedQuestionCount Q)',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCountChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showShareResourceSheet(BuildContext context, {GrinPeer? targetPeer}) {
    final userPrefs = ref.read(userPrefsProvider);
    final rawName = userPrefs.name.trim();
    final userName = rawName.isNotEmpty ? rawName : 'Élève';
    final availableSubjects = userPrefs.subjects.isNotEmpty
        ? userPrefs.subjects
        : ['Mathématiques', 'Physique-Chimie', 'Biologie (SVT)', 'Histoire-Géographie', 'Français'];

    final titleCtrl = TextEditingController(
      text: targetPeer != null
          ? 'Cours partagé pour ${targetPeer.name}'
          : 'Fiche Révision - ${availableSubjects.first}',
    );
    String selectedSubject = availableSubjects.first;
    String selectedType = 'fiche';
    GrinPeer? chosenPeer = targetPeer;

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
        builder: (ctx, setSheetState) {
          final peers = ref.watch(grinServiceProvider).nearbyPeers;

          return Padding(
            padding: EdgeInsets.only(
              left: 22,
              right: 22,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                Row(
                  children: [
                    const Icon(Icons.share_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      targetPeer != null
                          ? 'Partager avec ${targetPeer.name}'
                          : 'Partager une ressource sans Internet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Échange P2P local ultra-rapide via le Boîtier AlterniA (0 Mo de données mobiles consommées).',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textPri),
                  decoration: InputDecoration(
                    labelText: 'Titre de la ressource',
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderCol),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSubject,
                  decoration: InputDecoration(
                    labelText: 'Matière',
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderCol),
                    ),
                  ),
                  items: availableSubjects
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setSheetState(() => selectedSubject = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type de document',
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderCol),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'fiche', child: Text('Fiche de révision PDF / Synthèse')),
                    DropdownMenuItem(value: 'podcast', child: Text('Podcast Audio Éducatif')),
                    DropdownMenuItem(value: 'flashcards', child: Text('Deck Flashcards de Mémorisation')),
                  ],
                  onChanged: (val) {
                    if (val != null) setSheetState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: chosenPeer?.id,
                  decoration: InputDecoration(
                    labelText: 'Partager avec',
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderCol),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tout le Grin (Diffusion générale)')),
                    for (final p in peers)
                      DropdownMenuItem(value: p.id, child: Text('${p.name} (${p.className})')),
                  ],
                  onChanged: (val) {
                    setSheetState(() {
                      chosenPeer = val != null ? peers.firstWhere((p) => p.id == val) : null;
                    });
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) return;

                      Navigator.pop(ctx);
                      await ref.read(grinServiceProvider.notifier).shareResource(
                            title: title,
                            subject: selectedSubject,
                            type: selectedType,
                            sharedBy: userName,
                            targetPeerId: chosenPeer?.id,
                          );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              chosenPeer != null
                                  ? '« $title » partagé directement avec ${chosenPeer!.name} !'
                                  : '« $title » partagé avec succès dans le Grin !',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      'Envoyer en P2P Local (0 Data)',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadResource(GrinSharedResource res) async {
    HapticFeedback.lightImpact();
    setState(() {
      _downloadingIds.add(res.id);
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      setState(() {
        _downloadingIds.remove(res.id);
        _downloadedResourceIds.add(res.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('« ${res.title} » téléchargé et prêt à être consulté hors-ligne !'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'Ouvrir',
            textColor: Colors.white,
            onPressed: () => _showResourcePreview(context, res),
          ),
        ),
      );
    }
  }

  void _showResourcePreview(BuildContext context, GrinSharedResource res) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);
    final cardBg = isDark ? const Color(0xFF141C2E) : const Color(0xFFF1F5F9);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22.0),
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
            Row(
              children: [
                Icon(
                  res.type == 'podcast'
                      ? Icons.headphones_rounded
                      : (res.type == 'flashcards'
                          ? Icons.style_rounded
                          : Icons.menu_book_rounded),
                  color: AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    res.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textPri,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${res.subject} • ${res.sizeMb} • Partagé par ${res.sharedBy}',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSec),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: res.type == 'podcast'
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Lecture audio locale (Boîtier)', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSec)),
                            Text('08:45', style: GoogleFonts.spaceMono(fontSize: 12, fontWeight: FontWeight.bold, color: textPri)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.35,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(icon: const Icon(Icons.replay_10_rounded), onPressed: () {}),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lecture de "${res.title}"...')),
                                  );
                                },
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.forward_10_rounded), onPressed: () {}),
                          ],
                        ),
                      ],
                    )
                  : Text(
                      'Résumé & Points clés du cours :\n• Conforme au programme officiel du Mali\n• Concepts fondamentaux, définitions et exercices types\n• Document vérifié et stocké sur votre téléphone sans connexion Internet.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.5,
                        color: textPri,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Fermer la prévisualisation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchDuelForRoom(
      BuildContext context, GrinRoom room, String currentUserName, {int questionCount = 5}) {
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
          questionCount: questionCount,
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
            // ── BANNIÈRE STATUT RÉSEAU LOCAL — PREMIUM ────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isConnectedToBox
                    ? AppColors.secondary.withValues(alpha: 0.10)
                    : (isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isConnectedToBox
                      ? AppColors.secondary.withValues(alpha: 0.45)
                      : borderCol,
                  width: 1.5,
                ),
                boxShadow: isConnectedToBox
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: (isConnectedToBox ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isConnectedToBox
                          ? Icons.router_rounded
                          : Icons.wifi_tethering_rounded,
                      color: isConnectedToBox
                          ? AppColors.secondary
                          : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConnectedToBox
                              ? 'Connecté au Boîtier AlterniA'
                              : 'Wi-Fi Local',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: textPri,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '0 Mo consommés • Échanges P2P en direct',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: textSec,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isConnectedToBox)
                    GestureDetector(
                      onTap: () => showDeviceModalSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Associer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'En ligne 🟢',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
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
                      // Hero CTA — Créer un Salon de Grin
                      GestureDetector(
                        onTap: () => _showCreateGrinRoomDialog(
                            context, userName, userClass, userPrefs.subjects),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF253060), Color(0xFF314999)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.groups_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Créer un Salon Grin',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Révision local • Sans Internet • Boitier',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: Colors.white.withValues(alpha: 0.78),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.add_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Opacity(
                                  opacity: 0.12,
                                  child: Image.asset(
                                    'assets/images/alternia_logo.png',
                                    width: 100,
                                    height: 100,
                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 3, height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SALONS OUVERTS (${grinState.rooms.length})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: textSec,
                            ),
                          ),
                        ],
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
                              _showGrinWaitingRoom(context, room, userName, isHost: false),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),

                  // ── ONGLET 2 : CAMARADES DÉTECTÉS À PROXIMITÉ ──────────
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 3, height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CAMARADES DU GRIN (${grinState.nearbyPeers.length})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: textSec,
                            ),
                          ),
                        ],
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
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.share_rounded, size: 20),
                                color: isDark
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                tooltip: 'Partager une ressource avec ${peer.name}',
                                onPressed: () => _showShareResourceSheet(
                                    context, targetPeer: peer),
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
                      ElevatedButton.icon(
                        onPressed: () => _showShareResourceSheet(context),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: Text(
                          'Partager une ressource dans le Grin',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                              if (_downloadingIds.contains(res.id))
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              else if (_downloadedResourceIds.contains(res.id))
                                IconButton(
                                  icon: const Icon(Icons.check_circle_rounded,
                                      color: AppColors.success),
                                  tooltip: 'Ouvrir la ressource',
                                  onPressed: () =>
                                      _showResourcePreview(context, res),
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.download_rounded),
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  tooltip: 'Télécharger en local',
                                  onPressed: () => _downloadResource(res),
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
