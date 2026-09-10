import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';
import '../widgets/culture_audio_listen_badge.dart';

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
    final passport = ref.watch(culturePassportProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return CulturalAtmosphereCanvas(
      enableParticles: true,
      enableBogolanMotifs: true,
      motifOpacity: 0.10,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. HERO BANNER CINÉMATIQUE ────────────────────────────────────
            CulturalHeroBanner(
              totalXp: passport.totalXp,
              rankLevel: passport.rankLevel,
              onPassportTap: () => context.push('/culture/passport'),
            ),

            const SizedBox(height: 14),

            // ── 2. BANDE « EN VEDETTE » DYNAMIQUE ─────────────────────────────
            if (passport.featuredDiscoveryOfTheDay != null) ...[
              AnimatedCulturalReveal(
                delay: const Duration(milliseconds: 100),
                child: _buildFeaturedDiscoveryBanner(
                  context: context,
                  featured: passport.featuredDiscoveryOfTheDay!,
                  isDark: isDark,
                  borderCol: borderCol,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── 3. LE MÉDAILLON SACRÉ DU JOUR ────────────────────────────────
            const AnimatedCulturalReveal(
              delay: Duration(milliseconds: 180),
              child: CulturalMysteryVaultWidget(),
            ),

            const SizedBox(height: 24),

            // ── 4. TRÉSORS DÉCOUVERTS (CARROUSEL HORIZONTAL) ───────────────────
            AnimatedCulturalReveal(
              delay: const Duration(milliseconds: 260),
              child: _buildTreasuresCarousel(
                context: context,
                passport: passport,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BANDE « EN VEDETTE » DYNAMIQUE ──────────────────────────────────────────
  Widget _buildFeaturedDiscoveryBanner({
    required BuildContext context,
    required PassportEntry featured,
    required bool isDark,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final targetRoute = (featured.targetRoute.isNotEmpty &&
            !featured.targetRoute.contains('passport'))
        ? featured.targetRoute
        : '/culture/personnage/perso_soundiata';

    return GestureDetector(
      onTap: () {
        CulturalHaptics.cardPress();
        context.push(targetRoute,
            extra: 'home_featured_${featured.id}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? CultureTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol, width: 1.0),
        ),
        child: Row(
          children: [
            // Badge tag « EN VEDETTE »
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      size: 12, color: CultureTheme.accentOrange),
                  const SizedBox(width: 4),
                  Text(
                    'EN VEDETTE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Titre & Info région / tag
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    featured.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${featured.regionName.isNotEmpty ? '${featured.regionName} • ' : ''}${featured.tag}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CultureAudioListenBadge(
              contentId: '${featured.id}_featured_voice',
              speechText: featured.culturalQuote ??
                  '${featured.title}. ${featured.subtitle}',
              label: 'Griot',
              compact: true,
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: subtitleColor),
          ],
        ),
      ),
    );
  }

  // ── SECTION « TRÉSORS DÉCOUVERTS » (CARROUSEL HORIZONTAL) ───────────────────
  Widget _buildTreasuresCarousel({
    required BuildContext context,
    required PassportState passport,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final sortedEntries = List<PassportEntry>.from(passport.entries)
      ..sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
    final displayItems = sortedEntries.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête : Titre, Compteur de trésors & Bouton "Voir tout" vers le Passeport
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: CultureTheme.accentOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'TRÉSORS DÉCOUVERTS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? CultureTheme.darkSurfaceAlt
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CulturalRollingXpCounter(
                targetXp: passport.entries.length,
                duration: const Duration(milliseconds: 800),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: CultureTheme.primaryBlue,
                ),
              ),
            ),
            const Spacer(),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                CulturalHaptics.tabSwitch();
                onNavigateToTab(3); // Bascule vers l'onglet Passeport
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Voir tout',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: CultureTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: CultureTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Contenu du carrousel ou état vide invitant à l'exploration
        if (displayItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol, width: 1.0),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.explore_outlined,
                      color: CultureTheme.accentOrange,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Passeport prêt pour l\'exploration',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Débloquez vos trésors en explorant le Mali.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateToTab(1),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Explorer',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: CultureTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 136,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: displayItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, index) {
                final entry = displayItems[index];
                final typeColor = _getItemTypeColor(entry.type);

                return AnimatedCulturalReveal(
                  key: ValueKey('treasure_${entry.id}'),
                  delay: Duration(milliseconds: index * 45),
                  offset: const Offset(0.04, 0.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      CulturalHaptics.cardPress();
                      context.push(entry.targetRoute);
                    },
                    child: Container(
                    width: 216,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ligne supérieure : Type pill & Badge XP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(entry.type.icon,
                                      size: 10, color: typeColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    entry.type.label,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: typeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+${entry.xpEarned} XP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: CultureTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Ligne principale : Vignette + Titre & Région
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                entry.photoUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 48,
                                  height: 48,
                                  color: typeColor.withValues(alpha: 0.15),
                                  child: Icon(
                                    entry.type.icon,
                                    color: typeColor,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    entry.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: titleColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.regionName.isNotEmpty
                                        ? entry.regionName
                                        : entry.subtitle,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
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
                      ],
                    ),
                  ),
                ),
              );
            },
            ),
          ),
      ],
    );
  }

  Color _getItemTypeColor(PassportItemType type) {
    switch (type) {
      case PassportItemType.personnage:
        return CultureTheme.accentOrange;
      case PassportItemType.monument:
        return CultureTheme.primaryBlue;
      case PassportItemType.ville:
      case PassportItemType.region:
        return CultureTheme.cyanTurquoise;
      case PassportItemType.conte:
        return CultureTheme.cyanTurquoise;
      case PassportItemType.defi:
        return CultureTheme.accentOrange;
    }
  }
}
