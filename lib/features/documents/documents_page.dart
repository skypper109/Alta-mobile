// ─── AlterniA — Feature: Documents & Scanner Socratique ─────────────────────────
// Dédié exclusivement aux devoirs et exercices scannés par l'élève.
// Traitement OCR réel avec le backend AlternIA et persistance locale des scans.
library;

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../discussions/subject_chat_provider.dart';
import '../profile/user_prefs_notifier.dart';

class DocumentsPage extends ConsumerStatefulWidget {
  const DocumentsPage({super.key});

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isLoadingHistory = true;
  int _currentStep = 0;
  String? _scannedFileName;
  File? _scannedImageFile;
  String? _extractedOcrText;
  String? _detectedSubject;
  late final AnimationController _pulseCtrl;

  // Historique personnel des devoirs et exercices scannés par l'élève
  List<_ScannedDocItem> _history = [];
  List<Map<String, String>> _socraticSteps = [];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _loadSavedScansHistory();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  List<String> get _candidateBaseUrls => AltaApiConfig.candidateBaseUrls;

  /// Charge uniquement les scans réels effectués par l'élève depuis le stockage local
  Future<void> _loadSavedScansHistory() async {
    final loaded = <_ScannedDocItem>[];

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedScansJson = prefs.getString('alternia_user_scanned_documents');
      if (savedScansJson != null && savedScansJson.isNotEmpty) {
        final list = jsonDecode(savedScansJson) as List<dynamic>;
        for (final item in list) {
          loaded.add(_ScannedDocItem.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _history = loaded;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _saveScannedDocumentLocally(_ScannedDocItem doc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = _history.map((d) => d.toJson()).toList();
      await prefs.setString(
          'alternia_user_scanned_documents', jsonEncode(serialized));
    } catch (_) {}
  }

  Future<void> _clearScansHistory() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alternia_user_scanned_documents');
    setState(() {
      _history = [];
      _scannedFileName = null;
      _scannedImageFile = null;
      _extractedOcrText = null;
      _currentStep = 0;
    });
  }

  Future<void> _pickAndAnalyzeDocument(ImageSource source) async {
    final userPrefs = ref.read(userPrefsProvider);
    HapticFeedback.mediumImpact();

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (picked == null) return;

      setState(() {
        _isProcessing = true;
        _scannedFileName = picked.name;
        _scannedImageFile = File(picked.path);
        _extractedOcrText = null;
        _detectedSubject = null;
        _socraticSteps = [];
      });

      final dio = Dio();
      bool success = false;
      final bytes = await picked.readAsBytes();

      for (final url in _candidateBaseUrls) {
        try {
          final activeSub = ref.read(activeSubjectProvider) ??
              (userPrefs.subjects.isNotEmpty
                  ? userPrefs.subjects.first
                  : 'Général');
          final formData = FormData.fromMap({
            'subject': activeSub,
            'level': userPrefs.studentClassId,
            'image': MultipartFile.fromBytes(bytes, filename: picked.name),
          });

          final res = await dio.post(
            '$url/api/rag/analyze',
            data: formData,
            options: Options(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 25),
            ),
          );

          if (res.statusCode == 200 && res.data is Map) {
            final hints = (res.data['hints'] as List<dynamic>? ?? []);
            final ocrText = res.data['extracted_text'] as String?;
            final subject = res.data['subject'] as String? ?? 'Général';

            if (hints.isNotEmpty) {
              final parsedSteps = <Map<String, String>>[];
              for (var i = 0; i < hints.length; i++) {
                final h = hints[i] as Map<String, dynamic>;
                parsedSteps.add({
                  'title':
                      'Étape ${i + 1} • ${(h['type'] as String? ?? 'Raisonnement').toUpperCase()}',
                  'content': h['text'] as String? ??
                      h['content'] as String? ??
                      'Analyse en cours.',
                  'question': h['question'] as String? ??
                      'Quelle est ton hypothèse pour cette étape ?',
                });
              }

              final newDocItem = _ScannedDocItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: picked.name,
                subject: subject,
                date: 'Aujourd\'hui • ${_formatCurrentTime()}',
                stepsCount: parsedSteps.length,
                color: AltaColors.accent,
                imagePath: picked.path,
                ocrText: ocrText,
                steps: parsedSteps,
              );

              if (mounted) {
                setState(() {
                  _socraticSteps = parsedSteps;
                  _extractedOcrText = ocrText;
                  _detectedSubject = subject;
                  _isProcessing = false;
                  _currentStep = 0;
                  _history.insert(0, newDocItem);
                });
                await _saveScannedDocumentLocally(newDocItem);
              }
              success = true;
              break;
            }
          }
        } catch (_) {}
      }

      if (!success && mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Le serveur AlternIA n\'a pas répondu. Vérifiez que le backend est démarré.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _openDocumentDetails(_ScannedDocItem doc) {
    HapticFeedback.mediumImpact();
    setState(() {
      _scannedFileName = doc.name;
      _detectedSubject = doc.subject;
      _extractedOcrText = doc.ocrText;
      _scannedImageFile =
          (doc.imagePath != null && File(doc.imagePath!).existsSync())
              ? File(doc.imagePath!)
              : null;
      _currentStep = 0;

      if (doc.steps != null && doc.steps!.isNotEmpty) {
        _socraticSteps = doc.steps!;
      }
    });
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri =
        isDark ? AltaColors.textPrimaryDark : AltaColors.textPrimaryLight;
    final textSec =
        isDark ? AltaColors.textSecondaryDark : AltaColors.textSecondaryLight;
    final userPrefs = ref.watch(userPrefsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // ── En-tête ─────────────────────────────────────────────────────
            Row(
              children: const [
                AlterniaLogo(size: 28, showText: true),
                Spacer(),
                AlterniaAvatarTopBarButton(),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESPACE ÉDUCATION',
                  style: GoogleFonts.plusJakartaSans(
                    color: AltaColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mes Devoirs & Scanner OCR',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textPri,
                  ),
                ),
              ],
            ),

            const SizedBox(height: DetSizes.xl),

            // ── Zone d'importation réelle ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(DetSizes.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AltaColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                    AltaColors.secondary.withValues(alpha: isDark ? 0.1 : 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: DetSizes.borderRadiusXl,
                border: Border.all(
                  color: AltaColors.primary.withValues(alpha: 0.4),
                  width: DetSizes.borderWidth,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DetSizes.lg),
                    decoration: BoxDecoration(
                      color: AltaColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.document_scanner_rounded,
                      size: 40,
                      color: AltaColors.primary,
                    ),
                  ),
                  const SizedBox(height: DetSizes.md),
                  Text(
                    'Scanner un devoir ou exercice',
                    style: DetTextStyles.headingMd.copyWith(color: textPri),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prenez une photo : le service AlternIA extrait le texte par OCR et vous guide pas à pas.',
                    textAlign: TextAlign.center,
                    style: DetTextStyles.bodySm.copyWith(color: textSec),
                  ),
                  const SizedBox(height: DetSizes.lg),
                  Row(
                    children: [
                      Expanded(
                        child: DetButton(
                          label: 'Caméra',
                          icon: Icons.camera_alt_rounded,
                          onPressed: () =>
                              _pickAndAnalyzeDocument(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: DetSizes.md),
                      Expanded(
                        child: DetButton(
                          label: 'Galerie',
                          icon: Icons.photo_library_rounded,
                          variant: DetButtonVariant.secondary,
                          onPressed: () =>
                              _pickAndAnalyzeDocument(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: DetSizes.xl),

            // ── Résultat de l'analyse ou Chargement ──────────────────────────
            if (_isProcessing) ...[
              Container(
                padding: const EdgeInsets.all(DetSizes.xl),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: DetSizes.borderRadiusLg,
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.95 + 0.1 * _pulseCtrl.value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AltaColors.secondary.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AltaColors.secondary,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.psychology_rounded,
                              color: AltaColors.secondary,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: DetSizes.md),
                    Text(
                      'Traitement OCR & Analyse Socratique…',
                      style: DetTextStyles.headingSm.copyWith(color: textPri),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Extraction du texte par OCR et résolution guidée (${userPrefs.classFullLabel})',
                      style: DetTextStyles.bodySm.copyWith(color: textSec),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DetSizes.xl),
            ] else if (_scannedFileName != null &&
                _socraticSteps.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(DetSizes.lg),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: DetSizes.borderRadiusLg,
                  border: Border.all(
                    color: AltaColors.secondary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AltaColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _scannedFileName!,
                            style: DetTextStyles.bodyMd.copyWith(
                              color: textPri,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_detectedSubject != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AltaColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _detectedSubject!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AltaColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Aperçu miniature de la photo du devoir scanné
                    if (_scannedImageFile != null &&
                        _scannedImageFile!.existsSync()) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _scannedImageFile!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],

                    // Texte extrait par OCR de l'exercice
                    if (_extractedOcrText != null &&
                        _extractedOcrText!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderCol),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.document_scanner_rounded,
                                    size: 14, color: AltaColors.secondary),
                                const SizedBox(width: 6),
                                Text(
                                  'ÉNONCÉ DÉTECTÉ PAR OCR',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AltaColors.secondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _extractedOcrText!,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: textPri,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Divider(height: 24),
                    Text(
                      _socraticSteps[_currentStep]['title']!,
                      style: DetTextStyles.headingSm.copyWith(
                        color: AltaColors.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _socraticSteps[_currentStep]['content']!,
                      style: DetTextStyles.bodyMd.copyWith(
                        color: textPri,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(DetSizes.md),
                      decoration: BoxDecoration(
                        color: AltaColors.primary
                            .withValues(alpha: isDark ? 0.15 : 0.06),
                        borderRadius: DetSizes.borderRadiusMd,
                        border: Border.all(
                          color: AltaColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.help_outline_rounded,
                            color: AltaColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _socraticSteps[_currentStep]['question']!,
                              style: DetTextStyles.bodySm.copyWith(
                                color: textPri,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DetSizes.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _currentStep--);
                            },
                            icon:
                                const Icon(Icons.arrow_back_rounded, size: 16),
                            label: const Text('Précédent'),
                          )
                        else
                          const SizedBox.shrink(),
                        if (_currentStep < _socraticSteps.length - 1)
                          DetButton(
                            label: 'Étape suivante',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () {
                              setState(() => _currentStep++);
                            },
                          )
                        else
                          DetButton(
                            label: 'Fermer',
                            icon: Icons.check_circle_rounded,
                            variant: DetButtonVariant.secondary,
                            onPressed: () {
                              setState(() {
                                _scannedFileName = null;
                                _scannedImageFile = null;
                                _extractedOcrText = null;
                                _currentStep = 0;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DetSizes.xl),
            ],

            // ── Historique personnel des devoirs scannés ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HISTORIQUE DE MES DEVOIRS SCANNÉS',
                  style: GoogleFonts.plusJakartaSans(
                    color: textSec,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                if (_history.isNotEmpty)
                  GestureDetector(
                    onTap: _clearScansHistory,
                    child: Text(
                      'Effacer l\'historique',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DetSizes.sm),

            if (_isLoadingHistory)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                    child:
                        CircularProgressIndicator(color: AltaColors.primary)),
              )
            else if (_history.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  children: [
                    Icon(Icons.photo_camera_back_rounded,
                        size: 40, color: textSec.withValues(alpha: 0.5)),
                    const SizedBox(height: 10),
                    Text(
                      'Aucun devoir scanné pour le moment',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prenez une photo de votre exercice ou devoir avec la Caméra pour lancer l\'OCR et la résolution guidée.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: textSec),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: DetSizes.sm),
                itemBuilder: (context, index) {
                  final doc = _history[index];
                  return GestureDetector(
                    onTap: () => _openDocumentDetails(doc),
                    child: Container(
                      padding: const EdgeInsets.all(DetSizes.md),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: DetSizes.borderRadiusLg,
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(DetSizes.md),
                            decoration: BoxDecoration(
                              color: doc.color.withValues(alpha: 0.12),
                              borderRadius: DetSizes.borderRadiusMd,
                            ),
                            child: Icon(
                              Icons.photo_camera_rounded,
                              color: doc.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: DetSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.name,
                                  style: DetTextStyles.bodyMd.copyWith(
                                    color: textPri,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${doc.subject} • ${doc.date}',
                                  style: DetTextStyles.bodySm
                                      .copyWith(color: textSec),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DetSizes.sm,
                              vertical: DetSizes.xs,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AltaColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(DetSizes.xs),
                            ),
                            child: Text(
                              '${doc.stepsCount} étapes',
                              style: DetTextStyles.caption.copyWith(
                                color: AltaColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ScannedDocItem {
  _ScannedDocItem({
    required this.id,
    required this.name,
    required this.subject,
    required this.date,
    required this.stepsCount,
    required this.color,
    this.imagePath,
    this.ocrText,
    this.steps,
  });

  final String id;
  final String name;
  final String subject;
  final String date;
  final int stepsCount;
  final Color color;
  final String? imagePath;
  final String? ocrText;
  final List<Map<String, String>>? steps;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subject': subject,
        'date': date,
        'stepsCount': stepsCount,
        'color': '0x${color.toARGB32().toRadixString(16).padLeft(8, '0')}',
        'imagePath': imagePath,
        'ocrText': ocrText,
        'steps': steps,
      };

  factory _ScannedDocItem.fromJson(Map<String, dynamic> json) =>
      _ScannedDocItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Exercice',
        subject: json['subject'] as String? ?? 'Général',
        date: json['date'] as String? ?? '',
        stepsCount: json['stepsCount'] as int? ?? 4,
        color: json['color'] != null
            ? Color(int.tryParse(json['color'] as String) ?? 0xFFF1851F)
            : AltaColors.accent,
        imagePath: json['imagePath'] as String?,
        ocrText: json['ocrText'] as String?,
        steps: (json['steps'] as List<dynamic>?)
            ?.map((e) => Map<String, String>.from(e as Map))
            .toList(),
      );
}
