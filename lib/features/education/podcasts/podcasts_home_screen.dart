// ─── AlterniA — Podcasts de Révision (Éducation Malienne) ───────────────────
// Révision audio mains libres, conforme à la charte officielle AlterniA,
// sans dégradé et sans sticker, avec narration TTS Vivienne intégrée,
// générateur IA et contrôle des quotas (2 gratuits pour comptes non-pro / sans boîtier).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../../device/device_notifier.dart';
import '../../device/device_page.dart';
import '../../profile/user_prefs_notifier.dart';
import 'podcast_model.dart';
import 'podcast_player_screen.dart';
import 'podcast_service.dart';

class PodcastsHomeScreen extends ConsumerStatefulWidget {
  const PodcastsHomeScreen({super.key});

  @override
  ConsumerState<PodcastsHomeScreen> createState() => _PodcastsHomeScreenState();
}

class _PodcastsHomeScreenState extends ConsumerState<PodcastsHomeScreen> {
  String _selectedCategory = 'Tous';
  List<RevisionPodcast> _customPodcasts = [];
  int _generationsCount = 0;

  final List<String> _categories = [
    'Tous',
    'Mathématiques',
    'Physique-Chimie',
    'Histoire-Géo',
    'Philosophie',
    'SVT',
    'Français',
  ];

  @override
  void initState() {
    super.initState();
    _loadPodcastsAndQuota();
  }

  Future<void> _loadPodcastsAndQuota() async {
    final customList = await PodcastService.instance.loadCustomPodcasts();
    final count = await PodcastService.instance.getGenerationsCount();
    if (mounted) {
      setState(() {
        _customPodcasts = customList;
        _generationsCount = count;
      });
    }
  }

  Future<bool> _checkIsPro() async {
    final deviceState = ref.read(deviceNotifierProvider);
    return PodcastService.instance
        .isUserPro(isDeviceConnected: deviceState.isConnected);
  }

  void _onGeneratePressed() async {
    HapticFeedback.mediumImpact();
    final isPro = await _checkIsPro();

    if (!isPro && _generationsCount >= PodcastService.maxFreeGenerations) {
      if (mounted) _showProLockModal(context);
    } else {
      if (mounted) _showGeneratePodcastSheet(context);
    }
  }

  void _showProLockModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AltaColors.borderDark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AltaColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AltaColors.accent,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Limite de 2 Podcasts Gratuits Atteinte',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tu as exploré tes 2 générations de cours audio offertes.\n\nPour continuer à créer des cours audio personnalisés en illimité avec l\'IA et la voix Vivienne, connecte ton boîtier physique AlternIA ou active ta version Pro.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: textSec,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Option 1 : Connecter le boîtier physique
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AltaColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  showDeviceModalSheet(context);
                },
                icon: const Icon(Icons.devices_rounded, size: 20),
                label: const Text(
                  'Appairer un Boîtier AlternIA',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Option 2 : Code Pro
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AltaColors.secondary,
                  side: BorderSide(
                    color: AltaColors.secondary.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showEnterProCodeDialog(context);
                },
                icon: const Icon(Icons.vpn_key_rounded, size: 18),
                label: const Text(
                  'Activer avec un Code Pro',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Fermer',
                style: TextStyle(color: textSec),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEnterProCodeDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AltaColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Code d\'Activation Pro',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saisis le code d\'activation fourni avec ton boîtier ou ta licence scolaire :',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'EX: ALTA-PRO-2026',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: AltaColors.surfaceAltDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AltaColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final code = codeCtrl.text.trim();
              if (code.isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('alternia_premium_unlocked', true);
                await prefs.setString('alternia_premium_code', code);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadPodcastsAndQuota();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Version Pro activée avec succès ! Génération illimitée débloquée.'),
                    backgroundColor: AltaColors.primary,
                  ),
                );
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showGeneratePodcastSheet(BuildContext context) {
    final userState = ref.read(userPrefsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    String chosenSubject = 'Mathématiques';
    final topicCtrl = TextEditingController();
    final classCtrl = TextEditingController(
      text: userState.classShortLabel != 'Non définie' &&
              userState.classShortLabel != 'CLASSE NON CONFIGURÉE'
          ? userState.classShortLabel
          : 'Terminale / 12eme',
    );

    final subjectsList = [
      'Mathématiques',
      'Physique-Chimie',
      'Histoire-Géo',
      'SVT',
      'Philosophie',
      'Français',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: AltaColors.borderDark),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AltaColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AltaColors.secondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Générer un Podcast Audio',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: textPri,
                                ),
                              ),
                              Text(
                                'L\'IA AlternIA rédige et prépare ton cours audio',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: textSec,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 1. Matière
                    Text(
                      '1. MATIÈRE DU PROGRAMME',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AltaColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subjectsList.map((sub) {
                        final isSel = chosenSubject == sub;
                        return ChoiceChip(
                          label: Text(sub),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setModalState(() => chosenSubject = sub);
                          },
                          selectedColor: AltaColors.primary,
                          backgroundColor: isDark
                              ? AltaColors.surfaceAltDark
                              : AltaColors.surfaceAltLight,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : textPri,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // 2. Sujet / Chapitre
                    Text(
                      '2. CHAPITRE OU NOTION À RÉVISER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AltaColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: topicCtrl,
                      style: TextStyle(color: textPri, fontSize: 14),
                      decoration: InputDecoration(
                        hintText:
                            'Ex: Les Nombres Complexes, La Guerre Froide...',
                        hintStyle: TextStyle(color: textSec.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: isDark
                            ? AltaColors.surfaceAltDark
                            : AltaColors.surfaceAltLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AltaColors.borderDark),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. Classe / Niveau
                    Text(
                      '3. NIVEAU SCOLAIRE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AltaColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: classCtrl,
                      style: TextStyle(color: textPri, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Ex: Terminale TSE, 11eme, DEF...',
                        filled: true,
                        fillColor: isDark
                            ? AltaColors.surfaceAltDark
                            : AltaColors.surfaceAltLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AltaColors.borderDark),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bouton Générer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AltaColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          final topic = topicCtrl.text.trim();
                          if (topic.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Veuillez indiquer un chapitre ou un sujet.'),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(sheetCtx);
                          _executeGeneration(
                            subject: chosenSubject,
                            topic: topic,
                            classLevel: classCtrl.text.trim(),
                          );
                        },
                        icon: const Icon(Icons.bolt_rounded, size: 20),
                        label: const Text(
                          'Lancer la Génération IA',
                          style: TextStyle(
                            fontSize: 14,
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
        },
      ),
    );
  }

  void _executeGeneration({
    required String subject,
    required String topic,
    required String classLevel,
  }) async {
    final userState = ref.read(userPrefsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    // Dialogue d'attente animé
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AltaColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AltaColors.secondary),
              const SizedBox(height: 18),
              Text(
                'AlternIA compose ton cours audio...',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Adaptation didactique au programme malien & narration vocale.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final podcast = await PodcastService.instance.generatePodcast(
        subject: subject,
        topic: topic,
        classLevel: classLevel.isNotEmpty ? classLevel : 'Terminale',
        studentName: userState.name,
      );

      if (mounted) {
        nav.pop(); // Ferme le dialogue de chargement
        await _loadPodcastsAndQuota();

        // Ouvre directement le lecteur de podcast avec la voix Vivienne
        nav.push(
          MaterialPageRoute(
            builder: (_) => PodcastPlayerScreen(podcast: podcast),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        nav.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Impossible de générer le podcast pour le moment.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceNotifierProvider);
    final isConnected = deviceState.isConnected;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AltaColors.backgroundDark : AltaColors.backgroundLight;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    final allPodcasts = [..._customPodcasts, ...PodcastCatalog.podcasts];

    final filteredPodcasts = _selectedCategory == 'Tous'
        ? allPodcasts
        : allPodcasts
            .where((p) =>
                p.subject.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();

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
          'PODCASTS DE RÉVISION',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AltaColors.secondary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // ── 1. BANNIÈRE HERO SOTRAMA & MAINS LIBRES ─────────────────────
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.headphones_rounded,
                                  size: 13, color: AltaColors.secondary),
                              const SizedBox(width: 6),
                              Text(
                                'MODE MAINS LIBRES & SOTRAMA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AltaColors.secondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Révision Audio du Programme',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPri,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Les notions clés racontées en 6 minutes par la voix haute fidélité d\'AlternIA.',
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
                      Icons.graphic_eq_rounded,
                      size: 36,
                      color: AltaColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── 2. CARTE D'ACTION : GÉNÉRATEUR IA DE PODCASTS ───────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AltaColors.accent.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AltaColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AltaColors.accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Générateur de Cours IA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                        ],
                      ),
                      // Badge de quota
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isConnected
                              ? AltaColors.secondary.withValues(alpha: 0.15)
                              : (_generationsCount >=
                                      PodcastService.maxFreeGenerations
                                  ? Colors.red.withValues(alpha: 0.15)
                                  : AltaColors.accent.withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isConnected
                              ? 'PRO • BOÎTIER'
                              : 'GRATUIT : $_generationsCount / ${PodcastService.maxFreeGenerations}',
                          style: GoogleFonts.spaceMono(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isConnected
                                ? AltaColors.secondary
                                : (_generationsCount >=
                                        PodcastService.maxFreeGenerations
                                    ? Colors.redAccent
                                    : AltaColors.accent),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisis un thème ou un chapitre malien difficile, l\'IA te compose un podcast de 6 min sur mesure.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: textSec,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AltaColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _onGeneratePressed,
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 18),
                      label: const Text(
                        'Créer mon Podcast Audio',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 3. FILTRE PAR MATIÈRE ────────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AltaColors.primary
                            : (isDark
                                ? AltaColors.surfaceAltDark
                                : AltaColors.surfaceAltLight),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AltaColors.primary : borderCol,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : textPri,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── 4. LISTE DES COURS AUDIO DISPONIBLES ────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cours Disponibles (${filteredPodcasts.length})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPri,
                  ),
                ),
                if (_customPodcasts.isNotEmpty)
                  Text(
                    '${_customPodcasts.length} généré(s)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AltaColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (filteredPodcasts.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Aucun cours audio disponible dans cette matière.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: textSec,
                    ),
                  ),
                ),
              )
            else
              ...filteredPodcasts.map((podcast) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: podcast.isCustomGenerated
                          ? AltaColors.secondary.withValues(alpha: 0.5)
                          : borderCol,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Pochette matière sobre
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AltaColors.surfaceAltDark
                              : AltaColors.surfaceAltLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AltaColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Icon(podcast.icon,
                            color: AltaColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),

                      // Infos podcast
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AltaColors.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      podcast.subject.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AltaColors.secondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${podcast.classLevel} • ${podcast.durationMinutes} min',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: textSec,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              podcast.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textPri,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              podcast.summary,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: textSec,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Bouton Écouter
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill_rounded,
                            size: 36),
                        color: AltaColors.accent,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PodcastPlayerScreen(podcast: podcast),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
