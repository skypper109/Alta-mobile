import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/culture_theme.dart';

/// Feuille modale affichée lorsque la photo scannée ou importée
/// ne correspond à aucun monument malien répertorié avec au moins 45% de certitude.
class MonumentUnrecognizedSheet extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onPickGallery;

  const MonumentUnrecognizedSheet({
    super.key,
    required this.onRetry,
    required this.onPickGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Poignée supérieure discrète
              Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),

              // Icône d'avertissement bienveillante avec halo ambré
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                    width: 2.0,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 30,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Badge d'état
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Correspondance insuffisante (< 45%)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFBBF24),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Titre chaleureux
              Text(
                'Désolé, monument non reconnu',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Explication polie sans jargon technique
              Text(
                'Cette photo ne correspond à aucun monument ou site malien répertorié avec au moins 45% de certitude après vérification.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: 16),

              // Carte des conseils de prise de vue
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 16,
                          color: CultureTheme.accentOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Conseils pour une bonne reconnaissance :',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTipRow(Icons.crop_free_rounded, 'Cadrez bien la façade principale au centre'),
                    const SizedBox(height: 6),
                    _buildTipRow(Icons.wb_sunny_outlined, 'Privilégiez une bonne lumière naturelle'),
                    const SizedBox(height: 6),
                    _buildTipRow(Icons.camera_alt_outlined, 'Évitez les photos floues ou trop sombres'),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Bouton principal : Réessayer avec la caméra
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onRetry();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                  label: Text(
                    'Réessayer',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CultureTheme.accentOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Bouton secondaire : Choisir une autre photo
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onPickGallery();
                  },
                  icon: Icon(
                    Icons.photo_library_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  label: Text(
                    'Choisir une autre photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
      ],
    );
  }
}
