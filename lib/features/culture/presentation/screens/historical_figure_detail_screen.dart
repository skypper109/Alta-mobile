import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/controllers/culture_data_providers.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/models/cultural_guide_models.dart';
import '../../core/models/culture_detail_models.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import '../../../../core/services/vivienne_tts_service.dart';
import '../widgets/ask_cultural_guide_button.dart';
import '../widgets/character_motion_hero.dart';
import '../widgets/connected_contents_section.dart';
import '../widgets/documentary_scene_player.dart';
import '../widgets/historical_figure_motion_player.dart';
import '../widgets/historical_sacred_parchment_card.dart';
import '../widgets/passport_stamp_toast.dart';

/// Fiche de consultation immersive d'un Grand Personnage Historique
/// Sublimée avec du Motion Design 2D de classe mondiale (Soundiata Keïta, Mansa Moussa, etc.)
class HistoricalFigureDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final HistoricalFigureDetail? figure;
  final String? heroTag;
  final bool startInReadingMode;
  final int initialChapterIndex;

  const HistoricalFigureDetailScreen({
    super.key,
    required this.id,
    this.figure,
    this.heroTag,
    this.startInReadingMode = false,
    this.initialChapterIndex = 0,
  });

  @override
  ConsumerState<HistoricalFigureDetailScreen> createState() =>
      _HistoricalFigureDetailScreenState();
}

class _HistoricalFigureDetailScreenState
    extends ConsumerState<HistoricalFigureDetailScreen> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;
  bool _isBookmarked = false;

  // Gestion de l'affichage prioritaire de l'épopée vidéo et du mode lecture
  bool _showReadingSection = false;
  int _activeChapterIndex = 0;
  final GlobalKey _readingSectionKey = GlobalKey();
  final GlobalKey _playerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _showReadingSection = widget.startInReadingMode;
    _activeChapterIndex = widget.initialChapterIndex;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _scrollToPlayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_playerKey.currentContext != null) {
        Scrollable.ensureVisible(
          _playerKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _openReadingSection() {
    setState(() {
      _showReadingSection = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_readingSectionKey.currentContext != null) {
        Scrollable.ensureVisible(
          _readingSectionKey.currentContext!,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final scrolled = _scrollController.offset > 120;
    if (scrolled != _isScrolled) {
      setState(() {
        _isScrolled = scrolled;
      });
    }
  }

  @override
  void deactivate() {
    try {
      VivienneTtsService.instance.stop();
    } catch (_) {}
    super.deactivate();
  }

  @override
  void dispose() {
    try {
      VivienneTtsService.instance.stop();
    } catch (_) {}
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    final nextState = !_isBookmarked;
    CulturalHaptics.bookmarkToggle(nextState);
    setState(() {
      _isBookmarked = nextState;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked
              ? 'Ajouté à vos découvertes enregistrées'
              : 'Retiré des découvertes enregistrées',
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: CultureTheme.primaryDark,
      ),
    );
  }

  Widget _buildTopActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color borderCol,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _isScrolled
              ? (isDark
                  ? CultureTheme.darkSurfaceAlt
                  : const Color(0xFFF1F5F9))
              : Colors.black.withValues(alpha: 0.52),
          shape: BoxShape.circle,
          border: Border.all(
            color: _isScrolled
                ? borderCol
                : Colors.white.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isScrolled ? 0.08 : 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ??
              (_isScrolled
                  ? (isDark ? Colors.white : const Color(0xFF0F172A))
                  : Colors.white),
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = widget.figure != null
        ? null
        : ref.watch(historicalFigureDetailProvider(widget.id));
    final item = widget.figure ?? detailAsync?.valueOrNull;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (item == null) {
      return Scaffold(
        backgroundColor:
            isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? CultureTheme.orPatrimoine : CultureTheme.primaryDark,
          ),
        ),
      );
    }

    final activeRegion = ref.watch(activeCultureRegionProvider).activeRegion;

    // Enregistrement automatique de la découverte dans le Passeport Culturel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final added = ref.read(culturePassportProvider.notifier).recordDiscovery(
            id: item.id,
            type: PassportItemType.personnage,
            title: item.name,
            subtitle: item.titleHonorifique,
            regionId: item.regionId,
            regionName: item.regionName,
            photoUrl: item.photoUrl,
            tag: item.tag,
            culturalQuote: item.citationHistorique,
            targetRoute: '/culture/personnage/${item.id}',
          );
      if (added && context.mounted) {
        PassportStampToast.show(
          context,
          title: item.name,
          type: PassportItemType.personnage,
        );
      }
    });

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final topPadding = MediaQuery.paddingOf(context).top;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        VivienneTtsService.instance.stop();
      },
      child: Scaffold(
        backgroundColor:
            isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground,
        body: Stack(
          children: [
            // ── CONTENU DÉFILANT AVEC MOTION DESIGN ──────────────────────────
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── 1. HERO 2D MOTION DESIGN (AURA + PARTICULES + TILT) ───────
                if (!widget.startInReadingMode)
                  SliverToBoxAdapter(
                    child: CharacterMotionHero(
                      figure: item,
                      heroTag: widget.heroTag ?? 'culture_figure_${item.id}',
                      onBack: () {
                        VivienneTtsService.instance.stop();
                        Navigator.of(context).pop();
                      },
                      isBookmarked: _isBookmarked,
                      onToggleBookmark: _toggleBookmark,
                      onPlayEpic: _scrollToPlayer,
                    ),
                  ),

                // ── 2. CORPS ÉDITORIAL & ÉPOPÉE INTERACTIVE ───────────────────
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    widget.startInReadingMode ? (topPadding + 56) : 20,
                    20,
                    40,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Contexte régional transversal si actif
                      if (activeRegion != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: CultureTheme.orPatrimoine,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Région active : ${activeRegion.nom}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: CultureTheme.orPatrimoine,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Bannière spéciale d'indication et raccourci vidéo quand le mode lecture est actif
                      if (widget.startInReadingMode) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: CultureTheme.darkSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: CultureTheme.orPatrimoine.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: CultureTheme.orPatrimoine.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: CultureTheme.orPatrimoine,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.name} • Récit & Décrets',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: CultureTheme.sable,
                                      ),
                                    ),
                                    Text(
                                      'Lecture intégrale de l\'épopée historique',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        color: CultureTheme.sable.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  VivienneTtsService.instance.stop();
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.push('/culture/personnage/${item.id}/reel');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.accentOrange,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Vidéo',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
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
                      ],

                      // ── 1. EN 1ÈRE POSITION : LECTEUR ÉPOPÉE MOTION DESIGN (CINÉMATIQUE & INTERACTIF) ──
                      if (!widget.startInReadingMode)
                        KeyedSubtree(
                          key: _playerKey,
                          child: HistoricalFigureMotionPlayer(
                            figure: item,
                            isDark: isDark,
                            initialChapterIndex: _activeChapterIndex,
                            onChapterChanged: (idx) {
                              setState(() {
                                _activeChapterIndex = idx;
                              });
                            },
                            onReadingModeRequested: _openReadingSection,
                          ),
                        ),

                      // ── 2. SI L'UTILISATEUR VEUT LIRE : AFFICHAGE DU RÉCIT SANS REDONDANCE ──
                      if (_showReadingSection) ...[
                        KeyedSubtree(
                          key: _readingSectionKey,
                          child: DocumentaryScenePlayer(
                            figure: item,
                            isDark: isDark,
                            initialSceneIndex: _activeChapterIndex,
                            onSceneChanged: (idx) {
                              setState(() {
                                _activeChapterIndex = idx;
                              });
                            },
                            onCloseReadingMode: () {
                              setState(() {
                                _showReadingSection = false;
                              });
                            },
                          ),
                        ),
                      ] else ...[
                        GestureDetector(
                          key: const ValueKey('open_reading_mode_button'),
                          onTap: _openReadingSection,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? CultureTheme.darkSurface
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderCol),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                      alpha: isDark ? 0.2 : 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.orPatrimoine
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    size: 18,
                                    color: CultureTheme.orPatrimoine,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mode Lecture & Scènes Documentaires',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: titleColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Consulter le récit textuel complet et les citations historiques',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 13,
                                  color: CultureTheme.orPatrimoine,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── 3. PARCHEMIN SACRÉ & DÉCRET HISTORIQUE FONDATEUR ──
                      HistoricalSacredParchmentCard(
                        figure: item,
                        isDark: isDark,
                      ),

                      // ── 3. REPÈRES CLÉS & HÉRITAGE (GRILLE ÉLEVÉE ET RESPONSIVE) ──
                      if (item.keyFacts.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildKeyFactsSection(item, isDark),
                      ],

                      const SizedBox(height: 24),

                      // ── Bouton Guide Culturel IA Contextuel ─────────────────
                      AskCulturalGuideButton(
                        contextData: CulturalGuideContext(
                          contentType: CulturalContentType.personnage,
                          contentId: item.id,
                          contentTitle: item.name,
                          subtitle: item.titleHonorifique,
                          regionId: item.regionId,
                          regionName: item.regionName,
                          photoUrl: item.photoUrl,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── CONTENUS ASSOCIÉS & MAILLAGE CULTUREL ───────────────
                      ConnectedContentsSection(
                        items: item.connectedItems,
                        title: 'Patrimoine & Figures Liés',
                      ),
                    ]),
                  ),
                ),
              ],
            ),

            // ── HEADER UNIQUE FIGÉ EN HAUT (AUCUNE DUPLICATION) ───────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.only(
                  top: topPadding > 0 ? topPadding + 6 : 14,
                  bottom: 10,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: (_isScrolled || widget.startInReadingMode)
                      ? (isDark
                          ? CultureTheme.darkSurface.withValues(alpha: 0.96)
                          : Colors.white.withValues(alpha: 0.96))
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: (_isScrolled || widget.startInReadingMode)
                          ? borderCol
                          : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  boxShadow: (_isScrolled || widget.startInReadingMode)
                      ? [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.35 : 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Bouton Retour unique
                    _buildTopActionButton(
                      icon: Icons.arrow_back_rounded,
                      isDark: isDark,
                      borderCol: borderCol,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        VivienneTtsService.instance.stop();
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    // Centre : Titre en mode lecture ou quand scrolled, sinon Badge pill
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: (_isScrolled || widget.startInReadingMode)
                            ? Align(
                                key: const ValueKey('header_title_scrolled'),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.startInReadingMode
                                      ? '${item.name} • Mode Lecture'
                                      : item.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: titleColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Center(
                                key: const ValueKey('header_pill_unscrolled'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.darkSurface
                                        .withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: CultureTheme.orPatrimoine
                                          .withValues(alpha: 0.6),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: CultureTheme.orPatrimoine,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          item.id.contains('soundiata')
                                              ? 'ÉPOPÉE DU MANDEN'
                                              : item.tag.toUpperCase(),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: CultureTheme.orPatrimoine,
                                            letterSpacing: 0.8,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Bouton Favori unique
                    _buildTopActionButton(
                      icon: _isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      iconColor: _isBookmarked
                          ? CultureTheme.orPatrimoine
                          : (_isScrolled && !isDark
                              ? const Color(0xFF0F172A)
                              : Colors.white),
                      isDark: isDark,
                      borderCol: borderCol,
                      onTap: _toggleBookmark,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Repères historiques clés affichés de manière concise sans dupliquer l'épopée
  Widget _buildKeyFactsSection(HistoricalFigureDetail item, bool isDark) {
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.military_tech_rounded,
              size: 20,
              color: CultureTheme.orPatrimoine,
            ),
            const SizedBox(width: 8),
            Text(
              'Repères Clés & Héritage',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: titleColor,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isVeryNarrow = constraints.maxWidth < 340;
            final cardWidth = isVeryNarrow
                ? constraints.maxWidth
                : (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: item.keyFacts.map((fact) {
                return SizedBox(
                  width: cardWidth,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: CultureTheme.orPatrimoine.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            fact.icon,
                            size: 18,
                            color: CultureTheme.orPatrimoine,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          fact.label.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: subtitleColor,
                            letterSpacing: 0.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fact.value,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
