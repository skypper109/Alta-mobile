import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import '../../scanner/data/monument_scan_knowledge.dart';
import '../../scanner/models/monument_scan_models.dart';
import '../../scanner/widgets/monument_3d_viewer_modal.dart';
import 'monument_3d_interactive_stage.dart';

/// Ambiance lumineuse sahélienne pour le monument
enum MonumentSunAtmosphere {
  zenith('Zénith Saharien', Icons.wb_sunny_rounded, CultureTheme.accentOrange),
  crepuscule('Crépuscule d\'Ocre', Icons.nights_stay_rounded, Color(0xFFE11D48)),
  nuit('Nuit Mystique', Icons.star_rounded, Color(0xFF6366F1));

  final String label;
  final IconData icon;
  final Color accent;
  const MonumentSunAtmosphere(this.label, this.icon, this.accent);
}

/// Mode d'affichage du Monument Hero
enum LivingHeroMode {
  model3D,
  photosHD,
}

/// Hero photographique et interactif multi-angles pour les monuments
/// - Exploration 3D interactive 360° en temps réel intégrée directement
/// - Galerie HD tactile swipable (tous les clichés authentiques sans signature)
/// - Ambiances lumineuses du Sahel avec poussières d'or en suspension
/// - Mode plein écran avec zoom haute fidélité
class MonumentLivingHero extends StatefulWidget {
  final MonumentDetail monument;
  final MonumentScanTarget? scanTarget;
  final String? heroTag;

  const MonumentLivingHero({
    super.key,
    required this.monument,
    this.scanTarget,
    this.heroTag,
  });

  @override
  State<MonumentLivingHero> createState() => _MonumentLivingHeroState();
}

class _MonumentLivingHeroState extends State<MonumentLivingHero>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _particlesController;

  int _currentPage = 0;
  MonumentSunAtmosphere _atmosphere = MonumentSunAtmosphere.crepuscule;
  late final List<String> _photos;
  late final MonumentScanTarget _target;
  late LivingHeroMode _heroMode;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Récupérer la cible de scan du monument
    _target = widget.scanTarget ??
        MonumentScanKnowledge.findById(widget.monument.id) ??
        MonumentScanKnowledge.targets.firstWhere(
          (t) => t.id.contains('djenne'),
          orElse: () => MonumentScanKnowledge.targets.first,
        );

    // Récupérer toutes les photos réelles du dataset
    if (_target.galleryPhotos.isNotEmpty) {
      _photos = _target.galleryPhotos;
    } else if (widget.monument.photoUrl.isNotEmpty) {
      _photos = [widget.monument.photoUrl];
    } else {
      _photos = [
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_1.webp'
      ];
    }

    // Par défaut, afficher les photos réelles authentiques avec swipe intuitif,
    // tout en offrant le sélecteur [🏛 3D 360° | 📸 Photos HD] pour basculer instantanément
    _heroMode = LivingHeroMode.photosHD;

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  void _nextAtmosphere() {
    CulturalHaptics.tabSwitch();
    setState(() {
      final nextIndex = (_atmosphere.index + 1) % MonumentSunAtmosphere.values.length;
      _atmosphere = MonumentSunAtmosphere.values[nextIndex];
    });
  }

  void _open3DViewer() {
    CulturalHaptics.stamp();
    Monument3DViewerModal.show(context, _target);
  }

  void _openFullscreenGallery(int initialIndex) {
    CulturalHaptics.cardPress();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MonumentFullscreenGallery(
          photos: _photos,
          initialIndex: initialIndex,
          monumentName: widget.monument.name,
          credits: widget.monument.photoCredits,
        ),
      ),
    );
  }

  void _previousPhoto() {
    CulturalHaptics.tabSwitch();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _pageController.animateToPage(
        _photos.length - 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _nextPhoto() {
    CulturalHaptics.tabSwitch();
    if (_currentPage < _photos.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topPadding = MediaQuery.paddingOf(context).top;
    final heroHeight = (screenHeight * 0.48).clamp(380.0, 460.0);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── CONTENU PRINCIPAL SELON LE MODE ACTIF ─────────────────────────
          if (_heroMode == LivingHeroMode.model3D) ...[
            // SCÈNE 3D INTERACTIVE EMBARQUÉE
            Monument3DInteractiveStage(
              target: _target,
              height: heroHeight,
              showHeader: false,
              onExpandFullscreen: _open3DViewer,
            ),
          ] else ...[
            // ── GALERIE D'IMAGES RÉELLES AVEC SWIPE ─────────────────────────
            Hero(
              tag: widget.heroTag ?? 'monument_hero_${widget.monument.id}',
              child: PageView.builder(
                controller: _pageController,
                itemCount: _photos.length,
                onPageChanged: (idx) {
                  CulturalHaptics.tabSwitch();
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  return GestureDetector(
                    onTap: () => _openFullscreenGallery(index),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          photo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF1E293B),
                            child: const Center(
                              child: Icon(
                                Icons.museum_rounded,
                                size: 64,
                                color: CultureTheme.accentOrange,
                              ),
                            ),
                          ),
                        ),
                        // Filtre atmosphérique teinté
                        _buildAtmosphereOverlay(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── PARTICULES DE POUSSIÈRE D'ARGILE SAHÉLIENNE ────────────────
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _particlesController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _LivingHeroDustPainter(
                      progress: _particlesController.value,
                      atmosphere: _atmosphere,
                    ),
                  );
                },
              ),
            ),

            // ── DÉGRADÉ DE CONTIQUITÉ INFÉRIEURE ────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 0.75, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // ── SÉLECTEUR DE MODE [3D 360° | PHOTOS RÉELLES] (SOUS LA BARRE STICKY) ───
          Positioned(
            top: topPadding > 0 ? topPadding + 58 : 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.55),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeTab(
                      mode: LivingHeroMode.model3D,
                      label: 'Vue 360°',
                      icon: Icons.view_in_ar_rounded,
                    ),
                    _buildModeTab(
                      mode: LivingHeroMode.photosHD,
                      label: 'Photos Réelles (${_photos.length})',
                      icon: Icons.photo_camera_back_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── CHEVRONS DE DÉFILEMENT GAUCHE ET DROITE (MODE PHOTOS) ──────────
          if (_heroMode == LivingHeroMode.photosHD && _photos.length > 1) ...[
            // Chevron Gauche (Précédent)
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GalleryNavigationChevron(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Photo précédente',
                  onTap: _previousPhoto,
                ),
              ),
            ),

            // Chevron Droit (Suivant)
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GalleryNavigationChevron(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Photo suivante',
                  onTap: _nextPhoto,
                ),
              ),
            ),
          ],

          // ── BARRE INFÉRIEURE UNIFIÉE EN MODE PHOTOS RÉELLES ────────────────
          // Compacte, sans débordement et avec alignement parfait
          if (_heroMode == LivingHeroMode.photosHD) ...[
            // Compteur de photos au-dessus de la barre
            if (_photos.length > 1)
              Positioned(
                left: 16,
                bottom: 44,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_rounded,
                        size: 11,
                        color: Color(0xFFFCD34D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentPage + 1}/${_photos.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFCD34D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Rangée principale inférieure (UNESCO, Région, Ambiance)
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Row(
                children: [
                  // Badge UNESCO compact
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [CultureTheme.accentOrange, CultureTheme.accentLight],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'UNESCO',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Badge Région
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: CultureTheme.accentOrange,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.monument.regionName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Sélecteur d'ambiance solaire compact
                  GestureDetector(
                    onTap: _nextAtmosphere,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _atmosphere.accent.withValues(alpha: 0.7),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _atmosphere.accent.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_atmosphere.icon,
                              size: 12, color: _atmosphere.accent),
                          const SizedBox(width: 4),
                          Text(
                            _atmosphere.label.split(' ').first,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
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
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required LivingHeroMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _heroMode == mode;
    return GestureDetector(
      onTap: () {
        CulturalHaptics.tabSwitch();
        setState(() => _heroMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? CultureTheme.accentOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.45),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.black : Colors.white70,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.black : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtmosphereOverlay() {
    switch (_atmosphere) {
      case MonumentSunAtmosphere.zenith:
        return const SizedBox.shrink();
      case MonumentSunAtmosphere.crepuscule:
        return Container(
          color: const Color(0xFF991B1B).withValues(alpha: 0.15),
        );
      case MonumentSunAtmosphere.nuit:
        return Container(
          color: const Color(0xFF1E1B4B).withValues(alpha: 0.38),
        );
    }
  }
}

/// Peintre de particules de poussière et lumière sahéliennes
class _LivingHeroDustPainter extends CustomPainter {
  final double progress;
  final MonumentSunAtmosphere atmosphere;

  _LivingHeroDustPainter({required this.progress, required this.atmosphere});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(1337);
    final paint = Paint();

    final Color color = (atmosphere == MonumentSunAtmosphere.nuit)
        ? const Color(0xFF93C5FD)
        : const Color(0xFFFCD34D);

    for (int i = 0; i < 24; i++) {
      final double seedX = random.nextDouble() * size.width;
      final double seedY = random.nextDouble() * size.height;
      final double speed = 0.3 + random.nextDouble() * 0.7;
      final double currentY = (seedY - (progress * speed * size.height)) % size.height;
      final double radius = 0.8 + random.nextDouble() * 1.8;
      final double alpha = (math.sin(progress * math.pi * 2 + i) * 0.25 + 0.45).clamp(0.1, 0.7);

      paint.color = color.withValues(alpha: alpha * 0.5);
      canvas.drawCircle(Offset(seedX, currentY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LivingHeroDustPainter oldDelegate) => true;
}

/// Galerie plein écran avec zoom haute fidélité
class _MonumentFullscreenGallery extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final String monumentName;
  final String credits;

  const _MonumentFullscreenGallery({
    required this.photos,
    required this.initialIndex,
    required this.monumentName,
    required this.credits,
  });

  @override
  State<_MonumentFullscreenGallery> createState() =>
      _MonumentFullscreenGalleryState();
}

class _MonumentFullscreenGalleryState
    extends State<_MonumentFullscreenGallery> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (idx) {
              CulturalHaptics.tabSwitch();
              setState(() => _currentIndex = idx);
            },
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: Image.asset(
                    widget.photos[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // En-tête
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
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
                        widget.monumentName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Photo ${_currentIndex + 1} sur ${widget.photos.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: CultureTheme.accentOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chevrons de défilement plein écran (si plus d'1 photo)
          if (widget.photos.length > 1) ...[
            // Chevron Gauche
            Positioned(
              left: 14,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GalleryNavigationChevron(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Photo précédente',
                  onTap: () {
                    CulturalHaptics.tabSwitch();
                    if (_currentIndex > 0) {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOutCubic,
                      );
                    } else {
                      _controller.animateToPage(
                        widget.photos.length - 1,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                      );
                    }
                  },
                ),
              ),
            ),

            // Chevron Droit
            Positioned(
              right: 14,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GalleryNavigationChevron(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Photo suivante',
                  onTap: () {
                    CulturalHaptics.tabSwitch();
                    if (_currentIndex < widget.photos.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOutCubic,
                      );
                    } else {
                      _controller.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                      );
                    }
                  },
                ),
              ),
            ),
          ],

          // Pied de page : Crédits
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.camera_alt_rounded,
                    size: 13,
                    color: Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.credits,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: const Color(0xFFCBD5E1),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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

/// Bouton chevron tactile et glassmorphic pour faire défiler les photos à gauche et à droite
class _GalleryNavigationChevron extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _GalleryNavigationChevron({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: 26,
          containedInkWell: true,
          splashColor: CultureTheme.accentOrange.withValues(alpha: 0.4),
          highlightColor: Colors.white.withValues(alpha: 0.15),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.58),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.32),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

