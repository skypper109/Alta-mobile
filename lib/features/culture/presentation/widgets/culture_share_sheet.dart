import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/culture_challenge_models.dart';
import '../../core/models/culture_proverb_models.dart';
import '../../core/theme/culture_theme.dart';
import 'culture_share_card.dart';

/// Modal bottom sheet pour prévisualiser et partager une carte rectangulaire 16:9
class CultureShareSheet extends StatefulWidget {
  final CultureProverb? proverb;
  final TraditionalRiddle? riddle;

  const CultureShareSheet({
    super.key,
    this.proverb,
    this.riddle,
  }) : assert(proverb != null || riddle != null);

  /// Méthode d'ouverture pratique pour afficher la modal de partage
  static Future<void> show({
    required BuildContext context,
    CultureProverb? proverb,
    TraditionalRiddle? riddle,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CultureShareSheet(
        proverb: proverb,
        riddle: riddle,
      ),
    );
  }

  @override
  State<CultureShareSheet> createState() => _CultureShareSheetState();
}

class _CultureShareSheetState extends State<CultureShareSheet> {
  final GlobalKey _cardKey = GlobalKey();
  bool _showAnswer = false;
  bool _isExporting = false;

  String get _title => widget.proverb != null
      ? 'Partager la Sagesse'
      : 'Partager la Devinette';

  String get _subtitle => widget.proverb != null
      ? 'Carte souvenir des veillées et terroirs du Mali'
      : 'Défie tes amis avec cette énigme traditionnelle !';

  // Texte à copier ou partager en légende
  String _buildShareText() {
    if (widget.proverb != null) {
      final p = widget.proverb!;
      final buffer = StringBuffer();
      buffer.writeln('📜 Sagesse du Mali • ${p.regionName}');
      if (p.originalText != null && p.originalText!.isNotEmpty) {
        buffer.writeln('« ${p.originalText} »');
      }
      buffer.writeln('« ${p.text} »');
      buffer.writeln('\n💡 Signification : ${p.meaning}');
      buffer.writeln('\n🌟 Découvert sur AlterniA — Compagnon Culturel du Mali');
      buffer.writeln('#AlternIA #CultureMali #Sagesse #Mali');
      return buffer.toString();
    } else {
      final r = widget.riddle!;
      final buffer = StringBuffer();
      buffer.writeln('💡 Devinette du Mali • ${r.regionName}');
      buffer.writeln(r.formulaIntro);
      buffer.writeln('« ${r.riddleText} »');
      if (_showAnswer) {
        buffer.writeln('\n✅ Réponse : ${r.correctAnswer}');
        buffer.writeln('Explication : ${r.culturalExplanation}');
      } else {
        buffer.writeln('\n❓ Sauras-tu trouver la réponse ?');
      }
      buffer.writeln('\n🌟 Découvert sur AlterniA — Compagnon Culturel du Mali');
      buffer.writeln('#AlternIA #CultureMali #Devinette #Enigme');
      return buffer.toString();
    }
  }

  Future<void> _shareImage() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    HapticFeedback.lightImpact();

    try {
      // Attendre la stabilisation du rendu
      await Future.delayed(const Duration(milliseconds: 150));

      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Impossible de capturer la carte');
      }

      // Capture en ultra-haute résolution (pixelRatio: 3.0)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Conversion de l\'image échouée');
      }

      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.proverb != null
          ? 'alternia_proverbe_${widget.proverb!.id}.png'
          : 'alternia_devinette_${widget.riddle!.id}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(buffer);

      if (!mounted) return;

      // Partage natif via share_plus
      final xFile = XFile(file.path);
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [xFile],
        text: _buildShareText(),
        subject: _title,
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

  void _copyText() {
    HapticFeedback.selectionClick();
    final text = _buildShareText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Texte copié dans le presse-papiers !',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: CultureTheme.accentOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 26,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barre d'accroche drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // En-tête titre & fermeture
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.proverb != null
                      ? Icons.auto_stories_rounded
                      : Icons.lightbulb_rounded,
                  color: CultureTheme.accentOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      _subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_rounded, color: subtitleColor),
                tooltip: 'Fermer',
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── PRÉVISUALISATION DE LA CARTE RECTANGULAIRE 16:9 ───────────────
          Center(
            child: RepaintBoundary(
              key: _cardKey,
              child: CultureShareCard(
                proverb: widget.proverb,
                riddle: widget.riddle,
                showRiddleAnswer: _showAnswer,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Option interactive pour devinettes : afficher ou cacher la réponse
          if (widget.riddle != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? CultureTheme.darkBorder
                      : CultureTheme.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _showAnswer
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    size: 18,
                    color: CultureTheme.accentOrange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Révéler la solution sur l\'image',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                  Switch(
                    value: _showAnswer,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _showAnswer = val);
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: CultureTheme.accentOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const SizedBox(height: 8),
          ],

          // ── BOUTONS D'ACTION ─────────────────────────────────────────────
          Row(
            children: [
              // Bouton Copier le texte
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: _copyText,
                  icon: const Icon(Icons.copy_rounded, size: 17),
                  label: Text(
                    'Copier',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: titleColor,
                    side: BorderSide(
                      color: isDark
                          ? CultureTheme.darkBorder
                          : CultureTheme.lightBorder,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Bouton Partager l'image HD
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _shareImage,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.share_rounded,
                          size: 18, color: Colors.white),
                  label: Text(
                    _isExporting ? 'Génération...' : 'Partager l\'image HD',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CultureTheme.accentOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
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
