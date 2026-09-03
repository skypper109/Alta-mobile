import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../features/device/device_notifier.dart';
import '../../features/device/device_page.dart';
import '../../features/discussions/subject_chat_provider.dart';
import '../../features/profile/gamification_notifier.dart';
import '../../features/profile/user_prefs_notifier.dart';
import '../../shared/widgets.dart';
import '../common/widgets/universe_splash_transition.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userPrefsProvider);
    final deviceState = ref.watch(deviceNotifierProvider);
    final gamification = ref.watch(gamificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isConnected = deviceState.isConnected;
    final deviceName = deviceState.connectedDevice?.name ?? 'AlterniA-Box-01';

    final rawName = userState.name.trim();
    final firstName = rawName.isNotEmpty ? rawName.split(' ').first : 'Élève';

    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 125), // Bottom padding prevents clipping under floating nav
        children: [
          // ── 1. GREETING BANNER ──────────────────────────────────────────
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Bonjour $firstName',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.waving_hand_rounded, color: AppColors.accent, size: 22),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.primary.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    userState.classShortLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── 3. QUICK STATS PILL ROW (CONNECTÉ AU BACKEND) ─────────────
            Row(
              children: [
                Expanded(
                  child: _TeenStatBadge(
                    label: 'Streak',
                    value: gamification.streak,
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TeenStatBadge(
                    label: 'XP',
                    value: gamification.xp,
                    icon: Icons.stars_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TeenStatBadge(
                    label: 'Séances',
                    value: gamification.seances,
                    icon: Icons.school_rounded,
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── 4. HERO BANNER BOÎTIER ALTERNIA ─────────────────────────────
            GestureDetector(
              onTap: () => showDeviceModalSheet(context),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isConnected ? Icons.router_rounded : Icons.wifi_tethering_rounded,
                        size: 26,
                        color: isConnected ? AppColors.secondary : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected ? 'Boîtier AlterniA Connecté' : 'Boîtier AlterniA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isConnected ? 'Wi-Fi local • $deviceName' : 'Appairer ou utiliser le Cloud IA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isConnected ? AppColors.secondary : AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isConnected ? 'EN LIGNE' : 'HORS-LIGNE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── 5. VOS MATIÈRES (CARDS DE SUGGESTIONS GRID FOR TEENS) ────────
            DetSectionHeader(
              title: 'Matières du Programme (${userState.classShortLabel})',
            ),
            const SizedBox(height: 14),

            ...() {
              final subjects = userState.subjects;
              if (subjects.isEmpty) {
                return [
                  const DetEmptyState(
                    icon: Icons.menu_book_rounded,
                    title: 'Aucune matière disponible',
                    subtitle: 'Sélectionnez votre classe dans le profil.',
                  )
                ];
              }

              final colors = [
                AppColors.primary,
                AppColors.accent,
                AppColors.secondary,
                AppColors.accentViolet,
                AppColors.success,
              ];

              final icons = [
                Icons.calculate_rounded,
                Icons.science_rounded,
                Icons.biotech_rounded,
                Icons.auto_stories_rounded,
                Icons.history_edu_rounded,
                Icons.language_rounded,
                Icons.balance_rounded,
              ];

              return [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (context, i) {
                    final subject = subjects[i];
                    final color = colors[i % colors.length];
                    final icon = icons[i % icons.length];
                    final progress = gamification.getProgressForSubject(subject);

                    return CustomCard(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref.read(activeSubjectProvider.notifier).state = subject;
                        context.go('/discussions');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, size: 22, color: color),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${(progress * 100).toInt()}%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 5,
                                  backgroundColor: isDark ? AppColors.surfaceAlt : const Color(0xFFE2E8F0),
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ];
            }(),

            const SizedBox(height: 24),

            // ── 6. SUGGESTIONS IA VISUELLES ─────────────────────────────────
            DetSectionHeader(
              title: 'Suggestions IA Révision',
              actionLabel: 'Discuter',
              onAction: () => context.go('/discussions'),
            ),
            const SizedBox(height: 14),

            Builder(builder: (context) {
              final subjects = userState.subjects;
              final s1 = subjects.isNotEmpty ? subjects[0] : 'Mathématiques';
              final s2 = subjects.length > 1 ? subjects[1] : 'Histoire-Géo';

              return Row(
                children: [
                  Expanded(
                    child: _TeenSuggestionCard(
                      title: 'Réviser $s1',
                      subtitle: 'Carte interactive • 15 min',
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                      onTap: () => context.go('/discussions'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TeenSuggestionCard(
                      title: 'Quiz $s2',
                      subtitle: 'Défi Tuteur • 20 min',
                      icon: Icons.quiz_rounded,
                      color: AppColors.accent,
                      onTap: () => context.go('/discussions'),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),

            // ── 7. PATRIMOINE & CULTURE DU MALI ────────────────────────────
            DetSectionHeader(
              title: 'Patrimoine & Culture Malienne',
              actionLabel: 'Explorer',
              onAction: () => UniverseSplashTransition.toCulture(
                context,
                onComplete: () => context.go('/culture'),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _TeenSuggestionCard(
                    title: 'Monuments & Histoire',
                    subtitle: 'Djenné, Tombouctou & Rois',
                    icon: Icons.account_balance_rounded,
                    color: const Color(0xFFE0823D),
                    onTap: () => UniverseSplashTransition.toCulture(
                      context,
                      onComplete: () => context.push('/culture/monuments'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TeenSuggestionCard(
                    title: 'Contes & Devinettes',
                    subtitle: 'Traditions des Griots',
                    icon: Icons.auto_stories_rounded,
                    color: const Color(0xFF2E7D32),
                    onTap: () => UniverseSplashTransition.toCulture(
                      context,
                      onComplete: () => context.push('/culture/contes'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Footer Logo
            const Center(
              child: Opacity(
                opacity: 0.5,
                child: AlterniaLogo(size: 24, showText: true),
              ),
            ),
          ],
        ),
    );
  }
}

// ── Teen Stat Badge Widget ──────────────────────────────────────────────────
class _TeenStatBadge extends StatelessWidget {
  const _TeenStatBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final labelColor = isDark ? AppColors.textMuted : const Color(0xFF475569);

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
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

// ── Teen Suggestion Card Widget ─────────────────────────────────────────────
class _TeenSuggestionCard extends StatelessWidget {
  const _TeenSuggestionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textMuted : const Color(0xFF475569),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
