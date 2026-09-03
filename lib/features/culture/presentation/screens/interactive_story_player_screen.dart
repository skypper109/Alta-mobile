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
    HapticFeedback.mediumImpact();
    ref.read(narrationCoordinatorProvider.notifier).stop();
    setState(() {
      _selectedChoiceId = choice.id;
    });

    Future.delayed(const Duration(milliseconds: 280), () {
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
                                color: CultureTheme.rougeKoulikoro,
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
                                ? CultureTheme.rougeKoulikoro
                                : CultureTheme.rougeKoulikoro.withValues(
                                    alpha: 0.12,
                                  ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: CultureTheme.rougeKoulikoro.withValues(
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
                                    : CultureTheme.rougeKoulikoro,
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
                                      : CultureTheme.rougeKoulikoro,
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
                        CultureTheme.rougeKoulikoro,
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
                      // ── 1. BANDEAU D'ATMOSPHÈRE SENSORIELLE ───────────────
                      if (_currentScene.atmosphere != null &&
                          _currentScene.atmosphere!.isNotEmpty) ...[
                        AnimatedCulturalReveal(
                          delay: const Duration(milliseconds: 40),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: CultureTheme.rougeKoulikoro.withValues(
                                alpha: isDark ? 0.20 : 0.08,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: CultureTheme.rougeKoulikoro.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.wb_twilight_rounded,
                                  size: 14,
                                  color: CultureTheme.rougeKoulikoro,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _currentScene.atmosphere!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: CultureTheme.rougeKoulikoro,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ── 2. TITRE DE LA SCÈNE ──────────────────────────────
                      AnimatedCulturalReveal(
                        delay: const Duration(milliseconds: 70),
                        child: Text(
                          _currentScene.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: titleColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── 3. TEXTE NARRATIF RÉVÉLÉ PAR PARAGRAPHES (STAGGERED)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderCol),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.22 : 0.04,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CulturalSectionReveal(
                          baseDelay: const Duration(milliseconds: 90),
                          itemDelay: const Duration(milliseconds: 70),
                          children: paragraphs.map((paragraph) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                paragraph,
                                style: GoogleFonts.merriweather(
                                  fontSize: 14.5,
                                  height: 1.75,
                                  color: isDark
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF334155),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
                          delay: const Duration(milliseconds: 220),
                          child: Text(
                            'QUE DÉCIDEZ-VOUS ?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: CultureTheme.rougeKoulikoro,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(_currentScene.choices.length, (idx) {
                          final choice = _currentScene.choices[idx];
                          final isSelected = _selectedChoiceId == choice.id;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AnimatedCulturalReveal(
                              delay: Duration(milliseconds: 240 + (idx * 50)),
                              child: InteractiveChoiceCard(
                                label: choice.label,
                                subtitle: choice.description,
                                state: isSelected
                                    ? ChoiceCardState.selected
                                    : ChoiceCardState.normal,
                                accentColor: CultureTheme.rougeKoulikoro,
                                onTap: () => _onChoiceSelected(choice),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.rougeKoulikoro
                                        .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    choice.icon,
                                    size: 18,
                                    color: CultureTheme.rougeKoulikoro,
                                  ),
                                ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Morale traditionnelle du Griot
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CultureTheme.orPatrimoine,
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
                    color: CultureTheme.orPatrimoine,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SAGESSE DU GRIOT • LA MORALE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? CultureTheme.orPatrimoine
                          : const Color(0xFFB45309),
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
                    color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _restartStory,
                icon: const Icon(
                  Icons.replay_rounded,
                  size: 16,
                  color: CultureTheme.rougeKoulikoro,
                ),
                label: Text(
                  'Rejouer d\'autres choix',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CultureTheme.rougeKoulikoro,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CultureTheme.rougeKoulikoro,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (context.canPop()) context.pop();
                },
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  'Terminer l\'aventure',
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
