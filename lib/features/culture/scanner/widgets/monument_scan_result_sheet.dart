import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/datasources/culture_repository.dart';
import '../../core/theme/culture_theme.dart';
import '../models/monument_scan_models.dart';
import 'monument_3d_viewer_modal.dart';

/// Feuille de résultat immersive après identification certifiée par le Scanner IA CultureLens
class MonumentScanResultSheet extends ConsumerStatefulWidget {
  final MonumentScanResult result;
  final bool isAudioPlaying;
  final VoidCallback onToggleAudio;
  final VoidCallback onResetScan;

  const MonumentScanResultSheet({
    super.key,
    required this.result,
    required this.isAudioPlaying,
    required this.onToggleAudio,
    required this.onResetScan,
  });

  @override
  ConsumerState<MonumentScanResultSheet> createState() => _MonumentScanResultSheetState();
}

class _MonumentScanResultSheetState extends ConsumerState<MonumentScanResultSheet> {
  bool _isFavorite = false;
  int _selectedPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final repo = ref.read(cultureRepositoryProvider);
    final fav = await repo.isFavorite(widget.result.target.id);
    if (mounted) {
      setState(() => _isFavorite = fav);
    }
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();
    final repo = ref.read(cultureRepositoryProvider);
    final newFav = await repo.toggleFavorite(widget.result.target.id);
    if (mounted) {
      setState(() => _isFavorite = newFav);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: newFav ? CultureTheme.accentOrange : const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text(
            newFav ? 'Ajouté aux découvertes favorites !' : 'Retiré des favoris',
            style: GoogleFonts.plusJakartaSans(
              color: newFav ? Colors.black : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
  }

  void _shareMonument() {
    HapticFeedback.selectionClick();
    final target = widget.result.target;
    // ignore: deprecated_member_use
    Share.share(
      '🏛️ Découverte CultureLens — AlterniA :\n'
      '${target.name} (${target.regionName})\n\n'
      '« ${target.subtitle} »\n\n'
      '📍 Localisation : ${target.locationDetails}\n'
      '📜 Histoire : ${target.historicalStory}\n\n'
      'Explorez le patrimoine malien avec AlterniA !',
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final target = result.target;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final surfaceAlt = isDark ? CultureTheme.darkSurfaceAlt : CultureTheme.lightSurfaceAlt;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── TIREUR DU SHEET ────────────────────────────────────────────────
            Container(
              width: 44,
              height: 4.5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── BADGE DE CERTITUDE IA ET STATUTS ──────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: CultureTheme.accentOrange.withValues(alpha: 0.45),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'MONUMENT IDENTIFIÉ',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: CultureTheme.accentOrange,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderCol),
                          ),
                          child: Text(
                            target.regionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            if (widget.isAudioPlaying) widget.onToggleAudio();
                            widget.onResetScan();
                          },
                          icon: const Icon(Icons.close_rounded, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: subtitleColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── TITRE ET CATÉGORIE DU MONUMENT ─────────────────────────
                    Text(
                      target.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      target.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                        height: 1.35,
                      ),
                    ),

                    // ── GALERIE DE PHOTOS AUTHENTIQUES (DOSSIER DU MONUMENT) ───
                    _buildAuthenticGallerySection(
                      context: context,
                      target: target,
                      isDark: isDark,
                      surfaceAlt: surfaceAlt,
                      borderCol: borderCol,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),

                    const SizedBox(height: 12),

                    // ── MÉTADONNÉES CLÉS (ÉPOQUE, VILLE, STYLE) ────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMetaColumn(
                              icon: Icons.history_edu_rounded,
                              label: 'Époque',
                              value: target.era,
                              titleColor: titleColor,
                              subtitleColor: subtitleColor,
                            ),
                          ),
                          Container(width: 1, height: 28, color: borderCol),
                          Expanded(
                            child: _buildMetaColumn(
                              icon: Icons.location_on_rounded,
                              label: 'Localisation',
                              value: target.ville,
                              titleColor: titleColor,
                              subtitleColor: subtitleColor,
                            ),
                          ),
                          Container(width: 1, height: 28, color: borderCol),
                          Expanded(
                            child: _buildMetaColumn(
                              icon: Icons.verified_user_rounded,
                              label: 'Statut',
                              value: 'Vérifié',
                              titleColor: titleColor,
                              subtitleColor: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── LECTEUR AUDIO ORAL DU RECIT (TTS / NARRATION) ──────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: widget.isAudioPlaying
                            ? CultureTheme.accentOrange.withValues(alpha: 0.12)
                            : surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.isAudioPlaying ? CultureTheme.accentOrange : borderCol,
                          width: widget.isAudioPlaying ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: widget.onToggleAudio,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: CultureTheme.accentOrange,
                                shape: BoxShape.circle,
                                boxShadow: widget.isAudioPlaying
                                    ? [
                                        BoxShadow(
                                          color: CultureTheme.accentOrange.withValues(alpha: 0.45),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                widget.isAudioPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                                size: 26,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.isAudioPlaying
                                            ? 'Narration du Griot en cours...'
                                            : 'Écouter l\'histoire orale',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: titleColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: CultureTheme.accentOrange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'GRIOT',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                          color: CultureTheme.accentOrange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Récit authentique des traditions orales et faits vérifiés',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── HISTOIRE HISTORIQUE DU SITE ────────────────────────────
                    Text(
                      'RÉCIT & CONTEXTE HISTORIQUE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.accentOrange,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      target.historicalStory,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── CARACTÉRISTIQUES DÉTECTÉES PAR L'IA ─────────────────────
                    Text(
                      'SIGNATURES ARCHITECTURALES RECONNUES',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: subtitleColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: target.detectionFeatures.map((feat) {
                        return Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 40,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderCol),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                feat.icon,
                                size: 14,
                                color: CultureTheme.accentOrange,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  feat.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: CultureTheme.accentOrange.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 11,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // ── SECRETS & MYSTÈRES HISTORIQUES ─────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CultureTheme.iaYellow.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CultureTheme.iaYellow.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.key_rounded,
                                size: 18,
                                color: CultureTheme.iaYellow,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SECRETS & MYSTÈRES DU LIEU',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: CultureTheme.iaYellow,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            target.secretsAndMysteries,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: titleColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── BOUTONS D'ACTIONS MAJEURES : 3D, AR, CARTE, GUIDE, FAVORIS, PARTAGE ──
                    Row(
                      children: [
                        // Bouton 1 : Fiche Complète
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              if (widget.isAudioPlaying) widget.onToggleAudio();
                              final targetRoute = target.id.isNotEmpty
                                  ? '/culture/monument/${target.id}'
                                  : target.routePath;
                              context.push(targetRoute);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CultureTheme.accentOrange,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.menu_book_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Fiche complète',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Bouton 2 : Modèle 3D / AR Reconstitution
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Monument3DViewerModal.show(context, target);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: CultureTheme.accentOrange, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.view_in_ar_rounded, size: 18, color: CultureTheme.accentOrange),
                                const SizedBox(width: 6),
                                Text(
                                  '3D / AR',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: CultureTheme.accentOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── BARRE D'ACTIONS COMPLÉMENTAIRES (Guide RAG, Carte, Favori, Partager) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionCircle(
                          icon: Icons.auto_stories_rounded,
                          label: 'Le Guide',
                          color: CultureTheme.primaryBlue,
                          surfaceAlt: surfaceAlt,
                          borderCol: borderCol,
                          subtitleColor: subtitleColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (widget.isAudioPlaying) widget.onToggleAudio();
                            context.push('/culture/sage');
                          },
                        ),
                        _buildActionCircle(
                          icon: Icons.map_rounded,
                          label: 'Sur la carte',
                          color: CultureTheme.vertNaturel,
                          surfaceAlt: surfaceAlt,
                          borderCol: borderCol,
                          subtitleColor: subtitleColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/culture/map');
                          },
                        ),
                        _buildActionCircle(
                          icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          label: _isFavorite ? 'Enregistré' : 'Favori',
                          color: _isFavorite ? Colors.redAccent : subtitleColor,
                          surfaceAlt: surfaceAlt,
                          borderCol: borderCol,
                          subtitleColor: subtitleColor,
                          onTap: _toggleFavorite,
                        ),
                        _buildActionCircle(
                          icon: Icons.share_rounded,
                          label: 'Partager',
                          color: subtitleColor,
                          surfaceAlt: surfaceAlt,
                          borderCol: borderCol,
                          subtitleColor: subtitleColor,
                          onTap: _shareMonument,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: CultureTheme.accentOrange),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCircle({
    required IconData icon,
    required String label,
    required Color color,
    required Color surfaceAlt,
    required Color borderCol,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: surfaceAlt,
              shape: BoxShape.circle,
              border: Border.all(color: borderCol),
            ),
            child: Center(
              child: Icon(icon, size: 20, color: color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticGallerySection({
    required BuildContext context,
    required MonumentScanTarget target,
    required bool isDark,
    required Color surfaceAlt,
    required Color borderCol,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    final photos = target.galleryPhotos.isNotEmpty
        ? target.galleryPhotos
        : [target.photoUrl];
    final activePhoto = _selectedPhotoIndex < photos.length
        ? photos[_selectedPhotoIndex]
        : target.photoUrl;

    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 4),
      decoration: BoxDecoration(
        color: surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grande photo principale mise en avant
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(18),
              bottom: photos.length > 1 ? Radius.zero : const Radius.circular(18),
            ),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildPhotoWidget(activePhoto),
                ),
                // Gradient subtil pour la lisibilité
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                // Badge certifié photo réelle
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CultureTheme.accentOrange.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_library_rounded, size: 12, color: CultureTheme.accentOrange),
                        const SizedBox(width: 5),
                        Text(
                          'PHOTO RÉELLE CERTIFIÉE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Indicateur d'index
                if (photos.length > 1)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedPhotoIndex + 1} / ${photos.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Miniatures de la galerie si plus d'une photo réelle
          if (photos.length > 1)
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final p = photos[idx];
                    final isSel = idx == _selectedPhotoIndex;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedPhotoIndex = idx);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? CultureTheme.accentOrange : Colors.white24,
                            width: isSel ? 2.5 : 1.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildPhotoWidget(p, width: 52, height: 52),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoWidget(
    String photoPath, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    String resolved = photoPath.trim();
    if (resolved.startsWith('/api/v1/culture/dataset-images/')) {
      final rel = resolved.replaceFirst('/api/v1/culture/dataset-images/', '');
      resolved = 'assets/images/culture/monuments/$rel';
    }

    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return Image.network(
        resolved,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _buildFallbackImage(width, height),
      );
    }

    if (resolved.startsWith('assets/')) {
      return Image.asset(
        resolved,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) {
          final fallbackPath = widget.result.target.photoUrl;
          if (resolved != fallbackPath && fallbackPath.startsWith('assets/')) {
            return Image.asset(
              fallbackPath,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (_, __, ___) => _buildFallbackImage(width, height),
            );
          }
          return _buildFallbackImage(width, height);
        },
      );
    }

    if (resolved.startsWith('/') || resolved.startsWith('file://')) {
      final cleanPath = resolved.replaceFirst('file://', '');
      final f = File(cleanPath);
      if (f.existsSync()) {
        return Image.file(
          f,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _buildFallbackImage(width, height),
        );
      }
    }

    return Image.asset(
      resolved,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => _buildFallbackImage(width, height),
    );
  }

  Widget _buildFallbackImage(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1E293B),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_rounded,
              size: 28,
              color: CultureTheme.accentOrange,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.result.target.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
