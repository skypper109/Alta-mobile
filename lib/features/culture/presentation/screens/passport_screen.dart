import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/models/cultural_guide_models.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../exploration/data/datasources/mock_mali_regions.dart';
import '../widgets/passport_item_card.dart';

/// Écran Maître : Passeport Culturel & Collection des Découvertes (Étape 8)
/// Carnet de voyage culturel numérique & Mémoire vivante de l'exploration du Mali
/// STRICTEMENT SANS DÉGRADÉS selon les règles UX/UI
class PassportScreen extends ConsumerStatefulWidget {
  const PassportScreen({super.key});

  @override
  ConsumerState<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends ConsumerState<PassportScreen> {
  int _selectedFilterIndex = 0; // 0: Tout, 1: Figures, 2: Monuments, 3: Villes, 4: Contes, 5: Défis

  @override
  Widget build(BuildContext context) {
    final passport = ref.watch(culturePassportProvider);
    final notifier = ref.read(culturePassportProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final surfaceAlt = isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt;

    final distinctions = notifier.distinctions;

    // Filtre dynamique de collection
    List<PassportEntry> displayedEntries;
    switch (_selectedFilterIndex) {
      case 1:
        displayedEntries = passport.figures;
        break;
      case 2:
        displayedEntries = passport.monuments;
        break;
      case 3:
        displayedEntries = passport.villes;
        break;
      case 4:
        displayedEntries = passport.contes;
        break;
      case 5:
        displayedEntries = passport.defis;
        break;
      default:
        displayedEntries = passport.entries;
    }

    return Scaffold(
      backgroundColor: isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: CultureTheme.accentOrange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'PASSEPORT CULTUREL',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: CultureTheme.accentOrange,
              ),
            ),
          ],
        ),
        actions: [
          // Bouton Guide IA avec contexte Passeport
          IconButton(
            tooltip: 'Conseils personnalisés de l\'IA',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: CultureTheme.accentOrange,
              ),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              const guideContext = CulturalGuideContext(
                contentType: CulturalContentType.passeport,
                contentTitle: 'Mon Passeport Culturel',
                subtitle: 'Mémoire de voyage & Recommandations personnalisées',
              );
              context.push('/culture/guide', extra: guideContext);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. COUVERTURE & EN-TÊTE DU PASSEPORT DU VOYAGEUR ──────────────
            _buildPassportHeaderCard(context, passport, isDark, cardBg, borderCol, titleColor, subtitleColor),

            const SizedBox(height: 24),

            // ── 2. DÉCOUVERTE DU JOUR À L'HONNEUR ─────────────────────────────
            if (passport.featuredDiscoveryOfTheDay != null) ...[
              _buildSectionTitle('DÉCOUVERTE DU JOUR', Icons.flare_rounded, borderCol),
              const SizedBox(height: 12),
              PassportItemCard(
                entry: passport.featuredDiscoveryOfTheDay!,
                isFeatured: true,
              ),
              const SizedBox(height: 28),
            ],

            // ── 3. MON PARCOURS (RÉSUMÉ POÉTIQUE) ─────────────────────────────
            _buildSectionTitle('MON PARCOURS', Icons.insights_rounded, borderCol),
            const SizedBox(height: 12),
            _buildJourneySummary(passport, isDark, cardBg, borderCol, titleColor, subtitleColor),

            const SizedBox(height: 28),

            // ── 4. MOMENTS MÉMORABLES (« MES DÉCOUVERTES MARQUANTES ») ─────────
            if (passport.milestones.isNotEmpty) ...[
              _buildSectionTitle('MOMENTS MÉMORABLES', Icons.auto_awesome_rounded, borderCol),
              const SizedBox(height: 12),
              _buildMilestonesCarousel(context, passport.milestones, isDark, cardBg, borderCol, titleColor, subtitleColor),
              const SizedBox(height: 28),
            ],

            // ── 5. RÉGIONS EXPLORÉES (CARTE DE PROGRESSION TERRITORIALE) ───────
            _buildSectionTitle('RÉGIONS EXPLORÉES', Icons.map_rounded, borderCol),
            const SizedBox(height: 12),
            _buildRegionsExplorationTracker(context, passport, isDark, cardBg, borderCol, titleColor, subtitleColor),

            const SizedBox(height: 28),

            // ── 6. COLLECTION DES DÉCOUVERTES (AVEC SÉLECTEUR DE CATÉGORIE) ────
            _buildSectionTitle('COLLECTION DES DÉCOUVERTES', Icons.collections_bookmark_rounded, borderCol),
            const SizedBox(height: 12),
            _buildFilterPills(isDark, surfaceAlt, borderCol),
            const SizedBox(height: 16),
            _buildDiscoveriesGrid(context, displayedEntries, isDark, surfaceAlt, subtitleColor),

            const SizedBox(height: 32),

            // ── 7. SCEAUX & DISTINCTIONS CULTURELLES ──────────────────────────
            _buildSectionTitle('SCEAUX D\'AMBASSADEUR CULTUREL', Icons.workspace_premium_rounded, borderCol),
            const SizedBox(height: 12),
            _buildDistinctionsList(distinctions, isDark, cardBg, borderCol, titleColor, subtitleColor),

            const SizedBox(height: 24),

            // ── 8. BANNIÈRE INVITATION GUIDE IA ───────────────────────────────
            _buildAiGuideBanner(context, isDark, cardBg, borderCol, titleColor, subtitleColor),
          ],
        ),
      ),
    );
  }

  // ── TITRE DE SECTION STANDARDISÉ ──────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon, Color borderCol) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CultureTheme.primaryBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: CultureTheme.primaryBlue,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: CultureTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: borderCol)),
      ],
    );
  }

  // ── 1. CARTE EN-TÊTE DU PASSEPORT ─────────────────────────────────────────
  Widget _buildPassportHeaderCard(
    BuildContext context,
    PassportState passport,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: 0.4),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sceau officiel doré / orange
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CultureTheme.accentOrange,
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.public_rounded,
                    color: CultureTheme.accentOrange,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RÉPUBLIQUE DU MALI • ALTERNIA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Passeport d\'Exploration Culturelle',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'N° ${passport.passportNumber}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(height: 1, color: borderCol),
          const SizedBox(height: 14),

          // Infos du voyageur
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VOYAGEUR CULTUREL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: subtitleColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    passport.travelerName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MÉMOIRE VIVANTE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: subtitleColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${passport.totalDiscoveries} Découvertes inscrites',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 3. MON PARCOURS (RÉSUMÉ POÉTIQUE) ──────────────────────────────────────
  Widget _buildJourneySummary(
    PassportState passport,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '« Chaque pas posé sur les terres du Mali tisse la mémoire de son histoire millénaire. »',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: CultureTheme.primaryBlue,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatPill(
                icon: Icons.person_rounded,
                count: passport.figures.length,
                label: 'Figures',
                color: CultureTheme.primaryBlue,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatPill(
                icon: Icons.account_balance_rounded,
                count: passport.monuments.length,
                label: 'Monuments',
                color: CultureTheme.accentOrange,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatPill(
                icon: Icons.location_city_rounded,
                count: passport.villes.length,
                label: 'Cités',
                color: CultureTheme.vertNaturel,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatPill(
                icon: Icons.auto_stories_rounded,
                count: passport.contes.length,
                label: 'Contes',
                color: CultureTheme.cyanTurquoise,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. CARROUSEL DES MOMENTS MÉMORABLES ────────────────────────────────────
  Widget _buildMilestonesCarousel(
    BuildContext context,
    List<PassportEntry> milestones,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: milestones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = milestones[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (item.targetRoute.isNotEmpty) {
                context.push(item.targetRoute);
              }
            },
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: CultureTheme.accentOrange.withValues(alpha: 0.5), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 72,
                      height: 98,
                      child: Image.asset(
                        item.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: CultureTheme.primaryDark,
                          child: Icon(item.type.icon, color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (item.milestoneLabel ?? 'Jalon Historique').toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: CultureTheme.accentOrange,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor,
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
          );
        },
      ),
    );
  }

  // ── 5. RÉGIONS EXPLORÉES (CARTE DE PROGRESSION TERRITORIALE) ───────────────
  Widget _buildRegionsExplorationTracker(
    BuildContext context,
    PassportState passport,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    final allRegions = MockMaliRegions.regions;
    final exploredCount = passport.exploredRegionIds.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderCol, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sillonner le Territoire National',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CultureTheme.vertNaturel.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$exploredCount / ${allRegions.length} Régions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: CultureTheme.vertNaturel,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Liste des régions avec indicateur d'exploration
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allRegions.map((region) {
              final isExplored = passport.exploredRegionIds.contains(region.id);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/culture/region/${region.id}');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: isExplored
                        ? CultureTheme.vertNaturel.withValues(alpha: isDark ? 0.18 : 0.10)
                        : (isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isExplored ? CultureTheme.vertNaturel : borderCol,
                      width: isExplored ? 1.2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isExplored ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 13,
                        color: isExplored ? CultureTheme.vertNaturel : subtitleColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        region.nom,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: isExplored ? FontWeight.w800 : FontWeight.w600,
                          color: isExplored ? (isDark ? Colors.white : const Color(0xFF0F172A)) : subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── 6. FILTRES DE COLLECTION ──────────────────────────────────────────────
  Widget _buildFilterPills(bool isDark, Color surfaceAlt, Color borderCol) {
    const filters = ['Tout', 'Grandes Figures', 'Monuments', 'Cités', 'Contes', 'Défis'];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? CultureTheme.primaryBlue
                    : (isDark ? surfaceAlt : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? CultureTheme.primaryBlue : borderCol,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── GRILLE DE DÉCOUVERTES ─────────────────────────────────────────────────
  Widget _buildDiscoveriesGrid(
    BuildContext context,
    List<PassportEntry> entries,
    bool isDark,
    Color surfaceAlt,
    Color subtitleColor,
  ) {
    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? surfaceAlt : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.explore_off_rounded, size: 36, color: subtitleColor),
            const SizedBox(height: 10),
            Text(
              'Aucune découverte dans cette catégorie',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return PassportItemCard(entry: entries[index]);
      },
    );
  }

  // ── 7. DISTINCTIONS CULTURELLES ───────────────────────────────────────────
  Widget _buildDistinctionsList(
    List<CulturalDistinction> distinctions,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: distinctions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dist = distinctions[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: dist.isUnlocked ? dist.sealColor.withValues(alpha: 0.5) : borderCol,
              width: dist.isUnlocked ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              // Sceau circulaire
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: dist.isUnlocked
                      ? dist.sealColor.withValues(alpha: 0.15)
                      : (isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF1F5F9)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dist.isUnlocked ? dist.sealColor : borderCol,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    dist.icon,
                    size: 22,
                    color: dist.isUnlocked ? dist.sealColor : subtitleColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dist.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: dist.isUnlocked ? titleColor : subtitleColor,
                            ),
                          ),
                        ),
                        if (dist.isUnlocked) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: dist.sealColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'OCTROYÉ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: dist.sealColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dist.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: dist.isUnlocked ? CultureTheme.accentOrange : subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dist.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dist.requirementText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: dist.isUnlocked ? CultureTheme.vertNaturel : subtitleColor,
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

  // ── 8. BANNIÈRE GUIDE IA BASÉE SUR LE PASSEPORT ───────────────────────────
  Widget _buildAiGuideBanner(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
    Color subtitleColor,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        const guideContext = CulturalGuideContext(
          contentType: CulturalContentType.passeport,
          contentTitle: 'Mon Passeport Culturel',
          subtitle: 'Conseils & prochaines découvertes suggérées par l\'IA',
        );
        context.push('/culture/guide', extra: guideContext);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: CultureTheme.accentOrange.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guide Culturel IA & Votre Parcours',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'L\'IA analyse votre Passeport pour vous recommander vos prochaines découvertes au Mali.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: CultureTheme.accentOrange,
            ),
          ],
        ),
      ),
    );
  }
}
