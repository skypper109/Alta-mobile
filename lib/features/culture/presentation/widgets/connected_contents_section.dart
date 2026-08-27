import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';

/// Section de maillage culturel transversal (Monuments, Villes, Personnages liés)
class ConnectedContentsSection extends StatelessWidget {
  final List<ConnectedItemRef> items;
  final String title;

  const ConnectedContentsSection({
    super.key,
    required this.items,
    this.title = 'Contenus associés & Patrimoine lié',
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Titre de la section ──────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: titleColor,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Liste horizontale de cartes connectées ────────────────────────────
        SizedBox(
          height: 120,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final itemAccent = _getAccentForType(item.type);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(item.routePath);
                },
                child: Container(
                  width: 230,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: itemAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: itemAccent.withValues(alpha: 0.25),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: _buildItemVisual(item, itemAccent),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: itemAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.tag.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: itemAccent,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: CultureTheme.accentOrange,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              color: subtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemVisual(ConnectedItemRef item, Color itemAccent) {
    final imagePath = _resolveImagePath(item);
    if (imagePath != null) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(item.icon, size: 16, color: itemAccent),
      );
    }
    return Icon(item.icon, size: 16, color: itemAccent);
  }

  String? _resolveImagePath(ConnectedItemRef item) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return item.imageUrl;
    }
    final id = item.id.toLowerCase();
    if (id.contains('djenne') && id.contains('mosquee')) {
      return 'assets/images/culture/monuments/mosquee_djenne.jpg';
    }
    if (id.contains('tata')) return 'assets/images/culture/monuments/tata_sikasso.jpg';
    if (id.contains('askia') && id.contains('tombeau')) return 'assets/images/culture/monuments/tombeau_askia.jpg';
    if (id.contains('djingareyber')) return 'assets/images/culture/monuments/mosquee_djingareyber.jpg';
    if (id.contains('medine')) return 'assets/images/culture/monuments/fort_medine.jpg';
    if (id.contains('soundiata')) return 'assets/images/culture/personnages/soundiata.jpg';
    if (id.contains('mansa')) return 'assets/images/culture/personnages/mansa_moussa.jpg';
    if (id.contains('babemba')) return 'assets/images/culture/personnages/babemba_traore.jpg';
    if (id.contains('askia')) return 'assets/images/culture/personnages/askia_mohammed.jpg';
    if (id.contains('biton')) return 'assets/images/culture/personnages/biton_coulibaly.jpg';
    if (id.contains('djenne')) return 'assets/images/culture/villes/djenne_ville.jpg';
    if (id.contains('segou')) return 'assets/images/culture/villes/segou_koro.jpg';
    if (id.contains('bandiagara')) return 'assets/images/culture/villes/bandiagara_falaise.jpg';
    if (id.contains('tombouctou')) return 'assets/images/culture/villes/tombouctou_ville.jpg';
    if (id.contains('sikasso')) return 'assets/images/culture/villes/sikasso_ville.jpg';
    return null;
  }

  Color _getAccentForType(ConnectedItemType type) {
    switch (type) {
      case ConnectedItemType.personnage:
        return CultureTheme.primaryBlue;
      case ConnectedItemType.monument:
        return CultureTheme.accentOrange;
      case ConnectedItemType.ville:
        return CultureTheme.cyanTurquoise;
      case ConnectedItemType.region:
        return CultureTheme.orPatrimoine;
    }
  }
}
