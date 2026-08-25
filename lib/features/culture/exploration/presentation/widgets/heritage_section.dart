import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/heritage_item.dart';
import 'heritage_card.dart';

/// Section "Patrimoine à découvrir"
class HeritageSection extends StatelessWidget {
  final List<HeritageItem> heritages;
  final Color accentColor;
  final ValueChanged<HeritageItem> onExploreHeritage;

  const HeritageSection({
    super.key,
    required this.heritages,
    required this.accentColor,
    required this.onExploreHeritage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (heritages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de section
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Patrimoine d\'exception',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Liste des cartes patrimoine
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: heritages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = heritages[index];
              return HeritageCard(
                heritage: item,
                accentColor: accentColor,
                onExplore: () => onExploreHeritage(item),
              );
            },
          ),
        ],
      ),
    );
  }
}
