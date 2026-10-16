import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../presentation/common/widgets/alternia_logo.dart';
import '../../core/models/culture_item.dart';
import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';

/// Modal bottom sheet pour prévisualiser et partager une fiche de monument, personnage ou lieu
/// sous forme de carte visuelle graphique de classe mondiale adaptée aux Statuts WhatsApp et réseaux sociaux.
class CulturalContentShareSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String categoryTag;
  final String regionName;
  final String? imageUrl;
  final String description;
  final List<String> keyFacts;
  final String? era;
  final String appLink;

  const CulturalContentShareSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.categoryTag,
    required this.regionName,
    this.imageUrl,
    required this.description,
    this.keyFacts = const [],
    this.era,
    this.appLink = 'https://alternia.ml',
  });

  /// Méthode d'ouverture pratique pour un monument
  static Future<void> showForMonument({
    required BuildContext context,
    required MonumentDetail monument,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CulturalContentShareSheet(
        title: monument.name,
        subtitle: monument.subtitle,
        categoryTag: monument.tag.isNotEmpty ? monument.tag : 'PATRIMOINE MONDIAL',
        regionName: monument.regionName,
        imageUrl: monument.photoUrl,
        description: monument.presentation.isNotEmpty
            ? monument.presentation
            : monument.whyItMatters,
        era: monument.era,
        keyFacts: monument.keyFacts
            .map((f) => '${f.label}: ${f.value}')
            .take(3)
            .toList(),
      ),
    );
  }

  /// Méthode d'ouverture pratique pour un CultureItem générique
  static Future<void> showForCultureItem({
    required BuildContext context,
    required CultureItem item,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CulturalContentShareSheet(
        title: item.title,
        subtitle: item.subtitle,
        categoryTag: item.tag.isNotEmpty ? item.tag : 'PATRIMOINE DU MALI',
        regionName: item.regionName,
        imageUrl: item.imageUrl,
        description: item.description,
        era: item.info,
      ),
    );
  }

  /// Méthode d'ouverture universelle
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String categoryTag,
    required String regionName,
    String? imageUrl,
    required String description,
    List<String> keyFacts = const [],
    String? era,
    String appLink = 'https://alternia.ml',
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CulturalContentShareSheet(
        title: title,
        subtitle: subtitle,
        categoryTag: categoryTag,
        regionName: regionName,
        imageUrl: imageUrl,
        description: description,
        keyFacts: keyFacts,
        era: era,
        appLink: appLink,
      ),
    );
  }

  @override
  State<CulturalContentShareSheet> createState() =>
      _CulturalContentShareSheetState();
}

class _CulturalContentShareSheetState extends State<CulturalContentShareSheet> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isExporting = false;

  /// Légende invitant à la découverte pour WhatsApp et réseaux
  String _buildShareCaption() {
    final buffer = StringBuffer();
    buffer.writeln('🏛️ DÉCOUVERTE DU PATRIMOINE DU MALI 🇲🇱');
    buffer.writeln('« ${widget.title.toUpperCase()} »');
    if (widget.subtitle.isNotEmpty) {
      buffer.writeln('${widget.subtitle}\n');
    }
    buffer.writeln('📍 Région : ${widget.regionName}');
    if (widget.era != null && widget.era!.isNotEmpty) {
      buffer.writeln('⏳ Époque : ${widget.era}');
    }

    final cleanDesc = widget.description
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleanDesc.isNotEmpty) {
      final excerpt = cleanDesc.length > 200
          ? '${cleanDesc.substring(0, 197)}...'
          : cleanDesc;
      buffer.writeln('\n📜 Histoire : $excerpt');
    }

    buffer.writeln('\n✨ Explore les monuments, les contes et les grands personnages du Mali !');
    buffer.writeln('📲 Télécharge l\'application AlterniA : ${widget.appLink}');
    buffer.writeln('#CultureMali #AlternIA #PatrimoineMali #Mali');
    return buffer.toString();
  }

  /// Capture la carte en haute résolution et la partage
  Future<void> _shareImage() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    HapticFeedback.lightImpact();

    try {
      await Future.delayed(const Duration(milliseconds: 160));

      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Impossible de capturer la carte visuelle');
      }

      // Rendu en 3.0x pour une clarté absolue sur les écrans OLED et statuts WhatsApp
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Conversion de l\'image échouée');
      }

      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final safeTitle = widget.title
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .toLowerCase();
      final fileName =
          'alternia_patrimoine_${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(buffer);

      if (!mounted) return;

      final xFile = XFile(file.path);
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [xFile],
        text: _buildShareCaption(),
        subject: 'Patrimoine du Mali : ${widget.title} • AlterniA',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage : $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// Copie la légende et le lien dans le presse-papiers
  Future<void> _copyText() async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _buildShareCaption()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Légende et lien copiés dans le presse-papiers !',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: CultureTheme.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF0C1322) : const Color(0xFFF8FAFC);
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 25,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée de glissement
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // En-tête de la modale
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Partager ce Trésor Malien',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Visuel officiel haute définition avec logo et lien',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),

          const Divider(height: 12),

          // Zone défilable contenant la carte visuelle à capturer
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Center(
                child: RepaintBoundary(
                  key: _cardKey,
                  child: _buildVisualCard(),
                ),
              ),
            ),
          ),

          // Barre d'actions en bas
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 8
                  : 18,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF10192A) : Colors.white,
              border: Border(top: BorderSide(color: borderCol, width: 1)),
            ),
            child: Row(
              children: [
                // Bouton Copier texte
                OutlinedButton.icon(
                  onPressed: _copyText,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: Text(
                    'Copier',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CultureTheme.accentOrange,
                    side: const BorderSide(
                        color: CultureTheme.accentOrange, width: 1.2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Bouton principal Partager Visuel
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _shareImage,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share_rounded,
                            size: 18, color: Colors.white),
                    label: Text(
                      _isExporting
                          ? 'Génération HD...'
                          : 'Partager le Statut / Image',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CultureTheme.accentOrange,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      shadowColor:
                          CultureTheme.accentOrange.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construction de la carte visuelle splendide prête pour la capture
  Widget _buildVisualCard() {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Fond nuit africaine sobre et noble
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CultureTheme.accentOrange.withValues(alpha: 0.8),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: CultureTheme.accentOrange.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. EN-TÊTE DE LA CARTE : LOGO ALTERNIA & BRANDING ─────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            color: const Color(0xFF141F35),
            child: Row(
              children: [
                const AlterniaLogo(
                  size: 26,
                  showText: true,
                  iaColor: CultureTheme.iaYellow,
                  textColor: Colors.white,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 11, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'PATRIMOINE DU MALI 🇲🇱',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 2. VISUEL PHOTOGRAPHIQUE DU MONUMENT / LIEU ───────────────────
          SizedBox(
            height: 185,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                  Image.asset(
                    widget.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1E293B),
                      child: const Center(
                        child: Icon(Icons.museum_rounded,
                            size: 48, color: Colors.white38),
                      ),
                    ),
                  )
                else
                  Container(
                    color: const Color(0xFF1E293B),
                    child: const Center(
                      child: Icon(Icons.museum_rounded,
                          size: 48, color: Colors.white38),
                    ),
                  ),

                // Dégradé d'assombrissement pour contraster le texte
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        const Color(0xFF0F172A).withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),

                // Badges superposés
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 11, color: CultureTheme.accentOrange),
                        const SizedBox(width: 3),
                        Text(
                          widget.regionName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (widget.era != null && widget.era!.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CultureTheme.accentOrange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.era!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Titre et tag en bas de l'image
                Positioned(
                  bottom: 8,
                  left: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: CultureTheme.accentOrange,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          widget.categoryTag.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.15,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 6),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 3. CORPS DE LA CARTE : SOUS-TITRE & RÉSUMÉ ─────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.subtitle.isNotEmpty) ...[
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                Text(
                  widget.description.length > 210
                      ? '${widget.description.substring(0, 207)}...'
                      : widget.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    height: 1.42,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),

                if (widget.keyFacts.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.keyFacts.take(2).map((fact) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF334155),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          fact,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // ── 4. PIED DE PAGE : INVITATION À TÉLÉCHARGER ALTERNIA ────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF141F35),
              border: Border(
                top: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_stories_rounded,
                              size: 12, color: CultureTheme.accentOrange),
                          const SizedBox(width: 4),
                          Text(
                            'Explore l\'histoire vivante du Mali',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Télécharge l\'application : ${widget.appLink}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'AlterniA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: CultureTheme.accentOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
