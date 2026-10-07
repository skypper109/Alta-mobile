import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import '../../scanner/data/monument_scan_knowledge.dart';
import '../../scanner/models/monument_scan_models.dart';
import '../../scanner/widgets/monument_3d_viewer_modal.dart';

/// Ambiance lumineuse sahélienne pour le monument
enum MonumentSunAtmosphere {
  zenith('Zénith Saharien', Icons.wb_sunny_rounded, Color(0xFFF59E0B)),
  crepuscule('Crépuscule d\'Ocre', Icons.nights_stay_rounded, Color(0xFFE11D48)),
  nuit('Nuit Mystique', Icons.star_rounded, Color(0xFF6366F1));

  final String label;
  final IconData icon;
  final Color accent;
  const MonumentSunAtmosphere(this.label, this.icon, this.accent);
}

/// Hero photographique et interactif multi-angles pour les monuments
/// - Galerie HD tactile swipable (tous les clichés authentiques du dataset)
/// - Accès direct au modèle 3D polygonal rotatif
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Récupérer toutes les photos réelles du dataset
    final target = widget.scanTarget ??
        MonumentScanKnowledge.findById(widget.monument.id);
    if (target != null && target.galleryPhotos.isNotEmpty) {
      _photos = target.galleryPhotos;
    } else if (widget.monument.photoUrl.isNotEmpty) {
      _photos = [widget.monument.photoUrl];
    } else {
      _photos = [
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_1.webp'
      ];
    }

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
    final target = widget.scanTarget ??
        MonumentScanKnowledge.findById(widget.monument.id) ??
        MonumentScanKnowledge.targets.firstWhere(
          (t) => t.id.contains('djenne'),
          orElse: () => MonumentScanKnowledge.targets.first,
        );

    Monument3DViewerModal.show(context, target);
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.44).clamp(320.0, 420.0);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. GALERIE D'IMAGES RÉELLES AVEC SWIPE ─────────────────────────
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
                              color: Color(0xFFF59E0B),
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

          // ── 2. PARTICULES DE POUSSIÈRE D'ARGILE SAHÉLIENNE ────────────────
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

          // ── 3. DÉGRADÉ DE CONTIQUITÉ INFÉRIEURE ────────────────────────────
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

          // ── 4. BOUTONS D'INTERACTION SUPÉRIEURS ────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Row(
              children: [
                // Sélecteur d'ambiance solaire
                GestureDetector(
                  onTap: _nextAtmosphere,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _atmosphere.accent.withValues(alpha: 0.6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _atmosphere.accent.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_atmosphere.icon,
                            size: 13, color: _atmosphere.accent),
                        const SizedBox(width: 5),
                        Text(
                          _atmosphere.label,
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
                const SizedBox(width: 8),

                // Bouton Modèle 3D Interactif
                GestureDetector(
                  onTap: _open3DViewer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.view_in_ar_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Modèle 3D',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 5. BADGES PATRIMONIAUX EN BAS DU HERO ─────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ligne des badges
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Badge UNESCO / Tag avec éclat doré
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB45309), Color(0xFFD97706)],
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
                            widget.monument.tag.toUpperCase(),
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

                    // Badge Région
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4.5),
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
                          const SizedBox(width: 4),
                          Text(
                            widget.monument.regionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Badge Compteur Photos Réelles
                    if (_photos.length > 1)
                      GestureDetector(
                        onTap: () => _openFullscreenGallery(_currentPage),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
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
                                '${_currentPage + 1}/${_photos.length} photos',
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
                  ],
                ),
                const SizedBox(height: 6),

                // Indicateurs discrets de pagination (petits points)
                if (_photos.length > 1)
                  Row(
                    children: List.generate(_photos.length, (idx) {
                      final isSelected = idx == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 4),
                        height: 3.5,
                        width: isSelected ? 18 : 6,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF59E0B)
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
              ],
            ),
          ),
        ],
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
                          color: const Color(0xFFF59E0B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

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
