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
import '../../immersive/controllers/narration_coordinator.dart';
import '../widgets/connected_contents_section.dart';
import '../widgets/culture_audio_listen_badge.dart';
import '../widgets/passport_stamp_toast.dart';
import '../widgets/story_audio_player_sheet.dart';

/// Écran de lecture continue du conte avec écoute orale simultanée (Voix du Griot)
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class StoryReaderScreen extends ConsumerStatefulWidget {
  final String id;
  final InteractiveStory? story;

  const StoryReaderScreen({super.key, required this.id, this.story});

  @override
  ConsumerState<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends ConsumerState<StoryReaderScreen> {
  double _fontSize = 15.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final story =
          widget.story ?? MockCultureStoriesData.getStoryById(widget.id);
      final added = ref.read(culturePassportProvider.notifier).recordDiscovery(
            id: story.id,
            type: PassportItemType.conte,
            title: story.title,
            subtitle: story.subtitle,
            regionId: story.regionId,
            regionName: story.regionName,
            photoUrl: story.photoUrl,
            tag: story.tag,
            culturalQuote: story.moral,
            targetRoute: '/culture/conte/${story.id}',
          );
      if (added && mounted) {
        PassportStampToast.show(
          context,
          title: story.title,
          type: PassportItemType.conte,
        );
      }
    });
  }

  @override
  void dispose() {
    ref.read(narrationCoordinatorProvider.notifier).stop();
    super.dispose();
  }

  void _toggleFullStoryAudio(InteractiveStory story) {
    HapticFeedback.mediumImpact();
    final coordinator = ref.read(narrationCoordinatorProvider.notifier);
    final snapshot = ref.read(narrationCoordinatorProvider);

    final fullStoryId = '${story.id}_full_read';
    if (snapshot.isSpeaking && snapshot.activeContentId == fullStoryId) {
      coordinator.stop();
    } else {
      final textToSpeak =
          '${story.title}. Récit raconté par ${story.narrator}. '
          '${story.scenes.map((s) => 'Scène ${s.sceneNumber} : ${s.title}. ${s.narrativeText}').join(' ')} '
          'Morale du conte : ${story.moral}';
      coordinator.speak(textToSpeak, contentId: fullStoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final story =
        widget.story ?? MockCultureStoriesData.getStoryById(widget.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    final bgColor =
        isDark ? CultureTheme.darkBackground : const Color(0xFFFAF7F2);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final narration = ref.watch(narrationCoordinatorProvider);
    final fullStoryId = '${story.id}_full_read';
    final isFullStoryPlaying =
        narration.isSpeaking && narration.activeContentId == fullStoryId;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── 1. BARRE SUPÉRIEURE DE LECTURE ───────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 12),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(bottom: BorderSide(color: borderCol)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(narrationCoordinatorProvider.notifier).stop();
                      if (context.canPop()) context.pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? CultureTheme.darkSurfaceAlt
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 20, color: titleColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lecture & Écoute du Conte',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                        Text(
                          story.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Contrôles de taille de texte
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _fontSize = (_fontSize - 1.0).clamp(13.0, 20.0);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? CultureTheme.darkSurfaceAlt
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'A-',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _fontSize = (_fontSize + 1.0).clamp(13.0, 20.0);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? CultureTheme.darkSurfaceAlt
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'A+',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 2. BARRE D'ÉCOUTE DU GRIOT (TTS SIMULTANÉ) ────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? CultureTheme.darkSurfaceAlt
                    : const Color(0xFFFFF7ED),
                border: Border(bottom: BorderSide(color: borderCol)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleFullStoryAudio(story),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CultureTheme.accentOrange,
                        shape: BoxShape.circle,
                        boxShadow: isFullStoryPlaying
                            ? [
                                BoxShadow(
                                  color: CultureTheme.accentOrange
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isFullStoryPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFullStoryPlaying
                              ? 'Le Griot raconte le conte...'
                              : 'Écouter la veillée complète',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF9A3412),
                          ),
                        ),
                        Text(
                          'Récité par ${story.narrator}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Modal complet
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      StoryAudioPlayerSheet.show(context, story);
                    },
                    icon: const Icon(Icons.headphones_rounded,
                        size: 14, color: CultureTheme.accentOrange),
                    label: Text(
                      'Lecteur',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 3. CORPS DU CONTE ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vignette photographique & Origine
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderCol),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: Image.asset(
                          story.photoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Badges
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: CultureTheme.accentOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            story.tag.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? CultureTheme.darkSurfaceAlt
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderCol),
                          ),
                          child: Text(
                            story.origin,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Titre
                    Text(
                      story.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Récité par ${story.narrator}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: borderCol),
                    const SizedBox(height: 16),

                    // Scènes et chapitres successifs
                    ...story.scenes.map((scene) {
                      final sceneAudioId =
                          '${story.id}_sc_${scene.sceneNumber}';
                      final isScenePlaying = narration.isSpeaking &&
                          narration.activeContentId == sceneAudioId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Container(
                          padding: isScenePlaying
                              ? const EdgeInsets.all(12)
                              : EdgeInsets.zero,
                          decoration: isScenePlaying
                              ? BoxDecoration(
                                  color: isDark
                                      ? CultureTheme.darkSurfaceAlt
                                      : const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: CultureTheme.accentOrange
                                        .withValues(alpha: 0.4),
                                  ),
                                )
                              : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: CultureTheme.accentOrange
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${scene.sceneNumber}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: CultureTheme.accentOrange,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      scene.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: titleColor,
                                      ),
                                    ),
                                  ),
                                  // Écoute spécifique de la scène
                                  CultureAudioListenBadge(
                                    contentId: sceneAudioId,
                                    speechText:
                                        '${scene.title}. ${scene.narrativeText}',
                                    label: 'Écouter',
                                    compact: true,
                                    activeColor: CultureTheme.accentOrange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                scene.narrativeText,
                                style: GoogleFonts.merriweather(
                                  fontSize: _fontSize,
                                  height: 1.75,
                                  color: isDark
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF334155),
                                ),
                              ),
                              if (scene.culturalInsight != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? CultureTheme.darkSurfaceAlt
                                        : const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: CultureTheme.accentOrange
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    scene.culturalInsight!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF9A3412),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),

                    // ── 4. MORALE DU CONTE AVEC ÉCOUTE AUDIO ──────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? CultureTheme.darkSurfaceAlt
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              CultureTheme.accentOrange.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SAGESSE & MORALE DU CONTE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                              const Spacer(),
                              CultureAudioListenBadge(
                                contentId: '${story.id}_moral',
                                speechText:
                                    'Voici la morale du conte ${story.title} : ${story.moral}',
                                label: 'Écouter la morale',
                                compact: true,
                                activeColor: CultureTheme.accentOrange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            story.moral,
                            style: GoogleFonts.merriweather(
                              fontSize: 13,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                              color: isDark
                                  ? const Color(0xFFFED7AA)
                                  : const Color(0xFF78350F),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── 5. CONTENUS ASSOCIÉS ─────────────────────────────────
                    ConnectedContentsSection(items: story.connectedItems),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
