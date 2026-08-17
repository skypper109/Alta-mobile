import 'package:alternia/features/profile/user_prefs_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/malian_school_system.dart';
import '../../shared/widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  final TextEditingController _nameCtrl = TextEditingController();

  int _currentStep = 0;
  String _selectedLevel = 'Terminale';
  String _selectedClassId = defaultClassId;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentStep == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Veuillez saisir votre nom ou prénom.'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    HapticFeedback.lightImpact();
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.mediumImpact();
    final name = _nameCtrl.text.trim().isEmpty
        ? 'Élève AlterniA'
        : _nameCtrl.text.trim();

    await ref.read(userPrefsProvider.notifier).saveRegistration(
          name: name,
          classId: _selectedClassId,
        );

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR : Logo + Indicator ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AlterniaLogo(size: 32, showText: true),
                  Row(
                    children: List.generate(2, (index) {
                      final isActive = index <= _currentStep;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(left: 6),
                        width: isActive ? 24 : 10,
                        height: 6,
                        decoration: BoxDecoration(
                          color:
                              isActive ? AppColors.secondary : AppColors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 1),

            // ── PAGEVIEW ────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  _buildStep1Name(),
                  _buildStep2ClassSelection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ÉTAPE 1 : Nom & Prénom ────────────────────────────────────────────────
  Widget _buildStep1Name() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Text(
              'Étape 1 / 2',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Comment vous appelez-vous ?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AlterniA vous appellera par votre prénom dans chaque explication personnalisée.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Champ Texte Premium
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Nom & Prénom',
              prefixIcon: const Icon(Icons.person_outline_rounded,
                  color: AppColors.secondary),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onSubmitted: (_) => _nextPage(),
          ),

          const Spacer(),

          // CTA Button
          CustomButton(
            label: 'Continuer',
            icon: Icons.arrow_forward_rounded,
            variant: CustomButtonVariant.accent,
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }

  // ── ÉTAPE 2 : Sélection de la classe malienne ────────────────────────────
  Widget _buildStep2ClassSelection() {
    final currentClasses = classesByLevel(_selectedLevel);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _previousPage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'Étape 2 / 2',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Votre classe au Mali',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'L\'IA adaptera le programme, les matières et le niveau de rigueur.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Onglets Niveaux (10ème, 11ème, Terminale)
              Row(
                children: malianLevels.map((lvl) {
                  final isSelected = _selectedLevel == lvl;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedLevel = lvl;
                          final available = classesByLevel(lvl);
                          if (available.isNotEmpty) {
                            _selectedClassId = available.first.id;
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          lvl,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Liste des classes pour le niveau sélectionné
              ...currentClasses.map((cls) {
                final isSelected = _selectedClassId == cls.id;
                final color = Color(cls.color);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    backgroundColor: isSelected
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : AppColors.surface,
                    borderColor:
                        isSelected ? AppColors.secondary : AppColors.border,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedClassId = cls.id);
                    },
                    child: Row(
                      children: [
                        // Icon Box (No missing icons!)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Icon(cls.iconData, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cls.shortLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.secondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cls.description,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.textMuted,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Bottom CTA
        Padding(
          padding: const EdgeInsets.all(24),
          child: CustomButton(
            label: 'Valider et Démarrer',
            icon: Icons.rocket_launch_rounded,
            variant: CustomButtonVariant.accent,
            onPressed: _finishOnboarding,
          ),
        ),
      ],
    );
  }
}
