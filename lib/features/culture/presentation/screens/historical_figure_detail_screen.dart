import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/datasources/mock_culture_details_data.dart';
import '../../core/models/cultural_guide_models.dart';
import '../../core/models/culture_detail_models.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import '../widgets/ask_cultural_guide_button.dart';
import '../widgets/authentic_photo_hero.dart';
import '../widgets/connected_contents_section.dart';
import '../widgets/culture_audio_listen_badge.dart';
import '../widgets/passport_stamp_toast.dart';

/// Fiche de consultation immersive d'un Grand Personnage Historique
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
    final scrolled = _scrollController.offset > 100;
    if (scrolled != _isScrolled) {
      setState(() {
        _isScrolled = scrolled;
      });
    }
  }

  @override
  void dispose() {
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
    final item = widget.figure ?? MockCultureDetailsData.getFigureById(widget.id);
    final activeRegion = ref.watch(activeCultureRegionProvider).activeRegion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final surfaceAlt =
        isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor:
          isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground,
      body: Stack(
        children: [
          // ── CONTENU DÉFILANT ──────────────────────────────────────────────
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. GRANDE PHOTOGRAPHIE HISTORIQUE AUTHENTIQUE (HERO) ────────
              SliverToBoxAdapter(
                child: AuthenticPhotoHero(
                  photoUrl: item.photoUrl,
                  photoCredits: item.photoCredits,
                  tag: item.tag,
                  regionName: item.regionName,
                  subtitleInfo: item.period,
                  accentColor: CultureTheme.primaryBlue,
                  heroTag: widget.heroTag ?? 'culture_figure_${item.id}',
                  showTopActions: false, // Actions gérées par le header figé
                ),
              ),

              // ── 2. CORPS ÉDITORIAL IMMERSIF ────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Contexte régional transversal discret si filtre actif
                    if (activeRegion != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: CultureTheme.accentOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Région active : ${activeRegion.nom}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CultureTheme.accentOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Nom & Titre Honorifique
                    Text(
                      item.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.titleHonorifique,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: CultureTheme.primaryBlue,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Résumé Éditorial
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                      ),
                      child: Text(
                        item.resume,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: subtitleColor,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Écoute audio du récit par le Griot
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? CultureTheme.darkSurfaceAlt
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CultureTheme.primaryBlue
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: CultureTheme.primaryBlue
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.record_voice_over_rounded,
                                size: 19,
                                color: CultureTheme.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Écouter l\'épopée orale',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: titleColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Récit conté par la voix du Griot',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          CultureAudioListenBadge(
                            contentId: 'detail_${item.id}',
                            speechText:
                                '${item.name}. ${item.titleHonorifique}. Période : ${item.period}. '
                                '${item.resume}. '
                                '${item.citationHistorique ?? ''}. '
                                '${item.chapters.map((c) => '${c.title} : ${c.content}').join(' ')}',
                            label: 'Écouter',
                            compact: true,
                            activeColor: CultureTheme.primaryBlue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Guide Culturel IA Contextuel
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

                    const SizedBox(height: 20),

                    // ── CITATION HISTORIQUE SI PRÉSENTE ───────────────────────
                    if (item.citationHistorique != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CultureTheme.accentOrange
                              .withValues(alpha: isDark ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: CultureTheme.accentOrange
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: CultureTheme.accentOrange
                                    .withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.format_quote_rounded,
                                  size: 20,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.citationHistorique!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── FAITS MARQUANTS (GRILLE CLÉ) ──────────────────────────
                    Text(
                      'Repères Historiques & Faits Clés',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderCol),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                          alpha: isDark ? 0.15 : 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          fact.icon,
                                          size: 14,
                                          color: CultureTheme.primaryBlue,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            fact.label.toUpperCase(),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: subtitleColor,
                                              letterSpacing: 0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      fact.value,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: titleColor,
                                        height: 1.3,
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

                    const SizedBox(height: 28),

                    // ── RÉCIT HISTORIQUE STRUCTURÉ (STORYTELLING) ──────────────
                    ...item.chapters.map((chapter) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chapter.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              chapter.content,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: subtitleColor,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // ── CONTENUS ASSOCIÉS & MAILLAGE CULTUREL ─────────────────
                    ConnectedContentsSection(
                      items: item.connectedItems,
                      title: 'Patrimoine & Figures Liés',
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // ── HEADER FIGÉ EN HAUT (RETOUR & FAVORI) ───────────────────────────
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
                  // Bouton Retour
                  _buildTopActionButton(
                    icon: Icons.arrow_back_rounded,
                    isDark: isDark,
                    borderCol: borderCol,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  // Titre compact visible uniquement au scroll
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isScrolled ? 1.0 : 0.0,
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bouton Favori
                  _buildTopActionButton(
                    icon: _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    iconColor: _isBookmarked
                        ? CultureTheme.accentOrange
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
    );
  }
}
