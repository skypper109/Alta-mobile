import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';
import '../models/story_experience_models.dart';

/// Overlay de choix interactif ou question posée à l'élève à un tournant de l'histoire
class StoryChoiceOverlay extends StatelessWidget {
  final List<StoryInteractiveOption> choices;
  final String? selectedId;
  final ValueChanged<StoryInteractiveOption> onChoiceSelected;

  const StoryChoiceOverlay({
    super.key,
    required this.choices,
    this.selectedId,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.94),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: CultureTheme.accentOrange.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: CultureTheme.accentOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'À TOI DE JOUER • DILEMME HISTORIQUE',
                style: GoogleFonts.plusJakartaSans(
                  color: CultureTheme.accentOrange,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...choices.map((choice) {
            final isSelected = selectedId == choice.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onChoiceSelected(choice),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CultureTheme.accentOrange.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? CultureTheme.accentOrange
                          : Colors.white.withValues(alpha: 0.15),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? CultureTheme.accentOrange
                              : Colors.white.withValues(alpha: 0.10),
                        ),
                        child: Icon(
                          choice.icon,
                          color: isSelected ? Colors.white : Colors.white70,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              choice.label,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              choice.trait.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: CultureTheme.accentOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white38,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
