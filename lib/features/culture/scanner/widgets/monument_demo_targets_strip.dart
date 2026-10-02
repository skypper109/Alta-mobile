import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/culture_theme.dart';
import '../data/monument_scan_knowledge.dart';
import '../models/monument_scan_models.dart';

/// Bandeau horizontal de simulation / cibles de démonstration pour le Scanner IA
/// Permet de tester immédiatement la reconnaissance sur les trésors emblématiques du Mali.
class MonumentDemoTargetsStrip extends StatelessWidget {
  final String? activeTargetId;
  final ValueChanged<MonumentScanTarget> onSelectTarget;

  const MonumentDemoTargetsStrip({
    super.key,
    this.activeTargetId,
    required this.onSelectTarget,
  });

  @override
  Widget build(BuildContext context) {
    final targets = MonumentScanKnowledge.targets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: CultureTheme.accentOrange,
              ),
              const SizedBox(width: 6),
              Text(
                'DÉMONSTRATION DIRECTE (PATRIMOINE MALIEN)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 64,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: targets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final target = targets[index];
              final isSelected = target.id == activeTargetId;

              return GestureDetector(
                onTap: () => onSelectTarget(target),
                child: Container(
                  width: 148,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CultureTheme.accentOrange.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? CultureTheme.accentOrange
                          : Colors.white.withValues(alpha: 0.2),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Miniature photo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          target.photoUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.museum_rounded,
                              size: 20,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Textes
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              target.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              target.regionName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: CultureTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
