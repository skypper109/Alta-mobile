import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/datasources/mock_culture_challenges_data.dart';
import '../../core/models/culture_challenge_models.dart';
import '../../core/theme/culture_theme.dart';

/// Modal des Quêtes & Missions Découverte du Patrimoine
class DiscoveryMissionsSheet extends StatelessWidget {
  const DiscoveryMissionsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DiscoveryMissionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final missions = MockCultureChallengesData.discoveryMissions;

    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: borderCol)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poignée
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: subtitleColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CultureTheme.cyanTurquoise.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: CultureTheme.cyanTurquoise,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missions Découverte',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      'Explorez le patrimoine pour débloquer vos récompenses',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: missions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, index) {
              final mission = missions[index];
              return _buildMissionItem(
                mission: mission,
                context: context,
                isDark: isDark,
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

  Widget _buildMissionItem({
    required DiscoveryMission mission,
    required BuildContext context,
    required bool isDark,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        context.push(mission.actionRoute);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mission.isCompleted
                ? Colors.green.withValues(alpha: 0.4)
                : borderCol,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: mission.isCompleted
                    ? Colors.green.withValues(alpha: 0.15)
                    : CultureTheme.cyanTurquoise.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                mission.isCompleted ? Icons.check_circle_rounded : mission.icon,
                color: mission.isCompleted ? Colors.green : CultureTheme.cyanTurquoise,
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
                        mission.category.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.cyanTurquoise,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${mission.xp} XP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mission.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mission.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: subtitleColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: CultureTheme.cyanTurquoise,
            ),
          ],
        ),
      ),
    );
  }
}
