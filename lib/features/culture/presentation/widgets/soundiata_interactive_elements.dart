import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../immersive/services/cultural_haptics.dart';
import '../../../../core/services/vivienne_tts_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// 1. MODÈLES DE DONNÉES PATRIMONIALES (CITÉS & CHARTE)
// ══════════════════════════════════════════════════════════════════════════════

/// Modèle d'une cité historique du Manden médiéval
class MandeCity {
  final String id;
  final String name;
  final String title;
  final String description;
  final String goods;
  final String distanceInfo;
  final Offset relativeOffset; // [0.0 - 1.0] sur la carte
  final IconData icon;

  const MandeCity({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.goods,
    required this.distanceInfo,
    required this.relativeOffset,
    required this.icon,
  });

  static const List<MandeCity> cities = [
    MandeCity(
      id: 'niani',
      name: 'Niani',
      title: 'Capitale Impériale & Berceau des Keïta',
      description:
          'Cité fortifiée entourée de collines et baignée par le Sankarani. Siège royal de Naré Maghann Konaté et point de départ de l\'épopée de Soundiata.',
      goods: 'Or brut du Bouré, Pépites sacrées, Ivoire impérial',
      distanceInfo: 'Point de départ (Km 0)',
      relativeOffset: Offset(0.33, 0.68),
      icon: Icons.account_balance_rounded,
    ),
    MandeCity(
      id: 'kangaba',
      name: 'Kangaba (Kaba)',
      title: 'Terre du Serment & Kouroukan Fouga',
      description:
          'Haut lieu spirituel du Manden abritant le sanctuaire sacré du Kamablon. En 1236, Soundiata y réunit l\'assemblée des sages pour proclamer la première charte des droits de l\'homme.',
      goods: 'Coton tissé, Cuir tanné, Sel gemme',
      distanceInfo: '55 km au nord-ouest de Niani',
      relativeOffset: Offset(0.42, 0.54),
      icon: Icons.park_rounded,
    ),
    MandeCity(
      id: 'kirina',
      name: 'Kirina',
      title: 'Le Champ du Choc Suprême (1235)',
      description:
          'Plaine rocailleuse proche de Koulikoro où s\'affrontèrent les armées coalisées de Soundiata et les légions du roi-sorcier Soumaoro Kanté. La flèche d\'ergot blanc y scella le sort du Sosso.',
      goods: 'Forges royales, Lances trempées, Cuirasses de chasseurs',
      distanceInfo: '120 km au nord de Niani',
      relativeOffset: Offset(0.52, 0.50),
      icon: Icons.sports_kabaddi_rounded,
    ),
    MandeCity(
      id: 'djenne',
      name: 'Djenné',
      title: 'Carrefour Fluvial & Reine du Bani',
      description:
          'Métropole marchande millénaire et chef-d\'œuvre de l\'architecture en terre crue. Cœur du commerce entre les forêts aurifères du Sud et les pistes sahariennes du Nord.',
      goods: 'Or, Sel gemme du Sahara, Céréales, Poissons séchés',
      distanceInfo: '380 km le long du Djoliba',
      relativeOffset: Offset(0.66, 0.56),
      icon: Icons.water_rounded,
    ),
    MandeCity(
      id: 'tombouctou',
      name: 'Tombouctou',
      title: 'Métropole Savante & Phare du Désert',
      description:
          'Porte d\'or du Sahara et capitale intellectuelle mondiale du XIVe siècle. Ses universités (Sankoré) et ses centaines de milliers de manuscrits ont illuminé la civilisation universelle.',
      goods: 'Manuscrits enluminés, Plaques de sel de Taoudeni, Épices d\'Orient',
      distanceInfo: '680 km par voie fluviale et chamelière',
      relativeOffset: Offset(0.68, 0.36),
      icon: Icons.menu_book_rounded,
    ),
    MandeCity(
      id: 'gao',
      name: 'Gao',
      title: 'Cité Royale de la Boucle du Niger',
      description:
          'Grande capitale orientale sur le méandre navigable du Niger. Carrefour commercial majeur reliant l\'Égypte, le Maghreb, le Kanem et les royaumes forestiers.',
      goods: 'Sel d\'Idjil, Cuivre d\'Azelik, Draps fins, Chevaux barbes',
      distanceInfo: '920 km sur la grande boucle fluviale',
      relativeOffset: Offset(0.82, 0.38),
      icon: Icons.fort_rounded,
    ),
  ];
}

/// Modèle d'un article fondamental de la Charte de Kouroukan Fouga (1236)
class CharterArticle {
  final int number;
  final String title;
  final String quote;
  final String explanation;
  final IconData icon;

  const CharterArticle({
    required this.number,
    required this.title,
    required this.quote,
    required this.explanation,
    required this.icon,
  });

  static const List<CharterArticle> fundamentalArticles = [
    CharterArticle(
      number: 5,
      title: 'Inviolabilité de la Vie Humaine',
      quote:
          '« Toute vie humaine est une vie. Une vie ne vaut ni plus ni moins qu\'une autre vie. Le tort fait à l\'un est un tort fait à tous. Nul ne doit humilier son semblable. »',
      explanation:
          'Consacrée dès 1236, cette loi sacrée abolit le meurtre arbitraire, protège l\'intégrité physique de tout individu et pose l\'égalité primordiale des êtres vivants, 550 ans avant les déclarations occidentales.',
      icon: Icons.favorite_rounded,
    ),
    CharterArticle(
      number: 7,
      title: 'La Sanankouya (Parenté à Plaisanterie)',
      quote:
          '« Il est institué entre clans alliés le pacte sacré de Sanankouya. L\'humour et la dérision amicale désarmeront la haine et interdiront à jamais l\'effusion de sang entre frères. »',
      explanation:
          'Un génie sociologique unique au monde : un pacte de médiation par la plaisanterie codifiée entre patronymes (ex: Keïta et Traoré, Coulibaly et Touré) qui désamorce tout conflit avant qu\'il n\'éclate.',
      icon: Icons.handshake_rounded,
    ),
    CharterArticle(
      number: 16,
      title: 'Protection et Dignité des Femmes',
      quote:
          '« Les femmes sont nos mères et la source sacrée de la paix sociale. Ne provoquez jamais leur colère et veillez à leur respect dans chaque concession. »',
      explanation:
          'La charte place la femme au sommet de l\'autorité morale et familiale, interdisant les violences domestiques et garantissant sa protection dans toute l\'étendue de l\'empire.',
      icon: Icons.shield_rounded,
    ),
    CharterArticle(
      number: 20,
      title: 'L\'Hospitalité Sacrée (Diya)',
      quote:
          '« L\'étranger qui entre dans votre village est sous la protection inviolable du Manden. Partagez avec lui le bol et le toit, nul ne doit être dépouillé de ses biens sur nos terres. »',
      explanation:
          'Fondement de la sécurité des routes commerciales et de l\'accueil universel, garantissant la libre circulation des marchands, voyageurs et érudits de toutes nations.',
      icon: Icons.home_work_rounded,
    ),
    CharterArticle(
      number: 37,
      title: 'Sauvegarde de la Nature & Forêts',
      quote:
          '« Ne mettez point le feu à la brousse sans discernement. Préservez les grands arbres, les bêtes sacrées et les cours d\'eau qui étanchent la soif de nos générations futures. »',
      explanation:
          'L\'une des toutes premières chartes écologiques de l\'histoire humaine, réglementant la coupe des arbres, les feux de brousse et protégeant la faune et les berges du fleuve Djoliba.',
      icon: Icons.forest_rounded,
    ),
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
// 2. MICRO-INTERACTION 1 : CARTE ANCIENNE INTERACTIVE DU MANDÉ (ACTE III)
// ══════════════════════════════════════════════════════════════════════════════

/// Composant interactif pour la Carte du Mandé
/// Permet de toucher les cités directement sur la carte ou via les puces
class MandeInteractiveMapWidget extends StatefulWidget {
  final bool isDark;
  final bool isCompact;
  final ValueChanged<MandeCity>? onCitySelected;

  const MandeInteractiveMapWidget({
    super.key,
    required this.isDark,
    this.isCompact = false,
    this.onCitySelected,
  });

  @override
  State<MandeInteractiveMapWidget> createState() =>
      _MandeInteractiveMapWidgetState();
}

class _MandeInteractiveMapWidgetState extends State<MandeInteractiveMapWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  MandeCity _selectedCity = MandeCity.cities[0];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _selectCity(MandeCity city) {
    CulturalHaptics.cardPress();
    setState(() {
      _selectedCity = city;
    });
    if (widget.onCitySelected != null) {
      widget.onCitySelected!(city);
    }
  }

  void _showCityBottomSheet(BuildContext context, MandeCity city) {
    CulturalHaptics.stamp();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => MandeCityDetailSheet(city: city, isDark: widget.isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── BANDEAU INVITANT À L'INTERACTION TACTILE ──
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.touch_app_rounded,
                size: 14,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Touchez une cité sur la carte ou dans la liste pour révéler ses archives',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── SÉLECTEUR RAPIDE DE CITÉS (CHIPS HORIZONTAUX) ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: MandeCity.cities.map((city) {
              final isSelected = city.id == _selectedCity.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 10),
                child: GestureDetector(
                  onTap: () => _selectCity(city),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD97706)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08)),
                        width: isSelected ? 1.4 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          city.icon,
                          size: 13,
                          color: isSelected
                              ? Colors.black
                              : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          city.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w900
                                : FontWeight.w700,
                            color: isSelected
                                ? Colors.black
                                : (isDark ? Colors.white : Colors.black87),
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

        // ── CARTE AVEC HOTSPOTS TACTILES CLIQUABLES ──
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: widget.isCompact ? 200 : 240,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fond parchemin de la carte ancienne
                    Image.asset(
                      'assets/images/culture/scenes/carte_ancienne_mande.jpg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF0F172A),
                      ),
                    ),

                    // Filtre sombre pour contraste de lecture
                    Container(
                      color: Colors.black.withValues(alpha: 0.35),
                    ),

                    // Peintre vectoriel des voies caravanières
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _MandeVectorRoutesPainter(
                            progress: _pulseController.value,
                            selectedCity: _selectedCity,
                          ),
                        );
                      },
                    ),

                    // HOTSPOTS TACTILES POUR CHAQUE CITÉ
                    ...MandeCity.cities.map((city) {
                      final isSelected = city.id == _selectedCity.id;
                      final posX = city.relativeOffset.dx * width;
                      final posY = city.relativeOffset.dy * height;

                      return Positioned(
                        left: posX - 24,
                        top: posY - 24,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _selectCity(city);
                            _showCityBottomSheet(context, city);
                          },
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Anneau d'onde de choc pour la cité sélectionnée
                                if (isSelected)
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, _) {
                                      final scale = 1.0 +
                                          (_pulseController.value * 0.8);
                                      final opacity = (1.0 -
                                              _pulseController.value * 0.7)
                                          .clamp(0.0, 1.0);
                                      return Transform.scale(
                                        scale: scale,
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFF59E0B)
                                                  .withValues(alpha: opacity),
                                              width: 2.2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                // Point lumineux au centre
                                Container(
                                  width: isSelected ? 16 : 12,
                                  height: isSelected ? 16 : 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xFFF59E0B)
                                        : Colors.white,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isSelected
                                                ? const Color(0xFFF59E0B)
                                                : Colors.white)
                                            .withValues(alpha: 0.8),
                                        blurRadius: isSelected ? 10 : 6,
                                      ),
                                    ],
                                  ),
                                ),

                                // Étiquette flottante du nom de la cité
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                          alpha: isSelected ? 0.95 : 0.75),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFF59E0B)
                                            : Colors.white.withValues(alpha: 0.2),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      city.name.split(' ').first,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 8.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                        color: isSelected
                                            ? const Color(0xFFF59E0B)
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── CARTE D'ARCHIVE FLOTTANTE DE LA CITÉ SÉLECTIONNÉE ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF59E0B),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      _selectedCity.icon,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCity.name.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          _selectedCity.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF59E0B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _showCityBottomSheet(context, _selectedCity),
                    icon: const Icon(
                      Icons.open_in_full_rounded,
                      size: 18,
                      color: Color(0xFFF59E0B),
                    ),
                    tooltip: 'Consulter l\'archive complète',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _selectedCity.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  height: 1.45,
                  color: isDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_rounded,
                    size: 13,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Échanges : ${_selectedCity.goods}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFFCD34D)
                            : const Color(0xFFB45309),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Peintre vectoriel des routes caravanières avec mise en relief de la cité active
class _MandeVectorRoutesPainter extends CustomPainter {
  final double progress;
  final MandeCity selectedCity;

  _MandeVectorRoutesPainter({
    required this.progress,
    required this.selectedCity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final points = MandeCity.cities
        .map((c) => Offset(
              c.relativeOffset.dx * size.width,
              c.relativeOffset.dy * size.height,
            ))
        .toList();

    // Tracé continu
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, routePaint);
    canvas.drawPath(path, dashPaint);
  }

  @override
  bool shouldRepaint(covariant _MandeVectorRoutesPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.selectedCity.id != selectedCity.id;
}

/// Feuille modale d'archive pour une cité du Manden
class MandeCityDetailSheet extends StatelessWidget {
  final MandeCity city;
  final bool isDark;

  const MandeCityDetailSheet({
    super.key,
    required this.city,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
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
                child: Icon(city.icon, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ARCHIVE DU MANDEN MÉDIÉVAL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF59E0B),
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      city.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  final text =
                      '${city.name}. ${city.title}. ${city.distanceInfo}. ${city.description}. Échanges commerciaux : ${city.goods}.';
                  try {
                    VivienneTtsService.instance.speak(text);
                  } catch (_) {}
                },
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: Color(0xFFF59E0B),
                ),
                tooltip: 'Écouter l\'archive vocale',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            city.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_rounded,
                    size: 13, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Text(
                  city.distanceInfo,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            city.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.55,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_rounded,
                    color: Color(0xFFF59E0B), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Denrées & Richesses Échangées',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      Text(
                        city.goods,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
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
}

// ══════════════════════════════════════════════════════════════════════════════
// 3. MICRO-INTERACTION 2 : LE CHOC DE KIRINA & LA FLÈCHE BLANCHE (ACTE VI)
// ══════════════════════════════════════════════════════════════════════════════

/// Arène de combat interactive : permet à l'utilisateur de décocher la flèche
/// magique à l'ergot de coq blanc de Soundiata vers Soumaoro Kanté.
class KirinaBattleArenaWidget extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onVictory;

  const KirinaBattleArenaWidget({
    super.key,
    required this.isDark,
    this.onVictory,
  });

  @override
  State<KirinaBattleArenaWidget> createState() =>
      _KirinaBattleArenaWidgetState();
}

class _KirinaBattleArenaWidgetState extends State<KirinaBattleArenaWidget>
    with TickerProviderStateMixin {
  late final AnimationController _arrowController;
  late final AnimationController _shakeController;
  late final AnimationController _flashController;

  bool _isFired = false;
  bool _soumaoroDefeated = false;

  @override
  void initState() {
    super.initState();
    // Animation du vol de la flèche (durée 900ms)
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Animation du tremblement d'écran lors de l'impact
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Flash lumineux d'impact
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _arrowController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerImpact();
      }
    });
  }

  void _triggerImpact() {
    _flashController.forward(from: 0.0);
    _shakeController.forward(from: 0.0);
    CulturalHaptics.celebration();

    setState(() {
      _soumaoroDefeated = true;
    });

    if (widget.onVictory != null) {
      widget.onVictory!();
    }
  }

  void _shootArrow() {
    if (_arrowController.isAnimating) return;
    CulturalHaptics.cardPress();
    setState(() {
      _isFired = true;
      _soumaoroDefeated = false;
    });
    _arrowController.forward(from: 0.0);
  }

  void _resetBattle() {
    CulturalHaptics.tabSwitch();
    setState(() {
      _isFired = false;
      _soumaoroDefeated = false;
    });
    _arrowController.reset();
    _shakeController.reset();
    _flashController.reset();
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _shakeController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        // Effet de secousse sismique à l'impact
        final shakeFactor = (1.0 - _shakeController.value) *
            math.sin(_shakeController.value * 28) *
            6.0;

        return Transform.translate(
          offset: Offset(shakeFactor, 0),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF160B04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de l'arène interactive
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.flash_on_rounded,
                                    size: 13, color: Colors.black),
                                const SizedBox(width: 4),
                                Text(
                                  'CHOC INTERACTIF 1235',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_soumaoroDefeated)
                        TextButton.icon(
                          onPressed: _resetBattle,
                          icon: const Icon(Icons.refresh_rounded,
                              size: 14, color: Color(0xFFF59E0B)),
                          label: Text(
                            'Rejouer',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Arène de duel avec Soundiata (gauche) et Soumaoro (droite)
                  SizedBox(
                    height: 140,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final arenaWidth = constraints.maxWidth;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // ── SOUNDIATA (GAUCHE) ──
                            Positioned(
                              left: 6,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFF59E0B),
                                        width: 2.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF59E0B)
                                              .withValues(alpha: 0.5),
                                          blurRadius: 14,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/culture/personnages/soundiata.jpg',
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Soundiata',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Arc légendaire',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── TRAJECTOIRE DE LA FLÈCHE BLANCHE ──
                            if (_isFired)
                              AnimatedBuilder(
                                animation: _arrowController,
                                builder: (context, _) {
                                  final t = _arrowController.value;
                                  final startX = 76.0;
                                  final targetX = arenaWidth - 80.0;
                                  final currentX =
                                      startX + (targetX - startX) * t;
                                  // Trajectoire en cloche parabolique
                                  final arcY = -math.sin(t * math.pi) * 35.0;

                                  return Positioned(
                                    left: currentX,
                                    child: Transform.translate(
                                      offset: Offset(0, arcY),
                                      child: Transform.rotate(
                                        angle: (0.15 - (t * 0.3)),
                                        child: _buildFlyingArrow(),
                                      ),
                                    ),
                                  );
                                },
                              ),

                            // ── SOUMAORO KANTÉ (DROITE) ──
                            Positioned(
                              right: 6,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 600),
                                opacity: _soumaoroDefeated ? 0.35 : 1.0,
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 600),
                                  scale: _soumaoroDefeated ? 0.85 : 1.0,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 68,
                                        height: 68,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _soumaoroDefeated
                                                ? Colors.grey
                                                : const Color(0xFFEF4444),
                                            width: 2.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (_soumaoroDefeated
                                                      ? Colors.black
                                                      : const Color(0xFFEF4444))
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 14,
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            'assets/images/culture/personnages/soumaoro_kante.jpg',
                                            fit: BoxFit.cover,
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Soumaoro',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: _soumaoroDefeated
                                              ? Colors.white54
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        _soumaoroDefeated
                                            ? 'En fuite'
                                            : 'Roi-Sorcier',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          color: _soumaoroDefeated
                                              ? Colors.grey
                                              : const Color(0xFFEF4444),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── BOUTON D'ACTION OU MESSAGE DE VICTOIRE ──
                  if (!_soumaoroDefeated)
                    GestureDetector(
                      onTap: _shootArrow,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFF59E0B).withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.black,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Décocher la Flèche d\'Ergot Blanc !',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Soumaoro est touché ! Le roi-sorcier perd son invulnérabilité et s\'évanouit dans la montagne de Koulikoro.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // FLASH D'IMPACT
            AnimatedBuilder(
              animation: _flashController,
              builder: (context, _) {
                final opacity = (1.0 - _flashController.value) * 0.7;
                if (opacity <= 0.01) return const SizedBox.shrink();
                return Positioned.fill(
                  child: Container(
                    color: Colors.white.withValues(alpha: opacity),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlyingArrow() {
    return Container(
      width: 44,
      height: 16,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Traîne lumineuse d'étincelles dorées
          Container(
            width: 38,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.transparent, Color(0xFFF59E0B), Colors.white],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          // Pointe d'ergot de coq blanc
          Positioned(
            right: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 8,
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

// ══════════════════════════════════════════════════════════════════════════════
// 4. MICRO-INTERACTION 3 : TIROIR ACCORDÉON DE LA CHARTE (ACTE VII)
// ══════════════════════════════════════════════════════════════════════════════

/// Accordéon tactile révélant les 5 articles clés de la Charte de Kouroukan Fouga
class KouroukanCharterAccordion extends StatefulWidget {
  final bool isDark;

  const KouroukanCharterAccordion({
    super.key,
    required this.isDark,
  });

  @override
  State<KouroukanCharterAccordion> createState() =>
      _KouroukanCharterAccordionState();
}

class _KouroukanCharterAccordionState extends State<KouroukanCharterAccordion> {
  // Indice de l'article déployé (null si tous fermés)
  int? _expandedIndex = 0;

  void _toggleArticle(int index) {
    CulturalHaptics.cardPress();
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête du tiroir de la Charte
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_rounded,
                size: 13,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Déployez les articles fondateurs de 1236 (Classés UNESCO)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Liste des articles en accordéon
        ...List.generate(CharterArticle.fundamentalArticles.length, (index) {
          final article = CharterArticle.fundamentalArticles[index];
          final isExpanded = _expandedIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isExpanded
                    ? const Color(0xFFF59E0B)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08)),
                width: isExpanded ? 1.4 : 1.0,
              ),
              boxShadow: isExpanded
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                // Entête cliquable de l'article
                InkWell(
                  onTap: () => _toggleArticle(index),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // Numéro de l'article stylisé
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            'Art. ${article.number}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            article.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Contenu déplié avec animation fluide
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 260),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding:
                        const EdgeInsets.only(left: 14, right: 14, bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, thickness: 0.8),
                        const SizedBox(height: 10),
                        // Citation originale sacrée
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFFF59E0B),
                                width: 3.0,
                              ),
                            ),
                          ),
                          child: Text(
                            article.quote,
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
                        const SizedBox(height: 8),
                        // Explication patrimoniale
                        Text(
                          article.explanation,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF475569),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Bouton d'écoute vocale de l'article
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                final text =
                                    'Article ${article.number} de la Charte de Kouroukan Fouga : ${article.title}. ${article.quote}. ${article.explanation}';
                                try {
                                  VivienneTtsService.instance.speak(text);
                                } catch (_) {}
                              },
                              icon: const Icon(
                                Icons.volume_up_rounded,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                              label: Text(
                                'Écouter cet article',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
