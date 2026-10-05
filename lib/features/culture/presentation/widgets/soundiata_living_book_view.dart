import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import 'culture_audio_listen_badge.dart';
import 'soundiata_interactive_elements.dart';

/// Données narratives d'une section du Livre Vivant de Soundiata
class SoundiataBookChapter {
  final int number;
  final String actName;
  final String title;
  final String period;
  final String location;
  final String narrative;
  final String highlightQuote;
  final String bgImage;
  final String? leftCharImage;
  final String? leftCharName;
  final String? leftCharRole;
  final String? rightCharImage;
  final String? rightCharName;
  final String? rightCharRole;
  final bool isMapScene;
  final bool isBattleScene;
  final bool isCharterScene;

  const SoundiataBookChapter({
    required this.number,
    required this.actName,
    required this.title,
    required this.period,
    required this.location,
    required this.narrative,
    required this.highlightQuote,
    required this.bgImage,
    this.leftCharImage,
    this.leftCharName,
    this.leftCharRole,
    this.rightCharImage,
    this.rightCharName,
    this.rightCharRole,
    this.isMapScene = false,
    this.isBattleScene = false,
    this.isCharterScene = false,
  });
}

/// 📖 LIVRE INTERACTIF ANIMÉ DE SOUNDIATA KEÏTA
/// Moteur de Scrollytelling avec :
/// - Animations liées au défilement (Scroll-driven animations)
/// - Parallaxe multi-couches en profondeur (Ciel, Village, Personnages)
/// - Entrées chorégraphiées de gauche et droite pour les personnages
/// - Carte ancienne du Mandé avec routes vectorielles qui se tracent au scroll
/// - Choc stylisé de Kirina (silhouettes, poussière, secousses, confrontation)
/// - Révélation progressive du texte et synchronisation audio
class SoundiataLivingBookView extends StatefulWidget {
  final HistoricalFigureDetail figure;
  final bool isDark;

  const SoundiataLivingBookView({
    super.key,
    required this.figure,
    required this.isDark,
  });

  static List<SoundiataBookChapter> getChapters() =>
      _SoundiataLivingBookViewState.chapters;

  @override
  State<SoundiataLivingBookView> createState() =>
      _SoundiataLivingBookViewState();
}

class _SoundiataLivingBookViewState extends State<SoundiataLivingBookView>
    with TickerProviderStateMixin {
  late final ScrollController _bookScrollController;
  int _activeChapterIndex = 0;
  double _scrollProgress = 0.0;

  // Contrôleurs d'animations cinématiques
  late final AnimationController _pulseController;
  late final AnimationController _dustController;

  static const List<SoundiataBookChapter> chapters = [
    // ── SECTION 1 : L'AUBE DU MANDÉ ──────────────────────────────────────────
    SoundiataBookChapter(
      number: 1,
      actName: 'ACTE I',
      title: 'L\'Aube du Mandé & L\'Enfance',
      period: 'Vers 1205',
      location: 'Niani, Cité Royale du Manden',
      narrative:
          'Dans la cité millénaire de Niani, le ciel s\'embrase aux couleurs de l\'aube. Le roi Naré Maghann Konaté reçoit la visite d\'un devin chasseur : une femme sans beauté donnera naissance au plus grand monarque que l\'Afrique ait jamais porté. C\'est ainsi que naît Soundiata Keïta, fils de Sogolon Kondé, le destin déjà scellé par les prophéties des anciens.',
      highlightQuote:
          '« Le grand arbre dort dans la petite graine. Le futur souverain du monde est parmi vous. »',
      bgImage: 'assets/images/culture/scenes/scene_niani_prophetie.jpg',
      leftCharImage: 'assets/images/culture/personnages/soundiata_enfant.jpg',
      leftCharName: 'Soundiata Enfant',
      leftCharRole: 'Fils de la prophétie',
    ),

    // ── SECTION 2 : LE RÉVEIL DU LION ────────────────────────────────────────
    SoundiataBookChapter(
      number: 2,
      actName: 'ACTE II',
      title: 'Le Réveil du Lion & La Barre de Fer',
      period: '1215',
      location: 'Cour royale de Niani',
      narrative:
          'Pendant des années, Soundiata ne peut marcher et rampe sur le sol, subissant les moqueries des fils de Sassouma Bérété. Mais lorsque sa mère est humiliée publiquement pour de simples feuilles de baobab, Soundiata ordonne aux maîtres forgerons de lui forger la plus lourde barre de fer. Dans un effort titanesque qui fait trembler la terre, le fer plie sous sa poigne, et le lion du Manden se dresse enfin sur ses deux jambes !',
      highlightQuote:
          '« Mère, réjouis-toi ! Aujourd\'hui, ce n\'est pas une feuille que je t\'apporte, mais le baobab tout entier avec ses racines ! »\n— Soundiata Keïta',
      bgImage: 'assets/images/culture/scenes/scene_niani_prophetie.jpg',
      leftCharImage: 'assets/images/culture/personnages/soundiata_enfant.jpg',
      leftCharName: 'Soundiata Debout',
      leftCharRole: 'Le lion s\'est éveillé',
    ),

    // ── SECTION 3 : LA CARTE ANCIENNE DU MANDÉ ───────────────────────────────
    SoundiataBookChapter(
      number: 3,
      actName: 'ACTE III',
      title: 'La Carte Ancienne du Mandé & Ses Voies',
      period: '13ème Siècle',
      location: 'Du fleuve Niger aux falaises du Manding',
      narrative:
          'Le Manden ancien s\'étend le long des méandres nourriciers du Djoliba (fleuve Niger). Depuis Niani et Kangaba jusqu\'aux confins du Sahel, les pistes caravanières acheminent l\'or, le sel, le fer et la sagesse des lettrés. Observez les routes et cités historiques qui s\'illuminent sous vos yeux.',
      highlightQuote:
          '« Le Djoliba est le cordon ombilical du Manden. Qui contrôle ses gués maîtrise l\'âme de l\'empire. »',
      bgImage: 'assets/images/culture/scenes/carte_ancienne_mande.jpg',
      isMapScene: true,
    ),

    // ── SECTION 4 : L'EXIL ET LES ALLIANCES DE MÉMA ─────────────────────────
    SoundiataBookChapter(
      number: 4,
      actName: 'ACTE IV',
      title: 'L\'Épreuve de l\'Exil & La Fraternité',
      period: '1220 – 1234',
      location: 'Royaume de Méma & Terres du Sahel',
      narrative:
          'Pour protéger sa mère et sa lignée des complots jaloux, Soundiata prend la route de l\'exil. Il traverse les cours du Ghana déchu et trouve asile auprès du roi de Méma. Là-bas, il devient un cavalier hors pair et forge de puissantes alliances avec les chefs de clans qui voient en lui un chef juste et intrépide.',
      highlightQuote:
          '« L\'exil est une forge ardente : il consume la faiblesse et trempe la volonté d\'acier. »',
      bgImage: 'assets/images/culture/scenes/scene_niani_prophetie.jpg',
      leftCharImage: 'assets/images/culture/personnages/soundiata.jpg',
      leftCharName: 'Soundiata Cavalier',
      leftCharRole: 'Général en Exil',
      rightCharImage: 'assets/images/culture/personnages/soundiata.jpg',
      rightCharName: 'Alliés de Méma',
      rightCharRole: 'Cavalerie du Sahel',
    ),

    // ── SECTION 5 : LE GRAND RETOUR DU LIBÉRATEUR ───────────────────────────
    SoundiataBookChapter(
      number: 5,
      actName: 'ACTE V',
      title: 'L\'Appel du Manden & Le Retour',
      period: '1234',
      location: 'Aux portes du Manden',
      narrative:
          'Le roi-sorcier Soumaoro Kanté s\'est emparé du Manden, instaurant un règne de terreur et de spoliation. Une délégation de notables et de griots parcourt le continent pour retrouver l\'héritier légitime. Lorsque Soundiata entend les pleurs de sa patrie, il rassemble une immense coalition de chasseurs et de cavaliers pour libérer la terre de ses ancêtres.',
      highlightQuote:
          '« Mandenmansa ! Ton peuple gémit sous le joug de Soumaoro. Reviens, le trône de ton père t\'attend ! »\n— Les envoyés du Manden',
      bgImage: 'assets/images/culture/scenes/scene_kirina_1235.jpg',
      leftCharImage: 'assets/images/culture/personnages/soundiata.jpg',
      leftCharName: 'Mansa Soundiata',
      leftCharRole: 'Commandant de la Coalition',
    ),

    // ── SECTION 6 : LE CHOC DÉCISIF DE KIRINA ───────────────────────────────
    SoundiataBookChapter(
      number: 6,
      actName: 'ACTE VI',
      title: 'La Bataille Stylisée de Kirina',
      period: '1235',
      location: 'Plaines de Kirina, Koulikoro',
      narrative:
          'L\'affrontement suprême s\'engage dans la plaine de Kirina sous un ciel d\'or et de poussière. D\'un côté, Soumaoro Kanté, maître des forgerons et des incantations du Sosso. De l\'autre, Soundiata Keïta guidé par son courage et son arc légendaire. D\'une flèche munie d\'un ergot de coq blanc, Soundiata brise l\'invincibilité du tyran, qui s\'évanouit dans la montagne de Koulikoro.',
      highlightQuote:
          '« À Kirina, ce ne sont pas des hommes ordinaires qui combattent : c\'est le choc éternel entre la liberté et l\'oppression ! »',
      bgImage: 'assets/images/culture/scenes/scene_kirina_1235.jpg',
      leftCharImage: 'assets/images/culture/personnages/soundiata.jpg',
      leftCharName: 'Soundiata Keïta',
      leftCharRole: 'Le Vainqueur de Kirina',
      rightCharImage: 'assets/images/culture/personnages/soumaoro_kante.jpg',
      rightCharName: 'Soumaoro Kanté',
      rightCharRole: 'Le Roi-Sorcier du Sosso',
      isBattleScene: true,
    ),

    // ── SECTION 7 : LA CHARTE DE KOUROUKAN FOUGA ────────────────────────────
    SoundiataBookChapter(
      number: 7,
      actName: 'ACTE VII',
      title: 'La Charte Sacrée de Kouroukan Fouga',
      period: '1236',
      location: 'Clairière de Kangaba, sous le grand arbre',
      narrative:
          'Au lendemain de la victoire, Soundiata réunit l\'assemblée des sages et chefs de tribus à Kouroukan Fouga. Ensemble, ils proclament la Charte du Manden : 44 articles proclamant l\'inviolabilité de la vie humaine, la protection de la femme, l\'abolition de l\'esclavage cruel, la fraternité sociale par la parenté à plaisanterie (Sinankunya) et le respect de la nature. Première charte des droits humains de l\'humanité, elle fonde l\'Empire du Mali pour les siècles à venir.',
      highlightQuote:
          '« Toute vie humaine est une vie. Le tort fait à l\'un est un tort fait à tous. Nul ne doit humilier son semblable. »\n— Article 5 de la Charte de 1236 (UNESCO)',
      bgImage: 'assets/images/culture/scenes/scene_kouroukan_fouga.jpg',
      leftCharImage: 'assets/images/culture/personnages/soundiata.jpg',
      leftCharName: 'Mansa Soundiata Keïta',
      leftCharRole: 'Bâtisseur de la Paix Universelle',
      isCharterScene: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bookScrollController = ScrollController();
    _bookScrollController.addListener(_onBookScroll);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _dustController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  void _onBookScroll() {
    if (!_bookScrollController.hasClients) return;

    final maxScroll = _bookScrollController.position.maxScrollExtent;
    final currentScroll = _bookScrollController.offset;
    final totalChapters = chapters.length;

    if (maxScroll > 0) {
      final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
      final index =
          (progress * (totalChapters - 1)).round().clamp(0, totalChapters - 1);

      if (index != _activeChapterIndex) {
        CulturalHaptics.tabSwitch();
        setState(() {
          _activeChapterIndex = index;
          _scrollProgress = progress;
        });
      } else {
        setState(() {
          _scrollProgress = progress;
        });
      }
    }
  }

  @override
  void dispose() {
    _bookScrollController.removeListener(_onBookScroll);
    _bookScrollController.dispose();
    _pulseController.dispose();
    _dustController.dispose();
    super.dispose();
  }

  void _scrollToChapter(int index) {
    if (!_bookScrollController.hasClients) return;
    final targetOffset = index * 460.0;
    _bookScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── BANDEAU TITRE DU LIVRE INTERACTIF ─────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF140D07) : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                blurRadius: 14,
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF59E0B),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LIVRE INTERACTIF ANIMÉ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFF59E0B),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'L\'Épopée Sacrée de Soundiata Keïta',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Indicateur de progression du scroll
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      '${_activeChapterIndex + 1} / ${chapters.length}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _scrollProgress,
                  minHeight: 3.5,
                  backgroundColor:
                      (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── BOUTON PLEIN ÉCRAN CINÉMATIQUE ────────────────────────────────────
        GestureDetector(
          onTap: () {
            CulturalHaptics.celebration();
            context.push('/culture/soundiata-book');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fullscreen_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lancer l\'Épopée en Plein Écran Cinématique',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.black,
                  size: 16,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ── BARRE DE PROGRESSION & SÉLECTEUR RAPIDE PAR ACTES ─────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(chapters.length, (idx) {
              final isCurrent = _activeChapterIndex == idx;
              final ch = chapters[idx];

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () {
                    CulturalHaptics.tabSwitch();
                    _scrollToChapter(idx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFF59E0B)
                          : (isDark
                              ? CultureTheme.darkSurfaceAlt
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFFF59E0B)
                            : borderCol,
                        width: isCurrent ? 1.4 : 1.0,
                      ),
                    ),
                    child: Text(
                      '${ch.actName} : ${ch.title.split('&').first.trim()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight:
                            isCurrent ? FontWeight.w900 : FontWeight.w600,
                        color: isCurrent ? Colors.black : titleColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // ── FLUX DE SCÈNES SCROLL-DRIVEN (LE LIVRE ANIMÉ) ───────────────────────
        SizedBox(
          height: 600,
          child: ListView.separated(
            controller: _bookScrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: chapters.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return _buildScrollDrivenChapterScene(
                chapter: chapter,
                index: index,
                isDark: isDark,
                borderCol: borderCol,
                titleColor: titleColor,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Construction d'une scène complète scroll-driven avec ses couches superposées
  Widget _buildScrollDrivenChapterScene({
    required SoundiataBookChapter chapter,
    required int index,
    required bool isDark,
    required Color borderCol,
    required Color titleColor,
  }) {
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: chapter.isBattleScene
              ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
              : borderCol,
          width: chapter.isBattleScene ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── COUCHE 1 : LE THÉÂTRE DE LA SCÈNE (PARALLAXE + PERSONNAGES 2D) ──
          SizedBox(
            height: 230,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Décor d'arrière-plan avec mouvement cinématographique
                Image.asset(
                  chapter.bgImage,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF0F172A),
                  ),
                ),

                // 2. Filtre de contraste théâtral
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.96),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),

                // 3. Couche vectorielle spéciale pour la CARTE DU MANDÉ (Section 3)
                if (chapter.isMapScene)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _AnimatedTradeRoutesPainter(
                        progress: _pulseController.value,
                      ),
                    ),
                  ),

                // 4. Couche spéciale particules de bataille pour KIRINA (Section 6)
                if (chapter.isBattleScene)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BattlefieldDustPainter(
                        progress: _dustController.value,
                      ),
                    ),
                  ),

                // 5. Badges du Chapitre en haut (Acte + Lieu)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          chapter.actName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 11,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              chapter.location,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 6. PERSONNAGE PRINCIPAL : APPARAÎT DEPUIS LA GAUCHE !
                if (chapter.leftCharImage != null)
                  Positioned(
                    left: 14,
                    bottom: 12,
                    child: _buildAnimatedCharacterCard(
                      name: chapter.leftCharName ?? 'Soundiata',
                      role: chapter.leftCharRole ?? 'Héros',
                      imagePath: chapter.leftCharImage!,
                      accentColor: const Color(0xFFF59E0B),
                      isFromLeft: true,
                    ),
                  ),

                // 7. PERSONNAGE ADVERSE : APPARAÎT DEPUIS LA DROITE (Exil & Kirina) !
                if (chapter.rightCharImage != null)
                  Positioned(
                    right: 14,
                    bottom: 12,
                    child: _buildAnimatedCharacterCard(
                      name: chapter.rightCharName ?? 'Adversaire',
                      role: chapter.rightCharRole ?? 'Sosso',
                      imagePath: chapter.rightCharImage!,
                      accentColor: const Color(0xFFEF4444),
                      isFromLeft: false,
                    ),
                  ),

                // 8. Choc central animé pour la bataille de Kirina
                if (chapter.isBattleScene)
                  Positioned.fill(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale =
                              0.92 + (_pulseController.value * 0.14);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E0E05)
                                    .withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.flash_on_rounded,
                                    size: 14,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '1235 : LE CHOC',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFF59E0B),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── COUCHE 2 : LE RÉCIT NARRATIF PROGRESSIF (SCROLL-DRIVEN) ─────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre du chapitre
                Text(
                  chapter.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 4),

                // Époque
                Text(
                  chapter.period,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                  ),
                ),

                const SizedBox(height: 10),

                // Texte narratif du livre
                Text(
                  chapter.narrative,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.8,
                    color: titleColor,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                // Citation historique mise en exergue
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(
                        color: Color(0xFFF59E0B),
                        width: 3.5,
                      ),
                    ),
                  ),
                  child: Text(
                    chapter.highlightQuote,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFFB45309),
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // ── MICRO-INTERACTIONS TACTILES ÉTAPE 2 ────────────────────────
                if (chapter.isMapScene) ...[
                  const SizedBox(height: 14),
                  MandeInteractiveMapWidget(isDark: isDark),
                  const SizedBox(height: 14),
                ],
                if (chapter.isBattleScene) ...[
                  const SizedBox(height: 14),
                  KirinaBattleArenaWidget(isDark: isDark),
                  const SizedBox(height: 14),
                ],
                if (chapter.isCharterScene) ...[
                  const SizedBox(height: 14),
                  KouroukanCharterAccordion(isDark: isDark),
                  const SizedBox(height: 14),
                ],

                const SizedBox(height: 14),

                // ── COUCHE 3 : DÉCLENCHEURS AUDIO & ACTIONS DU LIVRE ───────────
                Row(
                  children: [
                    // Badge d'écoute vocale de ce chapitre
                    CultureAudioListenBadge(
                      contentId: 'soundiata_book_chap_${chapter.number}',
                      speechText:
                          '${chapter.actName}. ${chapter.title}. ${chapter.period}. ${chapter.narrative}',
                      label: 'Écouter ce chapitre',
                      compact: true,
                      activeColor: const Color(0xFFF59E0B),
                    ),

                    const Spacer(),

                    // Numéro de chapitre stylisé
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? CultureTheme.darkSurfaceAlt
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Chapitre ${chapter.number} sur 7',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Carte du personnage animée avec découpe 2D et cartouche documentaire
  Widget _buildAnimatedCharacterCard({
    required String name,
    required String role,
    required String imagePath,
    required Color accentColor,
    required bool isFromLeft,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isFromLeft) ...[
          _buildCharacterTag(name, role, accentColor, CrossAxisAlignment.end),
          const SizedBox(width: 8),
        ],

        // Portrait 2D découpé
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.4),
                blurRadius: 12,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(
                color: accentColor,
                child: const Icon(Icons.person_rounded, color: Colors.white),
              ),
            ),
          ),
        ),

        if (isFromLeft) ...[
          const SizedBox(width: 8),
          _buildCharacterTag(name, role, accentColor, CrossAxisAlignment.start),
        ],
      ],
    );
  }

  Widget _buildCharacterTag(
    String name,
    String role,
    Color accentColor,
    CrossAxisAlignment align,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: align,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            role,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Peintre vectoriel pour les routes et cités de la Carte Ancienne du Mandé (Section 3)
class _AnimatedTradeRoutesPainter extends CustomPainter {
  final double progress;

  _AnimatedTradeRoutesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.75)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cityGlowPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35 + (progress * 0.3))
      ..style = PaintingStyle.fill;

    final cityCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Coordonnées relatives des grandes cités du Manden
    final niani = Offset(size.width * 0.33, size.height * 0.68);
    final kangaba = Offset(size.width * 0.42, size.height * 0.54);
    final kirina = Offset(size.width * 0.52, size.height * 0.50);
    final djenne = Offset(size.width * 0.66, size.height * 0.56);
    final timbuktu = Offset(size.width * 0.68, size.height * 0.36);
    final gao = Offset(size.width * 0.82, size.height * 0.38);

    // Tracé des routes caravanières
    final path = Path()
      ..moveTo(niani.dx, niani.dy)
      ..lineTo(kangaba.dx, kangaba.dy)
      ..lineTo(kirina.dx, kirina.dy)
      ..lineTo(djenne.dx, djenne.dy)
      ..lineTo(timbuktu.dx, timbuktu.dy)
      ..lineTo(gao.dx, gao.dy);

    canvas.drawPath(path, routePaint);

    // Points lumineux des cités avec pulsation
    final cities = [niani, kangaba, kirina, djenne, timbuktu, gao];
    for (final city in cities) {
      canvas.drawCircle(city, 7.0 + (progress * 3.0), cityGlowPaint);
      canvas.drawCircle(city, 3.0, cityCenterPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedTradeRoutesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Peintre de poussière dorée et étincelles de la Bataille de Kirina (Section 6)
class _BattlefieldDustPainter extends CustomPainter {
  final double progress;

  _BattlefieldDustPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final dustPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 28; i++) {
      final baseX = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      final speed = 0.5 + rand.nextDouble();
      final currentY = (baseY - (progress * speed * size.height)) % size.height;
      final currentX = baseX + (math.sin(progress * 2 * math.pi + i) * 12);
      final radius = 1.0 + (rand.nextDouble() * 2.2);

      dustPaint.color = const Color(0xFFF59E0B).withValues(
        alpha: 0.15 + (rand.nextDouble() * 0.4),
      );

      canvas.drawCircle(Offset(currentX, currentY), radius, dustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BattlefieldDustPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
