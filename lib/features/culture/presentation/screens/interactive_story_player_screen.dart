import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/datasources/mock_culture_stories_data.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/models/culture_story_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';
import '../widgets/connected_contents_section.dart';

/// Moteur immersif de Narration Interactive Scène par Scène
/// Refactorisation cinématique avec transitions de scènes fluides, bandeau d'atmosphère,
/// révélation progressive du texte par paragraphes, coordinateur de narration et célébration d'épilogue.
class InteractiveStoryPlayerScreen extends ConsumerStatefulWidget {
  final String id;
  final InteractiveStory? story;

  const InteractiveStoryPlayerScreen({
    super.key,
    required this.id,
    this.story,
  });

  @override
  ConsumerState<InteractiveStoryPlayerScreen> createState() =>
      _InteractiveStoryPlayerScreenState();
}

class _InteractiveStoryPlayerScreenState
    extends ConsumerState<InteractiveStoryPlayerScreen> {
  late InteractiveStory _story;
  late StoryScene _currentScene;
  final List<String> _visitedSceneIds = [];
  String? _selectedChoiceId;
  bool _hasTriggeredCelebrationForScene = false;

  @override
  void initState() {
    super.initState();
    _story = widget.story ?? MockCultureStoriesData.getStoryById(widget.id);
    _currentScene = _story.initialScene;
    _visitedSceneIds.add(_currentScene.id);
  }

  void _toggleTtsNarration() {
    HapticFeedback.lightImpact();
    final text =
        '${_currentScene.title}. ${_currentScene.narrativeText} ${_currentScene.culturalInsight ?? ''}';
    ref.read(narrationCoordinatorProvider.notifier).toggle(text);
  }

  void _onChoiceSelected(StoryChoice choice) {
    CulturalHaptics.stamp();
    ref.read(narrationCoordinatorProvider.notifier).stop();
    setState(() {
      _selectedChoiceId = choice.id;
    });

    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      final nextScene = _story.getSceneById(choice.nextSceneId);
      if (nextScene != null) {
        setState(() {
          _currentScene = nextScene;
          _selectedChoiceId = null;
          _hasTriggeredCelebrationForScene = false;
          if (!_visitedSceneIds.contains(nextScene.id)) {
            _visitedSceneIds.add(nextScene.id);
          }
        });

        // Gestion de l'épilogue et célébration solennelle
        if (nextScene.isEpilogue) {
          _handleEpilogueReached();
        }
      }
    });
  }

  void _handleEpilogueReached() {
    final added = ref.read(culturePassportProvider.notifier).recordDiscovery(
          id: _story.id,
          type: PassportItemType.conte,
          title: _story.title,
          subtitle: _story.subtitle,
          regionId: _story.regionId,
          regionName: _story.regionName,
          photoUrl: _story.photoUrl,
          tag: _story.tag,
          culturalQuote: _story.moral,
          targetRoute: '/culture/conte/${_story.id}',
        );

    if (added && !_hasTriggeredCelebrationForScene && mounted) {
      _hasTriggeredCelebrationForScene = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        CulturalBadgeCelebration.show(
          context: context,
          title: 'Nouveau Tampon Culturel',
          subtitle:
              'Votre voyage dans « ${_story.title} » enrichit votre Passeport Culturel.',
          category: 'Passeport Culturel',
          xpGained: 50,
          badgeIcon: Icons.auto_awesome_rounded,
          photoUrl: _story.photoUrl,
        );
      });
    }
  }

  void _restartStory() {
    HapticFeedback.mediumImpact();
    ref.read(narrationCoordinatorProvider.notifier).stop();
    setState(() {
      _currentScene = _story.initialScene;
      _visitedSceneIds.clear();
      _visitedSceneIds.add(_currentScene.id);
      _selectedChoiceId = null;
      _hasTriggeredCelebrationForScene = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;
    final narrationState = ref.watch(narrationCoordinatorProvider);

    final bgColor =
        isDark ? CultureTheme.darkBackground : const Color(0xFFFAF7F2);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final progressRatio =
        (_visitedSceneIds.length / _story.scenes.length).clamp(0.1, 1.0);

    // Découpage du texte narratif en paragraphes pour une révélation progressive fluide
    final paragraphs = _currentScene.narrativeText
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    final castConfig = StoryCastConfig.forStory(
      _story.id,
      fallbackImage: _story.photoUrl,
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── BARRE DE CONTRÔLE SUPÉRIEURE DU CONTE ───────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 12),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(bottom: BorderSide(color: borderCol)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Bouton Quitter
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(narrationCoordinatorProvider.notifier).stop();
                          if (context.canPop()) context.pop();
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark
                                ? CultureTheme.darkSurfaceAlt
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: titleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Titre et Scène
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _story.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _currentScene.isEpilogue
                                  ? 'Épilogue & Morale sacrée'
                                  : 'Scène ${_currentScene.sceneNumber} / ${_story.scenes.length}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: CultureTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bouton Voix du Griot (TTS orchestré par NarrationCoordinator)
                      GestureDetector(
                        onTap: _toggleTtsNarration,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: narrationState.isSpeaking
                                ? CultureTheme.accentOrange
                                : CultureTheme.accentOrange.withValues(
                                    alpha: 0.12,
                                  ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: CultureTheme.accentOrange.withValues(
                                alpha: narrationState.isSpeaking ? 1.0 : 0.25,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                narrationState.isSpeaking
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_mute_rounded,
                                size: 16,
                                color: narrationState.isSpeaking
                                    ? Colors.white
                                    : CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                narrationState.isSpeaking
                                    ? 'Narrateur'
                                    : 'Écouter',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: narrationState.isSpeaking
                                      ? Colors.white
                                      : CultureTheme.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Indicateur de narration en cours si le Griot parle
                  if (narrationState.isSpeaking) ...[
                    const SizedBox(height: 8),
                    AnimatedCulturalReveal(
                      duration: const Duration(milliseconds: 220),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.record_voice_over_rounded,
                            size: 13,
                            color: CultureTheme.accentOrange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Parole du Griot en cours…',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: CultureTheme.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Jauge de progression
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 3.5,
                      backgroundColor:
                          isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        CultureTheme.accentOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── ZONE NARRATIVE SCÈNE PAR SCÈNE AVEC TRANSITION CINÉMATIQUE ───
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.98, end: 1.00).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.02),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    ),
                  );
                },
                child: SingleChildScrollView(
                  key: ValueKey<String>(_currentScene.id),
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. THÉÂTRE CINÉMATIQUE AVEC ACTEURS EN SCÈNE ─────────
                      AnimatedCulturalReveal(
                        delay: const Duration(milliseconds: 40),
                        child: _CinematicTheatricalStage(
                          scene: _currentScene,
                          castConfig: castConfig,
                          isDark: isDark,
                          borderCol: borderCol,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── 2. TITRE ET NUMÉRO DE L'ÉPISODE ───────────────────
                      AnimatedCulturalReveal(
                        delay: const Duration(milliseconds: 70),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: CultureTheme.accentOrange
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: CultureTheme.accentOrange
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                _currentScene.isEpilogue
                                    ? 'ÉPILOGUE'
                                    : 'ACTE ${_currentScene.sceneNumber}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _currentScene.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: titleColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── 3. DIALOGUES THÉÂTRAUX & RÉPLIQUES CADENCÉES ────────
                      _TheatricalDialogueBeats(
                        paragraphs: paragraphs,
                        castConfig: castConfig,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderCol: borderCol,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                      ),

                      // ── 4. ÉCLAIRAGE CULTUREL / SECRET DE TRADITION ────────
                      if (_currentScene.culturalInsight != null) ...[
                        const SizedBox(height: 14),
                        AnimatedCulturalReveal(
                          delay: const Duration(milliseconds: 200),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? CultureTheme.darkSurfaceAlt
                                  : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: CultureTheme.accentOrange.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lightbulb_rounded,
                                  color: CultureTheme.accentOrange,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _currentScene.culturalInsight!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF9A3412),
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── 5. CHOIX INTERACTIFS OU ÉPILOGUE ──────────────────
                      if (_currentScene.isEpilogue)
                        AnimatedCulturalReveal(
                          delay: const Duration(milliseconds: 240),
                          child: _buildEpilogueSection(
                            isDark,
                            cardBg,
                            borderCol,
                            titleColor,
                            subtitleColor,
                          ),
                        )
                      else ...[
                        AnimatedCulturalReveal(
                          delay: const Duration(milliseconds: 200),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.flash_on_rounded,
                                size: 14,
                                color: CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'LE DILEMME DU MANDEN • QUE DÉCIDEZ-VOUS ?',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_currentScene.choices.length, (idx) {
                          final choice = _currentScene.choices[idx];
                          final isSelected = _selectedChoiceId == choice.id;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AnimatedCulturalReveal(
                              delay: Duration(milliseconds: 220 + (idx * 50)),
                              child: _CinematicChoiceCard(
                                choice: choice,
                                isSelected: isSelected,
                                isDark: isDark,
                                cardBg: cardBg,
                                borderCol: borderCol,
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                                onTap: () => _onChoiceSelected(choice),
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION ÉPILOGUE & MORALE SACRÉE ──────────────────────────────────────
  Widget _buildEpilogueSection(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sceau royal physique estampillé
        CulturalRoyalStampAnimation(
          size: 84,
          icon: Icons.auto_awesome_rounded,
          label: 'SCEAU DU CONTE',
          color: CultureTheme.accentOrange,
          photoUrl: _story.photoUrl,
        ),
        const SizedBox(height: 12),

        // Pilule XP dynamique avec compteur roulant
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: CultureTheme.primaryBlue.withValues(alpha: isDark ? 0.25 : 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: CultureTheme.primaryBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 16,
                color: CultureTheme.primaryBlue,
              ),
              const SizedBox(width: 4),
              CulturalRollingXpCounter(
                targetXp: 50,
                prefix: '+',
                suffix: ' XP Conte',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: CultureTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Morale traditionnelle du Griot
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CultureTheme.accentOrange.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: CultureTheme.accentOrange,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SAGESSE DU GRIOT • LA MORALE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: CultureTheme.accentOrange,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _story.moral,
                style: GoogleFonts.merriweather(
                  fontSize: 14.5,
                  fontStyle: FontStyle.italic,
                  height: 1.65,
                  color: titleColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Boutons de fin de parcours
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _restartStory,
                icon: const Icon(
                  Icons.replay_rounded,
                  size: 16,
                  color: CultureTheme.accentOrange,
                ),
                label: Text(
                  'Rejouer le conte',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CultureTheme.accentOrange,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CultureTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/culture/passport');
                },
                icon: const Icon(
                  Icons.badge_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  'Voir mon Passeport',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Liens culturels associés
        ConnectedContentsSection(items: _story.connectedItems),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ── COMPOSANTS DU THÉÂTRE CINÉMATIQUE INTERACTIF ─────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════

/// Configuration d'un acteur sur scène
class StoryActorConfig {
  final String name;
  final String role;
  final String avatarPath;
  final Color accentColor;
  final String speakerTitle;
  final List<String> keywords;

  const StoryActorConfig({
    required this.name,
    required this.role,
    required this.avatarPath,
    required this.accentColor,
    required this.speakerTitle,
    required this.keywords,
  });
}

/// Configuration théâtrale complète d'un conte (décor, veillée, acteurs)
class StoryCastConfig {
  final String stageImagePath;
  final String stageTag;
  final StoryActorConfig actorLeft;
  final StoryActorConfig actorRight;

  const StoryCastConfig({
    required this.stageImagePath,
    required this.stageTag,
    required this.actorLeft,
    required this.actorRight,
  });

  static StoryCastConfig forStory(String storyId, {String? fallbackImage}) {
    switch (storyId) {
      case 'conte_wagadou_bida':
        return const StoryCastConfig(
          stageImagePath: 'assets/images/culture/contes/wagadou_koumbi_stage.jpg',
          stageTag: 'VEILLÉE DU WAGADOU',
          actorLeft: StoryActorConfig(
            name: 'Mamadou',
            role: 'Héros Soninké',
            avatarPath: 'assets/images/culture/contes/mamadou_lamine.jpg',
            accentColor: CultureTheme.cyanTurquoise,
            speakerTitle: 'MAMADOU LAMINE • LE BRAVE',
            keywords: ['mamadou', 'lamine', 'guerrier', 'cavalier', 'fiancé', 'sabre', 'étalon'],
          ),
          actorRight: StoryActorConfig(
            name: 'Wagadou Bida',
            role: 'Serpent Sacré',
            avatarPath: 'assets/images/culture/contes/wagadou_bida.jpg',
            accentColor: CultureTheme.accentOrange,
            speakerTitle: 'WAGADOU BIDA • LE SERPENT SACRÉ',
            keywords: ['wagadou', 'bida', 'serpent', 'monstre', 'puits', 'tribut', 'or', 'pacte'],
          ),
        );

      case 'conte_forgeron_oiseau':
        return const StoryCastConfig(
          stageImagePath: 'assets/images/culture/contes/segou_djoliba_stage.jpg',
          stageTag: 'VEILLÉE DU DJOLIBA',
          actorLeft: StoryActorConfig(
            name: 'Fodé',
            role: 'Apprenti Forgeron',
            avatarPath: 'assets/images/culture/contes/fode_forgeron.jpg',
            accentColor: CultureTheme.cyanTurquoise,
            speakerTitle: 'FODÉ • L\'APPRENTI FORGERON',
            keywords: ['fodé', 'fode', 'forgeron', 'apprenti', 'enclume', 'fer', 'marteau'],
          ),
          actorRight: StoryActorConfig(
            name: 'Oiseau Sacré',
            role: 'Esprit du Fleuve',
            avatarPath: 'assets/images/culture/contes/oiseau_djoliba.jpg',
            accentColor: CultureTheme.accentOrange,
            speakerTitle: 'L\'OISEAU MYSTIQUE DU DJOLIBA',
            keywords: ['oiseau', 'djoliba', 'plumes', 'esprit', 'mélodie', 'chant', 'balanzan'],
          ),
        );

      case 'conte_baobab_chasseur':
        return const StoryCastConfig(
          stageImagePath: 'assets/images/culture/contes/manden_baobab_stage.jpg',
          stageTag: 'VEILLÉE DES CHASSEURS',
          actorLeft: StoryActorConfig(
            name: 'Moussa',
            role: 'Chasseur Dozo',
            avatarPath: 'assets/images/culture/contes/moussa_chasseur.jpg',
            accentColor: CultureTheme.cyanTurquoise,
            speakerTitle: 'MOUSSA • LE JEUNE DOZO',
            keywords: ['moussa', 'chasseur', 'dozo', 'cauris', 'forêt', 'arbre'],
          ),
          actorRight: StoryActorConfig(
            name: 'Le Patriarche',
            role: 'Sage du Baobab',
            avatarPath: 'assets/images/culture/contes/sage_baobab.jpg',
            accentColor: CultureTheme.accentOrange,
            speakerTitle: 'LE SAGE AVEUGLE DU BAOBAB',
            keywords: ['sage', 'aveugle', 'patriarche', 'vieux', 'ancien', 'père', 'baobab', 'foyer'],
          ),
        );

      case 'conte_caravane_sable':
        return const StoryCastConfig(
          stageImagePath: 'assets/images/culture/contes/tombouctou_dunes_stage.jpg',
          stageTag: 'VEILLÉE DU SAHARA',
          actorLeft: StoryActorConfig(
            name: 'Bilal',
            role: 'Jeune Chamelier',
            avatarPath: 'assets/images/culture/contes/bilal_chamelier.jpg',
            accentColor: CultureTheme.cyanTurquoise,
            speakerTitle: 'BILAL • LE CARAVANIER DU DÉSERT',
            keywords: ['bilal', 'chamelier', 'caravane', 'dunes', 'chameau', 'sel', 'vent'],
          ),
          actorRight: StoryActorConfig(
            name: 'L\'Astronome',
            role: 'Gardien des Étoiles',
            avatarPath: 'assets/images/culture/contes/gardien_etoiles.jpg',
            accentColor: CultureTheme.accentOrange,
            speakerTitle: 'LE GARDIEN DES ÉTOILES • SAVANT DE TOMBOUCTOU',
            keywords: ['gardien', 'étoiles', 'savant', 'astronome', 'parchemin', 'constellation', 'tente', 'thé'],
          ),
        );

      case 'conte_lievre_hyene':
      default:
        return StoryCastConfig(
          stageImagePath: fallbackImage ?? 'assets/images/culture/contes/savane_crepuscule_stage.jpg',
          stageTag: 'VEILLÉE DU MANDEN',
          actorLeft: const StoryActorConfig(
            name: 'Zoumana',
            role: 'Le Lièvre Rusé',
            avatarPath: 'assets/images/culture/contes/zoumana_lievre.jpg',
            accentColor: CultureTheme.cyanTurquoise,
            speakerTitle: 'ZOUMANA LE LIÈVRE',
            keywords: ['zoumana', 'lièvre'],
          ),
          actorRight: const StoryActorConfig(
            name: 'Namori',
            role: 'L\'Hyène Avide',
            avatarPath: 'assets/images/culture/contes/namori_hyene.jpg',
            accentColor: CultureTheme.accentOrange,
            speakerTitle: 'NAMORI L\'HYÈNE',
            keywords: ['namori', 'hyène'],
          ),
        );
    }
  }
}

/// Scène panoramique 16:9 avec fond Ken Burns et acteurs en présence
class _CinematicTheatricalStage extends StatefulWidget {
  final StoryScene scene;
  final StoryCastConfig castConfig;
  final bool isDark;
  final Color borderCol;

  const _CinematicTheatricalStage({
    required this.scene,
    required this.castConfig,
    required this.isDark,
    required this.borderCol,
  });

  @override
  State<_CinematicTheatricalStage> createState() =>
      _CinematicTheatricalStageState();
}

class _CinematicTheatricalStageState extends State<_CinematicTheatricalStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _zoomController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lower = widget.scene.narrativeText.toLowerCase();
    final hasActorLeft = widget.castConfig.actorLeft.keywords
        .any((k) => lower.contains(k));
    final hasActorRight = widget.castConfig.actorRight.keywords
        .any((k) => lower.contains(k));

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: widget.isDark ? CultureTheme.darkSurface : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.45 : 0.20),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. FOND PANORAMIQUE AVEC DRIFT KEN BURNS ─────────────────────
            AnimatedBuilder(
              animation: _zoomAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _zoomAnimation.value,
                  child: Image.asset(
                    widget.castConfig.stageImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1E293B),
                      child: const Center(
                        child: Icon(Icons.wb_twilight_rounded,
                            size: 40, color: CultureTheme.accentOrange),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Voile sombre plat pour lisibilité (STRICTEMENT SANS DÉGRADÉ)
            Container(
              color: Colors.black.withValues(alpha: 0.30),
            ),

            // ── 2. CROCHETS D'ANGLES SOUDANO-SAHÉLIENS VECTEURS ──────────────
            const Positioned.fill(
              child: _SudaneseCornerAccents(),
            ),

            // ── 3. BANDEAU DE VEILLÉE & ATMOSPHÈRE AU SOMMET ─────────────────
            Positioned(
              top: 12,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.6),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.fireplace_rounded,
                          size: 13,
                          color: CultureTheme.accentOrange,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.castConfig.stageTag,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (widget.scene.atmosphere != null &&
                      widget.scene.atmosphere!.isNotEmpty)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                CultureTheme.cyanTurquoise.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          widget.scene.atmosphere!.split('•').first.trim(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: CultureTheme.cyanTurquoise,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── 4. ACTEURS SUR LA SCÈNE (POLYVALENTS SELON LE CONTE) ─────────
            Positioned(
              bottom: 12,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Acteur Gauche (ex: Zoumana, Mamadou, Fodé, Moussa, Bilal)
                  _ActorStageAvatar(
                    name: widget.castConfig.actorLeft.name,
                    role: widget.castConfig.actorLeft.role,
                    imagePath: widget.castConfig.actorLeft.avatarPath,
                    accentColor: widget.castConfig.actorLeft.accentColor,
                    isActive: hasActorLeft,
                    isLeft: true,
                  ),

                  // Acteur Droite (ex: Namori, Wagadou Bida, Oiseau, Sage, Gardien)
                  _ActorStageAvatar(
                    name: widget.castConfig.actorRight.name,
                    role: widget.castConfig.actorRight.role,
                    imagePath: widget.castConfig.actorRight.avatarPath,
                    accentColor: widget.castConfig.actorRight.accentColor,
                    isActive: hasActorRight,
                    isLeft: false,
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

/// Avatar animé d'un acteur sur la scène de théâtre
class _ActorStageAvatar extends StatefulWidget {
  final String name;
  final String role;
  final String imagePath;
  final Color accentColor;
  final bool isActive;
  final bool isLeft;

  const _ActorStageAvatar({
    required this.name,
    required this.role,
    required this.imagePath,
    required this.accentColor,
    required this.isActive,
    required this.isLeft,
  });

  @override
  State<_ActorStageAvatar> createState() => _ActorStageAvatarState();
}

class _ActorStageAvatarState extends State<_ActorStageAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breatheController;
  late final Animation<double> _breatheAnim;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isLeft ? 2400 : 2800),
    )..repeat(reverse: true);

    _breatheAnim = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(
        parent: _breatheController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breatheAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? (_breatheAnim.value * 1.05) : 0.96,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Portrait circulaire avec cadre couleur
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(
                    color: widget.isActive
                        ? widget.accentColor
                        : Colors.white.withValues(alpha: 0.4),
                    width: widget.isActive ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isActive ? widget.accentColor : Colors.black)
                          .withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.pets_rounded,
                      size: 28,
                      color: widget.accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Badge étiquette du personnage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isActive
                        ? widget.accentColor
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isActive) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accentColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      widget.name.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Crochets d'angles traditionnels soudano-sahéliens
class _SudaneseCornerAccents extends StatelessWidget {
  const _SudaneseCornerAccents();

  @override
  Widget build(BuildContext context) {
    const strokeW = 2.0;
    const cornerSize = 14.0;
    const accentCol = CultureTheme.accentOrange;

    return CustomPaint(
      painter: _CornerPainter(
        color: accentCol,
        strokeWidth: strokeW,
        cornerSize: cornerSize,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerSize;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const pad = 8.0;

    // Haut-Gauche
    canvas.drawLine(
        Offset(pad, pad + cornerSize), const Offset(pad, pad), paint);
    canvas.drawLine(
        const Offset(pad, pad), Offset(pad + cornerSize, pad), paint);

    // Haut-Droite
    canvas.drawLine(Offset(size.width - pad - cornerSize, pad),
        Offset(size.width - pad, pad), paint);
    canvas.drawLine(Offset(size.width - pad, pad),
        Offset(size.width - pad, pad + cornerSize), paint);

    // Bas-Gauche
    canvas.drawLine(Offset(pad, size.height - pad - cornerSize),
        Offset(pad, size.height - pad), paint);
    canvas.drawLine(Offset(pad, size.height - pad),
        Offset(pad + cornerSize, size.height - pad), paint);

    // Bas-Droite
    canvas.drawLine(Offset(size.width - pad - cornerSize, size.height - pad),
        Offset(size.width - pad, size.height - pad), paint);
    canvas.drawLine(Offset(size.width - pad, size.height - pad - cornerSize),
        Offset(size.width - pad, size.height - pad), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Découpage et présentation théâtralisée des répliques et didascalies
class _TheatricalDialogueBeats extends StatelessWidget {
  final List<String> paragraphs;
  final StoryCastConfig castConfig;
  final bool isDark;
  final Color cardBg;
  final Color borderCol;
  final Color titleColor;
  final Color subtitleColor;

  const _TheatricalDialogueBeats({
    required this.paragraphs,
    required this.castConfig,
    required this.isDark,
    required this.cardBg,
    required this.borderCol,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(paragraphs.length, (index) {
        final text = paragraphs[index];
        final lower = text.toLowerCase();

        final isActorLeft =
            castConfig.actorLeft.keywords.any((k) => lower.contains(k));
        final isActorRight =
            castConfig.actorRight.keywords.any((k) => lower.contains(k)) &&
                !isActorLeft;
        final isGriotIntro = index == 0 && !isActorLeft && !isActorRight;

        Color speakerColor;
        String speakerName;
        IconData speakerIcon;
        String avatarPath;

        if (isActorLeft) {
          speakerColor = castConfig.actorLeft.accentColor;
          speakerName = castConfig.actorLeft.speakerTitle;
          speakerIcon = Icons.stars_rounded;
          avatarPath = castConfig.actorLeft.avatarPath;
        } else if (isActorRight) {
          speakerColor = castConfig.actorRight.accentColor;
          speakerName = castConfig.actorRight.speakerTitle;
          speakerIcon = Icons.auto_awesome_rounded;
          avatarPath = castConfig.actorRight.avatarPath;
        } else {
          speakerColor = CultureTheme.primaryBlue;
          speakerName = 'LE GRIOT • VOIX DE LA VEILLÉE';
          speakerIcon = Icons.record_voice_over_rounded;
          avatarPath = 'assets/images/culture/griot_sage.jpg';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedCulturalReveal(
            delay: Duration(milliseconds: 70 * index),
            offset: const Offset(0.0, 0.04),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: speakerColor.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête du locuteur
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: speakerColor.withValues(alpha: 0.15),
                          border: Border.all(color: speakerColor, width: 1.2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            avatarPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              speakerIcon,
                              size: 14,
                              color: speakerColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        speakerName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: speakerColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Texte de réplique ou narration théâtralisée
                  Text(
                    text,
                    style: isGriotIntro
                        ? GoogleFonts.merriweather(
                            fontSize: 14.5,
                            height: 1.75,
                            fontStyle: FontStyle.italic,
                            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                          )
                        : GoogleFonts.merriweather(
                            fontSize: 14.5,
                            height: 1.7,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Carte de choix de dilemme cinématographique avec retour élastique
class _CinematicChoiceCard extends StatefulWidget {
  final StoryChoice choice;
  final bool isSelected;
  final bool isDark;
  final Color cardBg;
  final Color borderCol;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _CinematicChoiceCard({
    required this.choice,
    required this.isSelected,
    required this.isDark,
    required this.cardBg,
    required this.borderCol,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  State<_CinematicChoiceCard> createState() => _CinematicChoiceCardState();
}

class _CinematicChoiceCardState extends State<_CinematicChoiceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.975 : (widget.isSelected ? 1.015 : 1.0),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? CultureTheme.accentOrange.withValues(alpha: 0.15)
                : widget.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected
                  ? CultureTheme.accentOrange
                  : widget.borderCol,
              width: widget.isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: widget.isDark ? 0.22 : 0.04,
                ),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(
                    alpha: widget.isSelected ? 1.0 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.choice.icon,
                  size: 20,
                  color: widget.isSelected
                      ? Colors.white
                      : CultureTheme.accentOrange,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.choice.trait != null &&
                        widget.choice.trait!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: CultureTheme.accentOrange
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.choice.trait!.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                    Text(
                      widget.choice.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: widget.isSelected
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: widget.titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.choice.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: widget.subtitleColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: widget.isSelected
                    ? CultureTheme.accentOrange
                    : widget.subtitleColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
