import 'package:flutter/material.dart';
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
import '../widgets/ask_cultural_guide_button.dart';
import '../widgets/connected_contents_section.dart';
import '../widgets/culture_audio_listen_badge.dart';
import '../widgets/culture_detail_sticky_header.dart';
import '../widgets/monument_guided_tour_view.dart';
import '../widgets/monument_living_hero.dart';
import '../widgets/passport_stamp_toast.dart';
import '../../../../core/services/vivienne_tts_service.dart';

/// Onglets d'exploration thématique d'un monument
enum MonumentDetailTab {
  essentiel('L\'Essentiel', Icons.explore_rounded),
  architecture('Architecture', Icons.architecture_rounded),
  crepissage('Le Crépissage', Icons.celebration_rounded),
  histoire('Histoire', Icons.auto_stories_rounded);

  final String label;
  final IconData icon;
  const MonumentDetailTab(this.label, this.icon);
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
    final item = widget.monument ?? detailAsync?.valueOrNull;

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
                gradient: const LinearGradient(
                  colors: [Color(0xFFB45309), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.35),
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
              color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.4 : 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.18 : 0.08),
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
                    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
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
      case MonumentDetailTab.crepissage:
        return _buildCrepissageTab(
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
              color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.45 : 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.2 : 0.06),
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
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: Color(0xFFF59E0B),
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
          'Visite Guidée des 5 Stations',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Suivez le Maître Ousmane Barey à travers les stations secrètes du sanctuaire.',
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
                  const Icon(Icons.architecture_rounded, size: 20, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Text(
                    'Le Génie Bâtisseur Soudano-Sahélien',
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
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Les 4 Piliers de l\'Ingénierie de Djenné',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Comment la boue du Bani défie les siècles et les éléments.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 16),

        // Pilier 1 : Le Banco Alchimique
        _buildPillarCard(
          number: '01',
          title: 'Le Banco Alchimique (Terre Crue)',
          subtitle: 'Une composition vivante et imperméable',
          description:
              'Le banco n\'est pas de la simple terre : c\'est un alliage savant d\'argile fine récoltée dans le lit du fleuve Bani, de paille de riz fermentée pour la cohésion fibreuse, de balle de mil et de beurre de karité. Le karité apporte les lipides nécessaires pour rendre le mortier hydrofuge face aux orages tropicaux.',
          icon: Icons.grain_rounded,
          color: const Color(0xFFD97706),
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        const SizedBox(height: 14),

        // Pilier 2 : Les Torons de Palmier Rônier
        _buildPillarCard(
          number: '02',
          title: 'Les Torons en Bois de Rônier',
          subtitle: 'L\'échafaudage permanent et armature antisismique',
          description:
              'Ces poutres en bois qui hérissent les murailles sont prélevées sur le palmier rônier (Borassus aethiopum). Ce bois extraordinaire ne pourrit jamais et repousse naturellement les termites. Il permet aux maçons d\'escalader les façades lors du crépissage et dissipe les tensions mécaniques causées par les chocs thermiques du Sahel (de 15°C la nuit à 45°C le jour).',
          icon: Icons.carpenter_rounded,
          color: const Color(0xFFB45309),
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        const SizedBox(height: 14),

        // Pilier 3 : Les Cimes aux Œufs d'Autruche
        _buildPillarCard(
          number: '03',
          title: 'Les Cimes aux Œufs d\'Autruche',
          subtitle: 'Pureté sacrée, fertilité et protection divine',
          description:
              'Au sommet des trois minarets culminent de véritables œufs d\'autruche blancs polis. Dans la cosmogonie sahélienne, l\'œuf d\'autruche est le symbole premier de la fécondité, de la pureté morale et du renouveau perpétuel. Traditionnellement, ils servaient également de protection spirituelle contre la foudre.',
          icon: Icons.egg_rounded,
          color: const Color(0xFFF59E0B),
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        const SizedBox(height: 14),

        // Pilier 4 : La Forêt Hypostyle des 90 Piliers
        _buildPillarCard(
          number: '04',
          title: 'La Forêt des 90 Piliers Hypostyles',
          subtitle: 'Climatisation naturelle bio-climatique à 22°C',
          description:
              'À l\'intérieur, la nef est soutenue par 90 piliers massifs en banco d\'une épaisseur allant jusqu\'à 60 centimètres. Cette masse thermique colossale emmagasine la fraîcheur de la nuit pour tempérer le sanctuaire en plein jour, maintenant une température intérieure stable à 22°C sous un soleil de plomb.',
          icon: Icons.temple_buddhist_rounded,
          color: const Color(0xFF0D9488),
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        const SizedBox(height: 22),

        // Focus Système Bioclimatique & Ventilation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF0D9488).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.air_rounded,
                  size: 22,
                  color: Color(0xFF0D9488),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Les 104 Lucarnes Zénithales du Toit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Le toit-terrasse est percé de 104 orifices fermés par des couvercles en terre cuite. En saison chaude, les fidèles ôtent les chapeaux pour créer un tirage d\'air ascendant. Dès que l\'hivernage approche, ils sont scellés pour protéger le sanctuaire des pluies battantes.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: subtitleColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // ONGLET 3 : LE CRÉPISSAGE SACRÉ (FÊTE ANNUELLE)
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildCrepissageTab(
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
        // Carte Héroïque du Crépissage
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.45 : 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo réelle du festival
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/culture/monuments/monument_mosquee_djenne/dje_4.webp',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: const Color(0xFF1E293B),
                        child: const Center(
                          child: Icon(Icons.celebration_rounded, size: 48, color: Color(0xFFF59E0B)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'TRADITION SÉCULAIRE UNIQUE AU MONDE',
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
                            'La Fête Sacrée du Crépissage',
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
                      'Chaque année, à la fin de la saison sèche, toute la cité de Djenné s\'unit en une seule matinée de liesse collective pour réenduire entièrement la mosquée d\'une nouvelle couche d\'argile sacrée.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
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
                          const Icon(Icons.record_voice_over_rounded, size: 20, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Écouter le récit de la fête du Crépissage',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                          ),
                          CultureAudioListenBadge(
                            contentId: 'crepissage_${item.id}',
                            speechText:
                                'La fête sacrée du Crépissage de Djenné. '
                                'Chaque année, la veille au crépuscule, des milliers de garçons malaxent le banco dans les fosses du Bani. '
                                'À quatre heures du matin, le tambour retentit depuis les minarets. '
                                'À l\'aube, une marée humaine s\'élance avec les corbeilles de mortier. '
                                'Les jeunes escaladent les torons en bois et réenduient les murailles à mains nues sous le chant des femmes et le regard vigilant des maîtres maçons Barey Ton.',
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
          'Chronologie de la Journée Sacrée',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),

        // Étape 1 : La Veille
        _buildRitualStep(
          time: 'La Veille au Crépuscule',
          title: 'Le Malaxage dans les Fosses du Bani',
          content:
              'Dans d\'immenses bassins d\'argile creusés aux abords du fleuve, des centaines de jeunes hommes et garçons piétinent et malaxent le banco en chantant. Le mortier repose toute la nuit pour atteindre une texture parfaite.',
          icon: Icons.nightlife_rounded,
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        const SizedBox(height: 12),

        // Étape 2 : L'Appel
        _buildRitualStep(
          time: '4h00 du Matin',
          title: 'L\'Appel Solennel du Tambour',
          content:
              'Un son lourd et profond retentit depuis la terrasse de la mosquée. Le tocsin traditionnel réveille chaque foyer de Djenné. Personne ne dort : la fête du Crépissage a commencé.',
          icon: Icons.notifications_active_rounded,
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        const SizedBox(height: 12),

        // Étape 3 : La Ruée
        _buildRitualStep(
          time: 'L\'Aube (6h00)',
          title: 'La Ruée Folle du Mortier',
          content:
              'Des équipes de porteurs de chaque quartier rivalisent de vitesse. Les corbeilles d\'osier remplies d\'argile fraîche sont hissées sur les têtes. Des courses effrénées s\'engagent à travers les ruelles jusqu\'au parvis.',
          icon: Icons.directions_run_rounded,
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        const SizedBox(height: 12),

        // Étape 4 : L'Escalade
        _buildRitualStep(
          time: '7h00 – 10h00',
          title: 'L\'Escalade des Torons & L\'Enduit à Mains Nues',
          content:
              'Perchés à 15 mètres de hauteur sur les poutres de palmier, les jeunes maçons étalent l\'argile à mains nues avec une agilité acrobatique. En bas, les femmes apportent l\'eau fraîche du fleuve en entonnant des hymnes guerriers et spirituels.',
          icon: Icons.pan_tool_rounded,
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        const SizedBox(height: 12),

        // Étape 5 : La Bénédiction
        _buildRitualStep(
          time: 'Midi',
          title: 'L\'Inspection des Maîtres Barey Ton & Le Festin',
          content:
              'Les doyens de la corporation des maçons inspectent chaque pan de mur. La mosquée brille d\'une robe neuve ocre-dorée. La journée se termine par un immense banquet populaire où tous les différends de la cité sont pardonnés.',
          icon: Icons.restaurant_rounded,
          isDark: isDark,
          cardBg: cardBg,
          borderCol: borderCol,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frise Chronologique Interactive
        Text(
          'Frise Chronologique des Huit Siècles',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Des fondations médiévales du XIIIe siècle à la renaissance de 1907.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 16),

        _buildTimelineItem(
          year: '1280',
          title: 'Fondation par le Roi Koy Konboro',
          content:
              'Le 26e roi de Djenné, Koy Konboro, se convertit à l\'islam. En signe d\'humilité spirituelle, il fait raser son somptueux palais royal pour édifier à sa place la toute première Grande Mosquée.',
          isFirst: true,
          isDark: isDark,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        _buildTimelineItem(
          year: '1324',
          title: 'L\'Âge d\'Or de l\'Empire du Mali',
          content:
              'Sous le règne de l\'empereur Mansa Moussa, Djenné devient la métropole commerciale sœur de Tombouctou. Des caravanes de sel et d\'or transitent chaque jour devant la mosquée.',
          isDark: isDark,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        _buildTimelineItem(
          year: '1834',
          title: 'L\'Épreuve de l\'Empire du Macina',
          content:
              'Le conquérant peul Sékou Amadou juge l\'édifice originel trop orné et luxueux. Il fait bâtir une mosquée austère à proximité et laisse l\'ancien sanctuaire se dégrader sous les intempéries.',
          isDark: isDark,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        _buildTimelineItem(
          year: '1907',
          title: 'La Renaissance Triomphale',
          content:
              'La corporation des maçons traditionnels de Djenné (Barey Ton), dirigée par le maître d\'œuvre Ismaïla Traoré, reconstruit le monument selon son architecture originelle monumentale avec ses trois minarets emblématiques.',
          isDark: isDark,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

        _buildTimelineItem(
          year: '1988',
          title: 'Consécration au Patrimoine Mondial UNESCO',
          content:
              'L\'UNESCO classe la Grande Mosquée et la ville ancienne de Djenné au Patrimoine Mondial de l\'Humanité, consacrant le plus grand chef-d\'œuvre architectural en terre crue de la planète.',
          isLast: true,
          isDark: isDark,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
        ),

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
                  Icon(fact.icon, size: 15, color: const Color(0xFFD97706)),
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
              color: const Color(0xFFD97706).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFD97706)),
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
                        color: const Color(0xFFD97706).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        time,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFD97706),
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
                  color: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: const Color(0xFFD97706).withValues(alpha: 0.3),
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
  final MonumentDetailTab currentTab;
  final ValueChanged<MonumentDetailTab> onTabSelected;
  final bool isDark;

  const _MonumentTabHeaderDelegate({
    required this.currentTab,
    required this.onTabSelected,
    required this.isDark,
  });

  @override
  double get minExtent => 52.0;

  @override
  double get maxExtent => 52.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bgColor = isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground;
    final tabBg = isDark ? CultureTheme.darkSurface : const Color(0xFFF1F5F9);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: tabBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          children: MonumentDetailTab.values.map((tab) {
            final isSelected = tab == currentTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(tab),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD97706)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.35),
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
                        tab.icon,
                        size: 13,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tab.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MonumentTabHeaderDelegate oldDelegate) {
    return oldDelegate.currentTab != currentTab || oldDelegate.isDark != isDark;
  }
}
