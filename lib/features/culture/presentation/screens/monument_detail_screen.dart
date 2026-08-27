import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_details_data.dart';
import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';
import '../widgets/authentic_photo_hero.dart';
import '../widgets/connected_contents_section.dart';

/// Fiche de consultation immersive d'un Monument Historique
class MonumentDetailScreen extends ConsumerWidget {
  final String id;
  final MonumentDetail? monument;

  const MonumentDetailScreen({
    super.key,
    required this.id,
    this.monument,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = monument ?? MockCultureDetailsData.getMonumentById(id);
    final activeRegion = ref.watch(activeCultureRegionProvider).activeRegion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final surfaceAlt = isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt;

    return Scaffold(
      backgroundColor: isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. GRANDE PHOTOGRAPHIE DU MONUMENT (HERO) ──────────────────────
          SliverToBoxAdapter(
            child: AuthenticPhotoHero(
              photoUrl: item.photoUrl,
              photoCredits: item.photoCredits,
              tag: item.tag,
              regionName: item.regionName,
              subtitleInfo: item.era,
              accentColor: CultureTheme.accentOrange,
            ),
          ),

          // ── 2. CORPS ÉDITORIAL & DÉCOUVERTE DU PATRIMOINE ──────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Contexte régional transversal discret
                if (activeRegion != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: CultureTheme.accentOrange),
                      const SizedBox(width: 4),
                      Text(
                        'Région active : ${activeRegion.nom}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Nom du Monument
                Text(
                  item.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: CultureTheme.accentOrange,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Localisation précise
                Row(
                  children: [
                    const Icon(
                      Icons.pin_drop_rounded,
                      size: 14,
                      color: CultureTheme.accentOrange,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.locationDetails,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Présentation générale
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol),
                  ),
                  child: Text(
                    item.presentation,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: subtitleColor,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── POURQUOI CE MONUMENT EST IMPORTANT ────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.12 : 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: CultureTheme.accentOrange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pourquoi ce monument est important',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.whyItMatters,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── FAITS CLÉS ARCHITECTURAUX ─────────────────────────────────
                Text(
                  'Repères & Fiche Technique',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: item.keyFacts.map((fact) {
                    return Container(
                      width: (MediaQuery.of(context).size.width - 50) / 2,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderCol),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(fact.icon, size: 14, color: CultureTheme.accentOrange),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  fact.label.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: subtitleColor,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fact.value,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ── ARCHITECTURE ET MATÉRIAUX ─────────────────────────────────
                Text(
                  'Architecture & Matériaux',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.architectureAndMaterials,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: subtitleColor,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // ── RÉCIT HISTORIQUE & CHAPITRES ──────────────────────────────
                ...item.chapters.map((chapter) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chapter.content,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: subtitleColor,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // ── CONTENUS ASSOCIÉS & MAILLAGE CULTUREL ─────────────────────
                ConnectedContentsSection(
                  items: item.connectedItems,
                  title: 'Figures & Villes Liées',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
