import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';

/// Données d'un élément anatomique du monument
class MonumentAnatomicalFeature {
  final String id;
  final String title;
  final String subtitle;
  final String material;
  final String role;
  final String description;
  final IconData icon;

  const MonumentAnatomicalFeature({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.material,
    required this.role,
    required this.description,
    required this.icon,
  });
}

/// Carte de découverte interactive du Génie Bio-Climatique et de l'Anatomie des Bâtisseurs
/// - Sonde thermique interactive (44°C extérieur vs 22°C intérieur naturel)
/// - Hotspots anatomiques tactiles (Torons, Piliers, Œufs d'autruche, Gargouilles)
class MonumentBioClimaticDiscoveryCard extends StatefulWidget {
  final MonumentDetail monument;

  const MonumentBioClimaticDiscoveryCard({
    super.key,
    required this.monument,
  });

  @override
  State<MonumentBioClimaticDiscoveryCard> createState() =>
      _MonumentBioClimaticDiscoveryCardState();
}

class _MonumentBioClimaticDiscoveryCardState
    extends State<MonumentBioClimaticDiscoveryCard> {
  int _selectedFeatureIndex = 0;

  late final List<MonumentAnatomicalFeature> _features;

  @override
  void initState() {
    super.initState();
    _features = _buildFeaturesForMonument(widget.monument.id);
  }

  List<MonumentAnatomicalFeature> _buildFeaturesForMonument(String id) {
    if (id.contains('djenne')) {
      return const [
        MonumentAnatomicalFeature(
          id: 'torons',
          title: 'Torons de Rônier',
          subtitle: 'Échafaudages rituels permanents',
          material: 'Bois de palmier rônier imputrescible',
          role: 'Support ascensionnel & amortisseur thermique',
          description:
              'Poutres de palmier rônier insérées profondément dans les façades. Naturellement insensibles aux termites et à la pourriture, elles permettent aux maçons de gravir les façades lors du crépissage annuel sans aucun échafaudage externe.',
          icon: Icons.carpenter_rounded,
        ),
        MonumentAnatomicalFeature(
          id: 'oeufs_autruche',
          title: 'Œufs d\'Autruche Sommitaux',
          subtitle: 'Protection cosmique & pureté',
          material: 'Coquille minérale sacrée',
          role: 'Symbole de fertilité et paratonnerre traditionnel',
          description:
              'Couronnant les trois minarets emblématiques, ces véritables œufs d\'autruche symbolisent dans la cosmogonie mandingue la renaissance, la pureté et la fécondité. Ils protègent également les pointes d\'argile de l\'érosion zénithale.',
          icon: Icons.egg_rounded,
        ),
        MonumentAnatomicalFeature(
          id: 'piliers_90',
          title: 'Forêt des 90 Piliers',
          subtitle: 'Nef hypostyle bio-climatique',
          material: 'Terre crue (banco massif) & balle de riz',
          role: 'Régulateur de fraîcheur à 22°C',
          description:
              'La grande salle de prière intérieure repose sur une forêt de 90 piliers rectangulaires massifs. Leurs épaisses parois emmagasinent l\'air frais de la nuit pour le restituer pendant la chaleur torride de la journée, sans aucune climatisation.',
          icon: Icons.temple_buddhist_rounded,
        ),
        MonumentAnatomicalFeature(
          id: 'gargouilles',
          title: 'Gargouilles en Terre Cuite',
          subtitle: 'Canalisations d\'hivernage',
          material: 'Poterie d\'argile cuite au feu',
          role: 'Protection absolue contre l\'érosion fluviale',
          description:
              'Des conduits tubulaires en poterie s\'avancent de plus d\'un mètre au-dessus des terrasses. Lors des pluies diluviennes de l\'hivernage, ils expulsent l\'eau loin des murs de banco pour empêcher tout ravinement de l\'argile.',
          icon: Icons.water_drop_rounded,
        ),
      ];
    } else if (id.contains('askia')) {
      return const [
        MonumentAnatomicalFeature(
          id: 'degres_pyramide',
          title: 'Degrés Pyramidaux (17m)',
          subtitle: 'Architecture impériale songhoï',
          material: 'Banco & mortier d\'argile rouge du fleuve Niger',
          role: 'Symbole de grandeur et nécropole impériale',
          description:
              'Structure pyramidale à degrés unique dans tout l\'espace saharien, inspirée du voyage d\'Askia Mohammed au Caire et réinterprétée par les maîtres bâtisseurs de Gao.',
          icon: Icons.change_history_rounded,
        ),
        MonumentAnatomicalFeature(
          id: 'bois_acacia',
          title: 'Échafaudages en Acacia',
          subtitle: 'Branches d\'entretien séculaire',
          material: 'Acacia blanc du Sahel',
          role: 'Ascension rituelle pour l\'enduit',
          description:
              'Des dizaines de madriers en bois d\'acacia dépassent des parois pour permettre aux artisans de Gao de renouveler l\'enduit protecteur après chaque saison des pluies.',
          icon: Icons.forest_rounded,
        ),
      ];
    } else {
      return const [
        MonumentAnatomicalFeature(
          id: 'terre_crue',
          title: 'Matériau Banco Bio-Climatique',
          subtitle: 'Terre locale & fibres végétales',
          material: 'Argile alluviale & balle de riz',
          role: 'Inertie thermique et bilan carbone neutre',
          description:
              'Conception ancestrale respectueuse de l\'écosystème sahélien : les matériaux sont puisés directement dans la terre environnante et recyclés perpétuellement.',
          icon: Icons.nature_rounded,
        ),
        MonumentAnatomicalFeature(
          id: 'minarets_aeration',
          title: 'Minarets & Tirage d\'Air',
          subtitle: 'Ventilation naturelle',
          material: 'Tours élancées ajourées',
          role: 'Évacuation de l\'air chaud par tirage thermique',
          description:
              'Les ouvertures stratégiquement placées au sommet des tours créent un effet venturi continu qui renouvelle l\'air intérieur en permanence.',
          icon: Icons.air_rounded,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final selectedFeature = _features[_selectedFeatureIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── EN-TÊTE DE LA CARTE ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.biotech_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Génie des Bâtisseurs & Sonde Thermique',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'L\'intelligence bio-climatique millénaire du banco',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 1. LA SONDE BIO-CLIMATIQUE (44°C vs 22°C) ─────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Côté Extérieur : Chaleur
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.wb_sunny_rounded,
                                  size: 14,
                                  color: Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'EXTÉRIEUR',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFEF4444),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '44°C',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? const Color(0xFFFCA5A5)
                                    : const Color(0xFFB91C1C),
                              ),
                            ),
                            Text(
                              'Soleil torride du Sahel',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: subtitleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Côté Intérieur : Fraîcheur Banco
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF059669).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.ac_unit_rounded,
                                  size: 14,
                                  color: Color(0xFF059669),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'INTÉRIEUR BANCO',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF059669),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '22°C',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? const Color(0xFF6EE7B7)
                                    : const Color(0xFF047857),
                              ),
                            ),
                            Text(
                              'Fraîcheur 100% naturelle',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: subtitleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Explication de la sonde
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        size: 15,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Climatisation ancestrale sans électricité : inertie de l\'argile, beurre de karité et balle de riz.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── 2. ONGLETS DES HOTSPOTS ANATOMIQUES ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Touchez un organe de l\'édifice pour comprendre :',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: subtitleColor,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Sélecteur horizontal des éléments anatomiques
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_features.length, (idx) {
                final feat = _features[idx];
                final isSelected = idx == _selectedFeatureIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      CulturalHaptics.tabSwitch();
                      setState(() => _selectedFeatureIndex = idx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CultureTheme.accentOrange
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? CultureTheme.accentOrange
                              : borderCol,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            feat.icon,
                            size: 14,
                            color: isSelected ? Colors.white : titleColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            feat.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : titleColor,
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

          // ── 3. CARTE DÉTAILLÉE DU HOTSPOT SÉLECTIONNÉ ─────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        selectedFeature.icon,
                        color: CultureTheme.accentOrange,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFeature.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: titleColor,
                            ),
                          ),
                          Text(
                            selectedFeature.subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CultureTheme.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Rôle & Matériau
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Matériau : ${selectedFeature.material}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFFCD34D)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  selectedFeature.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    height: 1.55,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
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
