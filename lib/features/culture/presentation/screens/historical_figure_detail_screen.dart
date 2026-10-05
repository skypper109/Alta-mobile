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
import '../widgets/passport_stamp_toast.dart';
import '../widgets/soundiata_epic_story_view.dart';
import '../widgets/soundiata_living_book_view.dart';

/// Fiche de consultation immersive d'un Grand Personnage Historique
/// Sublimée avec du Motion Design 2D de classe mondiale (Soundiata Keïta, Mansa Moussa, etc.)
class HistoricalFigureDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final HistoricalFigureDetail? figure;
  final String? heroTag;

  const HistoricalFigureDetailScreen({
    super.key,
    required this.id,
    this.figure,
    this.heroTag,
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
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
            color: isDark ? const Color(0xFFF59E0B) : CultureTheme.primaryDark,
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
                  ),
                ),

                // ── 2. CORPS ÉDITORIAL & ÉPOPÉE INTERACTIVE ───────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Contexte régional transversal si actif
                      if (activeRegion != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Région active : ${activeRegion.nom}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── 📖 LIVRE INTERACTIF ANIMÉ SCROLL-DRIVEN (SOUNDIATA KEÏTA) ──
                      if (item.id.contains('soundiata')) ...[
                        SoundiataLivingBookView(
                          figure: item,
                          isDark: isDark,
                        ),
                        if (item.keyFacts.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildKeyFactsSection(item, isDark),
                        ],
                        const SizedBox(height: 24),
                      ] else ...[
                        // ── 🎬 THÉÂTRE DE SCÈNE DOCUMENTAIRE ANIMÉ (POUR AUTRES FIGURES) ──
                        DocumentaryScenePlayer(
                          figure: item,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),

                        // ── Vue d'Épopée Interactive (Audio, Parchemin, Chapitres, Faits Clés) ──
                        SoundiataEpicStoryView(
                          figure: item,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                      ],

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
                  color: _isScrolled
                      ? (isDark
                          ? CultureTheme.darkSurface.withValues(alpha: 0.96)
                          : Colors.white.withValues(alpha: 0.96))
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: _isScrolled ? borderCol : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  boxShadow: _isScrolled
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
                    // Centre : Badge pill quand unscrolled, Nom du personnage quand scrolled
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _isScrolled
                            ? Align(
                                key: const ValueKey('header_title_scrolled'),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item.name,
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
                                    color: const Color(0xFF1E0E05)
                                        .withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B)
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
                                          color: Color(0xFFF59E0B),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        item.id.contains('soundiata')
                                            ? 'ÉPOPÉE DU MANDEN'
                                            : item.tag.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFF59E0B),
                                          letterSpacing: 0.8,
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
                          ? const Color(0xFFF59E0B)
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
              color: Color(0xFFF59E0B),
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
            final cardWidth = (constraints.maxWidth - 10) / 2;
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
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            fact.icon,
                            size: 18,
                            color: const Color(0xFFF59E0B),
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
