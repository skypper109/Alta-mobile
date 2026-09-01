import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/malian_school_system.dart';
import '../../features/profile/user_prefs_notifier.dart';
import '../../shared/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showClassSelectorDialog(BuildContext context, WidgetRef ref, String currentClassId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textPri = isDark ? Colors.white : const Color(0xFF0F172A);

        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sélectionnez votre classe (Mali)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'AlterniA adaptera ses explications et questions au programme officiel malien.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: malianClasses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final c = malianClasses[idx];
                    final isSelected = c.id == currentClassId;

                    return GestureDetector(
                      onTap: () {
                        ref.read(userPrefsProvider.notifier).updateClass(c.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Programme mis à jour : ${c.label}'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.border : const Color(0xFFE2E8F0)),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.school_rounded,
                                size: 16,
                                color: isSelected ? Colors.white : (isDark ? AppColors.textMuted : const Color(0xFF64748B)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.label,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primary : textPri,
                                    ),
                                  ),
                                  Text(
                                    '${c.level} • ${c.subjects.length} matières',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
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
    final userState = ref.watch(userPrefsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderCol = isDark ? AppColors.border : const Color(0xFFE2E8F0);

    final rawName = userState.name.trim();
    final name = rawName.isNotEmpty ? rawName : 'Élève AlterniA';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // ── TOP HEADER ──────────────────────────────────────────────────
            Row(
              children: const [
                AlterniaLogo(size: 28, showText: true),
                Spacer(),
                AlterniaAvatarTopBarButton(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Mon Profil',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPri,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 20),

            // ── PROFILE CARD ────────────────────────────────────────────────
            CustomCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.secondary, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            name[0].toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPri,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                userState.classFullLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: borderCol, height: 1),
                  const SizedBox(height: 14),

                  // Button Change Class
                  CustomButton(
                    label: 'Changer de classe (Mali)',
                    icon: Icons.tune_rounded,
                    variant: CustomButtonVariant.secondary,
                    onPressed: () => _showClassSelectorDialog(context, ref, userState.studentClassId),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── STATS CARDS ─────────────────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: const [
                _ProfileStatTile(
                  title: 'SÉRIE DE RÉVISION',
                  subtitle: 'Streak actif',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.accent,
                ),
                _ProfileStatTile(
                  title: 'POINTS MAÎTRISE',
                  subtitle: 'Niveau 14',
                  icon: Icons.military_tech_rounded,
                  color: AppColors.secondary,
                ),
                _ProfileStatTile(
                  title: 'TEMPS ÉTUDE TOTAL',
                  subtitle: '+4h cette semaine',
                  icon: Icons.timer_rounded,
                  color: AppColors.success,
                ),
                _ProfileStatTile(
                  title: 'SESSIONS BOÎTIER',
                  subtitle: 'Synchronisés',
                  icon: Icons.memory_rounded,
                  color: AppColors.accentViolet,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Reset Onboarding Button
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.restart_alt_rounded, size: 16, color: AppColors.error),
                label: Text(
                  'Réinitialiser l\'Enregistrement / Onboarding',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                onPressed: () async {
                  await ref.read(userPrefsProvider.notifier).resetOnboarding();
                  if (context.mounted) {
                    context.go('/onboarding');
                  }
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatTile extends StatelessWidget {
  const _ProfileStatTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? AppColors.textMuted : const Color(0xFF475569);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textMuted,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
          ),
        ],
      ),
    );
  }
}
