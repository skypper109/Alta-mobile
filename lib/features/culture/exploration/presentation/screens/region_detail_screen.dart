import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/heritage_item.dart';
import '../../data/models/mali_region.dart';
import '../controllers/region_detail_controller.dart';
import '../widgets/continue_journey_section.dart';
import '../widgets/contribution_banner.dart';
import '../widgets/cultural_ai_card.dart';
import '../widgets/discovery_section.dart';
import '../widgets/heritage_section.dart';
import '../widgets/region_hero.dart';
import '../widgets/regional_challenge_card.dart';
import '../widgets/testimony_section.dart';

/// Écran maître d'immersion régionale (RegionDetailScreen)
class RegionDetailScreen extends ConsumerWidget {
  final MaliRegion region;

  const RegionDetailScreen({
    super.key,
    required this.region,
  });

  void _showFeedbackSnackBar(BuildContext context, String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: CultureTheme.orPatrimoine, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: CultureTheme.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: CultureTheme.ocreTerre, width: 1),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showChallengeModal(BuildContext context, String challengeTitre, int xp) {
    HapticFeedback.heavyImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? CultureTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? CultureTheme.darkBorder : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CultureTheme.orPatrimoine.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 40,
                  color: CultureTheme.orPatrimoine,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                challengeTitre,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accomplissez ce défi pour débloquer +$xp XP sur votre Passeport Culturel Alternia.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showFeedbackSnackBar(
                      context,
                      'Défi activé ! Système complet disponible aux étapes suivantes.',
                      Icons.check_circle_rounded,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CultureTheme.orPatrimoine,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Commencer le défi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContributionModal(BuildContext context, String regionNom) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? CultureTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? CultureTheme.darkBorder : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CultureTheme.ocreTerre.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.history_edu_rounded,
                      color: CultureTheme.ocreTerre,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Contribuer à la mémoire de $regionNom',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Partagez un proverbe, un chant ou une anecdote familiale liée à $regionNom.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showFeedbackSnackBar(
                      context,
                      'Merci ! Le module de contribution sera actif à l\'Étape Contributions.',
                      Icons.volunteer_activism_rounded,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CultureTheme.ocreTerre,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Envoyer une contribution',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(regionDetailProvider(region.id));
    final notifier = ref.read(regionDetailProvider(region.id).notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = region.couleurAccent;

    return Scaffold(
      backgroundColor: isDark
          ? CultureTheme.darkBackground
          : CultureTheme.lightBackground,
      body: state.detailAsync.when(
        loading: () => _buildLoadingState(isDark, accent),
        error: (err, _) => _buildErrorState(context, isDark, err.toString()),
        data: (detail) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Hero Immersif ─────────────────────────────────────────
                RegionHero(
                  region: region,
                  accroche: detail.accrocheEditoriale,
                  isBookmarked: state.isBookmarked,
                  onBack: () => Navigator.of(context).pop(),
                  onToggleBookmark: () {
                    notifier.toggleBookmark();
                    _showFeedbackSnackBar(
                      context,
                      state.isBookmarked
                          ? 'Retiré des favoris'
                          : 'Ajouté aux favoris de voyage',
                      state.isBookmarked
                          ? Icons.bookmark_remove_rounded
                          : Icons.bookmark_added_rounded,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── 2. Section À Découvrir ───────────────────────────────────
                DiscoverySection(
                  discoveries: detail.discoveries,
                  accentColor: accent,
                  region: region,
                  onDiscoveryTap: (discovery) {
                    // Navigation vers l'écran de détail (disponible aux étapes suivantes)
                    _showFeedbackSnackBar(
                      context,
                      '${discovery.titre} — Fiche complète disponible à l\'étape suivante !',
                      discovery.icone,
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── 3. Section Histoires & Mémoire Vivante ───────────────────
                TestimonySection(
                  testimonies: detail.testimonies,
                  accentColor: accent,
                  currentlyPlayingId: state.currentlyPlayingTestimonyId,
                  isAudioPlaying: state.isAudioPlaying,
                  onToggleAudio: (id) => notifier.toggleAudio(id),
                ),

                const SizedBox(height: 32),

                // ── 4. Section Patrimoine à Découvrir ────────────────────────
                HeritageSection(
                  heritages: detail.heritages,
                  accentColor: accent,
                  onExploreHeritage: (HeritageItem item) {
                    _showFeedbackSnackBar(
                      context,
                      'Patrimoine « ${item.nom} » — Fiche complète disponible à l\'étape Patrimoine !',
                      Icons.account_balance_rounded,
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── 5. Section Défi Gamifié ──────────────────────────────────
                RegionalChallengeCard(
                  challenge: detail.challenge,
                  accentColor: accent,
                  onStartChallenge: () => _showChallengeModal(
                    context,
                    detail.challenge.titre,
                    detail.challenge.xpPoints,
                  ),
                ),

                const SizedBox(height: 28),

                // ── 6. Section Contribution ──────────────────────────────────
                ContributionBanner(
                  regionNom: region.nom,
                  accentColor: accent,
                  onContribute: () => _showContributionModal(
                    context,
                    region.nom,
                  ),
                ),

                const SizedBox(height: 28),

                // ── 7. Guide IA Contextuel ───────────────────────────────────
                CulturalAiCard(
                  regionId: region.id,
                  regionNom: region.nom,
                  onAskAi: () {
                    _showFeedbackSnackBar(
                      context,
                      'Connexion à l\'IA Culturelle pour ${region.nom} — Prochaine étape !',
                      Icons.auto_awesome_rounded,
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── 8. Continuez votre voyage (Régions voisines) ─────────────
                ContinueJourneySection(
                  neighborRegionIds: detail.neighborRegionIds,
                  onSelectNeighbor: (MaliRegion neighbor) {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => RegionDetailScreen(
                          region: neighbor,
                        ),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark, Color accent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: accent),
          const SizedBox(height: 16),
          Text(
            'Immersion dans la région ${region.nom}...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: CultureTheme.rougeKoulikoro,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retour à la carte'),
            ),
          ],
        ),
      ),
    );
  }
}
