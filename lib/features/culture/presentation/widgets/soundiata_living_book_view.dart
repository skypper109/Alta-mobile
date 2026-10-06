import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/controllers/narration_coordinator.dart';
import '../../immersive/services/cultural_haptics.dart';
import 'culture_audio_listen_badge.dart';
import 'soundiata_interactive_elements.dart';
import 'soundiata_audio_elements.dart';
import 'soundiata_prestige_elements.dart';

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
/// - Visualiseur audio d'ondes & mode Autoplay Ciné-Conteur
class SoundiataLivingBookView extends ConsumerStatefulWidget {
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
  ConsumerState<SoundiataLivingBookView> createState() =>
      _SoundiataLivingBookViewState();
}

class _SoundiataLivingBookViewState extends ConsumerState<SoundiataLivingBookView>
    with TickerProviderStateMixin {
  late final ScrollController _bookScrollController;
  int _activeChapterIndex = 0;
  double _scrollProgress = 0.0;
  bool _isAutoplayActive = false;
  SoundiataReadingTheme _readingTheme = SoundiataReadingTheme.imperialDark;

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

  void _playChapterNarration(int index) {
    if (index < 0 || index >= chapters.length) return;
    final chapter = chapters[index];
    final text =
        '${chapter.actName} : ${chapter.title}. ${chapter.location}, ${chapter.period}. ${chapter.narrative}. ${chapter.highlightQuote}';
    final contentId = 'soundiata_book_chap_${chapter.number}';

    ref.read(narrationCoordinatorProvider.notifier).speak(
      text,
      contentId: contentId,
      onComplete: () {
        if (_isAutoplayActive && mounted && index < chapters.length - 1) {
          _scrollToChapter(index + 1);
          Future.delayed(const Duration(milliseconds: 700), () {
            if (_isAutoplayActive && mounted) {
              _playChapterNarration(index + 1);
            }
          });
        }
      },
    );
  }

  void _toggleAutoplay() {
    setState(() {
      _isAutoplayActive = !_isAutoplayActive;
    });
    if (_isAutoplayActive) {
      CulturalHaptics.celebration();
      _playChapterNarration(_activeChapterIndex);
    } else {
      ref.read(narrationCoordinatorProvider.notifier).stop();
    }
  }

  void _toggleMasterPlay() {
    final narration = ref.read(narrationCoordinatorProvider);
    if (narration.isSpeaking) {
      ref.read(narrationCoordinatorProvider.notifier).stop();
      if (_isAutoplayActive) {
        setState(() => _isAutoplayActive = false);
      }
    } else {
      _playChapterNarration(_activeChapterIndex);
    }
  }

  @override
  void dispose() {
    try {
      ref.read(narrationCoordinatorProvider.notifier).stop();
    } catch (_) {}
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
    final isParchment = _readingTheme == SoundiataReadingTheme.ancientParchment;
    final themeColors = SoundiataThemeColors.of(_readingTheme);
    final isDark = !isParchment && widget.isDark;
    final titleColor = themeColors.textPrimary;
    final borderCol = themeColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── BANDEAU TITRE DU LIVRE INTERACTIF ─────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isParchment
                ? themeColors.cardBackground
                : (isDark ? const Color(0xFF140D07) : const Color(0xFFFFFBEB)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isParchment
                  ? themeColors.border
                  : const Color(0xFFF59E0B).withValues(alpha: 0.4),
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
                  // Bouton Sélecteur de Thème (Nuit Impériale / Parchemin Ancien)
                  SoundiataThemeSwitchButton(
                    currentTheme: _readingTheme,
                    isCompact: MediaQuery.sizeOf(context).width < 410,
                    onThemeChanged: (theme) {
                      setState(() {
                        _readingTheme = theme;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  // Indicateur de progression du scroll
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: isParchment
                          ? themeColors.cardBackgroundAlt
                          : Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: themeColors.goldAccent.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      '${_activeChapterIndex + 1} / ${chapters.length}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: themeColors.goldAccent,
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
                      AlwaysStoppedAnimation<Color>(themeColors.goldAccent),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                Flexible(
                  child: Text(
                    'Lancer l\'Épopée en Plein Écran',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.2,
                    ),
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

        const SizedBox(height: 14),

        // ── BARRE AUDIO MAÎTRE (ÉTAPE 3 : AMBIANCE & NARRATEUR) ───────────────
        SoundiataMasterAudioBar(
          activeChapterIndex: _activeChapterIndex,
          totalChapters: chapters.length,
          activeChapterTitle: chapters[_activeChapterIndex].title,
          isAutoplayEnabled: _isAutoplayActive,
          onToggleAutoplay: _toggleAutoplay,
          onTogglePlay: _toggleMasterPlay,
          onPreviousChapter: () {
            if (_activeChapterIndex > 0) {
              _scrollToChapter(_activeChapterIndex - 1);
            }
          },
          onNextChapter: () {
            if (_activeChapterIndex < chapters.length - 1) {
              _scrollToChapter(_activeChapterIndex + 1);
            }
          },
          isDark: isDark,
        ),

        const SizedBox(height: 14),

        // ── FLUX DE SCÈNES SCROLL-DRIVEN (LE LIVRE ANIMÉ) ───────────────────────
        SizedBox(
          height: (MediaQuery.sizeOf(context).height * 0.74).clamp(520.0, 720.0),
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
                themeColors: themeColors,
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
    required SoundiataThemeColors themeColors,
  }) {
    final isParchment = _readingTheme == SoundiataReadingTheme.ancientParchment;
    final narration = ref.watch(narrationCoordinatorProvider);
    final isActivelySpeaking = narration.isSpeaking &&
        narration.activeContentId == 'soundiata_book_chap_${chapter.number}';
    final subtitleColor = themeColors.textSecondary;
    final cardBg = themeColors.cardBackground;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActivelySpeaking
              ? const Color(0xFFF59E0B)
              : (chapter.isBattleScene
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                  : borderCol),
          width: isActivelySpeaking ? 2.0 : (chapter.isBattleScene ? 1.6 : 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: isActivelySpeaking
                ? const Color(0xFFF59E0B).withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: isActivelySpeaking ? 22 : 16,
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
            height: 255,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Décor d'arrière-plan avec mouvement cinématographique (drift & steadycam zoom)
                AnimatedBuilder(
                  animation: _dustController,
                  builder: (context, _) {
                    final driftX =
                        math.sin(_dustController.value * 2 * math.pi) * 0.04;
                    final zoomScale = 1.05 +
                        math.cos(_dustController.value * 2 * math.pi) * 0.02;
                    return Transform.scale(
                      scale: zoomScale,
                      child: Image.asset(
                        chapter.bgImage,
                        fit: BoxFit.cover,
                        alignment: Alignment(driftX, 0),
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    );
                  },
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

                // 3. MOTEUR ATMOSPHÉRIQUE CINÉMATIQUE SANS PARTICULES DORÉES
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _dustController,
                    builder: (context, _) => CustomPaint(
                      painter: SoundiataAtmospherePainter(
                        progress: _dustController.value,
                        type: SoundiataAtmosphereType.forChapter(chapter.number),
                      ),
                    ),
                  ),
                ),

                // 4. Couche vectorielle spéciale pour la CARTE DU MANDÉ (Section 3)
                if (chapter.isMapScene)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _AnimatedTradeRoutesPainter(
                        progress: _pulseController.value,
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

                // 6. PERSONNAGE PRINCIPAL : PLAN 2.5D HÉROÏQUE DEPUIS LA GAUCHE !
                if (chapter.leftCharImage != null)
                  Positioned(
                    left: 12,
                    bottom: 10,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) => _buildAnimatedCharacterCard(
                        name: chapter.leftCharName ?? 'Soundiata',
                        role: chapter.leftCharRole ?? 'Héros',
                        imagePath: chapter.leftCharImage!,
                        accentColor: const Color(0xFFF59E0B),
                        isFromLeft: true,
                        pulseProgress: _pulseController.value,
                      ),
                    ),
                  ),

                // 7. PERSONNAGE ADVERSE : PLAN 2.5D HÉROÏQUE DEPUIS LA DROITE (Exil & Kirina) !
                if (chapter.rightCharImage != null)
                  Positioned(
                    right: 12,
                    bottom: 10,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) => _buildAnimatedCharacterCard(
                        name: chapter.rightCharName ?? 'Adversaire',
                        role: chapter.rightCharRole ?? 'Sosso',
                        imagePath: chapter.rightCharImage!,
                        accentColor: const Color(0xFFEF4444),
                        isFromLeft: false,
                        pulseProgress: _pulseController.value,
                      ),
                    ),
                  ),

                // 8. Choc central animé pour la bataille de Kirina (arc énergétique duel 2.5D + impact)
                if (chapter.isBattleScene) ...[
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) => CustomPaint(
                        painter: _KirinaDuelTensionPainter(
                          progress: _pulseController.value,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final screenW = MediaQuery.sizeOf(context).width;
                          final isCompact = screenW < 360;
                          final scale =
                              (0.94 + (_pulseController.value * 0.12)) *
                                  (isCompact ? 0.85 : 1.0);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 8 : 11,
                                  vertical: isCompact ? 4 : 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E0E05)
                                    .withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B),
                                  width: 1.6,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.6),
                                    blurRadius: 18,
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
              ],
            ),
          ),

          // ── COUCHE 2 : LE RÉCIT NARRATIF PROGRESSIF (SCROLL-DRIVEN) ─────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre sur toute la largeur (évite le passage à la ligne mot par mot)
                Text(
                  chapter.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Ligne secondaire : Période à gauche + Badge d'ambiance à droite
                Row(
                  children: [
                    Text(
                      chapter.period,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: SoundiataSoundscapeBadge(
                        chapterNumber: chapter.number,
                        isDark: isDark,
                      ),
                    ),
                  ],
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

                // Citation synchronisée avec l'audio en direct (Waveform + Glow)
                SoundiataSynchronizedQuote(
                  quote: chapter.highlightQuote,
                  isActivelySpeaking: isActivelySpeaking,
                  isDark: isDark,
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
                            : (isParchment
                                ? themeColors.cardBackgroundAlt
                                : const Color(0xFFF1F5F9)),
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

  /// Carte du personnage animée en relief 2.5D avec perspective, reflet spéculaire et micro-haptique
  Widget _buildAnimatedCharacterCard({
    required String name,
    required String role,
    required String imagePath,
    required Color accentColor,
    required bool isFromLeft,
    required double pulseProgress,
  }) {
    final tiltAngle = isFromLeft ? 0.08 : -0.08;
    final floatY =
        math.sin(pulseProgress * 2 * math.pi + (isFromLeft ? 0.0 : math.pi)) *
            3.2;
    final sheenProgress = ((pulseProgress * 1.5) % 1.0);

    final screenW = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenW * 0.22).clamp(70.0, 86.0);
    final cardPortraitHeight = cardWidth * 0.98;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002) // Perspective 3D
        ..rotateY(tiltAngle)
        ..rotateZ(isFromLeft ? -0.02 : 0.02)
        ..setTranslationRaw(0.0, floatY, 0.0),
      alignment: isFromLeft ? Alignment.bottomLeft : Alignment.bottomRight,
      child: GestureDetector(
        onTap: () => CulturalHaptics.cardPress(),
        child: Container(
          width: cardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.85),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.35),
                blurRadius: 14,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Portrait 2.5D en relief avec reflet spéculaire et badge
              SizedBox(
                height: cardPortraitHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) => Container(
                        color: accentColor.withValues(alpha: 0.3),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 28),
                      ),
                    ),
                    // Dégradé de contraste
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                    // Reflet spéculaire lumineux traversant
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin:
                                Alignment(-2.0 + (sheenProgress * 4.0), -1.0),
                            end: Alignment(-1.0 + (sheenProgress * 4.0), 1.0),
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.24),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Badge héroïque / icône de camp
                    Positioned(
                      top: 4,
                      right: isFromLeft ? 4 : null,
                      left: isFromLeft ? null : 4,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor,
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          isFromLeft
                              ? Icons.shield_rounded
                              : Icons.local_fire_department_rounded,
                          size: 10,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Cartouche documentaire incrusté
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                color: Colors.black.withValues(alpha: 0.94),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isFromLeft
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      role,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Peintre d'arc énergétique et de tension du duel épique de Kirina (1235)
class _KirinaDuelTensionPainter extends CustomPainter {
  final double progress;

  _KirinaDuelTensionPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final startOffset = Offset(95, size.height - 65);
    final endOffset = Offset(size.width - 95, size.height - 65);
    final midX = size.width * 0.5;
    final midY = (size.height * 0.48) - (math.sin(progress * math.pi) * 12);

    // Trajectoire en arc électrique entre Soundiata et Soumaoro
    final arcPath = Path()
      ..moveTo(startOffset.dx, startOffset.dy)
      ..quadraticBezierTo(midX, midY, endOffset.dx, endOffset.dy);

    // Halo d'énergie cinétique
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: 0.65),
          const Color(0xFFEF4444).withValues(alpha: 0.65),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(arcPath, glowPaint);

    // Faisceau central de tension
    final corePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFEF08A),
          const Color(0xFFFCA5A5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(arcPath, corePaint);

    // Onde de choc circulaire au centre d'impact
    final shockRadius = 14 + (progress * 18);
    final shockAlpha = ((1.0 - progress) * 0.65).clamp(0.0, 1.0);
    final shockPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: shockAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(Offset(midX, size.height * 0.5), shockRadius, shockPaint);
  }

  @override
  bool shouldRepaint(covariant _KirinaDuelTensionPainter oldDelegate) =>
      oldDelegate.progress != progress;
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
