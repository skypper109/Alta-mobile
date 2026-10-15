import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_data_providers.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/models/culture_item.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';
import '../../../../presentation/common/widgets/alternia_logo.dart';
import '../../../curiosity/presentation/widgets/daily_curiosity_card.dart';
import '../widgets/culture_region_bottom_sheet.dart';

/// Vue 1 : Accueil Culture — « Le Sanctuaire Vivant du Mali »
/// Expérience immersive et cinématique de classe mondiale.
/// ZÉRO répétition de catalogue des autres onglets.
/// Vraie 3D gyroscopique au toucher, Médaillon sacré à déflagration radiale,
/// Compas orbital des terroirs et Défi éclair du Crépuscule.
/// STRICTEMENT SANS DÉGRADÉS selon les 3 couleurs de marque AlterniA.
class CultureHomeView extends ConsumerWidget {
  final ValueChanged<int> onNavigateToTab;

  const CultureHomeView({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRegion = ref.watch(activeCultureRegionProvider).activeRegion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final featuredAsync = ref.watch(cultureFeaturedItemProvider);
    final figuresAsync = ref.watch(cultureFiguresProvider);
    final monumentsAsync = ref.watch(cultureMonumentsProvider);
    final villesAsync = ref.watch(cultureVillesProvider);

    final featured = featuredAsync.valueOrNull ??
        const CultureItem(
          id: 'featured_soundiata',
          title: 'Soundiata Keïta & la Charte du Manden',
          subtitle: 'Le fondateur de l\'Empire du Mali et la proclamation de 1236',
          category: 'accueil',
          subCategory: 'personnages',
          description:
              'Découvrez l\'épopée du Lion du Manden, sa victoire décisive à Kirina en 1235 et la proclamation de l\'une des premières déclarations des droits humains à Kouroukan Fouga.',
          regionId: 'koulikoro',
          regionName: 'Koulikoro',
          tag: 'Épopée Majeure',
          icon: Icons.shield_rounded,
          imageUrl: 'assets/images/culture/personnages/soundiata.jpg',
          isFeatured: true,
          info: 'Lecture : 4 min',
        );

    final allItems = [
      ...(figuresAsync.valueOrNull ?? []),
      ...(monumentsAsync.valueOrNull ?? []),
      ...(villesAsync.valueOrNull ?? []),
    ];
    final recommendations = allItems
        .where((item) => item.matchesRegion(activeRegion?.id))
        .take(4)
        .toList();

    return CulturalAtmosphereCanvas(
      enableParticles: true,
      enableBogolanMotifs: true,
      motifOpacity: 0.12,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 0. LE RITUEL QUOTIDIEN : LA PÉPITE DU JOUR & LE DÉFI ÉCLAIR (60s) ──
            const AnimatedCulturalReveal(
              delay: Duration(milliseconds: 60),
              child: DailyCuriosityCard(),
            ),

            // ── 1. LE GRAND BAOBAB : CHAT AVEC GRAND-MÈRE MAH (MIS EN VALEUR) ──
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 90),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131B2A) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: CultureTheme.accentOrange,
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CultureTheme.accentOrange
                          .withValues(alpha: isDark ? 0.35 : 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push('/culture/sage');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Visuel photographique immersif du Baobab et Grand-mère Mah
                        SizedBox(
                          height: 125,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/culture/contes/manden_baobab_stage.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF131B2A),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.35),
                                      const Color(0xFF0F172A).withValues(alpha: 0.88),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.accentOrange,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CultureTheme.accentOrange
                                            .withValues(alpha: 0.45),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.fireplace_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'VEILLÉE SOUS LE GRAND BAOBAB',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 12,
                                right: 12,
                                child: Text(
                                  'Parle avec Grand-mère Mah',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                    shadows: const [
                                      Shadow(color: Colors.black, blurRadius: 6),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Descriptif & Actions
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Découvre l\'origine sacrée et le totem de ton nom de famille (Jamu), et écoute la sagesse du Mandé au coin du feu.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  height: 1.4,
                                  color: subtitleColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF22C55E),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Conteuse & Généalogie active',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: CultureTheme.accentOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: CultureTheme.accentOrange,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: CultureTheme.accentOrange
                                              .withValues(alpha: 0.35),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Entrer dans la veillée',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward_rounded,
                                            size: 13, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── 2. SECTION « À LA UNE » (FORMAT ÉPURÉ ET COMPACT) ─────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 140),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: CultureTheme.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'À LA UNE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 1, color: borderCol)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Carte À la une compacte et interactive avec ornementation soudanaise
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 180),
              child: CulturalInteractiveCard(
                onTap: () {
                  context.push('/culture/personnage/perso_soundiata');
                },
                backgroundColor: cardBg,
                borderColor: borderCol,
                activeAccentColor: CultureTheme.accentOrange,
                padding: EdgeInsets.zero,
                showSudaneseCorners: true,
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bandeau visuel photographique compact (hauteur réduite à 110px)
                    SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (featured.imageUrl != null &&
                              featured.imageUrl!.isNotEmpty)
                            Image.asset(
                              featured.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: CultureTheme.primaryDark,
                                child: const Center(
                                  child: Icon(Icons.shield_rounded,
                                      size: 36, color: Colors.white54),
                                ),
                              ),
                            )
                          else
                            Container(color: CultureTheme.primaryDark),

                          // Overlay sombre uni pour contraste texte
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: CultureTheme.accentOrange,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CultureTheme.accentOrange
                                                .withValues(alpha: 0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        featured.tag.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.4,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.25),
                                          width: 1,
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
                                            featured.regionName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  featured.info,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    shadows: const [
                                      Shadow(
                                          color: Colors.black, blurRadius: 4),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Corps éditorial compact
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      featured.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w800,
                                        color: titleColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      featured.subtitle,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: CultureTheme.accentOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  context.push(
                                      '/culture/personnage/perso_soundiata');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.accentOrange
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Découvrir',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: CultureTheme.accentOrange,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 13,
                                        color: CultureTheme.accentOrange,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            featured.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: subtitleColor,
                              height: 1.35,
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

            const SizedBox(height: 20),

            // ── NOUVEAUTÉ : SCANNER IA DE MONUMENTS & LIEUX ──────────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 220),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.push('/culture/scanner');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? CultureTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.5),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            CultureTheme.accentOrange.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: CultureTheme.accentOrange,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: CultureTheme.accentOrange
                                  .withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.document_scanner_rounded,
                            size: 28,
                            color: Colors.black,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.accentOrange
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'DÉCOUVERTE & HISTOIRE',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: CultureTheme.accentOrange,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Scanner un Monument ou Lieu',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pointez votre caméra pour révéler son histoire',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              CultureTheme.accentOrange.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── 3. REPRENDRE — ACTIVITÉ RÉCENTE PERSONNALISÉE ────────────────
            Builder(
              builder: (context) {
                final passport = ref.watch(culturePassportProvider);
                // Récupérer les dernières activités par type
                final recentItems = <PassportEntry>[];
                // Dernier conte
                if (passport.contes.isNotEmpty) {
                  recentItems.add(passport.contes.first);
                }
                // Dernier défi
                if (passport.defis.isNotEmpty) {
                  recentItems.add(passport.defis.first);
                }
                // Dernier monument
                if (passport.monuments.isNotEmpty) {
                  recentItems.add(passport.monuments.first);
                }
                // Dernière figure
                if (passport.figures.isNotEmpty) {
                  recentItems.add(passport.figures.first);
                }

                if (recentItems.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Trier par date la plus récente
                recentItems
                    .sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
                final displayItems = recentItems.take(3).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: CultureTheme.primaryBlue
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.history_rounded,
                                size: 14,
                                color: CultureTheme.primaryBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'REPRENDRE',
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
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayItems.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (ctx, index) {
                          return _buildRecentActivityCard(
                            context: context,
                            entry: displayItems[index],
                            isDark: isDark,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // ── 4. RECOMMANDATIONS FILTRÉES ─────────────────────────────────────
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CultureTheme.vertNaturel.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: CultureTheme.vertNaturel,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activeRegion != null
                            ? 'SÉLECTION : ${activeRegion.nom.toUpperCase()}'
                            : 'RECOMMANDATIONS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: CultureTheme.vertNaturel,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Container(height: 1, color: borderCol)),
              ],
            ),

            const SizedBox(height: 12),

            if (recommendations.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.location_off_rounded,
                          color: subtitleColor, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        'Aucun élément spécifique pour cette région',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => CultureRegionBottomSheet.show(context),
                        child: const Text('Changer de région'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recommendations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final item = recommendations[index];
                  return AnimatedCulturalReveal(
                    delay: Duration(milliseconds: 200 + (index * 60)),
                    child: _buildRecommendationTile(
                      context,
                      item: item,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderCol: borderCol,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),
                  );
                },
              ),

            const SizedBox(height: 28),

            // Footer Logo Culture avec "iA" en jaune !
            const Center(
              child: Opacity(
                opacity: 0.5,
                child: AlterniaLogo(
                  size: 24,
                  showText: true,
                  iaColor: CultureTheme.iaYellow,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard({
    required BuildContext context,
    required PassportEntry entry,
    required bool isDark,
  }) {
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    // Couleur d'accent par type
    Color typeColor;
    String typeLabel;
    switch (entry.type) {
      case PassportItemType.conte:
        typeColor = CultureTheme.rougeKoulikoro;
        typeLabel = 'Conte';
        break;
      case PassportItemType.defi:
        typeColor = CultureTheme.vertNaturel;
        typeLabel = 'Défi';
        break;
      case PassportItemType.monument:
        typeColor = CultureTheme.accentOrange;
        typeLabel = 'Monument';
        break;
      case PassportItemType.personnage:
        typeColor = CultureTheme.primaryBlue;
        typeLabel = 'Figure';
        break;
      case PassportItemType.ville:
        typeColor = CultureTheme.cyanTurquoise;
        typeLabel = 'Ville';
        break;
      case PassportItemType.region:
        typeColor = CultureTheme.ocreTerre;
        typeLabel = 'Région';
        break;
    }

    // Temps relatif
    final diff = DateTime.now().difference(entry.discoveredAt);
    String timeAgo;
    if (diff.inDays > 0) {
      timeAgo = 'Il y a ${diff.inDays}j';
    } else if (diff.inHours > 0) {
      timeAgo = 'Il y a ${diff.inHours}h';
    } else {
      timeAgo = 'Récent';
    }

    return CulturalInteractiveCard(
      width: 224,
      backgroundColor: cardBg,
      borderColor: typeColor.withValues(alpha: 0.25),
      activeAccentColor: typeColor,
      borderRadius: 18,
      padding: EdgeInsets.zero,
      showSudaneseCorners: true,
      onTap: () {
        context.push(entry.targetRoute);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo avec overlay
          SizedBox(
            height: 68,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  entry.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: typeColor.withValues(alpha: 0.15),
                    child: Center(
                      child: Icon(entry.type.icon, color: typeColor, size: 24),
                    ),
                  ),
                ),
                Container(
                  color: Colors.black.withValues(alpha: 0.32),
                ),
                // Badge type en haut à gauche
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      typeLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                // Temps en haut à droite
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      timeAgo,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contenu texte
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: subtitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Reprendre',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: typeColor,
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
  }

  Widget _buildRecommendationTile(
    BuildContext context, {
    required CultureItem item,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    String route = '/culture/personnage/${item.id}';
    if (item.id.startsWith('monument')) {
      route = '/culture/monument/${item.id}';
    } else if (item.id.startsWith('ville')) {
      route = '/culture/ville/${item.id}';
    }

    return CulturalInteractiveCard(
      width: double.infinity,
      backgroundColor: cardBg,
      borderColor: borderCol,
      activeAccentColor: CultureTheme.accentOrange,
      borderRadius: 16,
      padding: const EdgeInsets.all(12),
      showSudaneseCorners: false,
      onTap: () {
        context.push(route);
      },
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.asset(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color:
                            CultureTheme.accentOrange.withValues(alpha: 0.12),
                        child: Icon(item.icon,
                            color: CultureTheme.accentOrange, size: 22),
                      ),
                    )
                  : Container(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                      child: Icon(item.icon,
                          color: CultureTheme.accentOrange, size: 22),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              CultureTheme.accentOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          item.tag.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '• ${item.regionName}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: subtitleColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: CultureTheme.accentOrange,
          ),
        ],
      ),
    );
  }
}

