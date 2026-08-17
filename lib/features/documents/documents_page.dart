// ─── AlterniA — Feature: Documents & Scanner Socratique ──────────────────────
// Import et analyse socratique d'exercices connecté au moteur RAG AlternIA.
library;

import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../profile/user_prefs_notifier.dart';

class DocumentsPage extends ConsumerStatefulWidget {
  const DocumentsPage({super.key});

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  int _currentStep = 0;
  String? _scannedFileName;
  late final AnimationController _pulseCtrl;

  final List<_DocHistory> _history = [
    _DocHistory(
      name: 'Exercice_Maths_Intégrales.pdf',
      subject: 'Mathématiques',
      date: 'Hier • 14:32',
      steps: 4,
      color: AltaColors.primary,
    ),
    _DocHistory(
      name: 'Devoir_Physique_Newton.jpg',
      subject: 'Physique',
      date: 'Il y a 2 jours',
      steps: 4,
      color: AltaColors.accent,
    ),
    _DocHistory(
      name: 'Cours_SVT_Mitose.pdf',
      subject: 'Sciences Naturelles',
      date: 'Il y a 5 jours',
      steps: 4,
      color: AltaColors.secondary,
    ),
  ];

  List<Map<String, String>> _socraticSteps = [
    {
      'title': 'Étape 1 • Observons l\'énoncé',
      'content': 'Analyse RAG réalisée avec succès. AlterniA a identifié le type d\'exercice et les données clés du problème.',
      'question': 'Quelle est la première donnée importante que tu remarques dans l\'énoncé ?',
    },
    {
      'title': 'Étape 2 • Que comprends-tu ?',
      'content': 'Avant d\'appliquer une formule, il faut comprendre ce qu\'on cherche. AlterniA t\'accompagne dans cette réflexion.',
      'question': 'Quelle méthode ou formule du programme malien te semble appropriée ?',
    },
    {
      'title': 'Étape 3 • Essayons ensemble',
      'content': 'AlterniA te guide pas à pas. Chaque étape de raisonnement compte autant que la réponse finale.',
      'question': 'Que vaut le résultat intermédiaire après cette première simplification ?',
    },
    {
      'title': 'Étape 4 • Validation de la méthode',
      'content': 'Excellent travail ! Vérifions ensemble que la solution est cohérente avec les données de départ.',
      'question': 'As-tu bien compris chaque étape de la méthode ?',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  List<String> get _candidateBaseUrls {
    if (kIsWeb) return ['http://127.0.0.1:8000', 'http://localhost:8000'];
    try {
      if (Platform.isAndroid) {
        return [
          'http://10.0.2.2:8000',
          'http://127.0.0.1:8000',
          'http://192.168.4.1:8000',
        ];
      }
    } catch (_) {}
    return [
      'http://127.0.0.1:8000',
      'http://localhost:8000',
      'http://192.168.4.1:8000',
    ];
  }

  Future<void> _importDocument(String type) async {
    final userPrefs = ref.read(userPrefsProvider);
    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _scannedFileName = 'Document_${userPrefs.classShortLabel}_$type.pdf';
    });

    final dio = Dio();
    bool success = false;

    for (final url in _candidateBaseUrls) {
      try {
        final formData = FormData.fromMap({
          'subject': 'Sciences & Mathématiques',
          'level': userPrefs.studentClassId,
          'text': 'Analyse d\'exercice scolaire du programme malien',
        });

        final res = await dio.post(
          '$url/api/rag/analyze',
          data: formData,
          options: Options(connectTimeout: const Duration(seconds: 4), receiveTimeout: const Duration(seconds: 8)),
        );

        if (res.statusCode == 200 && res.data is Map) {
          final hints = (res.data['hints'] as List<dynamic>? ?? []);
          if (hints.isNotEmpty) {
            final parsedSteps = <Map<String, String>>[];
            for (var i = 0; i < hints.length; i++) {
              final h = hints[i] as Map<String, dynamic>;
              parsedSteps.add({
                'title': 'Étape ${i + 1} • ${(h['type'] as String? ?? 'Raisonnement').toUpperCase()}',
                'content': h['text'] as String? ?? h['content'] as String? ?? 'Analyse en cours.',
                'question': h['question'] as String? ?? 'Quelle est ton hypothèse pour cette étape ?',
              });
            }
            if (mounted) {
              setState(() {
                _socraticSteps = parsedSteps;
                _isProcessing = false;
                _currentStep = 0;
              });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? AltaColors.textPrimaryDark : AltaColors.textPrimaryLight;
    final textSec = isDark ? AltaColors.textSecondaryDark : AltaColors.textSecondaryLight;
    final userPrefs = ref.watch(userPrefsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // ── En-tête ─────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MES DOCUMENTS',
                      style: DetTextStyles.caption.copyWith(
                        color: AltaColors.accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scanner Socratique',
                      style: DetTextStyles.displayMd.copyWith(
                        color: textPri,
                      ),
                    ),
                  ],
                ),
                const AlterniaLogo(size: 28, showText: true),
              ],
            ),

            const SizedBox(height: DetSizes.xl),

            // ── Zone d'importation ──────────────────────────────────────────
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
                    'Importer un exercice',
                    style: DetTextStyles.headingMd.copyWith(color: textPri),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AlterniA analyse votre devoir et vous guide pas à pas.',
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
                          onPressed: () => _importDocument('Photo'),
                        ),
                      ),
                      const SizedBox(width: DetSizes.md),
                      Expanded(
                        child: DetButton(
                          label: 'Galerie',
                          icon: Icons.photo_library_rounded,
                          variant: DetButtonVariant.secondary,
                          onPressed: () => _importDocument('Galerie'),
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
                              color: AltaColors.secondary.withValues(alpha: 0.2),
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
                      'Analyse Socratique par AlterniA…',
                      style: DetTextStyles.headingSm.copyWith(color: textPri),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recherche des concepts du programme (${userPrefs.classFullLabel})',
                      style: DetTextStyles.bodySm.copyWith(color: textSec),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DetSizes.xl),
            ] else if (_scannedFileName != null) ...[
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
                          ),
                        ),
                      ],
                    ),
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
                        color: AltaColors.primary.withValues(alpha: isDark ? 0.15 : 0.06),
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
                            icon: const Icon(Icons.arrow_back_rounded, size: 16),
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
                            label: 'Terminer',
                            icon: Icons.done_all_rounded,
                            variant: DetButtonVariant.secondary,
                            onPressed: () {
                              setState(() {
                                _scannedFileName = null;
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

            // ── Historique des devoirs ──────────────────────────────────────
            Text(
              'HISTORIQUE DES ANALYSES',
              style: DetTextStyles.caption.copyWith(
                color: AltaColors.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: DetSizes.md),
            ..._history.map((doc) => Padding(
              padding: const EdgeInsets.only(bottom: DetSizes.sm),
              child: _DocHistoryCard(doc: doc),
            )),
          ],
        ),
      ),
    );
  }
}

class _DocHistory {
  _DocHistory({
    required this.name,
    required this.subject,
    required this.date,
    required this.steps,
    required this.color,
  });

  final String name;
  final String subject;
  final String date;
  final int steps;
  final Color color;
}

class _DocHistoryCard extends StatelessWidget {
  const _DocHistoryCard({required this.doc});
  final _DocHistory doc;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? AltaColors.textPrimaryDark : AltaColors.textPrimaryLight;
    final textSec = isDark ? AltaColors.textSecondaryDark : AltaColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(DetSizes.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: DetSizes.borderRadiusMd,
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: doc.color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: DetSizes.borderRadiusSm,
            ),
            child: Icon(Icons.picture_as_pdf_rounded, color: doc.color, size: 22),
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
                ),
                const SizedBox(height: 2),
                Text(
                  '${doc.subject} • ${doc.date}',
                  style: DetTextStyles.caption.copyWith(color: textSec),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AltaColors.secondary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: DetSizes.borderRadiusSm,
            ),
            child: Text(
              '${doc.steps} étapes',
              style: DetTextStyles.caption.copyWith(
                color: AltaColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
