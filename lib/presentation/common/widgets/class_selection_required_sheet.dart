// ─── AlterniA — Modal : Sélection de Classe Requise pour l'Éducation ──────────
// Empêche l'accès aux cours/devoirs sans classe sélectionnée.
// Propose la sélection des niveaux (10ème, 11ème, Terminale) et séries maliennes.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/malian_school_system.dart';
import '../../../features/profile/user_prefs_notifier.dart';

/// Affiche la feuille modale interactive exigeant la sélection d'une classe.
/// Retourne `true` si une classe a été validée et enregistrée, `false` sinon.
Future<bool> showClassSelectionRequiredSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ClassSelectionRequiredSheetContent(),
  );
  return result ?? false;
}

class _ClassSelectionRequiredSheetContent extends ConsumerStatefulWidget {
  const _ClassSelectionRequiredSheetContent();

  @override
  ConsumerState<_ClassSelectionRequiredSheetContent> createState() =>
      _ClassSelectionRequiredSheetContentState();
}

class _ClassSelectionRequiredSheetContentState
    extends ConsumerState<_ClassSelectionRequiredSheetContent> {
  late String _selectedLevel;
  late String _selectedClassId;

  @override
  void initState() {
    super.initState();
    final userPrefs = ref.read(userPrefsProvider);
    if (userPrefs.hasSelectedClass && userPrefs.malianClass != null) {
      _selectedLevel = userPrefs.malianClass!.level;
      _selectedClassId = userPrefs.studentClassId;
    } else {
      _selectedLevel = 'Terminale';
      final defaultForLevel = classesByLevel(_selectedLevel);
      _selectedClassId =
          defaultForLevel.isNotEmpty ? defaultForLevel.first.id : defaultClassId;
    }
  }

  void _onLevelChanged(String newLevel) {
    if (_selectedLevel == newLevel) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLevel = newLevel;
      final available = classesByLevel(newLevel);
      if (available.isNotEmpty) {
        _selectedClassId = available.first.id;
      }
    });
  }

  void _onClassSelected(String classId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedClassId = classId;
    });
  }

  Future<void> _onConfirm() async {
    HapticFeedback.mediumImpact();
    await ref.read(userPrefsProvider.notifier).updateClass(_selectedClassId);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _onCancel() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF131D33) : Colors.white;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final cardBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    final currentClasses = classesByLevel(_selectedLevel);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.2),
          left: BorderSide(color: borderColor, width: 1.2),
          right: BorderSide(color: borderColor, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Poignée de glissement ───────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // ── En-tête avec Icône & Message clair ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'PÔLE ÉDUCATION',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Requis',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Choisis ta classe scolaire',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPri,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _onCancel,
                    icon: const Icon(Icons.close_rounded),
                    color: textSec,
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'L\'espace Éducation adapte les cours, les annales du BAC et le tuteur IA au programme officiel malien correspondant à ta filière.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: textSec,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Onglets de niveau (10ème, 11ème, Terminale) ───────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: malianLevels.map((lvl) {
                    final isSelected = _selectedLevel == lvl;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onLevelChanged(lvl),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 6,
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
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : textSec,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Liste scrollable des classes / séries ────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: currentClasses.length,
                itemBuilder: (context, index) {
                  final cls = currentClasses[index];
                  final isSelected = _selectedClassId == cls.id;
                  final clsColor = Color(cls.color);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onClassSelected(cls.id),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                    .withValues(alpha: isDark ? 0.2 : 0.08)
                                : cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.secondary
                                  : borderColor,
                              width: isSelected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: clsColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: clsColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Icon(cls.iconData,
                                    color: clsColor, size: 19),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cls.shortLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.secondary
                                            : textPri,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      cls.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: textSec,
                                      ),
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
                                    : (isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFFCBD5E1)),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Divider(color: borderColor, height: 1),

            // ── Boutons d'Action (Annuler vs Confirmer) ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: _onCancel,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: borderColor),
                        foregroundColor: textSec,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Plus tard (Culture)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: _onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Confirmer & Ouvrir',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
