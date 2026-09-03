import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/malian_school_system.dart';
import '../../features/profile/user_prefs_notifier.dart';
import '../common/widgets/alternia_logo.dart';

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
            content: Text(
              'Veuillez saisir votre prénom pour continuer.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AltaColors.accent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else if (_currentStep == 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    HapticFeedback.lightImpact();
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B111E) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF131D33) : Colors.white;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── EN-TÊTE SUPÉRIEUR : Logo AlterniA & Indicateur d'étape ─────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AlterniaLogo(
                    size: 34,
                    showText: true,
                    textColor: textPri,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Étape ${_currentStep + 1} / 3',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AltaColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(3, (index) {
                            final isActive = index <= _currentStep;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(left: 4),
                              width: isActive ? 18 : 6,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AltaColors.secondary
                                    : borderColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: borderColor, height: 1),

            // ── CONTENU DES ÉTAPES (PAGEVIEW) ───────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  _buildStep1Name(
                      isDark, surfaceColor, borderColor, textPri, textSec),
                  _buildStep2ClassSelection(
                      isDark, surfaceColor, borderColor, textPri, textSec),
                  _buildStep3CultureUniverse(
                      isDark, surfaceColor, borderColor, textPri, textSec),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ÉTAPE 1 : Nom & Prénom ────────────────────────────────────────────────
  Widget _buildStep1Name(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orbe AlterniA animé & Accroche
          Center(
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF314999), Color(0xFF40BBCC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF314999).withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AltaColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AltaColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'BIENVENUE SUR ALTERNIA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AltaColors.secondary : AltaColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Comment t\'appelles-tu ?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textPri,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'AlterniA adaptera son accompagnement pédagogique et s\'adressera à toi par ton prénom.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: textSec,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 22),

          // Champ de saisie élégant
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _nameCtrl,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                color: textPri,
                fontWeight: FontWeight.w600,
              ),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Ton prénom ou nom complet…',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AltaColors.secondary,
                  size: 22,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _nextPage(),
            ),
          ),

          const SizedBox(height: 28),

          // ── PÔLE 1 : ÉDUCATION & RÉUSSITE SCOLAIRE ───────────────────────
          Row(
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: AltaColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'PÔLE ÉDUCATION NATIONALE DU MALI',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AltaColors.secondary : AltaColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            icon: Icons.school_rounded,
            iconColor: const Color(0xFF314999),
            title: 'Programme officiel du Mali (BAC)',
            description:
                'Couverture intégrale des référentiels nationaux, fiches de révision structurées et annales.',
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPri: textPri,
            textSec: textSec,
          ),
          const SizedBox(height: 10),
          _buildFeatureCard(
            icon: Icons.psychology_rounded,
            iconColor: const Color(0xFF40BBCC),
            title: 'Tuteur Pédagogique IA Interactif',
            description:
                'Accompagnement bienveillant pas-à-pas, méthodologie guidée et explications adaptées.',
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPri: textPri,
            textSec: textSec,
          ),

          const SizedBox(height: 32),

          // Bouton Continuer
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AltaColors.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continuer vers le choix de classe',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: textSec,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCultureFeatureCard({
    required IconData icon,
    required String badge,
    required Color badgeColor,
    required String title,
    required String description,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPri,
    required Color textSec,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: badgeColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: badgeColor, size: 20),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPri,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: textSec,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── ÉTAPE 2 : Sélection de la classe malienne ────────────────────────────
  Widget _buildStep2ClassSelection(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    final currentClasses = classesByLevel(_selectedLevel);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _previousPage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: textPri,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CHOISIR MA CLASSE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AltaColors.secondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Quelle est ta classe actuelle ?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPri,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'AlterniA adaptera immédiatement le programme officiel, les matières et le niveau de rigueur.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: textSec,
                  height: 1.45,
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
                          color: isSelected ? AltaColors.primary : surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? AltaColors.secondary : borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AltaColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          lvl,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : textSec,
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
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedClassId = cls.id);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AltaColors.primary
                                  .withValues(alpha: isDark ? 0.2 : 0.08)
                              : surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected ? AltaColors.secondary : borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: color.withValues(alpha: 0.3)),
                              ),
                              child: Icon(cls.iconData, color: color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cls.shortLabel,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AltaColors.secondary
                                          : textPri,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cls.description,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: textSec,
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
                                  ? AltaColors.secondary
                                  : (isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFFCBD5E1)),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Bottom CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: IconButton(
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: textPri,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AltaColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continuer vers la Culture',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── ÉTAPE 3 : Découverte du Pôle Patrimoine & Culture Malienne ───────────
  Widget _buildStep3CultureUniverse(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPri,
    Color textSec,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orbe Culturel chaleureux & Badge
          Center(
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0823D), Color(0xFFB45309)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE0823D).withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.public_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0823D).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE0823D).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '✦ UNIVERS CULTUREL DU MALI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE0823D),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Explore les Trésors du Mali',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textPri,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'En plus de tes cours scolaires, AlterniA t\'ouvre les portes de l\'histoire du Mali, des contes de nos griots et des 19 régions.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: textSec,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 22),

          // Section Culture 1 : Monuments & Grandes Figures
          _buildCultureFeatureCard(
            icon: Icons.account_balance_rounded,
            badge: 'HISTOIRE & MONUMENTS',
            badgeColor: const Color(0xFFE0823D),
            title: 'Monuments & Grandes Figures',
            description:
                'Explore la Grande Mosquée de Djenné, les manuscrits de Tombouctou, le Tombeau des Askia et l\'épopée de Soundiata Keïta.',
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPri: textPri,
            textSec: textSec,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Section Culture 2 : Contes, Légendes & Devinettes
          _buildCultureFeatureCard(
            icon: Icons.auto_stories_rounded,
            badge: 'TRADITIONS & CONTES',
            badgeColor: const Color(0xFF2E7D32),
            title: 'Contes, Devinettes & Sagesses des Griots',
            description:
                'Écoute les récits oraux du terroir malien, résous les énigmes des anciens et enrichis ton passeport culturel.',
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPri: textPri,
            textSec: textSec,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Section Culture 3 : Carte Interactive des Régions & Défis
          _buildCultureFeatureCard(
            icon: Icons.explore_rounded,
            badge: 'EXPLORATION & RÉGIONS',
            badgeColor: const Color(0xFF314999),
            title: 'Carte des 19 Régions & Quiz Culturels',
            description:
                'Voyage de Kayes à Kidal à travers la carte interactive, relève les défis culturels et collectionne tes trophées.',
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPri: textPri,
            textSec: textSec,
            isDark: isDark,
          ),

          const SizedBox(height: 30),

          // Bouton Final d'Inscription
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: IconButton(
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: textPri,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _finishOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0823D),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'Démarrer l\'Aventure',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
