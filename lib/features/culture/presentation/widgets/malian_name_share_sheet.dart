import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../presentation/common/widgets/alternia_logo.dart';
import '../../core/datasources/malian_names_knowledge.dart';
import '../../core/theme/culture_theme.dart';

/// Modal bottom sheet pour prévisualiser et partager la fiche ancestrale d'un nom
/// sous forme de visuel haute définition adapté au Statut WhatsApp et réseaux sociaux.
class MalianNameShareSheet extends StatefulWidget {
  final MalianNameInfo info;
  final bool autoTriggerWhatsApp;

  const MalianNameShareSheet({
    super.key,
    required this.info,
    this.autoTriggerWhatsApp = false,
  });

  /// Méthode d'ouverture pratique de la feuille de partage
  static Future<void> show({
    required BuildContext context,
    required MalianNameInfo info,
    bool autoTriggerWhatsApp = false,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MalianNameShareSheet(
        info: info,
        autoTriggerWhatsApp: autoTriggerWhatsApp,
      ),
    );
  }

  @override
  State<MalianNameShareSheet> createState() => _MalianNameShareSheetState();
}

class _MalianNameShareSheetState extends State<MalianNameShareSheet> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoTriggerWhatsApp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _shareForWhatsApp();
      });
    }
  }

  /// Légende invitant à la découverte pour le Statut WhatsApp
  String _buildWhatsAppCaption() {
    final buffer = StringBuffer();
    buffer.writeln('🌟 FIERTÉ & ORIGINE DU NOM : ${widget.info.name.toUpperCase()} 🇲🇱');
    buffer.writeln('Transmis par Grand-mère Mah sous le grand baobab sur AlterniA ✨\n');
    buffer.writeln('🌍 Berceau : ${widget.info.origin}');
    buffer.writeln('📜 Signification : ${widget.info.meaning}');
    if (widget.info.totem.isNotEmpty) {
      buffer.writeln('🐾 Animal Totem (Tanan) : ${widget.info.totem}');
    }
    if (widget.info.senankouya.isNotEmpty) {
      buffer.writeln('🤝 Cousinage à plaisanterie : ${widget.info.senankouya}');
    }
    if (widget.info.deviseOuLouange != null && widget.info.deviseOuLouange!.isNotEmpty) {
      buffer.writeln('👑 Devise ancestrale : « ${widget.info.deviseOuLouange} »');
    }
    buffer.writeln('\n👉 Découvre toi aussi l\'origine sacrée et le totem de ton nom de famille !');
    buffer.writeln('📲 Télécharge l\'application AlterniA — Mémoire vivante et Éducation du Mali');
    buffer.writeln('#AlternIA #CultureMali #Danbe #NomDeFamille #Mali');
    return buffer.toString();
  }

  /// Partage l'image optimisée pour le Statut WhatsApp
  Future<void> _shareForWhatsApp() async {
    await _exportAndShare(
      caption: _buildWhatsAppCaption(),
      subject: 'Origine et Totem du nom ${widget.info.name} • AlterniA',
    );
  }

  /// Partage générique
  Future<void> _shareGeneric() async {
    await _exportAndShare(
      caption: _buildWhatsAppCaption(),
      subject: 'Mon Danbé : ${widget.info.name} sur AlterniA',
    );
  }

  /// Capture de la carte en haute définition et diffusion
  Future<void> _exportAndShare({
    required String caption,
    required String subject,
  }) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    HapticFeedback.lightImpact();

    try {
      // Attente de stabilisation du rendu visuel
      await Future.delayed(const Duration(milliseconds: 160));

      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Impossible de capturer la carte visuelle');
      }

      // Capture en 3.0x pour une netteté cristalline sur grand écran et statut
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Erreur de conversion de l\'image');
      }

      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final safeName = widget.info.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
      final fileName = 'alternia_danbe_${safeName}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(buffer);

      if (!mounted) return;

      final xFile = XFile(file.path);
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [xFile],
        text: caption,
        subject: subject,
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
    Clipboard.setData(ClipboardData(text: _buildWhatsAppCaption()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Fiche du nom ${widget.info.name} copiée pour statut !',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée supérieure
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // En-tête du modal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: CultureTheme.accentOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Partager mon Danbé (Origine du Nom)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Carte illustrée officielle pour Statut WhatsApp & Réseaux',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF1E293B), height: 1),

          // ── ZONE DE PRÉVISUALISATION DE LA CARTE ──────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: RepaintBoundary(
                  key: _cardKey,
                  child: MalianNameShareCard(info: widget.info),
                ),
              ),
            ),
          ),

          // ── ACTIONS DE PARTAGE & STATUT WHATSAPP ─────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0B1120),
              border: Border(
                top: BorderSide(color: Color(0xFF1E293B), width: 1.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouton Statut WhatsApp prioritaire
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isExporting ? null : _shareForWhatsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // Vert officiel WhatsApp
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Partager sur Statut WhatsApp',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 8),

                // Boutons secondaires : Autres applications & Copier texte
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isExporting ? null : _shareGeneric,
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: Text(
                          'Autres applications',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF334155)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyText,
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: Text(
                          'Copier le texte',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFBBF24),
                          side: const BorderSide(color: Color(0xFFD97706)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de partage graphique premium pour les origines des noms du Mali
class MalianNameShareCard extends StatelessWidget {
  final MalianNameInfo info;
  final double? width;

  const MalianNameShareCard({
    super.key,
    required this.info,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD97706),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // ── FOND SCÉNIQUE DU BAOBAB SOUS LA NUIT ÉTOILÉE ────────────────
            Positioned.fill(
              child: Image.asset(
                'assets/images/culture/contes/manden_baobab_stage.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF111827),
                ),
              ),
            ),

            // Voile sombre texturé pour un contraste de texte exemplaire
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F172A).withValues(alpha: 0.88),
                      const Color(0xFF090D18).withValues(alpha: 0.94),
                    ],
                  ),
                ),
              ),
            ),

            // ── CROCHETS D'ANGLES SOUDANO-SAHÉLIENS DORÉS ────────────────────
            const Positioned.fill(
              child: _SudaneseCornerAccents(),
            ),

            // ── CONTENU DE LA TRANSMISSION DU NOM ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. En-tête : Badge Patrimoine + Logo AlterniA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706).withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF59E0B),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇲🇱', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 5),
                            Text(
                              'DANBÉ & HISTOIRE DU MALI',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFDE68A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const AlterniaLogo(
                        size: 19,
                        showText: true,
                        textColor: Colors.white,
                        iaColor: CultureTheme.iaYellow,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 2. Cartouche central du Nom Ancestral
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD97706).withValues(alpha: 0.28),
                          const Color(0xFF78350F).withValues(alpha: 0.18),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ORIGINE DU NOM',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFDE68A),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          info.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFD97706).withValues(alpha: 0.8),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                info.origin,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Détails étymologiques et totémiques
                  _buildDetailRow(
                    icon: Icons.auto_stories_rounded,
                    title: 'Signification sacrée',
                    content: info.meaning,
                  ),

                  if (info.totem.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.shield_rounded,
                      title: 'Animal Totem (Tanan)',
                      content: info.totem,
                      highlightColor: const Color(0xFF34D399),
                    ),
                  ],

                  if (info.senankouya.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.handshake_rounded,
                      title: 'Cousinage à plaisanterie (Senankouya)',
                      content: info.senankouya,
                      highlightColor: const Color(0xFF60A5FA),
                    ),
                  ],

                  if (info.deviseOuLouange != null &&
                      info.deviseOuLouange!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.military_tech_rounded,
                      title: 'Devise clanique',
                      content: '« ${info.deviseOuLouange} »',
                      highlightColor: const Color(0xFFFBBF24),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // 4. Invitation découverte & Branding AlterniA
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '« Transmis sous le baobab par Grand-mère Mah »',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFFFDE68A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Découvre toi aussi ton totem et ton histoire sur l\'app AlterniA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
    Color? highlightColor,
  }) {
    final accent = highlightColor ?? const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: const Color(0xFFF1F5F9),
            ),
          ),
        ],
      ),
    );
  }
}

/// Crochets d'angles traditionnels soudano-sahéliens
class _SudaneseCornerAccents extends StatelessWidget {
  const _SudaneseCornerAccents();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerPainter(
        color: const Color(0xFFF59E0B),
        strokeWidth: 2.2,
        cornerSize: 16.0,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerSize;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const pad = 9.0;

    // Haut-Gauche
    canvas.drawLine(
        Offset(pad, pad + cornerSize), const Offset(pad, pad), paint);
    canvas.drawLine(
        const Offset(pad, pad), Offset(pad + cornerSize, pad), paint);

    // Haut-Droite
    canvas.drawLine(Offset(size.width - pad - cornerSize, pad),
        Offset(size.width - pad, pad), paint);
    canvas.drawLine(Offset(size.width - pad, pad),
        Offset(size.width - pad, pad + cornerSize), paint);

    // Bas-Gauche
    canvas.drawLine(Offset(pad, size.height - pad - cornerSize),
        Offset(pad, size.height - pad), paint);
    canvas.drawLine(Offset(pad, size.height - pad),
        Offset(pad + cornerSize, size.height - pad), paint);

    // Bas-Droite
    canvas.drawLine(Offset(size.width - pad - cornerSize, size.height - pad),
        Offset(size.width - pad, size.height - pad), paint);
    canvas.drawLine(Offset(size.width - pad, size.height - pad),
        Offset(size.width - pad, size.height - pad - cornerSize), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      cornerSize != oldDelegate.cornerSize;
}
