import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_stage1_data.dart';
import '../../core/theme/culture_theme.dart';
import '../widgets/region_filter_pill.dart';

/// Vue 2 : Découvrir — Portail éditorial Culture
/// Joue le rôle de bibliothèque d'entrée vers Personnages, Villes & Monuments.
/// STRICTEMENT SANS DÉGRADÉS selon les règles d'architecture UX/UI
class CultureDecouvrirView extends ConsumerWidget {
  const CultureDecouvrirView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final surfaceAlt =
        isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt;

    // Élément featured pour "À découvrir aujourd'hui"
    final featured = MockCultureStage1Data.featuredItem;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. FILTRE RÉGIONAL TRANSVERSAL ──────────────────────────────────
          Row(
            children: [
              const RegionFilterPill(),
              const Spacer(),
              if (filterState.hasActiveFilter)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Contenu filtré',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 22),

          // ── 2. SECTION : À DÉCOUVRIR AUJOURD'HUI ────────────────────────────
          Text(
            'À découvrir aujourd\'hui',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Carte featured éditoriale
          _FeaturedEditorialCard(
            item: featured,
            isDark: isDark,
            cardBg: cardBg,
            borderCol: borderCol,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/culture/personnage/perso_soundiata');
            },
          ),

          const SizedBox(height: 28),

          // ── 3. SECTION : EXPLORER PAR THÈME ─────────────────────────────────
          Row(
            children: [
              Text(
                'Explorer par thème',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: CultureTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'MALI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: CultureTheme.primaryBlue,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Carte Personnages
          _ThemeEntryCard(
            icon: Icons.person_rounded,
            iconBg: CultureTheme.primaryBlue.withValues(alpha: 0.1),
            iconColor: CultureTheme.primaryBlue,
            accentColor: CultureTheme.primaryBlue,
            title: 'Grands Personnages',
            description:
                'Découvrez les héros et bâtisseurs qui ont façonné l\'histoire du Mali à travers les siècles.',
            count: MockCultureStage1Data.personnages.length,
            countLabel: 'personnages',
            isDark: isDark,
            cardBg: cardBg,
            borderCol: borderCol,
            surfaceAlt: surfaceAlt,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/culture/personnages');
            },
          ),

          const SizedBox(height: 12),

          // Carte Villes & Villages
          _ThemeEntryCard(
            icon: Icons.location_city_rounded,
            iconBg: CultureTheme.cyanTurquoise.withValues(alpha: 0.1),
            iconColor: CultureTheme.cyanTurquoise,
            accentColor: CultureTheme.cyanTurquoise,
            title: 'Villes & Villages',
            description:
                'Partez à la rencontre des cités millénaires, des terroirs et des récits des lieux du Mali.',
            count: MockCultureStage1Data.villes.length,
            countLabel: 'lieux',
            isDark: isDark,
            cardBg: cardBg,
            borderCol: borderCol,
            surfaceAlt: surfaceAlt,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/culture/villes');
            },
          ),

          const SizedBox(height: 12),

          // Carte Monuments
          _ThemeEntryCard(
            icon: Icons.museum_rounded,
            iconBg: CultureTheme.accentOrange.withValues(alpha: 0.1),
            iconColor: CultureTheme.accentOrange,
            accentColor: CultureTheme.accentOrange,
            title: 'Monuments Historiques',
            description:
                'Explorez les grandes œuvres architecturales et les sites classés du patrimoine malien.',
            count: MockCultureStage1Data.monuments.length,
            countLabel: 'monuments',
            isDark: isDark,
            cardBg: cardBg,
            borderCol: borderCol,
            surfaceAlt: surfaceAlt,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/culture/monuments');
            },
          ),

          const SizedBox(height: 24),

          // ── 4. NOTE DE BAS DE PAGE ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: subtitleColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Utilisez le filtre 📍 pour explorer par région du Mali.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: subtitleColor,
                      height: 1.4,
                    ),
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

// ── Carte Featured Éditoriale ──────────────────────────────────────────────
class _FeaturedEditorialCard extends StatelessWidget {
  const _FeaturedEditorialCard({
    required this.item,
    required this.isDark,
    required this.cardBg,
    required this.borderCol,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
  });

  final dynamic item;
  final bool isDark;
  final Color cardBg;
  final Color borderCol;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                CultureTheme.primaryBlue.withValues(alpha: isDark ? 0.3 : 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Vignette photographique authentique
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CultureTheme.primaryBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CultureTheme.primaryBlue.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: item.imageUrl != null && (item.imageUrl as String).isNotEmpty
                    ? Image.asset(
                        item.imageUrl as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: CultureTheme.primaryBlue.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.shield_rounded,
                            size: 28,
                            color: CultureTheme.primaryBlue,
                          ),
                        ),
                      )
                    : Container(
                        color: CultureTheme.primaryBlue.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 28,
                          color: CultureTheme.primaryBlue,
                        ),
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
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: CultureTheme.accentOrange
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.tag.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 10,
                            color: CultureTheme.accentOrange,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            item.regionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: CultureTheme.primaryBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: CultureTheme.accentOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Découvrir le personnage',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CultureTheme.accentOrange,
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
    );
  }
}

// ── Carte Thématique d'entrée ─────────────────────────────────────────────
class _ThemeEntryCard extends StatelessWidget {
  const _ThemeEntryCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.count,
    required this.countLabel,
    required this.isDark,
    required this.cardBg,
    required this.borderCol,
    required this.surfaceAlt,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color accentColor;
  final String title;
  final String description;
  final int count;
  final String countLabel;
  final bool isDark;
  final Color cardBg;
  final Color borderCol;
  final Color surfaceAlt;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône thématique large
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(icon, size: 26, color: iconColor),
            ),
            const SizedBox(width: 14),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count $countLabel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: subtitleColor,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
