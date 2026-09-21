import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/theme/culture_theme.dart';
import '../services/cultural_haptics.dart';

/// Modèle pour un terroir du Compas
class TerroirOrbData {
  final String id;
  final String title;
  final String subtitle;
  final String cities;
  final String photoUrl;
  final IconData icon;
  final Color accentColor;
  final String highlightFact;

  const TerroirOrbData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.cities,
    required this.photoUrl,
    required this.icon,
    required this.accentColor,
    required this.highlightFact,
  });
}

/// Le Compas Vivant des Terroirs du Mali (Orbes Interactifs & Capsule de Voyage)
/// Rapprochement tactile et visuel d'exception. ZÉRO répétition de catalogue.
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI AlterniA.
class CulturalTerroirCompassWidget extends ConsumerStatefulWidget {
  const CulturalTerroirCompassWidget({super.key});

  @override
  ConsumerState<CulturalTerroirCompassWidget> createState() =>
      _CulturalTerroirCompassWidgetState();
}

class _CulturalTerroirCompassWidgetState
    extends ConsumerState<CulturalTerroirCompassWidget>
    with SingleTickerProviderStateMixin {
  int _selectedOrbIndex = 0;

  static const List<TerroirOrbData> _orbs = [
    TerroirOrbData(
      id: 'nord',
      title: 'Nord Millénaire',
      subtitle: 'Tombouctou, Gao & Kidal',
      cities: 'Les 333 Saints • Le Tombeau des Askia',
      photoUrl: 'assets/images/culture/monuments/djingareyber_tombouctou.jpg',
      icon: Icons.account_balance_rounded,
      accentColor: CultureTheme.accentOrange,
      highlightFact: 'Haut lieu de la pensée savante et des manuscrits anciens d\'Afrique.',
    ),
    TerroirOrbData(
      id: 'centre',
      title: 'Falaises & Dogon',
      subtitle: 'Bandiagara & Mopti',
      cities: 'Venise Malienne • Toguna & Kanaga',
      photoUrl: 'assets/images/culture/villes/bandiagara_falaise.jpg',
      icon: Icons.landscape_rounded,
      accentColor: CultureTheme.cyanTurquoise,
      highlightFact: 'Architecture rupestre classée à l\'UNESCO et cosmogonie céleste.',
    ),
    TerroirOrbData(
      id: 'mande',
      title: 'Cœur Mandingue',
      subtitle: 'Koulikoro & Bamako',
      cities: 'Berceau des Keïta • Kouroukan Fouga',
      photoUrl: 'assets/images/culture/personnages/soundiata_keita.jpg',
      icon: Icons.shield_rounded,
      accentColor: CultureTheme.primaryBlue,
      highlightFact: 'La première déclaration universelle des droits de l\'Homme en 1236.',
    ),
    TerroirOrbData(
      id: 'sud',
      title: 'Royaumes du Sud',
      subtitle: 'Sikasso & Ségou',
      cities: 'Le Tata Héroïque • Les 4444 Balanzans',
      photoUrl: 'assets/images/culture/villes/djenne_mosquee.jpg',
      icon: Icons.military_tech_rounded,
      accentColor: CultureTheme.accentOrange,
      highlightFact: 'Terre des fiers rois du Kénédougou et de l\'Empire bambara.',
    ),
  ];

  void _selectOrb(int index) {
    if (_selectedOrbIndex == index) return;
    CulturalHaptics.tabSwitch();
    setState(() {
      _selectedOrbIndex = index;
    });

    // Mettre à jour la région active pour tout l'univers
    final orb = _orbs[index];
    final regionId = orb.id == 'nord'
        ? 'tombouctou'
        : (orb.id == 'centre'
            ? 'mopti'
            : (orb.id == 'mande' ? 'koulikoro' : 'sikasso'));
    ref.read(activeCultureRegionProvider.notifier).selectRegionById(regionId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final selectedOrb = _orbs[_selectedOrbIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── TITRE DE SECTION DU COMPAS ─────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: CultureTheme.cyanTurquoise.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CultureTheme.cyanTurquoise.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    size: 16,
                    color: CultureTheme.cyanTurquoise,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPAS DES TERROIRS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: CultureTheme.cyanTurquoise,
                      ),
                    ),
                    Text(
                      'Voyagez à travers les 4 Régions du Mali',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── 4 ORBES EN RANGÉE TACTILE ──────────────────────────────────────
        Row(
          children: List.generate(_orbs.length, (index) {
            final orb = _orbs[index];
            final isSelected = _selectedOrbIndex == index;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < _orbs.length - 1 ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => _selectOrb(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? orb.accentColor.withValues(alpha: isDark ? 0.25 : 0.12)
                          : cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? orb.accentColor
                            : borderCol,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: orb.accentColor.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          orb.icon,
                          size: 22,
                          color: isSelected ? orb.accentColor : subtitleColor,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          orb.title.split(' ').first,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? orb.accentColor : titleColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 14),

        // ── CAPSULE SENSORIELLE ACTIVE DU TERROIR SÉLECTIONNÉ ──────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(anim),
              child: child,
            ),
          ),
          child: Container(
            key: ValueKey('terroir_capsule_${selectedOrb.id}'),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selectedOrb.accentColor.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: selectedOrb.accentColor.withValues(alpha: isDark ? 0.15 : 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image miniature du terroir
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    selectedOrb.photoUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: selectedOrb.accentColor.withValues(alpha: 0.15),
                      child: Icon(selectedOrb.icon, color: selectedOrb.accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Informations clés
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: selectedOrb.accentColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              selectedOrb.title.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            selectedOrb.subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedOrb.cities,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedOrb.highlightFact,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: subtitleColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
