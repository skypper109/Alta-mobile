import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/vivienne_tts_service.dart';
import '../../core/theme/culture_theme.dart';
import '../models/monument_scan_models.dart';

/// Modes d'éclairage cinématographiques pour le rendu 3D
enum LightingEnvironment {
  soleilSahelien, // Plein soleil d'or zénithal
  crepuscule,     // Coucher de soleil ambré
  nuitEtoilee,    // Nuit saharienne avec projecteurs
}

/// Point d'intérêt architectural ancré en coordonnées 3D réelles (X, Y, Z)
class Architectural3DHotspot {
  final double x;
  final double y;
  final double z;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const Architectural3DHotspot({
    required this.x,
    required this.y,
    required this.z,
    required this.title,
    required this.subtitle,
    required this.description,
    this.icon = Icons.architecture_rounded,
  });
}

/// Facette 3D triangulaire ou polygonale avec calcul d'éclairage Lambertian
class PolygonFace3D {
  final List<List<double>> vertices; // Coordonnées [x, y, z]
  final Color baseColor;
  final double roughness; // 0.0 lisse, 1.0 mat (banco)
  final String? textureType; // 'banco', 'metal', 'marble', 'wood'

  const PolygonFace3D({
    required this.vertices,
    required this.baseColor,
    this.roughness = 0.8,
    this.textureType,
  });
}

/// Modal d'exploration 3D haute fidélité pour les monuments de CultureLens
class Monument3DViewerModal extends StatefulWidget {
  final MonumentScanTarget target;

  const Monument3DViewerModal({
    super.key,
    required this.target,
  });

  static Future<void> show(BuildContext context, MonumentScanTarget target) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Monument3DViewerModal(target: target),
    );
  }

  @override
  State<Monument3DViewerModal> createState() => _Monument3DViewerModalState();
}

class _Monument3DViewerModalState extends State<Monument3DViewerModal>
    with TickerProviderStateMixin {
  // Angles de rotation 3D (orbite)
  double _rotX = -0.22;
  double _rotY = 0.45;
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;

  // Contrôles interactifs
  bool _isArMode = false;
  bool _showWireframe = false;
  bool _autoRotate = true;
  LightingEnvironment _lighting = LightingEnvironment.soleilSahelien;
  Architectural3DHotspot? _activeHotspot;

  late final AnimationController _animController;
  late final AnimationController _particlesController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..addListener(() {
        if (_autoRotate && mounted) {
          setState(() {
            _rotY += 0.004;
          });
        }
      });
    _animController.repeat();

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  List<Architectural3DHotspot> _getHotspotsForTarget(MonumentScanTarget target) {
    final id = target.id;
    if (id.contains('independance')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -140,
          z: 0,
          title: 'Flèche Minaret Soudanaise',
          subtitle: 'Sommet pyramidal couronné de l\'emblème national',
          description:
              'Symbole d\'élévation spirituelle et civique, cette flèche géométrique s\'inspire des minarets de Tombouctou et Djenné.',
          icon: Icons.flag_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: -20,
          z: 32,
          title: 'Frises Géométriques Mandingues',
          subtitle: 'Reliefs ciselés dans le béton stabilisé',
          description:
              'Motifs traditionnels symbolisant l\'union sacrée des peuples du Mali et la transmission intergénérationnelle.',
          icon: Icons.grain_rounded,
        ),
        Architectural3DHotspot(
          x: 35,
          y: 70,
          z: 35,
          title: 'Piédestal Républicain',
          subtitle: 'Base octogonale monumentale',
          description:
              'Socle cérémoniel en pierre de taille où se tiennent les célébrations solennelles de la souveraineté du 22 septembre 1960.',
          icon: Icons.account_balance_rounded,
        ),
      ];
    } else if (id.contains('tour_afrique')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -150,
          z: 0,
          title: 'Le Flambeau Éternel de l\'Unité',
          subtitle: 'Sculpture métallique culminante',
          description:
              'Brasier en cuivre stylisé rappelant la flamme de la libération panafricaine allumée par les pères fondateurs de l\'OUA.',
          icon: Icons.local_fire_department_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: -85,
          z: 42,
          title: 'Plateforme Panoramique',
          subtitle: 'Belvédère à 360° sur Bamako',
          description:
              'Galerie circulaire offrant une vue plongeante sur l\'échangeur de Faladié et les collines du Mandé.',
          icon: Icons.remove_red_eye_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 30,
          z: 46,
          title: 'Fût Cannelé en Baobab',
          subtitle: 'Tour cylindrique de 46 mètres',
          description:
              'Inspirée de la circonférence d\'un baobab protecteur, la structure est habillée de bas-reliefs narrant les luttes africaines.',
          icon: Icons.park_rounded,
        ),
      ];
    } else if (id.contains('paix')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -110,
          z: 0,
          title: 'Colombe Métallique Ajourée',
          subtitle: 'Envergure d\'acier de 12 mètres',
          description:
              'Chef-d\'œuvre de ferronnerie d\'art figurant la concorde et la réconciliation nationale proclamée lors de la Flamme de la Paix.',
          icon: Icons.flutter_dash_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 40,
          z: 28,
          title: 'Stèle en Marbre de Sélinkegny',
          subtitle: 'Socle pyramidal blanc immaculé',
          description:
              'Bloc monolithique taillé dans les carrières de marbre malien, gravé d\'inscriptions en hommage à la paix.',
          icon: Icons.architecture_rounded,
        ),
      ];
    } else if (id.contains('ciwara')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -140,
          z: 10,
          title: 'Cornes Mythiques de l\'Antilope',
          subtitle: 'Élancement vers le soleil et la pluie',
          description:
              'Les cornes recourbées symbolisent la croissance vigoureuse des céréales (mil et sorgho) bénies par le génie agricole.',
          icon: Icons.pets_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: -20,
          z: 25,
          title: 'Crinière Ajourée en Dents de Scie',
          subtitle: 'Détail sculptural traditionnel',
          description:
              'Représente le mouvement ondoyant du soleil et l\'énergie infatigable du paysan labourant la terre féconde.',
          icon: Icons.auto_awesome_rounded,
        ),
      ];
    } else {
      // Modèle soudanais par défaut (Djenné / Médine / etc.)
      return const [
        Architectural3DHotspot(
          x: -40,
          y: -120,
          z: 20,
          title: 'Minaret Soudanais & Œuf d\'Autruche',
          subtitle: 'Apogée spirituelle en terre crue',
          description:
              'Chaque minaret est couronné d\'un œuf d\'autruche traditionnel symbolisant la fertilité, la pureté et la protection céleste.',
          icon: Icons.egg_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: -10,
          z: 42,
          title: 'Torons en Bois de Rônier',
          subtitle: 'Échafaudages permanents en bois',
          description:
              'Poutres de palmier rônier insérées dans les murs servant d\'échafaudage séculaire lors de la grande fête rituelle du crépissage.',
          icon: Icons.carpenter_rounded,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.target;
    final size = MediaQuery.of(context).size;
    final hotspots = _getHotspotsForTarget(target);

    return Container(
      height: size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF080C16),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── TIREUR ────────────────────────────────────────────────────────
          Container(
            width: 44,
            height: 4.5,
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // ── EN-TÊTE IMMERSIF ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.view_in_ar_rounded,
                    color: CultureTheme.accentOrange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Jumeau Spatial 3D',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'HAUTE FIDÉLITÉ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF34D399),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${target.name} • ${target.regionName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF1E293B), height: 1),

          // ── SCÈNE DE RENDU 3D RÉALISTE ────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Fond d'ambiance selon le mode d'éclairage
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.1,
                        colors: _getBackgroundColors(),
                      ),
                    ),
                  ),
                ),

                // Particules atmosphériques (poussière d'or / étoiles)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _particlesController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _AtmosphericDustPainter(
                          progress: _particlesController.value,
                          lighting: _lighting,
                        ),
                      );
                    },
                  ),
                ),

                // Podestat circulaire avec ombre de contact projetée
                Center(
                  child: CustomPaint(
                    size: const Size(280, 280),
                    painter: _PedestalShadowPainter(
                      rotX: _rotX,
                      scale: _scale,
                    ),
                  ),
                ),

                // Modèle 3D architectural interactif
                Positioned.fill(
                  child: GestureDetector(
                    onScaleStart: (_) => setState(() => _autoRotate = false),
                    onScaleUpdate: (details) {
                      setState(() {
                        if (details.pointerCount > 1) {
                          _panOffset += details.focalPointDelta;
                        } else {
                          _rotY += details.focalPointDelta.dx * 0.012;
                          _rotX -= details.focalPointDelta.dy * 0.012;
                          _rotX = _rotX.clamp(-math.pi / 2.5, math.pi / 2.5);
                        }
                        _scale = (_scale * details.scale).clamp(0.6, 2.5);
                      });
                    },
                    child: Center(
                      child: CustomPaint(
                        size: const Size(360, 360),
                        painter: _RealisticMonument3DPainter(
                          target: target,
                          rotX: _rotX,
                          rotY: _rotY,
                          scale: _scale,
                          panOffset: _panOffset,
                          lighting: _lighting,
                          showWireframe: _showWireframe,
                        ),
                      ),
                    ),
                  ),
                ),

                // Hotspots 3D projetés en perspective
                for (final hp in hotspots) _buildProjected3DHotspot(hp),

                // ── HUD COMMANDES DROITE ────────────────────────────────────
                Positioned(
                  right: 16,
                  top: 16,
                  child: Column(
                    children: [
                      _buildHudPill(
                        icon: _autoRotate ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        tooltip: _autoRotate ? 'Mettre en pause rotation' : 'Rotation automatique',
                        isActive: _autoRotate,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _autoRotate = !_autoRotate);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildHudPill(
                        icon: Icons.wb_sunny_rounded,
                        tooltip: 'Changer éclairage',
                        onTap: _cycleLighting,
                      ),
                      const SizedBox(height: 8),
                      _buildHudPill(
                        icon: Icons.grid_4x4_rounded,
                        tooltip: 'Affichage écorché fil de fer',
                        isActive: _showWireframe,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _showWireframe = !_showWireframe);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildHudPill(
                        icon: Icons.refresh_rounded,
                        tooltip: 'Réinitialiser vue',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _rotX = -0.22;
                            _rotY = 0.45;
                            _scale = 1.0;
                            _activeHotspot = null;
                            _autoRotate = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // ── SÉLECTEUR D'AMBIANCE LUMINEUSE GAUCHE ────────────────────
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _lighting == LightingEnvironment.soleilSahelien
                              ? Icons.wb_sunny_rounded
                              : _lighting == LightingEnvironment.crepuscule
                                  ? Icons.wb_twilight_rounded
                                  : Icons.nightlight_round,
                          size: 14,
                          color: CultureTheme.accentOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getLightingLabel(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── POPUP D'INFORMATION DU POINT CHAUD ──────────────────────
                if (_activeHotspot != null)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 84,
                    child: _buildHotspotDetailCard(_activeHotspot!),
                  ),

                // ── BARRE INFÉRIEURE D'ACTIONS ──────────────────────────────
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: Row(
                    children: [
                      // Bouton AR Mode
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            setState(() => _isArMode = !_isArMode);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF1E293B),
                                behavior: SnackBarBehavior.floating,
                                content: Row(
                                  children: [
                                    const Icon(Icons.view_in_ar_rounded, color: CultureTheme.accentOrange),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _isArMode
                                            ? 'Mode AR actif : Dirigez la caméra vers un sol plat.'
                                            : 'Mode 3D temps réel actif.',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isArMode
                                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                    : [CultureTheme.primaryBlue, const Color(0xFF253B82)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: CultureTheme.primaryBlue.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isArMode ? Icons.check_circle_rounded : Icons.view_in_ar_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isArMode ? 'AR Activée' : 'Ancrer en AR',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bouton En Savoir Plus
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _showDossierArchitectural(context, target);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: CultureTheme.accentOrange,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_stories_rounded, color: Colors.black, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'En savoir plus',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cycleLighting() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_lighting == LightingEnvironment.soleilSahelien) {
        _lighting = LightingEnvironment.crepuscule;
      } else if (_lighting == LightingEnvironment.crepuscule) {
        _lighting = LightingEnvironment.nuitEtoilee;
      } else {
        _lighting = LightingEnvironment.soleilSahelien;
      }
    });
  }

  String _getLightingLabel() {
    switch (_lighting) {
      case LightingEnvironment.soleilSahelien:
        return 'Plein Soleil Sahélien';
      case LightingEnvironment.crepuscule:
        return 'Coucher de Soleil Ambré';
      case LightingEnvironment.nuitEtoilee:
        return 'Nuit Étoilée & Projecteurs';
    }
  }

  List<Color> _getBackgroundColors() {
    switch (_lighting) {
      case LightingEnvironment.soleilSahelien:
        return const [
          Color(0xFF1E293B),
          Color(0xFF0F172A),
          Color(0xFF070B14),
        ];
      case LightingEnvironment.crepuscule:
        return const [
          Color(0xFF3B1E1E),
          Color(0xFF1E1118),
          Color(0xFF0A060E),
        ];
      case LightingEnvironment.nuitEtoilee:
        return const [
          Color(0xFF0B172E),
          Color(0xFF070E1C),
          Color(0xFF03060B),
        ];
    }
  }

  Widget _buildProjected3DHotspot(Architectural3DHotspot hp) {
    // Calcul de projection 3D exacte du hotspot
    const double d = 420.0;
    // Rotation Y
    final double cosY = math.cos(_rotY);
    final double sinY = math.sin(_rotY);
    final double x1 = hp.x * cosY + hp.z * sinY;
    final double z1 = -hp.x * sinY + hp.z * cosY;

    // Rotation X
    final double cosX = math.cos(_rotX);
    final double sinX = math.sin(_rotX);
    final double y2 = hp.y * cosX - z1 * sinX;
    final double z2 = hp.y * sinX + z1 * cosX;

    // Masque si la facette est tournée vers l'arrière
    if (z2 < -60) return const SizedBox.shrink();

    final double proj = (d / (d + z2)) * _scale;
    final double screenX = x1 * proj;
    final double screenY = y2 * proj;

    final bool isSelected = _activeHotspot == hp;

    return Center(
      child: Transform.translate(
        offset: Offset(screenX, screenY),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _activeHotspot = isSelected ? null : hp;
              _autoRotate = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isSelected ? 38 : 30,
            height: isSelected ? 38 : 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.white : CultureTheme.accentOrange,
              border: Border.all(
                color: isSelected ? CultureTheme.accentOrange : Colors.white,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? Colors.white : CultureTheme.accentOrange).withValues(alpha: 0.8),
                  blurRadius: isSelected ? 16 : 8,
                  spreadRadius: isSelected ? 3 : 1,
                ),
              ],
            ),
            child: Icon(
              hp.icon,
              size: isSelected ? 20 : 16,
              color: isSelected ? CultureTheme.accentOrange : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotspotDetailCard(Architectural3DHotspot hp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CultureTheme.accentOrange, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(hp.icon, color: CultureTheme.accentOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hp.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      hp.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: CultureTheme.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _activeHotspot = null),
                icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hp.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.45,
              color: const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudPill({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isActive
                ? CultureTheme.accentOrange
                : Colors.black.withValues(alpha: 0.65),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? CultureTheme.accentOrange
                  : Colors.white.withValues(alpha: 0.2),
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
            ],
          ),
          child: Icon(
            icon,
            size: 19,
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  void _showDossierArchitectural(BuildContext context, MonumentScanTarget target) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dossier Architectural & Symbolique',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          target.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: CultureTheme.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildDossierSection(
                      icon: Icons.foundation_rounded,
                      title: 'Matériaux & Génie Constructif',
                      content:
                          'Conçu pour résister aux amplitudes thermiques sahéliennes, cet édifice intègre des techniques bio-climatiques ancestrales et des matériaux locaux de haute tenue (latérite, grès rouge, banco stabilisé).',
                    ),
                    const SizedBox(height: 14),
                    _buildDossierSection(
                      icon: Icons.straighten_rounded,
                      title: 'Orientation Cosmique & Proportions',
                      content:
                          'L\'alignement avec la course du soleil et les axes fluviaux du fleuve Niger (Djoliba) confère au monument une présence magnétique et une aération naturelle optimale.',
                    ),
                    const SizedBox(height: 14),
                    _buildDossierSection(
                      icon: Icons.auto_stories_rounded,
                      title: 'Transmission & Récits Populaires',
                      content: target.historicalStory,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        VivienneTtsService.instance.speak(
                          '${target.name}. ${target.historicalStory}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CultureTheme.accentOrange,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: Text(
                        'Écouter la Narration Historique',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDossierSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: CultureTheme.accentOrange, size: 18),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.5,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Peintre du podestat circulaire et de l'ombre d'occlusion ambiante
class _PedestalShadowPainter extends CustomPainter {
  final double rotX;
  final double scale;

  _PedestalShadowPainter({required this.rotX, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 130 * scale);
    final shadowRadiusX = 110.0 * scale;
    final shadowRadiusY = (34.0 + rotX * 14.0) * scale;

    // Ombre d'occlusion portée diffuse
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: shadowRadiusX * 2, height: shadowRadiusY * 2),
      shadowPaint,
    );

    // Disque de base en marbre / grès
    final diskPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2C394F),
          const Color(0xFF151D2C),
        ],
      ).createShader(Rect.fromCenter(center: center, width: shadowRadiusX * 1.6, height: shadowRadiusY * 1.6));
    canvas.drawOval(
      Rect.fromCenter(center: center, width: shadowRadiusX * 1.6, height: shadowRadiusY * 1.6),
      diskPaint,
    );

    // Cerclage métallique doré de base
    final ringPaint = Paint()
      ..color = CultureTheme.accentOrange.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: shadowRadiusX * 1.6, height: shadowRadiusY * 1.6),
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PedestalShadowPainter oldDelegate) =>
      oldDelegate.rotX != rotX || oldDelegate.scale != scale;
}

/// Peintre volumétrique 3D réaliste calculant la géométrie, normales et éclairage Phong
class _RealisticMonument3DPainter extends CustomPainter {
  final MonumentScanTarget target;
  final double rotX;
  final double rotY;
  final double scale;
  final Offset panOffset;
  final LightingEnvironment lighting;
  final bool showWireframe;

  _RealisticMonument3DPainter({
    required this.target,
    required this.rotX,
    required this.rotY,
    required this.scale,
    required this.panOffset,
    required this.lighting,
    required this.showWireframe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 + panOffset.dx, size.height / 2 + panOffset.dy);

    // Vecteur de lumière directionnel selon l'éclairage choisi
    final List<double> lightDir = _getLightDirection();

    // Génération des polygones du monument ciblé
    final List<PolygonFace3D> faces = _generateMonumentFaces(target);

    // Transformation 3D -> 2D avec tri par profondeur Z (Painter's Algorithm)
    final List<_ProjectedPolygon> projectedList = [];

    const double d = 420.0;
    final double cosY = math.cos(rotY);
    final double sinY = math.sin(rotY);
    final double cosX = math.cos(rotX);
    final double sinX = math.sin(rotX);

    for (final face in faces) {
      final List<Offset> screenPoints = [];
      double sumZ = 0.0;
      final List<List<double>> transformedVertices = [];

      for (final v in face.vertices) {
        // Rotation Y (azimut)
        final double x1 = v[0] * cosY + v[2] * sinY;
        final double z1 = -v[0] * sinY + v[2] * cosY;

        // Rotation X (élévation)
        final double y2 = v[1] * cosX - z1 * sinX;
        final double z2 = v[1] * sinX + z1 * cosX;

        transformedVertices.add([x1, y2, z2]);
        sumZ += z2;

        // Projection perspective
        final double proj = (d / (d + z2)) * scale;
        screenPoints.add(Offset(center.dx + x1 * proj, center.dy + y2 * proj));
      }

      final double avgZ = sumZ / face.vertices.length;

      // Calcul de la normale de surface
      if (transformedVertices.length >= 3) {
        final v0 = transformedVertices[0];
        final v1 = transformedVertices[1];
        final v2 = transformedVertices[2];

        final ab = [v1[0] - v0[0], v1[1] - v0[1], v1[2] - v0[2]];
        final ac = [v2[0] - v0[0], v2[1] - v0[1], v2[2] - v0[2]];

        // Produit vectoriel pour la normale
        double nx = ab[1] * ac[2] - ab[2] * ac[1];
        double ny = ab[2] * ac[0] - ab[0] * ac[2];
        double nz = ab[0] * ac[1] - ab[1] * ac[0];

        final len = math.sqrt(nx * nx + ny * ny + nz * nz);
        if (len > 0) {
          nx /= len;
          ny /= len;
          nz /= len;
        }

        // Back-face culling partiel (conserve pour le wireframe)
        if (nz <= 0 && !showWireframe) continue;

        // Éclairage diffus Lambertian : dot(N, L)
        final double dot = math.max(0.0, nx * lightDir[0] + ny * lightDir[1] + nz * lightDir[2]);
        final double ambient = (lighting == LightingEnvironment.nuitEtoilee) ? 0.20 : 0.35;
        final double intensity = (ambient + dot * 0.65).clamp(0.15, 1.0);

        final shadedColor = _applyShading(face.baseColor, intensity, face.roughness);

        projectedList.add(_ProjectedPolygon(
          points: screenPoints,
          avgZ: avgZ,
          fillColor: shadedColor,
          textureType: face.textureType,
        ));
      }
    }

    // Tri du fond vers l'avant (Z décroissant)
    projectedList.sort((a, b) => b.avgZ.compareTo(a.avgZ));

    // Dessin des polygones projetés
    for (final poly in projectedList) {
      final path = Path();
      if (poly.points.isNotEmpty) {
        path.moveTo(poly.points[0].dx, poly.points[0].dy);
        for (int i = 1; i < poly.points.length; i++) {
          path.lineTo(poly.points[i].dx, poly.points[i].dy);
        }
        path.close();
      }

      if (!showWireframe) {
        final fillPaint = Paint()
          ..color = poly.fillColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);

        // Arêtes subtiles pour rehausser la géométrie
        final borderPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawPath(path, borderPaint);
      } else {
        // Mode Écorché / Wireframe architectural
        final wirePaint = Paint()
          ..color = CultureTheme.accentOrange.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawPath(path, wirePaint);
      }
    }
  }

  List<double> _getLightDirection() {
    switch (lighting) {
      case LightingEnvironment.soleilSahelien:
        return [-0.55, -0.75, 0.45]; // Soleil haut à gauche
      case LightingEnvironment.crepuscule:
        return [-0.85, -0.30, 0.40]; // Lumière rasante ambrée
      case LightingEnvironment.nuitEtoilee:
        return [0.0, 0.90, 0.40];    // Projecteurs orientés du bas vers le haut
    }
  }

  Color _applyShading(Color base, double intensity, double roughness) {
    if (lighting == LightingEnvironment.crepuscule) {
      // Teinte chaude ambrée de coucher de soleil
      final r = (base.r * intensity * 1.15).clamp(0.0, 1.0);
      final g = (base.g * intensity * 0.90).clamp(0.0, 1.0);
      final b = (base.b * intensity * 0.70).clamp(0.0, 1.0);
      return Color.fromRGBO((r * 255).round(), (g * 255).round(), (b * 255).round(), 1.0);
    } else if (lighting == LightingEnvironment.nuitEtoilee) {
      // Teinte bleutée nocturne avec surbrillance dorée ponctuelle
      final r = (base.r * intensity * 0.85).clamp(0.0, 1.0);
      final g = (base.g * intensity * 0.95).clamp(0.0, 1.0);
      final b = (base.b * intensity * 1.20).clamp(0.0, 1.0);
      return Color.fromRGBO((r * 255).round(), (g * 255).round(), (b * 255).round(), 1.0);
    } else {
      // Rendu plein soleil
      final r = (base.r * intensity).clamp(0.0, 1.0);
      final g = (base.g * intensity).clamp(0.0, 1.0);
      final b = (base.b * intensity).clamp(0.0, 1.0);
      return Color.fromRGBO((r * 255).round(), (g * 255).round(), (b * 255).round(), 1.0);
    }
  }

  List<PolygonFace3D> _generateMonumentFaces(MonumentScanTarget target) {
    final id = target.id;
    if (id.contains('tour_afrique')) {
      return _buildTourAfriqueFaces();
    } else if (id.contains('paix')) {
      return _buildMonumentPaixFaces();
    } else if (id.contains('ciwara')) {
      return _buildCiwaraFaces();
    } else {
      // Monument de l'Indépendance ou style soudanais étagé
      return _buildIndependanceFaces();
    }
  }

  /// Géométrie 3D fidèle du Monument de l'Indépendance à Bamako
  List<PolygonFace3D> _buildIndependanceFaces() {
    final List<PolygonFace3D> faces = [];
    const stoneColor = Color(0xFFD6A76C); // Grès ocre doré
    const darkStone = Color(0xFFAC7C46);

    // 1. Base octogonale / carrée évasée (socle de cérémonie)
    faces.addAll(_buildBox(
      cx: 0, cy: 90, cz: 0,
      w: 120, h: 26, d: 120,
      color: darkStone,
    ));

    // 2. Étage intermédiaire avec arcades
    faces.addAll(_buildBox(
      cx: 0, cy: 62, cz: 0,
      w: 86, h: 32, d: 86,
      color: stoneColor,
    ));

    // 3. Obélisque / minaret tronconique élancé (3 sections effilées)
    // Section basse du tronc
    faces.addAll(_buildPyramidFrustum(
      yBottom: 46, yTop: -30,
      wBottom: 68, wTop: 48,
      color: stoneColor,
    ));

    // Section médiane avec frises géométriques
    faces.addAll(_buildPyramidFrustum(
      yBottom: -30, yTop: -100,
      wBottom: 48, wTop: 32,
      color: stoneColor,
    ));

    // Section haute
    faces.addAll(_buildPyramidFrustum(
      yBottom: -100, yTop: -145,
      wBottom: 32, wTop: 18,
      color: const Color(0xFFE2B880),
    ));

    // 4. Couronnement sommital pyramidal (flèche républicaine)
    faces.addAll([
      const PolygonFace3D(
        vertices: [
          [-9, -145, -9],
          [9, -145, -9],
          [0, -170, 0],
        ],
        baseColor: Color(0xFFF1851F),
      ),
      const PolygonFace3D(
        vertices: [
          [9, -145, -9],
          [9, -145, 9],
          [0, -170, 0],
        ],
        baseColor: Color(0xFFF1851F),
      ),
      const PolygonFace3D(
        vertices: [
          [9, -145, 9],
          [-9, -145, 9],
          [0, -170, 0],
        ],
        baseColor: Color(0xFFF1851F),
      ),
      const PolygonFace3D(
        vertices: [
          [-9, -145, 9],
          [-9, -145, -9],
          [0, -170, 0],
        ],
        baseColor: Color(0xFFF1851F),
      ),
    ]);

    return faces;
  }

  /// Géométrie 3D fidèle de la Tour de l'Afrique (Faladié, Bamako)
  List<PolygonFace3D> _buildTourAfriqueFaces() {
    final List<PolygonFace3D> faces = [];
    const concreteOcre = Color(0xFFBF8A52);
    const torchColor = Color(0xFFF59E0B);

    // 1. Base cylindrique circulaire
    faces.addAll(_buildCylinder(
      cx: 0, yBottom: 100, yTop: 75,
      radiusBottom: 85, radiusTop: 75,
      segments: 14,
      color: const Color(0xFF8B5A2B),
    ));

    // 2. Fût cannelé baobab (hauteur 46m modélisée en 2 tronçons)
    faces.addAll(_buildCylinder(
      cx: 0, yBottom: 75, yTop: -30,
      radiusBottom: 65, radiusTop: 45,
      segments: 14,
      color: concreteOcre,
    ));

    faces.addAll(_buildCylinder(
      cx: 0, yBottom: -30, yTop: -90,
      radiusBottom: 45, radiusTop: 38,
      segments: 14,
      color: concreteOcre,
    ));

    // 3. Plateforme panoramique circulaire en encorbellement
    faces.addAll(_buildCylinder(
      cx: 0, yBottom: -90, yTop: -108,
      radiusBottom: 58, radiusTop: 54,
      segments: 14,
      color: const Color(0xFF475569),
    ));

    // 4. Sommet et flamme stylisée
    faces.addAll(_buildCylinder(
      cx: 0, yBottom: -108, yTop: -130,
      radiusBottom: 30, radiusTop: 18,
      segments: 10,
      color: const Color(0xFF94A3B8),
    ));

    // Flamme dorée
    faces.addAll([
      const PolygonFace3D(
        vertices: [
          [-10, -130, 0],
          [10, -130, 0],
          [0, -170, 0],
        ],
        baseColor: torchColor,
      ),
      const PolygonFace3D(
        vertices: [
          [0, -130, -10],
          [0, -130, 10],
          [0, -170, 0],
        ],
        baseColor: torchColor,
      ),
    ]);

    return faces;
  }

  /// Géométrie 3D du Monument de la Paix (Hamdallaye ACI 2000)
  List<PolygonFace3D> _buildMonumentPaixFaces() {
    final List<PolygonFace3D> faces = [];
    const marbleWhite = Color(0xFFECEFF1);
    const doveSteel = Color(0xFFCFD8DC);

    // 1. Pyramide tronquée en marbre de Sélinkegny
    faces.addAll(_buildPyramidFrustum(
      yBottom: 100, yTop: 10,
      wBottom: 90, wTop: 40,
      color: marbleWhite,
    ));

    // 2. Colombe monumentale déployée (corps et ailes ajourées)
    // Corps
    faces.addAll(_buildBox(
      cx: 0, cy: -10, cz: 0,
      w: 22, h: 38, d: 36,
      color: doveSteel,
    ));

    // Aile gauche déployée vers le haut
    faces.add(const PolygonFace3D(
      vertices: [
        [-11, -15, 0],
        [-95, -115, 20],
        [-65, -85, -15],
      ],
      baseColor: Color(0xFFB0BEC5),
    ));
    faces.add(const PolygonFace3D(
      vertices: [
        [-11, -25, 0],
        [-120, -130, 25],
        [-95, -115, 20],
      ],
      baseColor: Colors.white,
    ));

    // Aile droite déployée vers le haut
    faces.add(const PolygonFace3D(
      vertices: [
        [11, -15, 0],
        [65, -85, -15],
        [95, -115, 20],
      ],
      baseColor: Color(0xFFB0BEC5),
    ));
    faces.add(const PolygonFace3D(
      vertices: [
        [11, -25, 0],
        [95, -115, 20],
        [120, -130, 25],
      ],
      baseColor: Colors.white,
    ));

    // Tête et bec levés vers le ciel
    faces.add(const PolygonFace3D(
      vertices: [
        [-6, -30, 10],
        [6, -30, 10],
        [0, -55, 24],
      ],
      baseColor: Colors.white,
    ));

    return faces;
  }

  /// Géométrie 3D du Masque Ciwara (Sénou, Bamako)
  List<PolygonFace3D> _buildCiwaraFaces() {
    final List<PolygonFace3D> faces = [];
    const woodDark = Color(0xFF5D4037);
    const goldHorn = Color(0xFFD7CCC8);

    // Socle
    faces.addAll(_buildBox(
      cx: 0, cy: 90, cz: 0,
      w: 80, h: 25, d: 80,
      color: const Color(0xFF3E2723),
    ));

    // Corps de l'antilope
    faces.addAll(_buildBox(
      cx: 0, cy: 50, cz: 0,
      w: 32, h: 55, d: 50,
      color: woodDark,
    ));

    // Crinière ajourée en dents de scie
    faces.add(const PolygonFace3D(
      vertices: [
        [0, 20, -15],
        [0, -40, -45],
        [0, -10, -5],
      ],
      baseColor: Color(0xFF8D6E63),
    ));

    // Grandes cornes recourbées en arc
    faces.add(const PolygonFace3D(
      vertices: [
        [-8, 0, 10],
        [-14, -80, 5],
        [-4, -150, -35],
      ],
      baseColor: goldHorn,
    ));
    faces.add(const PolygonFace3D(
      vertices: [
        [8, 0, 10],
        [4, -150, -35],
        [14, -80, 5],
      ],
      baseColor: goldHorn,
    ));

    return faces;
  }

  // ── UTILITAIRES DE GÉOMÉTRIE 3D ───────────────────────────────────────────

  List<PolygonFace3D> _buildBox({
    required double cx,
    required double cy,
    required double cz,
    required double w,
    required double h,
    required double d,
    required Color color,
  }) {
    final hw = w / 2;
    final hh = h / 2;
    final hd = d / 2;

    return [
      // Devant (+Z)
      PolygonFace3D(
        vertices: [
          [cx - hw, cy - hh, cz + hd],
          [cx + hw, cy - hh, cz + hd],
          [cx + hw, cy + hh, cz + hd],
          [cx - hw, cy + hh, cz + hd],
        ],
        baseColor: color,
      ),
      // Derrière (-Z)
      PolygonFace3D(
        vertices: [
          [cx + hw, cy - hh, cz - hd],
          [cx - hw, cy - hh, cz - hd],
          [cx - hw, cy + hh, cz - hd],
          [cx + hw, cy + hh, cz - hd],
        ],
        baseColor: color,
      ),
      // Gauche (-X)
      PolygonFace3D(
        vertices: [
          [cx - hw, cy - hh, cz - hd],
          [cx - hw, cy - hh, cz + hd],
          [cx - hw, cy + hh, cz + hd],
          [cx - hw, cy + hh, cz - hd],
        ],
        baseColor: color,
      ),
      // Droite (+X)
      PolygonFace3D(
        vertices: [
          [cx + hw, cy - hh, cz + hd],
          [cx + hw, cy - hh, cz - hd],
          [cx + hw, cy + hh, cz - hd],
          [cx + hw, cy + hh, cz + hd],
        ],
        baseColor: color,
      ),
      // Haut (-Y)
      PolygonFace3D(
        vertices: [
          [cx - hw, cy - hh, cz - hd],
          [cx + hw, cy - hh, cz - hd],
          [cx + hw, cy - hh, cz + hd],
          [cx - hw, cy - hh, cz + hd],
        ],
        baseColor: color,
      ),
      // Bas (+Y)
      PolygonFace3D(
        vertices: [
          [cx - hw, cy + hh, cz + hd],
          [cx + hw, cy + hh, cz + hd],
          [cx + hw, cy + hh, cz - hd],
          [cx - hw, cy + hh, cz - hd],
        ],
        baseColor: color,
      ),
    ];
  }

  List<PolygonFace3D> _buildPyramidFrustum({
    required double yBottom,
    required double yTop,
    required double wBottom,
    required double wTop,
    required Color color,
  }) {
    final hb = wBottom / 2;
    final ht = wTop / 2;

    return [
      // Devant (+Z)
      PolygonFace3D(
        vertices: [
          [-ht, yTop, ht],
          [ht, yTop, ht],
          [hb, yBottom, hb],
          [-hb, yBottom, hb],
        ],
        baseColor: color,
      ),
      // Derrière (-Z)
      PolygonFace3D(
        vertices: [
          [ht, yTop, -ht],
          [-ht, yTop, -ht],
          [-hb, yBottom, -hb],
          [hb, yBottom, -hb],
        ],
        baseColor: color,
      ),
      // Gauche (-X)
      PolygonFace3D(
        vertices: [
          [-ht, yTop, -ht],
          [-ht, yTop, ht],
          [-hb, yBottom, hb],
          [-hb, yBottom, -hb],
        ],
        baseColor: color,
      ),
      // Droite (+X)
      PolygonFace3D(
        vertices: [
          [ht, yTop, ht],
          [ht, yTop, -ht],
          [hb, yBottom, -hb],
          [hb, yBottom, hb],
        ],
        baseColor: color,
      ),
    ];
  }

  List<PolygonFace3D> _buildCylinder({
    required double cx,
    required double yBottom,
    required double yTop,
    required double radiusBottom,
    required double radiusTop,
    required int segments,
    required Color color,
  }) {
    final List<PolygonFace3D> faces = [];
    final double step = (math.pi * 2) / segments;

    for (int i = 0; i < segments; i++) {
      final a1 = i * step;
      final a2 = (i + 1) * step;

      final x1b = cx + math.cos(a1) * radiusBottom;
      final z1b = math.sin(a1) * radiusBottom;
      final x2b = cx + math.cos(a2) * radiusBottom;
      final z2b = math.sin(a2) * radiusBottom;

      final x1t = cx + math.cos(a1) * radiusTop;
      final z1t = math.sin(a1) * radiusTop;
      final x2t = cx + math.cos(a2) * radiusTop;
      final z2t = math.sin(a2) * radiusTop;

      faces.add(PolygonFace3D(
        vertices: [
          [x1t, yTop, z1t],
          [x2t, yTop, z2t],
          [x2b, yBottom, z2b],
          [x1b, yBottom, z1b],
        ],
        baseColor: color,
      ));
    }
    return faces;
  }

  @override
  bool shouldRepaint(covariant _RealisticMonument3DPainter oldDelegate) {
    return oldDelegate.rotX != rotX ||
        oldDelegate.rotY != rotY ||
        oldDelegate.scale != scale ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.lighting != lighting ||
        oldDelegate.showWireframe != showWireframe;
  }
}

class _ProjectedPolygon {
  final List<Offset> points;
  final double avgZ;
  final Color fillColor;
  final String? textureType;

  _ProjectedPolygon({
    required this.points,
    required this.avgZ,
    required this.fillColor,
    this.textureType,
  });
}

/// Peintre de poussières atmosphériques et particules de lumière sahéliennes
class _AtmosphericDustPainter extends CustomPainter {
  final double progress;
  final LightingEnvironment lighting;

  _AtmosphericDustPainter({required this.progress, required this.lighting});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();

    final Color particleColor = (lighting == LightingEnvironment.nuitEtoilee)
        ? const Color(0xFF60A5FA)
        : CultureTheme.accentOrange;

    for (int i = 0; i < 36; i++) {
      final double seedX = random.nextDouble() * size.width;
      final double seedY = random.nextDouble() * size.height;
      final double speed = 0.2 + random.nextDouble() * 0.8;
      final double currentY = (seedY - (progress * speed * size.height)) % size.height;
      final double radius = 1.0 + random.nextDouble() * 2.2;
      final double alpha = (math.sin(progress * math.pi * 2 + i) * 0.3 + 0.5).clamp(0.1, 0.8);

      paint.color = particleColor.withValues(alpha: alpha * 0.45);
      canvas.drawCircle(Offset(seedX, currentY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AtmosphericDustPainter oldDelegate) => true;
}
