import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/datasources/mock_culture_stage1_data.dart';
import '../../core/models/culture_item.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';
import '../widgets/culture_region_bottom_sheet.dart';

/// Vue 1 : Accueil Culture
/// STRICTEMENT SANS DÉGRADÉS selon les règles d'architecture UX/UI
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
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final featured = MockCultureStage1Data.featuredItem;
    final recommendations = [
      ...MockCultureStage1Data.personnages,
      ...MockCultureStage1Data.monuments,
      ...MockCultureStage1Data.villes,
    ].where((item) => item.matchesRegion(activeRegion?.id)).take(4).toList();

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
            // ── ACCUEIL DU VIEUX SAGE DU MANDEN (LE GRIOT) ────────────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 60),
              child: _buildGriotWelcomeSection(context, ref, isDark),
            ),
            const SizedBox(height: 20),

            // ── 1. SECTION « À LA UNE » ─────────────────────────────────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 120),
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

            const SizedBox(height: 12),

            // Grande carte À la une interactive avec ornementation soudanaise
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
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bandeau visuel photographique réel
                SizedBox(
                  height: 145,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (featured.imageUrl != null && featured.imageUrl!.isNotEmpty)
                        Image.asset(
                          featured.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: CultureTheme.primaryDark,
                            child: const Center(
                              child: Icon(Icons.shield_rounded, size: 40, color: Colors.white54),
                            ),
                          ),
                        )
                      else
                        Container(color: CultureTheme.primaryDark),

                      // Overlay sombre uni pour contraste texte (strictement sans dégradé)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.accentOrange,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    featured.tag.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
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
                                          fontSize: 11,
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
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(color: Colors.black, blurRadius: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Corps éditorial
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        featured.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        featured.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        featured.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: subtitleColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              context.push('/culture/personnage/perso_soundiata');
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Découvrir Soundiata Keïta',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: CultureTheme.accentOrange,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: CultureTheme.accentOrange,
                                ),
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

          const SizedBox(height: 24),

          // ── 3. REPRENDRE — ACTIVITÉ RÉCENTE PERSONNALISÉE ────────────────
          Builder(
            builder: (context) {
              final passport = ref.watch(culturePassportProvider);
              // Récupérer les dernières activités par type
              final recentItems = <PassportEntry>[];
              // Dernier conte
              if (passport.contes.isNotEmpty) recentItems.add(passport.contes.first);
              // Dernier défi
              if (passport.defis.isNotEmpty) recentItems.add(passport.defis.first);
              // Dernier monument
              if (passport.monuments.isNotEmpty) recentItems.add(passport.monuments.first);
              // Dernière figure
              if (passport.figures.isNotEmpty) recentItems.add(passport.figures.first);

              if (recentItems.isEmpty) return const SizedBox.shrink();

              // Trier par date la plus récente
              recentItems.sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
              final displayItems = recentItems.take(3).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    Icon(Icons.location_off_rounded, color: subtitleColor, size: 28),
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
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

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
                    Container(
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
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${item.regionName}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
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

  // ── ACCUEIL DU VIEUX SAGE / GRIOT DU MANDEN ────────────────────────────────
  Widget _buildGriotWelcomeSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    final narrationState = ref.watch(narrationCoordinatorProvider);

    const welcomeSpeech =
        "I ni sogoma voyageur ! Je suis le Griot-Bot d'AlternIA. Quel conte veux-tu écouter, ou qu'aimerais-tu découvrir aujourd'hui ?";

    return CulturalInteractiveCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      showSudaneseCorners: true,
      activeAccentColor: CultureTheme.accentOrange,
      backgroundColor: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LIGNE 1 : TÊTE DE ROBOT 2D SAGE + BULLE DE DIALOGUE ────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Médaillon animé de la tête de Robot 2D
              Stack(
                alignment: Alignment.center,
                children: [
                  // Halo d'aura technologique cyan uni (flat)
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CultureTheme.cyanTurquoise.withValues(
                        alpha: narrationState.isSpeaking ? 0.32 : 0.15,
                      ),
                    ),
                  ),

                  // Tête de robot 2D sage
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF090E18),
                      border: Border.all(
                        color: narrationState.isSpeaking
                            ? CultureTheme.cyanTurquoise
                            : CultureTheme.accentOrange,
                        width: narrationState.isSpeaking ? 2.6 : 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/culture/robot_sage.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.smart_toy_rounded,
                          color: CultureTheme.cyanTurquoise,
                          size: 34,
                        ),
                      ),
                    ),
                  ),

                  // Badge audio actif avec barres d'onde
                  if (narrationState.isSpeaking)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: CultureTheme.cyanTurquoise,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          size: 12,
                          color: Color(0xFF090E18),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              // Bulle de dialogue et question du Robot Sage
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: CultureTheme.cyanTurquoise
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: CultureTheme.cyanTurquoise
                                  .withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.smart_toy_rounded,
                                size: 12,
                                color: CultureTheme.cyanTurquoise,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'GRIOT-BOT • GUIDE IA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: CultureTheme.cyanTurquoise,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bouton d'écoute audio TTS de la parole du vieux
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(narrationCoordinatorProvider.notifier)
                                .toggle(welcomeSpeech);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: (narrationState.isSpeaking
                                      ? CultureTheme.accentOrange
                                      : CultureTheme.primaryBlue)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: (narrationState.isSpeaking
                                        ? CultureTheme.accentOrange
                                        : CultureTheme.primaryBlue)
                                    .withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              narrationState.isSpeaking
                                  ? Icons.volume_up_rounded
                                  : Icons.play_arrow_rounded,
                              size: 16,
                              color: narrationState.isSpeaking
                                  ? CultureTheme.accentOrange
                                  : CultureTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Texte de la question
                    Text(
                      '« I ni sogoma voyageur ! Quel conte veux-tu écouter, ou qu\'aimerais-tu découvrir aujourd\'hui ? »',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Ligne séparatrice subtile
          Container(
            height: 1,
            color: borderCol,
          ),

          const SizedBox(height: 12),

          // ── LIGNE 2 : CHOIX RAPIDES GUIDÉS PAR LE VIEUX SAGE ───────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildGriotChoiceChip(
                context: context,
                label: 'Écouter un conte',
                icon: Icons.auto_stories_rounded,
                accentColor: CultureTheme.rougeKoulikoro,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onNavigateToTab(2); // Onglet Jeux & Contes
                },
              ),
              _buildGriotChoiceChip(
                context: context,
                label: 'Héros & Figures',
                icon: Icons.shield_rounded,
                accentColor: CultureTheme.primaryBlue,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.push('/culture/personnage/perso_soundiata');
                },
              ),
              _buildGriotChoiceChip(
                context: context,
                label: 'Monuments sacrés',
                icon: Icons.account_balance_rounded,
                accentColor: CultureTheme.accentOrange,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onNavigateToTab(1); // Onglet Découverte
                },
              ),
              _buildGriotChoiceChip(
                context: context,
                label: 'Mon Passeport',
                icon: Icons.timeline_rounded,
                accentColor: CultureTheme.cyanTurquoise,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onNavigateToTab(3); // Onglet Passeport
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Puce d'action rapide sous la question du vieux sage
  Widget _buildGriotChoiceChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: isDark ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 9,
              color: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

