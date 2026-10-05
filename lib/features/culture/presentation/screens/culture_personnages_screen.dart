import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_data_providers.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/models/culture_item.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';
import '../widgets/culture_audio_listen_badge.dart';
import '../widgets/region_filter_pill.dart';

/// Écran immersif — Grands Personnages Historiques du Mali
/// Design en portrait-card storytelling avec hiérarchie visuelle forte.
class CulturePersonnagesScreen extends ConsumerWidget {
  const CulturePersonnagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final bgColor = isDark ? CultureTheme.darkBackground : CultureTheme.lightBackground;

    final figuresAsync = ref.watch(cultureFiguresProvider);
    final allFigures = figuresAsync.valueOrNull ?? [];
    final items = allFigures
        .where((p) => p.matchesRegion(filterState.activeRegionId))
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  // Bouton retour
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (context.canPop()) context.pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? CultureTheme.darkSurface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? CultureTheme.darkBorder
                              : CultureTheme.lightBorder,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grands Personnages',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Figures historiques du Mali',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filtre régional
                  const RegionFilterPill(compact: true),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Séparateur
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
                height: 20,
              ),
            ),

            // ── CONTENU ───────────────────────────────────────────────────────
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState(ref, isDark, titleColor, subtitleColor,
                      filterState.displayName)
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (ctx, index) {
                        return AnimatedCulturalReveal(
                          key: ValueKey('perso_${items[index].id}'),
                          delay: Duration(milliseconds: 40 * (index % 8)),
                          child: _PersonnageCard(
                            item: items[index],
                            isDark: isDark,
                            titleColor: titleColor,
                            subtitleColor: subtitleColor,
                            index: index,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    WidgetRef ref,
    bool isDark,
    Color titleColor,
    Color subtitleColor,
    String regionName,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: 34,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aucun personnage\npour $regionName',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de changer la région ou explorez tout le Mali.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                ref.read(activeCultureRegionProvider.notifier).clearFilter();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Voir tout le Mali',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carte Personnage immersive ────────────────────────────────────────────
class _PersonnageCard extends StatelessWidget {
  const _PersonnageCard({
    required this.item,
    required this.isDark,
    required this.titleColor,
    required this.subtitleColor,
    required this.index,
  });

  final CultureItem item;
  final bool isDark;
  final Color titleColor;
  final Color subtitleColor;
  final int index;

  // Couleurs de la charte Alta-mobile (strictement sans vert/rouge/violet)
  static const List<Color> _accentColors = [
    CultureTheme.accentOrange,
    CultureTheme.primaryBlue,
    CultureTheme.cyanTurquoise,
  ];

  Color get _accent => _accentColors[index % _accentColors.length];

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final isSoundiata = item.id.contains('soundiata');
    final heroTag = 'personnage_list_${item.id}';
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    // Bordure premium avec accentuation or pour Soundiata
    final borderCol = isSoundiata
        ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.45 : 0.35)
        : (isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder);

    final speechNarrative =
        '${item.title}. ${item.subtitle}. Époque : ${item.info}. ${item.description}';

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/culture/personnage/${item.id}', extra: heroTag);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: borderCol,
            width: isSoundiata ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSoundiata
                  ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.16 : 0.08)
                  : Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
              blurRadius: isSoundiata ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── VITRINE CINÉMATIQUE DU PERSONNAGE (2D HERO SHOWCASE) ──────────
            SizedBox(
              height: 190,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Portrait d'art 2D plein format
                  if (hasImage)
                    Hero(
                      tag: heroTag,
                      child: Image.asset(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildInitialAvatar(),
                      ),
                    )
                  else
                    _buildInitialAvatar(),

                  // Scrim dégradé supérieur pour contraster les badges
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Scrim dégradé inférieur pour détacher le titre et les mérites
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 110,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                            Colors.black.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── BADGES HAUT : TAG & ÉPOQUE ──────────────────────────────
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Badge Rôle / Statut
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSoundiata
                                ? const Color(0xFFF59E0B)
                                : _accent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: (isSoundiata
                                        ? const Color(0xFFF59E0B)
                                        : _accent)
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSoundiata
                                    ? Icons.shield_rounded
                                    : item.icon,
                                size: 12,
                                color: isSoundiata ? Colors.black : Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isSoundiata
                                    ? 'LE LION DU MANDÉ'
                                    : item.tag.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: isSoundiata
                                      ? Colors.black
                                      : Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Badge Chronologie / Époque
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSoundiata
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                                  : Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: isSoundiata
                                    ? const Color(0xFFF59E0B)
                                    : Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.info,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: isSoundiata
                                      ? const Color(0xFFF59E0B)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── INFORMATIONS BAS DE PHOTO ──────────────────────────────
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.8),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSoundiata
                                      ? const Color(0xFFF59E0B)
                                      : _accent,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Badge Région compact
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 10,
                                color: CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                item.regionName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
            ),

            // ── CORPS ÉDITORIAL & ACTIONS ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: subtitleColor,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Pill spécifique pour Soundiata avec mention de l'épopée 2D
                  if (isSoundiata) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 13,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Motion 2D • Épopée de Kirina & Charte de 1236',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? const Color(0xFFFCD34D)
                                    : const Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ── PIED DE CARTE : ÉCOUTE AUDIO & BOUTON EXPLORER ──────────
                  Row(
                    children: [
                      // Badge d'écoute orale Griot
                      CultureAudioListenBadge(
                        contentId: item.id,
                        speechText: speechNarrative,
                        label: 'Écouter',
                        compact: true,
                        activeColor: isSoundiata
                            ? const Color(0xFFF59E0B)
                            : _accent,
                      ),

                      const Spacer(),

                      // Bouton d'action immersif
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8.5),
                        decoration: BoxDecoration(
                          color: isSoundiata
                              ? const Color(0xFFF59E0B)
                              : _accent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: (isSoundiata
                                      ? const Color(0xFFF59E0B)
                                      : _accent)
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isSoundiata ? 'Explorer l\'Épopée 2D' : 'Découvrir',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isSoundiata ? Colors.black : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              isSoundiata
                                  ? Icons.play_circle_fill_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 14,
                              color: isSoundiata ? Colors.black : Colors.white,
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
    );
  }

  Widget _buildInitialAvatar() {
    return Container(
      color: _accent,
      child: Center(
        child: Text(
          item.title.isNotEmpty ? item.title[0].toUpperCase() : '?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
