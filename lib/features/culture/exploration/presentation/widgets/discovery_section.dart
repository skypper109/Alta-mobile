import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/cultural_discovery.dart';
import '../../data/models/mali_region.dart';
import 'discovery_secondary_card.dart';
import 'featured_discovery_card.dart';

/// Section éditoriale "À Découvrir" — composition premium façon magazine.
///
/// Layout :
///   Label "À DÉCOUVRIR"
///   Titre dynamique "Les trésors de [Région]"
///   [GRANDE CARTE FEATURED]
///   [CARTE] [CARTE]   (grille 2 colonnes)
///   [CARTE HORIZONTALE] (full width)
///   [CARTE] [CARTE]   (si plus de contenu)
///
/// États gérés : loading skeleton, empty, error, data.
class DiscoverySection extends StatelessWidget {
  final List<CulturalDiscovery> discoveries;
  final Color accentColor;
  final MaliRegion region;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;
  final void Function(CulturalDiscovery)? onDiscoveryTap;

  const DiscoverySection({
    super.key,
    required this.discoveries,
    required this.accentColor,
    required this.region,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
    this.onDiscoveryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── En-tête de section ─────────────────────────────────────────────
        _SectionHeader(accentColor: accentColor, region: region),

        const SizedBox(height: 20),

        // ── Corps de section ───────────────────────────────────────────────
        if (isLoading)
          _DiscoveryLoadingSkeleton(accentColor: accentColor)
        else if (hasError)
          _DiscoveryErrorState(accentColor: accentColor, onRetry: onRetry)
        else if (discoveries.isEmpty)
          _DiscoveryEmptyState(accentColor: accentColor)
        else
          _DiscoveryEditorialLayout(
            discoveries: discoveries,
            accentColor: accentColor,
            onDiscoveryTap: onDiscoveryTap,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// En-tête de section
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final Color accentColor;
  final MaliRegion region;

  const _SectionHeader({required this.accentColor, required this.region});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Petit label "À DÉCOUVRIR"
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'À DÉCOUVRIR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Titre dynamique
          Text(
            'Les trésors de ${region.nom}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 4),

          // Sous-titre descriptif
          Text(
            region.descriptionCourte,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
              height: 1.45,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout éditorial principal
// ─────────────────────────────────────────────────────────────────────────────

class _DiscoveryEditorialLayout extends StatelessWidget {
  final List<CulturalDiscovery> discoveries;
  final Color accentColor;
  final void Function(CulturalDiscovery)? onDiscoveryTap;

  const _DiscoveryEditorialLayout({
    required this.discoveries,
    required this.accentColor,
    this.onDiscoveryTap,
  });

  @override
  Widget build(BuildContext context) {
    // Séparation featured / secondaires
    final CulturalDiscovery? featured = discoveries.any((d) => d.isFeatured)
        ? discoveries.firstWhere((d) => d.isFeatured)
        : discoveries.isNotEmpty
            ? discoveries.first
            : null;

    final List<CulturalDiscovery> secondary = discoveries
        .where((d) => d != featured)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Grande carte featured ───────────────────────────────────────
        if (featured != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FeaturedDiscoveryCard(
              discovery: featured,
              accentColor: accentColor,
              onTap: () => onDiscoveryTap?.call(featured),
            ),
          ),

        if (featured != null && secondary.isNotEmpty)
          const SizedBox(height: 16),

        // ── 2. Grille éditoriale alternée des secondaires ─────────────────
        if (secondary.isNotEmpty)
          _EditorialGrid(
            secondary: secondary,
            accentColor: accentColor,
            onDiscoveryTap: onDiscoveryTap,
          ),

        const SizedBox(height: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grille éditoriale alternée
// ─────────────────────────────────────────────────────────────────────────────

class _EditorialGrid extends StatelessWidget {
  final List<CulturalDiscovery> secondary;
  final Color accentColor;
  final void Function(CulturalDiscovery)? onDiscoveryTap;

  const _EditorialGrid({
    required this.secondary,
    required this.accentColor,
    this.onDiscoveryTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = secondary;
    final widgets = <Widget>[];
    int i = 0;

    while (i < items.length) {
      final remaining = items.length - i;

      if (remaining == 1) {
        // Un seul restant → carte horizontale full width
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DiscoverySecondaryCard(
              discovery: items[i],
              accentColor: accentColor,
              isHorizontal: true,
              onTap: () => onDiscoveryTap?.call(items[i]),
            ),
          ),
        );
        i++;
      } else if (remaining >= 2) {
        // Par deux → rangée de deux cartes portrait côte-à-côte
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: DiscoverySecondaryCard(
                    discovery: items[i],
                    accentColor: accentColor,
                    onTap: () => onDiscoveryTap?.call(items[i]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DiscoverySecondaryCard(
                    discovery: items[i + 1],
                    accentColor: accentColor,
                    onTap: () => onDiscoveryTap?.call(items[i + 1]),
                  ),
                ),
              ],
            ),
          ),
        );
        i += 2;

        // Après chaque duo, intercaler une carte horizontale si dispo
        if (i < items.length) {
          widgets.add(const SizedBox(height: 12));
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DiscoverySecondaryCard(
                discovery: items[i],
                accentColor: accentColor,
                isHorizontal: true,
                onTap: () => onDiscoveryTap?.call(items[i]),
              ),
            ),
          );
          i++;
        }
      }

      if (i < items.length) {
        widgets.add(const SizedBox(height: 12));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// État Chargement — Skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _DiscoveryLoadingSkeleton extends StatefulWidget {
  final Color accentColor;
  const _DiscoveryLoadingSkeleton({required this.accentColor});

  @override
  State<_DiscoveryLoadingSkeleton> createState() =>
      _DiscoveryLoadingSkeletonState();
}

class _DiscoveryLoadingSkeletonState
    extends State<_DiscoveryLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? CultureTheme.darkSurface : const Color(0xFFE8E4DC);

    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, _) {
        final shimmedColor =
            baseColor.withValues(alpha: _shimmerAnim.value);
        return Column(
          children: [
            // Skeleton grande carte
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  color: shimmedColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Skeleton duo de petites cartes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: shimmedColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: shimmedColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// État Vide
// ─────────────────────────────────────────────────────────────────────────────

class _DiscoveryEmptyState extends StatelessWidget {
  final Color accentColor;
  const _DiscoveryEmptyState({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.explore_outlined,
              size: 48,
              color: accentColor.withValues(alpha: 0.50),
            ),
            const SizedBox(height: 14),
            Text(
              'De nouvelles découvertes arrivent bientôt.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// État Erreur
// ─────────────────────────────────────────────────────────────────────────────

class _DiscoveryErrorState extends StatelessWidget {
  final Color accentColor;
  final VoidCallback? onRetry;
  const _DiscoveryErrorState({required this.accentColor, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.70),
            ),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger les découvertes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry?.call();
              },
              icon: Icon(Icons.refresh_rounded, size: 16, color: accentColor),
              label: Text(
                'Réessayer',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
