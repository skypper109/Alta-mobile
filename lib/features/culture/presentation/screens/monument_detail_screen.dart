import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/controllers/culture_data_providers.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/datasources/mock_culture_details_data.dart';
import '../../core/models/cultural_guide_models.dart';
import '../../core/models/culture_detail_models.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import '../../scanner/data/monument_scan_knowledge.dart';
import '../../core/datasources/monument_bespoke_content_data.dart';
import '../widgets/ask_cultural_guide_button.dart';
import '../widgets/connected_contents_section.dart';
import '../widgets/culture_audio_listen_badge.dart';
import '../widgets/culture_detail_sticky_header.dart';
import '../widgets/monument_guided_tour_view.dart';
import '../widgets/monument_living_hero.dart';
import '../widgets/passport_stamp_toast.dart';
import '../../../../core/services/vivienne_tts_service.dart';

/// Onglets d'exploration thématique d'un monument adaptés dynamiquement à chaque édifice
enum MonumentDetailTab {
  essentiel,
  architecture,
  tradition,
  histoire;

  String getLabel(MonumentDetail monument) {
    switch (this) {
      case MonumentDetailTab.essentiel:
        return 'L\'Essentiel';
      case MonumentDetailTab.architecture:
        return 'Architecture';
      case MonumentDetailTab.tradition:
        return MonumentBespokeContentRegistry.getTradition(monument).tabLabel;
      case MonumentDetailTab.histoire:
        return 'Histoire';
    }
  }

  IconData getIcon(MonumentDetail monument) {
    switch (this) {
      case MonumentDetailTab.essentiel:
        return Icons.explore_rounded;
      case MonumentDetailTab.architecture:
        return Icons.architecture_rounded;
      case MonumentDetailTab.tradition:
        return MonumentBespokeContentRegistry.getTradition(monument).tabIcon;
      case MonumentDetailTab.histoire:
        return Icons.auto_stories_rounded;
    }
  }
}

/// Fiche de consultation immersive d'un Monument Historique
class MonumentDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final MonumentDetail? monument;
  final String? heroTag;

  const MonumentDetailScreen({
    super.key,
    required this.id,
    this.monument,
    this.heroTag,
  });

  @override
  ConsumerState<MonumentDetailScreen> createState() =>
      _MonumentDetailScreenState();
}

class _MonumentDetailScreenState extends ConsumerState<MonumentDetailScreen> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;
  MonumentDetailTab _currentTab = MonumentDetailTab.essentiel;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled =
        _scrollController.hasClients && _scrollController.offset > 160;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  void _switchTab(MonumentDetailTab tab) {
    if (_currentTab == tab) return;
    CulturalHaptics.tabSwitch();
    setState(() => _currentTab = tab);
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = widget.monument != null
        ? null
        : ref.watch(monumentDetailProvider(widget.id));
    MonumentDetail? loaded = widget.monument ?? detailAsync?.valueOrNull;

    // Repli de secours immédiat et synchrone (hors-ligne instantané)
    if (loaded == null) {
      try {
        // ignore: deprecated_member_use_from_same_package
        loaded = MockCultureDetailsData.monuments.firstWhere(
          (m) =>
              m.id == widget.id ||
              m.id == 'monument_${widget.id}' ||
              widget.id == 'monument_${m.id}' ||
              (widget.id.contains('djenne') && m.id.contains('djenne')),
        );
      } catch (_) {
        final target = MonumentScanKnowledge.findById(widget.id);
        if (target != null) {
          loaded = MonumentDetail(
            id: target.id,
            name: target.name,
            subtitle: target.subtitle,
            era: target.era,
            regionId: target.regionId,
            regionName: target.regionName,
            tag: target.tag,
            photoUrl: target.photoUrl,
            photoCredits: 'Direction Nationale du Patrimoine',
            locationDetails: target.locationDetails,
            presentation: target.historicalStory,
            architectureAndMaterials: target.architectureStyle,
            whyItMatters: target.whyItMatters,
            keyFacts: target.detectionFeatures
                .map((f) => HistoricalKeyFact(label: f.label, value: f.category, icon: f.icon))
                .toList(),
            chapters: [
              EditorialStoryChapter(
                title: 'Histoire & Origine',
                content: target.historicalStory,
              ),
              EditorialStoryChapter(
                title: 'Secrets & Mystères',
                content: target.secretsAndMysteries,
              ),
            ],
            connectedItems: const [],
          );
        }
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (loaded == null) {
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

    final item = loaded;

    final activeRegion = ref.watch(activeCultureRegionProvider).activeRegion;

    // Enregistrement automatique au Passeport Culturel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final added = ref.read(culturePassportProvider.notifier).recordDiscovery(
            id: item.id,
            type: PassportItemType.monument,
            title: item.name,
            subtitle: item.subtitle,
            regionId: item.regionId,
            regionName: item.regionName,
            photoUrl: item.photoUrl,
            tag: item.tag,
            culturalQuote: '« Bâti en terre de banco, sanctuaire de mémoire. »',
            targetRoute: '/culture/monument/${item.id}',
          );
      if (added && context.mounted) {
        PassportStampToast.show(
          context,
          title: item.name,
          type: PassportItemType.monument,
        );
      }
    });

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final surfaceAlt = isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        VivienneTtsService.instance.stop();
      },
      child: Scaffold(
        backgroundColor:
            isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── 1. HERO VIVANT DU MONUMENT (MULTI-ANGLES & 3D INTERACTIF) ─
                SliverToBoxAdapter(
                  child: MonumentLivingHero(
                    monument: item,
                    heroTag: widget.heroTag ?? 'culture_monument_${item.id}',
                  ),
                ),

                // ── 2. EN-TÊTE D'IDENTITÉ & LECTEUR AUDIO GRIOT ────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _buildMonumentHeader(
                      context,
                      item,
                      activeRegion?.nom,
                      isDark,
                      titleColor,
                      subtitleColor,
                      cardBg,
                      borderCol,
                      surfaceAlt,
                    ),
                  ),
                ),

                // ── 3. BARRE D'ONGLETS THÉMATIQUES INTERACTIVE ────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _MonumentTabHeaderDelegate(
                    monument: item,
                    currentTab: _currentTab,
                    onTabSelected: _switchTab,
                    isDark: isDark,
                  ),
                ),

                // ── 4. CONTENU DYNAMIQUE DE L'ONGLET SÉLECTIONNÉ ──────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: KeyedSubtree(
                        key: ValueKey(_currentTab),
                        child: _buildActiveTabContent(
                          context,
                          item,
                          isDark,
                          titleColor,
                          subtitleColor,
                          cardBg,
                          borderCol,
                          surfaceAlt,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── 5. EN-TÊTE SUPÉRIEUR PERSISTANT (RETOUR & FAVORI) ──────────────
            CultureDetailStickyHeader(
              title: item.name,
              isScrolled: _isScrolled,
              accentColor: CultureTheme.accentOrange,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // EN-TÊTE DU MONUMENT & AUDIO GRIOT VIVANT
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildMonumentHeader(
    BuildContext context,
    MonumentDetail item,
    String? activeRegionName,
    bool isDark,
    Color titleColor,
    Color subtitleColor,
    Color cardBg,
    Color borderCol,
    Color surfaceAlt,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge UNESCO & Statut Mondial
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    'PATRIMOINE MONDIAL UNESCO',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (activeRegionName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 11, color: CultureTheme.accentOrange),
                    const SizedBox(width: 4),
                    Text(
                      activeRegionName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Nom du Monument
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

        // Sous-titre poétique & historique
        Text(
          item.subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: CultureTheme.accentOrange,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 10),

        // Localisation géographique avec bouton d'accès direct à la carte
        Row(
          children: [
            const Icon(Icons.pin_drop_rounded, size: 15, color: CultureTheme.accentOrange),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.locationDetails,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: subtitleColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                CulturalHaptics.cardPress();
                context.push(
                  '/culture/map?placeId=${item.id}&regionId=${item.regionId}',
                  extra: item.id,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.22 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_rounded, size: 13, color: CultureTheme.accentOrange),
                    const SizedBox(width: 4),
                    Text(
                      'Carte',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── LECTEUR AUDIO DU GRIOT VIVANT ───────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFFFFFBEB),
                      const Color(0xFFFEF3C7),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.4 : 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.18 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CultureTheme.accentOrange, CultureTheme.accentLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Écouter l\'Histoire Orale du Griot',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Récit conté du sanctuaire millénaire • 2 min',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              CultureAudioListenBadge(
                contentId: 'detail_monument_${item.id}',
                speechText:
                    '${item.name}. ${item.subtitle}. Époque : ${item.era}. '
                    'Localisation : ${item.locationDetails}. ${item.presentation}. '
                    'Pourquoi ce monument est important : ${item.whyItMatters}. '
                    '${item.architectureAndMaterials}. '
                    '${item.chapters.map((c) => '${c.title} : ${c.content}').join(' ')}',
                label: 'Écouter',
                compact: true,
                activeColor: CultureTheme.accentOrange,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // DISPATCH DU CONTENU DE L'ONGLET ACTIF
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildActiveTabContent(
    BuildContext context,
    MonumentDetail item,
    bool isDark,
    Color titleColor,
    Color subtitleColor,
    Color cardBg,
    Color borderCol,
    Color surfaceAlt,
  ) {
    switch (_currentTab) {
      case MonumentDetailTab.essentiel:
        return _buildEssentielTab(
          context,
          item,
          isDark,
          titleColor,
          subtitleColor,
          cardBg,
          borderCol,
          surfaceAlt,
        );
      case MonumentDetailTab.architecture:
        return _buildArchitectureTab(
          context,
          item,
          isDark,
          titleColor,
          subtitleColor,
          cardBg,
          borderCol,
          surfaceAlt,
        );
      case MonumentDetailTab.tradition:
        return _buildTraditionTab(
          context,
          item,
          isDark,
          titleColor,
          subtitleColor,
          cardBg,
          borderCol,
          surfaceAlt,
        );
      case MonumentDetailTab.histoire:
        return _buildHistoireTab(
          context,
          item,
          isDark,
          titleColor,
          subtitleColor,
          cardBg,
          borderCol,
          surfaceAlt,
        );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ONGLET 1 : L'ESSENTIEL & VISITE PAS-À-PAS
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildEssentielTab(
    BuildContext context,
    MonumentDetail item,
    bool isDark,
    Color titleColor,
    Color subtitleColor,
    Color cardBg,
    Color borderCol,
    Color surfaceAlt,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── CLÉ DE VOÛTE : POURQUOI CE MONUMENT EST LÉGENDAIRE ─────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFFFFFBEB),
                      Colors.white,
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.45 : 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pourquoi ce monument est légendaire',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.whyItMatters,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // ── VISITE GUIDÉE PAS-À-PAS DU MONUMENT ─────────────────────────────
        Text(
          'Visite Guidée des Stations',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Explorez pas-à-pas les stations secrètes et repères historiques de ${item.name}.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: subtitleColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),

        MonumentGuidedTourView(monument: item),

        const SizedBox(height: 24),

        // ── REPÈRES & FICHE D'IDENTITÉ TECHNIQUE (6 CARTES) ─────────────────
        Text(
          'Fiche d\'Identité & Chiffres Clés',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 12),

        _buildTechnicalGrid(context, item, isDark, cardBg, borderCol, titleColor, subtitleColor),

        const SizedBox(height: 24),

        // ── GUIDE CULTUREL IA CONTEXTUEL ────────────────────────────────────
        AskCulturalGuideButton(
          contextData: CulturalGuideContext(
            contentType: CulturalContentType.monument,
            contentId: item.id,
            contentTitle: item.name,
            subtitle: item.subtitle,
            regionId: item.regionId,
            regionName: item.regionName,
            photoUrl: item.photoUrl,
          ),
        ),

        const SizedBox(height: 28),

        // ── MAILLAGE TRANSVERSAL ────────────────────────────────────────────
        ConnectedContentsSection(
          items: item.connectedItems,
          title: 'Figures & Cités Liées',
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ONGLET 2 : ARCHITECTURE & SECRETS DU BANCO
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildArchitectureTab(
    BuildContext context,
    MonumentDetail item,
    bool isDark,
    Color titleColor,
    Color subtitleColor,
    Color cardBg,
    Color borderCol,
    Color surfaceAlt,
  ) {
    final sectionTitle =
        MonumentBespokeContentRegistry.getArchitectureSectionTitle(item);
    final pillars = MonumentBespokeContentRegistry.getPillars(item);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Introduction Architecture
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surfaceAlt,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.architecture_rounded,
                      size: 20, color: CultureTheme.accentOrange),
                  const SizedBox(width: 8),
                  Text(
                    'Le Génie Bâtisseur & Matériaux',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.architectureAndMaterials,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          sectionTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Les particularités constructives et trésors bâtis de ${item.name}.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 16),

        ...pillars.map((pillar) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildPillarCard(
              number: pillar.number,
              title: pillar.title,
              subtitle: pillar.subtitle,
              description: pillar.description,
              icon: pillar.icon,
              color: CultureTheme.accentOrange,
              isDark: isDark,
              cardBg: cardBg,
              borderCol: borderCol,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
          );
        }),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ONGLET 3 : TRADITION, CÉLÉBRATION & RITUELS SPÉCIFIQUES
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildTraditionTab(
    BuildContext context,
    MonumentDetail item,
    bool isDark,
    Color titleColor,
    Color subtitleColor,
    Color cardBg,
    Color borderCol,
    Color surfaceAlt,
  ) {
    final tradition = MonumentBespokeContentRegistry.getTradition(item);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carte Héroïque de la Tradition Spécifique
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: CultureTheme.accentOrange
                  .withValues(alpha: isDark ? 0.45 : 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: CultureTheme.accentOrange
                    .withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo réelle du monument / rituel
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                child: Stack(
                  children: [
                    Image.asset(
                      tradition.photoAsset,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: const Color(0xFF1E293B),
                        child: const Center(
                          child: Icon(Icons.celebration_rounded,
                              size: 48, color: CultureTheme.accentOrange),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: CultureTheme.accentOrange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tradition.badge,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tradition.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tradition.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: isDark
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFF334155),
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bouton d'écoute audio dédié
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.record_voice_over_rounded,
                              size: 20, color: CultureTheme.accentOrange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tradition.audioListenTitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                          ),
                          CultureAudioListenBadge(
                            contentId: tradition.audioContentId,
                            speechText: tradition.audioSpeechText,
                            label: 'Écouter',
                            compact: true,
                            activeColor: CultureTheme.accentOrange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          tradition.chronologyTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tradition.chronologySubtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 14),

        ...tradition.steps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRitualStep(
              time: step.time,
              title: step.title,
              content: step.content,
              icon: step.icon,
              isDark: isDark,
              cardBg: cardBg,
              borderCol: borderCol,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
          );
        }),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ONGLET 4 : HISTOIRE & CHRONOLOGIE
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildHistoireTab(
    BuildContext context,
    MonumentDetail item,
    bool isDark,
    Color titleColor,
    Color subtitleColor,
    Color cardBg,
    Color borderCol,
    Color surfaceAlt,
  ) {
    final timelineEvents = MonumentBespokeContentRegistry.getTimeline(item);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frise Chronologique Interactive
        Text(
          'Frise Chronologique & Mémoire',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Les grands jalons historiques et l\'épopée de ${item.name}.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 16),

        ...timelineEvents.map((event) {
          return _buildTimelineItem(
            year: event.year,
            title: event.title,
            content: event.content,
            isFirst: event.isFirst,
            isLast: event.isLast,
            isDark: isDark,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
          );
        }),

        const SizedBox(height: 24),

        // Chapitres Éditoriaux Détaillés
        Text(
          'Récits & Mémoires Historiques',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 12),

        ...item.chapters.map((chapter) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  chapter.content,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: subtitleColor,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),

        // Maillage culturel
        ConnectedContentsSection(
          items: item.connectedItems,
          title: 'Figures & Cités Historiques Liées',
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // WIDGETS AUXILIAIRES DE HAUTE QUALITÉ
  // ══════════════════════════════════════════════════════════════════════════════

  Widget _buildTechnicalGrid(
    BuildContext context,
    MonumentDetail item,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    final defaultFacts = [
      HistoricalKeyFact(
        label: 'Matériau',
        value: '100% Banco fluviatile & Rônier',
        icon: Icons.nature_rounded,
      ),
      HistoricalKeyFact(
        label: 'Minarets',
        value: '3 tours crénelées de 16 mètres',
        icon: Icons.apartment_rounded,
      ),
      HistoricalKeyFact(
        label: 'Nef Intérieure',
        value: '90 piliers massifs (Fraîcheur à 22°C)',
        icon: Icons.temple_buddhist_rounded,
      ),
      HistoricalKeyFact(
        label: 'Capacité',
        value: 'Plus de 3 000 fidèles',
        icon: Icons.groups_rounded,
      ),
      HistoricalKeyFact(
        label: 'Tradition Sacrée',
        value: 'Fête annuelle du Crépissage',
        icon: Icons.celebration_rounded,
      ),
      HistoricalKeyFact(
        label: 'Statut',
        value: 'Classée UNESCO en 1988',
        icon: Icons.verified_rounded,
      ),
    ];

    final facts = item.keyFacts.isNotEmpty ? item.keyFacts : defaultFacts;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: facts.map((fact) {
        return Container(
          width: (MediaQuery.of(context).size.width - 50) / 2,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(fact.icon, size: 15, color: CultureTheme.accentOrange),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fact.label.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: subtitleColor,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                fact.value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPillarCard({
    required String number,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: subtitleColor,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRitualStep({
    required String time,
    required String title,
    required String content,
    required IconData icon,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CultureTheme.accentOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: CultureTheme.accentOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        time,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String year,
    required String title,
    required String content,
    bool isFirst = false,
    bool isLast = false,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 54,
          child: Column(
            children: [
              Text(
                year,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: CultureTheme.accentOrange,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: CultureTheme.accentOrange,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DÉLÉGUÉ D'EN-TÊTE PERSISTANT DES ONGLETS DU MONUMENT
// ══════════════════════════════════════════════════════════════════════════════
class _MonumentTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final MonumentDetail monument;
  final MonumentDetailTab currentTab;
  final ValueChanged<MonumentDetailTab> onTabSelected;
  final bool isDark;

  const _MonumentTabHeaderDelegate({
    required this.monument,
    required this.currentTab,
    required this.onTabSelected,
    required this.isDark,
  });

  @override
  double get minExtent => 54.0;

  @override
  double get maxExtent => 54.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bgColor = isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground;
    final tabBg = isDark ? CultureTheme.darkSurface : const Color(0xFFF1F5F9);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return SizedBox(
      height: 54.0,
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Container(
          decoration: BoxDecoration(
            color: tabBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderCol),
          ),
          child: Row(
            children: MonumentDetailTab.values.map((tab) {
              final isSelected = tab == currentTab;
              final label = tab.getLabel(monument);
              final icon = tab.getIcon(monument);
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabSelected(tab),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CultureTheme.accentOrange
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 13,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MonumentTabHeaderDelegate oldDelegate) {
    return oldDelegate.currentTab != currentTab ||
        oldDelegate.isDark != isDark ||
        oldDelegate.monument.id != monument.id;
  }
}
