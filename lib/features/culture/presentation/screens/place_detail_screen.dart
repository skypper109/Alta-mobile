import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/datasources/mock_culture_details_data.dart';
import '../../core/models/cultural_guide_models.dart';
import '../../core/models/culture_detail_models.dart';
import '../../core/models/culture_passport_models.dart';
import '../../core/theme/culture_theme.dart';
import '../widgets/ask_cultural_guide_button.dart';
import '../widgets/authentic_photo_hero.dart';
import '../widgets/connected_contents_section.dart';
import '../widgets/passport_stamp_toast.dart';

/// Fiche de consultation immersive d'une Ville ou Village du Mali
class PlaceDetailScreen extends ConsumerWidget {
  final String id;
  final PlaceDetail? place;

  const PlaceDetailScreen({
    super.key,
    required this.id,
    this.place,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = place ?? MockCultureDetailsData.getPlaceById(id);
    final activeRegion = ref.watch(activeCultureRegionProvider).activeRegion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Enregistrement automatique au Passeport Culturel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final added = ref.read(culturePassportProvider.notifier).recordDiscovery(
            id: item.id,
            type: PassportItemType.ville,
            title: item.name,
            subtitle: item.subtitle,
            regionId: item.regionId,
            regionName: item.regionName,
            photoUrl: item.photoUrl,
            tag: item.tag,
            culturalQuote: '« Cité vivante aux racines ancestrales du fleuve. »',
            targetRoute: '/culture/ville/${item.id}',
          );
      if (added && context.mounted) {
        PassportStampToast.show(
          context,
          title: item.name,
          type: PassportItemType.ville,
        );
      }
    });

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
          // ── 1. GRANDE PHOTOGRAPHIE AUTHENTIQUE DU LIEU (HERO) ──────────────
          SliverToBoxAdapter(
            child: AuthenticPhotoHero(
              photoUrl: item.photoUrl,
              photoCredits: item.photoCredits,
              tag: item.tag,
              regionName: item.regionName,
              subtitleInfo: item.fondation,
              accentColor: CultureTheme.cyanTurquoise,
            ),
          ),

          // ── 2. CORPS ÉDITORIAL & DÉCOUVERTE DU TERROIR ────────────────────
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

                // Nom du Lieu
                Text(
                  item.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                    letterSpacing: -0.6,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: CultureTheme.cyanTurquoise,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 16),

                // Résumé du Lieu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol),
                  ),
                  child: Text(
                    item.resume,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: subtitleColor,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Guide Culturel IA Contextuel
                AskCulturalGuideButton(
                  contextData: CulturalGuideContext(
                    contentType: CulturalContentType.ville,
                    contentId: item.id,
                    contentTitle: item.name,
                    subtitle: item.subtitle,
                    regionId: item.regionId,
                    regionName: item.regionName,
                    photoUrl: item.photoUrl,
                  ),
                ),

                const SizedBox(height: 22),

                // ── IDENTITÉ CULTURELLE ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: CultureTheme.cyanTurquoise.withValues(alpha: isDark ? 0.12 : 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CultureTheme.cyanTurquoise.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.palette_rounded,
                            size: 18,
                            color: CultureTheme.cyanTurquoise,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Identité Culturelle & Art de Vivre',
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
                        item.identiteCulturelle,
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

                // ── FAITS CLÉS DU LIEU ────────────────────────────────────────
                Text(
                  'Repères & Clés du Terroir',
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
                              Icon(fact.icon, size: 14, color: CultureTheme.cyanTurquoise),
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

                // ── TRADITIONS ET PATRIMOINE ──────────────────────────────────
                Text(
                  'Traditions & Patrimoine Vivant',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.traditionsAndPatrimoine,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: subtitleColor,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // ── RÉCIT HISTORIQUE DU TERROIR ───────────────────────────────
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
                  title: 'Monuments & Figures du Lieu',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
