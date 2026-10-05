import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import 'culture_audio_listen_badge.dart';

/// Données d'une scène documentaire avec personnages et décors
class DocuSceneData {
  final int index;
  final String actTitle;
  final String periodLocation;
  final String narrative;
  final String keyQuote;
  final String bgImagePath;
  final String primaryCharName;
  final String primaryCharRole;
  final String primaryCharImage;
  final String? opponentCharName;
  final String? opponentCharRole;
  final String? opponentCharImage;
  final bool isConfrontation;

  const DocuSceneData({
    required this.index,
    required this.actTitle,
    required this.periodLocation,
    required this.narrative,
    required this.keyQuote,
    required this.bgImagePath,
    required this.primaryCharName,
    required this.primaryCharRole,
    required this.primaryCharImage,
    this.opponentCharName,
    this.opponentCharRole,
    this.opponentCharImage,
    this.isConfrontation = false,
  });
}

/// Lecteur de Scène Documentaire Animée (Motion Design Documentaire)
/// Anime l'entrée cinématographique des personnages (glissement depuis la gauche/droite,
/// transitions de scènes et mise en récit narrative style documentaire historique).
class DocumentaryScenePlayer extends StatefulWidget {
  final HistoricalFigureDetail figure;
  final bool isDark;

  const DocumentaryScenePlayer({
    super.key,
    required this.figure,
    required this.isDark,
  });

  @override
  State<DocumentaryScenePlayer> createState() => _DocumentaryScenePlayerState();
}

class _DocumentaryScenePlayerState extends State<DocumentaryScenePlayer>
    with TickerProviderStateMixin {
  int _currentSceneIndex = 0;
  late final List<DocuSceneData> _scenes;

  // Contrôleurs d'animations pour les personnages
  late final AnimationController _sceneEntryController;
  late final Animation<Offset> _primarySlideAnimation;
  late final Animation<double> _primaryFadeAnimation;
  late final Animation<double> _primaryScaleAnimation;

  late final Animation<Offset> _opponentSlideAnimation;
  late final Animation<double> _opponentFadeAnimation;

  late final AnimationController _kenBurnsController;
  late final AnimationController _clashPulseController;

  @override
  void initState() {
    super.initState();
    _initScenes();

    // 1. Contrôleur d'entrée de scène et des personnages
    _sceneEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Personnage principal : Glisse depuis la GAUCHE comme dans les documentaires
    _primarySlideAnimation = Tween<Offset>(
      begin: const Offset(-0.85, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _sceneEntryController,
        curve: const Interval(0.1, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _primaryFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sceneEntryController,
        curve: const Interval(0.1, 0.65, curve: Curves.easeIn),
      ),
    );

    _primaryScaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _sceneEntryController,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOutBack),
      ),
    );

    // Personnage opposant / secondaire : Glisse depuis la DROITE
    _opponentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.85, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _sceneEntryController,
        curve: const Interval(0.25, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    _opponentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sceneEntryController,
        curve: const Interval(0.25, 0.80, curve: Curves.easeIn),
      ),
    );

    // 2. Mouvement lent cinématique de caméra (Effet Ken Burns)
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    // 3. Pulsation d'impact du choc pour la bataille de Kirina
    _clashPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Démarrer l'animation de la première scène
    _sceneEntryController.forward();
  }

  void _initScenes() {
    final isSoundiata = widget.figure.id.contains('soundiata');

    if (isSoundiata) {
      _scenes = [
        const DocuSceneData(
          index: 0,
          actTitle: 'ACTE I : L\'ENFANCE & LA PROPHÉTIE',
          periodLocation: '1205 • Niani, Royaume du Manden',
          narrative:
              'Fils de Naré Maghann Konaté et de Sogolon Kondé, Soundiata naît paralysé. Écarté du pouvoir et raillé, il fait preuve d\'une volonté inébranlable. Grâce à la barre de fer des forgerons, le jeune prince se dresse sur ses jambes et prend son destin en main sous le regard médusé du peuple.',
          keyQuote:
              '« Qu\'on m\'apporte la plus lourde barre de fer. Aujourd\'hui, le lion va marcher ! »\n— Soundiata Keïta',
          bgImagePath: 'assets/images/culture/scenes/scene_niani_prophetie.jpg',
          primaryCharName: 'Soundiata Keïta',
          primaryCharRole: 'Jeune Prince du Manden',
          primaryCharImage: 'assets/images/culture/personnages/soundiata.jpg',
        ),
        const DocuSceneData(
          index: 1,
          actTitle: 'ACTE II : L\'ÉPREUVE DE L\'EXIL & LES ALLIANCES',
          periodLocation: '1220 – 1234 • Royaume de Méma',
          narrative:
              'Contraint à l\'exil par les intrigues de cour, Soundiata parcourt le Sahel et trouve refuge auprès du roi de Méma. Il y devient un maître cavalier et affine son génie stratégique. Pendant ce temps, le tyran Soumaoro Kanté ravage le Manden, poussant les anciens à appeler Soundiata à la rescousse.',
          keyQuote:
              '« L\'exil n\'a pas brisé mon âme ; il a trempé ma lame pour la libération de mon peuple. »',
          bgImagePath: 'assets/images/culture/scenes/scene_niani_prophetie.jpg',
          primaryCharName: 'Soundiata Keïta',
          primaryCharRole: 'Général & Libérateur en Exil',
          primaryCharImage: 'assets/images/culture/personnages/soundiata.jpg',
        ),
        const DocuSceneData(
          index: 2,
          actTitle: 'ACTE III : LE CHOC DÉCISIF DE KIRINA',
          periodLocation: '1235 • Plaines de Kirina, Koulikoro',
          narrative:
              'Face-à-face historique entre Soundiata Keïta et le redoutable roi-sorcier Soumaoro Kanté du Sosso. Dans un affrontement titanesque où s\'entrechoquent bravoure et magie ancestrale, Soundiata triomphe grâce à un ergot de coq blanc, mettant fin à la terreur et unifiant les royaumes sous une même bannière.',
          keyQuote:
              '« À Kirina, ce n\'est pas seulement deux rois qui se heurtent, c\'est la liberté qui brise la tyrannie. »\n— Les Griots du Manden',
          bgImagePath: 'assets/images/culture/scenes/scene_kirina_1235.jpg',
          primaryCharName: 'Soundiata Keïta',
          primaryCharRole: 'Commandant de la Coalition Mandingue',
          primaryCharImage: 'assets/images/culture/personnages/soundiata.jpg',
          opponentCharName: 'Soumaoro Kanté',
          opponentCharRole: 'Le Roi-Sorcier du Sosso',
          opponentCharImage:
              'assets/images/culture/personnages/soumaoro_kante.jpg',
          isConfrontation: true,
        ),
        const DocuSceneData(
          index: 3,
          actTitle: 'ACTE IV : LA CHARTE DE KOUROUKAN FOUGA',
          periodLocation: '1236 • Clairière sacrée de Kangaba',
          narrative:
              'Proclamé Mansa de l\'Empire du Mali, Soundiata réunit les sages et chefs de clans pour proclamer la Charte du Manden. Composée de 44 articles, elle institue l\'une des toutes premières déclarations des droits humains au monde, sacralisant la vie humaine, la paix sociale et la protection de l\'environnement.',
          keyQuote:
              '« Toute vie humaine est une vie. Une vie n\'est pas plus respectable qu\'une autre. »\n— Article 5, Charte de Kouroukan Fouga (1236)',
          bgImagePath: 'assets/images/culture/scenes/scene_kouroukan_fouga.jpg',
          primaryCharName: 'Mansa Soundiata',
          primaryCharRole: 'Fondateur de l\'Empire du Mali',
          primaryCharImage: 'assets/images/culture/personnages/soundiata.jpg',
        ),
      ];
    } else {
      // Scènes générées à partir des chapitres de la figure historique
      _scenes = widget.figure.chapters.asMap().entries.map((entry) {
        final idx = entry.key;
        final chap = entry.value;
        return DocuSceneData(
          index: idx,
          actTitle: 'ACTE ${idx + 1} : ${chap.title.toUpperCase()}',
          periodLocation: '${widget.figure.period} • ${widget.figure.regionName}',
          narrative: chap.content,
          keyQuote: idx == 0
              ? (widget.figure.citationHistorique ??
                  '« L\'histoire est le guide des générations futures. »')
              : '« L\'histoire est le guide des générations futures. »',
          bgImagePath: widget.figure.photoUrl,
          primaryCharName: widget.figure.name,
          primaryCharRole: widget.figure.titleHonorifique,
          primaryCharImage: widget.figure.photoUrl,
        );
      }).toList();

      if (_scenes.isEmpty) {
        _scenes = [
          DocuSceneData(
            index: 0,
            actTitle: 'ACTE I : L\'HÉRITAGE DU HÉROS',
            periodLocation: '${widget.figure.period} • ${widget.figure.regionName}',
            narrative: widget.figure.resume,
            keyQuote: widget.figure.citationHistorique ??
                '« L\'histoire est le guide des générations futures. »',
            bgImagePath: widget.figure.photoUrl,
            primaryCharName: widget.figure.name,
            primaryCharRole: widget.figure.titleHonorifique,
            primaryCharImage: widget.figure.photoUrl,
          ),
        ];
      }
    }
  }

  @override
  void dispose() {
    _sceneEntryController.dispose();
    _kenBurnsController.dispose();
    _clashPulseController.dispose();
    super.dispose();
  }

  void _goToScene(int index) {
    if (index == _currentSceneIndex || index < 0 || index >= _scenes.length) {
      return;
    }
    CulturalHaptics.tabSwitch();
    setState(() {
      _currentSceneIndex = index;
    });
    _replayScene();
  }

  void _replayScene() {
    _sceneEntryController.reset();
    _sceneEntryController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final scene = _scenes[_currentSceneIndex];
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── EN-TÊTE DE SECTION DOCUMENTAIRE ───────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.movie_filter_rounded,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RÉCIT DOCUMENTAIRE ANIMÉ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFF59E0B),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Bouton Rejouer l'animation de scène
            GestureDetector(
              onTap: () {
                CulturalHaptics.cardPress();
                _replayScene();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? CultureTheme.darkSurfaceAlt
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.replay_rounded,
                      size: 13,
                      color: subtitleColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Rejouer la scène',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── BARRE DE SÉLECTION DES SCÈNES (TIMELINE CHRONOLOGIQUE) ────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_scenes.length, (index) {
              final isSelected = _currentSceneIndex == index;
              final sc = _scenes[index];
              final shortTitle = sc.actTitle.split(':').last.trim();

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _goToScene(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8.5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : (isDark
                              ? CultureTheme.darkSurfaceAlt
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF59E0B)
                            : borderCol,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Acte ${index + 1}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.black : titleColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.black54
                                : subtitleColor.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          shortTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected ? Colors.black : subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),

        // ── 🎬 LE THÉÂTRE DE SCÈNE DOCUMENTAIRE (CANVAS & MOTION CHARACTERS) ───
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scene.isConfrontation
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                  : borderCol,
              width: scene.isConfrontation ? 1.6 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Décor d'arrière-plan avec zoom cinématique Ken Burns
              AnimatedBuilder(
                animation: _kenBurnsController,
                builder: (context, child) {
                  final scale = 1.0 + (_kenBurnsController.value * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: Image.asset(
                      scene.bgImagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  );
                },
              ),

              // 2. Filtre dégradé théâtral pour la lisibilité
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.98),
                    ],
                    stops: const [0.0, 0.35, 0.75, 1.0],
                  ),
                ),
              ),

              // 3. Indicateur de scène / Acte en haut
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        scene.actTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF59E0B),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        scene.periodLocation,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. PERSONNAGE PRINCIPAL (SOUNDIATA) : GLISSE DEPUIS LA GAUCHE !
              Positioned(
                left: scene.isConfrontation ? 10 : 20,
                bottom: 12,
                child: SlideTransition(
                  position: _primarySlideAnimation,
                  child: FadeTransition(
                    opacity: _primaryFadeAnimation,
                    child: ScaleTransition(
                      scale: _primaryScaleAnimation,
                      child: _buildCharacterFigure(
                        name: scene.primaryCharName,
                        role: scene.primaryCharRole,
                        imagePath: scene.primaryCharImage,
                        accentColor: const Color(0xFFF59E0B),
                        isFacingRight: true,
                        isLarge: !scene.isConfrontation,
                      ),
                    ),
                  ),
                ),
              ),

              // 5. PERSONNAGE OPPOSANT (SOUMAORO KANTÉ) : GLISSE DEPUIS LA DROITE !
              if (scene.isConfrontation && scene.opponentCharImage != null)
                Positioned(
                  right: 10,
                  bottom: 12,
                  child: SlideTransition(
                    position: _opponentSlideAnimation,
                    child: FadeTransition(
                      opacity: _opponentFadeAnimation,
                      child: _buildCharacterFigure(
                        name: scene.opponentCharName!,
                        role: scene.opponentCharRole ?? 'Adversaire',
                        imagePath: scene.opponentCharImage!,
                        accentColor: const Color(0xFFEF4444),
                        isFacingRight: false,
                        isLarge: false,
                      ),
                    ),
                  ),
                ),

              // 6. Symbole de confrontation centrale pour Kirina
              if (scene.isConfrontation)
                Positioned.fill(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _clashPulseController,
                      builder: (context, child) {
                        final pulse = 0.95 + (_clashPulseController.value * 0.12);
                        return Transform.scale(
                          scale: pulse,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E0E05)
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 14,
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
                                  'CHOC DE KIRINA',
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

        const SizedBox(height: 14),

        // ── RÉCIT & NARRATION DE LA SCÈNE (CARTOUCHE HISTORIQUE) ──────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Container(
            key: ValueKey('docu_text_$_currentSceneIndex'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderCol),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Récit narratif de la scène
                Text(
                  scene.narrative,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: titleColor,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                // Citation marquante
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: const Color(0xFFF59E0B),
                        width: 3.5,
                      ),
                    ),
                  ),
                  child: Text(
                    scene.keyQuote,
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

                const SizedBox(height: 14),

                // ── ACTIONS : NARRATION VOCALE & NAVIGATION SCÈNE SUIVANTE ────
                Row(
                  children: [
                    // Badge d'écoute orale de la scène
                    CultureAudioListenBadge(
                      contentId: '${widget.figure.id}_scene_$_currentSceneIndex',
                      speechText:
                          '${scene.actTitle}. ${scene.periodLocation}. ${scene.narrative}',
                      label: 'Écouter la scène',
                      compact: true,
                      activeColor: const Color(0xFFF59E0B),
                    ),

                    const Spacer(),

                    // Bouton Scène Précédente
                    if (_currentSceneIndex > 0)
                      GestureDetector(
                        onTap: () => _goToScene(_currentSceneIndex - 1),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark
                                ? CultureTheme.darkSurfaceAlt
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderCol),
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 22,
                            color: titleColor,
                          ),
                        ),
                      ),

                    if (_currentSceneIndex > 0) const SizedBox(width: 8),

                    // Bouton Scène Suivante
                    if (_currentSceneIndex < _scenes.length - 1)
                      GestureDetector(
                        onTap: () => _goToScene(_currentSceneIndex + 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Scène Suivante',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Fin de l\'Épopée',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Figure 2D découpée avec son cartouche de nom documentaire
  Widget _buildCharacterFigure({
    required String name,
    required String role,
    required String imagePath,
    required Color accentColor,
    required bool isFacingRight,
    required bool isLarge,
  }) {
    final double avatarSize = isLarge ? 88.0 : 72.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isFacingRight) ...[
          // Pour l'opposant à droite, le texte est à gauche de son avatar
          _buildCharacterLabel(name, role, accentColor, CrossAxisAlignment.end),
          const SizedBox(width: 8),
        ],

        // Portrait 2D rond découpé avec bordure d'aura
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor,
              width: 2.4,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.45),
                blurRadius: 14,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 10,
                offset: const Offset(0, 4),
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

        if (isFacingRight) ...[
          const SizedBox(width: 8),
          // Pour Soundiata à gauche, le texte est à droite de son avatar
          _buildCharacterLabel(name, role, accentColor, CrossAxisAlignment.start),
        ],
      ],
    );
  }

  Widget _buildCharacterLabel(
    String name,
    String role,
    Color accentColor,
    CrossAxisAlignment align,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: align,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            role,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
