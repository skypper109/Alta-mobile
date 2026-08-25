import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/region_testimony.dart';
import 'testimony_card.dart';

/// Section "Histoires de la région" (Mémoire & Récits)
class TestimonySection extends StatelessWidget {
  final List<RegionTestimony> testimonies;
  final Color accentColor;
  final String? currentlyPlayingId;
  final bool isAudioPlaying;
  final ValueChanged<String> onToggleAudio;

  const TestimonySection({
    super.key,
    required this.testimonies,
    required this.accentColor,
    required this.currentlyPlayingId,
    required this.isAudioPlaying,
    required this.onToggleAudio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (testimonies.isEmpty) {
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
                'Histoires & Mémoire vivante',
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

          // Liste des cartes de témoignages
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: testimonies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = testimonies[index];
              final isPlaying =
                  currentlyPlayingId == item.id && isAudioPlaying;

              return TestimonyCard(
                testimony: item,
                accentColor: accentColor,
                isPlaying: isPlaying,
                onTogglePlay: () => onToggleAudio(item.id),
              );
            },
          ),
        ],
      ),
    );
  }
}
