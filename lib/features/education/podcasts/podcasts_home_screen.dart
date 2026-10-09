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

  Future<void> _deleteCustomPodcast(RevisionPodcast podcast) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Supprimer ce cours audio ?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Voulez-vous retirer « ${podcast.title} » de votre bibliothèque locale ?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: isDark ? Colors.white70 : const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PodcastService.instance.deleteCustomPodcast(podcast.id);
      await _loadPodcastsAndQuota();
    }
  }

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
                color: AltaColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AltaColors.primary,
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
                  backgroundColor: AltaColors.primary,
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
      builder: (ctx) {
        final isDlgDark = Theme.of(ctx).brightness == Brightness.dark;
        final dlgBg =
            isDlgDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
        final dlgTextPri = isDlgDark ? Colors.white : const Color(0xFF0D1525);
        final dlgTextSec = isDlgDark ? Colors.white70 : const Color(0xFF4A5878);
        final dlgHint = isDlgDark ? Colors.white30 : const Color(0xFF94A3B8);
        final dlgFill =
            isDlgDark ? AltaColors.surfaceAltDark : AltaColors.surfaceAltLight;
        return AlertDialog(
          backgroundColor: dlgBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Code d\'Activation Pro',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: dlgTextPri,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saisis le code d\'activation fourni avec ton boîtier ou ta licence scolaire :',
                style: TextStyle(color: dlgTextSec, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: codeCtrl,
                textCapitalization: TextCapitalization.characters,
                style:
                    TextStyle(color: dlgTextPri, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'EX: ALTA-PRO-2026',
                  hintStyle: TextStyle(color: dlgHint),
                  filled: true,
                  fillColor: dlgFill,
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
              child: Text('Annuler', style: TextStyle(color: dlgTextSec)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AltaColors.primary,
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
        );
      },
    );
  }

  void _showGeneratePodcastSheet(BuildContext context) {
    final userState = ref.read(userPrefsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    final subjectsList = userState.subjects.isNotEmpty
        ? userState.subjects
        : [
            'Mathématiques',
            'Physique-Chimie',
            'Histoire-Géo',
            'SVT',
            'Philosophie',
            'Français',
          ];

    String chosenSubject = subjectsList.first;
    final topicCtrl = TextEditingController();
    final classCtrl = TextEditingController(
      text: userState.classShortLabel != 'Non définie' &&
              userState.classShortLabel != 'CLASSE NON CONFIGURÉE'
          ? userState.classShortLabel
          : 'Terminale',
    );

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
                            color: AltaColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.mic_none_rounded,
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
                                'Nouveau Cours Audio',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: textPri,
                                ),
                              ),
                              Text(
                                'Synthèse sonore pour la classe de ${userState.classShortLabel}',
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
                            'Ex: La stratification sociale, La Constitution, Le PIB...',
                        hintStyle:
                            TextStyle(color: textSec.withValues(alpha: 0.5)),
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
                        hintText: 'Ex: Terminale TSS, 11eme, DEF...',
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
                          backgroundColor: AltaColors.primary,
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
                        icon: const Icon(Icons.headphones_rounded, size: 20),
                        label: const Text(
                          'Composer le cours audio',
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
      builder: (ctx) {
        final isDlgDark = Theme.of(ctx).brightness == Brightness.dark;
        final dlgBg =
            isDlgDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
        final dlgTextPri = isDlgDark ? Colors.white : const Color(0xFF0D1525);
        final dlgTextSec = isDlgDark ? Colors.white70 : const Color(0xFF4A5878);
        return AlertDialog(
          backgroundColor: dlgBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    color: dlgTextPri,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Adaptation didactique au programme malien & narration vocale.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: dlgTextSec,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    ref.watch(deviceNotifierProvider);
    final userState = ref.watch(userPrefsProvider);
    final studentClass = userState.classShortLabel != 'Non définie' &&
            userState.classShortLabel != 'CLASSE NON CONFIGURÉE'
        ? userState.classShortLabel
        : 'TSS';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AltaColors.backgroundDark : AltaColors.backgroundLight;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    // ── Dérivation stricte des matières selon la classe de l'élève ────────────
    final classSubjects = userState.subjects.isNotEmpty
        ? userState.subjects
        : [
            'Sociologie Générale',
            'Droit & Institutions',
            'Science Politique',
            'Histoire-Géographie',
            'Philosophie',
            'Économie',
            'Français',
            'Anglais',
          ];

    final availableCategories = ['Tous', ...classSubjects];

    if (_selectedCategory != 'Tous' &&
        !availableCategories
            .any((c) => c.toLowerCase() == _selectedCategory.toLowerCase())) {
      _selectedCategory = 'Tous';
    }

    // ── Filtrage strict des podcasts selon la filière active ─────────────────
    final relevantCustomPodcasts = _customPodcasts.where((p) {
      if (userState.subjects.isNotEmpty) {
        final isMatchingSubject = userState.subjects.any(
          (s) => s.toLowerCase() == p.subject.toLowerCase(),
        );
        final isMatchingClass = p.classLevel
                .toLowerCase()
                .contains(userState.studentClassId.toLowerCase()) ||
            p.classLevel.toLowerCase().contains(studentClass.toLowerCase());
        return isMatchingSubject || isMatchingClass;
      }
      return true;
    }).toList();

    final relevantCatalogPodcasts = PodcastCatalog.podcasts.where((p) {
      if (userState.subjects.isNotEmpty) {
        final isMatchingSubject = userState.subjects.any(
          (s) => s.toLowerCase() == p.subject.toLowerCase(),
        );
        final isMatchingClass = p.classLevel
                .toLowerCase()
                .contains(userState.studentClassId.toLowerCase()) ||
            p.classLevel.toLowerCase().contains(studentClass.toLowerCase());
        return isMatchingSubject || isMatchingClass;
      }
      return true;
    }).toList();

    final allPodcasts = [...relevantCustomPodcasts, ...relevantCatalogPodcasts];

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
            // ── 1. HERO BANNER GRADIENT ─────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    decoration: const BoxDecoration(
                      gradient: AltaColors.heroBannerGradient,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.20)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.school_rounded,
                                      size: 13, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(
                                    'PROGRAMME $studentClass',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.graphic_eq_rounded,
                                color: Colors.white70, size: 24),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Podcasts & Cours Audio',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Cours sonores de 6 min calibrés pour le Bac malien,\navec narration Vivienne & transcription.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: _onGeneratePressed,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: AltaColors.accent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.headphones_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Composer un cours audio ($studentClass)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Logo watermark
                  Positioned(
                    right: -24,
                    bottom: -24,
                    child: Opacity(
                      opacity: 0.12,
                      child: Image.asset(
                        'assets/images/alternia_logo.png',
                        width: 130,
                        height: 130,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 2. FILTRE PAR MATIÈRE DU PROGRAMME ──────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: availableCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final cat = availableCategories[i];
                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
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

            const SizedBox(height: 18),

            // ── 3. LISTE DES COURS AUDIO DISPONIBLES ────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AltaColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'COURS DISPONIBLES (${filteredPodcasts.length})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: textSec,
                      ),
                    ),
                  ],
                ),
                if (relevantCustomPodcasts.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AltaColors.secondary.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${relevantCustomPodcasts.length} personnalisé(s)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AltaColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
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
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.headphones_outlined,
                      size: 40,
                      color: AltaColors.secondary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aucun cours audio dans cette matière pour $studentClass.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tu peux composer instantanément ce cours audio adapté au programme officiel malien.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: textSec,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AltaColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _onGeneratePressed,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Composer ce cours'),
                    ),
                  ],
                ),
              )
            else ...[
              for (final podcast in filteredPodcasts)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PodcastPlayerScreen(podcast: podcast),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: podcast.isCustomGenerated
                            ? AltaColors.secondary.withValues(alpha: 0.50)
                            : borderCol,
                        width: podcast.isCustomGenerated ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.18 : 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Colored accent top strip
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: podcast.accentColor,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Subject icon box
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: podcast.accentColor
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: podcast.accentColor
                                        .withValues(alpha: 0.30),
                                  ),
                                ),
                                child: Icon(
                                  podcast.icon,
                                  color: podcast.accentColor,
                                  size: 25,
                                ),
                              ),
                              const SizedBox(width: 13),

                              // Info column
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
                                                horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: podcast.accentColor
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              podcast.subject.toUpperCase(),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: podcast.accentColor,
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
                                    const SizedBox(height: 5),
                                    Text(
                                      podcast.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: textPri,
                                        height: 1.25,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      podcast.summary,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: textSec,
                                        height: 1.35,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Action column
                              Column(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AltaColors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  if (podcast.isCustomGenerated) ...[
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () =>
                                          _deleteCustomPodcast(podcast),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18,
                                        color: AltaColors.error
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
