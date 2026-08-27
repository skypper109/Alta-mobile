import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/controllers/culture_filter_controller.dart';
import '../../core/datasources/mock_culture_challenges_data.dart';
import '../../core/models/culture_challenge_models.dart';
import '../../core/theme/culture_theme.dart';
import '../widgets/discovery_missions_sheet.dart';
import '../widgets/region_filter_pill.dart';

/// Vue 4 : Défis & Jeux Culturels du Mali
/// Véritable univers d'apprentissage ludique, moderne et engageant
class CultureDefisView extends ConsumerWidget {
  const CultureDefisView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(activeCultureRegionProvider);
    final activeRegion = filterState.activeRegion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final filteredRiddles = MockCultureChallengesData.getFilteredRiddles(
      regionId: activeRegion?.id,
    );

    const userProfile = ChallengeUserProfile();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. BARRE DE STATUT GAMIFICATION & FILTRE RÉGIONAL ───────────────
          Row(
            children: [
              const RegionFilterPill(),
              const Spacer(),
              // Badge Niveau / XP
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CultureTheme.cyanTurquoise.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: CultureTheme.cyanTurquoise.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: CultureTheme.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${userProfile.totalXp} XP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.cyanTurquoise,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── 2. DÉFI DU JOUR (HERO CHALLENGE CARD) ───────────────────────────
          _buildDailyChallengeCard(
            context: context,
            isDark: isDark,
            cardBg: cardBg,
            borderCol: borderCol,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
          ),

          const SizedBox(height: 24),

          // ── 3. SECTION « CONTINUER » ────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      size: 14,
                      color: CultureTheme.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CONTINUER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
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

          const SizedBox(height: 12),

          _buildContinueCard(
            context: context,
            isDark: isDark,
            cardBg: cardBg,
            borderCol: borderCol,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
          ),

          const SizedBox(height: 24),

          // ── 4. CATÉGORIES DE DÉFIS ──────────────────────────────────────────
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
                      Icons.category_rounded,
                      size: 13,
                      color: CultureTheme.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CATÉGORIES DE JEUX',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
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

          // Grille des 4 catégories
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 1. Devinettes traditionnelles
              _buildCategoryCard(
                context: context,
                title: 'Devinettes « N\'Da »',
                subtitle: 'Énigmes orales des aînés',
                icon: Icons.psychology_rounded,
                accentColor: CultureTheme.accentOrange,
                badgeText: 'Populaire',
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.push('/culture/defis/devinettes');
                },
              ),

              // 2. Quiz culturels
              _buildCategoryCard(
                context: context,
                title: 'Quiz Culturels',
                subtitle: 'Empires, Villes & Arts',
                icon: Icons.quiz_rounded,
                accentColor: CultureTheme.primaryBlue,
                badgeText: 'Chrono',
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.push('/culture/defis/quiz');
                },
              ),

              // 3. Défis express
              _buildCategoryCard(
                context: context,
                title: 'Défis Express',
                subtitle: '60 secondes chrono',
                icon: Icons.flash_on_rounded,
                accentColor: CultureTheme.rougeKoulikoro,
                badgeText: 'Rapide',
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.push('/culture/defis/quiz');
                },
              ),

              // 4. Missions découverte
              _buildCategoryCard(
                context: context,
                title: 'Missions Patrimoine',
                subtitle: 'Quêtes & Découvertes',
                icon: Icons.explore_rounded,
                accentColor: CultureTheme.cyanTurquoise,
                badgeText: 'Quêtes',
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                onTap: () {
                  HapticFeedback.lightImpact();
                  DiscoveryMissionsSheet.show(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 26),

          // ── 5. DÉCOUVERTE RAPIDE (« DEVINETTES EN VEDETTE ») ────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.cyanTurquoise.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: CultureTheme.cyanTurquoise,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activeRegion != null
                          ? 'DEVINETTES : ${activeRegion.nom.toUpperCase()}'
                          : 'DÉCOUVERTES RAPIDES',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: CultureTheme.cyanTurquoise,
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

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredRiddles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, index) {
              final riddle = filteredRiddles[index];
              return _buildRiddleRowCard(
                riddle: riddle,
                context: context,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
              );
            },
          ),
        ],
      ),
    );
  }

  // ── CARTE DÉFI DU JOUR (HERO) ──────────────────────────────────────────────
  Widget _buildDailyChallengeCard({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    const daily = MockCultureChallengesData.dailyChallenge;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? CultureTheme.darkSurface : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: 0.35),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'DÉFI DU JOUR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isDark ? CultureTheme.darkSurfaceAlt : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderCol),
                ),
                child: Text(
                  '+${daily.xpReward} XP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: CultureTheme.accentOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            daily.formulaIntro,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: CultureTheme.accentOrange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            daily.riddleText.split('\n').first,
            style: GoogleFonts.merriweather(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: titleColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: CultureTheme.accentOrange,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/culture/defis/devinettes');
              },
              icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 18),
              label: Text(
                'Lancer le défi du jour',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CARTE CONTINUER ────────────────────────────────────────────────────────
  Widget _buildContinueCard({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/culture/defis/devinettes');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: CultureTheme.accentOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'SÉRIE N\'DA • 3/6 ÉNIGMES',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.accentOrange,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Les Mystères des Éléments',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: const LinearProgressIndicator(
                      value: 0.5,
                      minHeight: 4,
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(CultureTheme.accentOrange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: CultureTheme.accentOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ── CARTE DE CATÉGORIE ─────────────────────────────────────────────────────
  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String badgeText,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
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
  }

  // ── LIGNE DE DEVINETTE RAPIDE ──────────────────────────────────────────────
  Widget _buildRiddleRowCard({
    required TraditionalRiddle riddle,
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/culture/defis/devinettes');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: CultureTheme.cyanTurquoise.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology_alt_rounded,
                color: CultureTheme.cyanTurquoise,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        riddle.category.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.cyanTurquoise,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        riddle.regionName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    riddle.riddleText.split('\n').first,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: CultureTheme.cyanTurquoise,
            ),
          ],
        ),
      ),
    );
  }
}
