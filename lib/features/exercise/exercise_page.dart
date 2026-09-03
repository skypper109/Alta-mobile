// ─── DetAI — Feature: Exercise (Écran 3 : Mes Exercices / Scanner Socratique) ──
// Importation Image/PDF/Caméra et résolution Socratique pas-à-pas.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../shared/widgets.dart';

class ExerciseScannerPage extends ConsumerStatefulWidget {
  const ExerciseScannerPage({super.key});

  @override
  ConsumerState<ExerciseScannerPage> createState() => _ExerciseScannerPageState();
}

class _ExerciseScannerPageState extends ConsumerState<ExerciseScannerPage> {
  bool _isProcessing = false;
  int _currentStep = 0;
  String? _scannedFileName;

  final List<Map<String, String>> _socraticSteps = [
    {
      'title': 'Étape 1 • Observons l\'énoncé',
      'content': 'Analyse OCR réalisée avec succès. Le problème concerne un système de deux équations à deux inconnues.',
      'question': 'Quelle est la première relation donnée entre x et y dans le texte ?',
    },
    {
      'title': 'Étape 2 • Que comprends-tu ?',
      'content': 'Nous devons isoler la variable x dans la première équation avant d\'effectuer la substitution.',
      'question': 'Quelle méthode préfères-tu utiliser : la substitution ou la combinaison linéaire ?',
    },
    {
      'title': 'Étape 3 • Essayons ensemble',
      'content': 'En isolant x = 5 - 2y et en remplaçant dans la seconde équation, nous obtenons : 3(5 - 2y) + 4y = 11.',
      'question': 'Que vaut la valeur de y après simplification de cette équation ?',
    },
    {
      'title': 'Étape 4 • Validation de la méthode',
      'content': 'La solution du système est le couple (x = 1, y = 2). Vérification immédiate dans les deux équations initiales.',
      'question': 'As-tu bien compris chaque étape de la méthode ?',
    },
  ];

  void _importDocument(String type) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _scannedFileName = 'Exercice_Maths_$type.pdf';
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DetColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DetSizes.lg),
          children: [
            // ── En-tête ───────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MES EXERCICES', style: DetTextStyles.caption.copyWith(color: DetColors.primary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('Scanner Pédagogique', style: DetTextStyles.displayMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: DetSizes.sm),
                StatusBrick(
                  label: 'RAG ENGINE ACTIVE',
                  color: DetColors.accentGreen,
                ),
              ],
            ),

            const SizedBox(height: DetSizes.xxl),

            // ── Zone d'importation centrale ────────────────────────────────────
            DetCard(
              backgroundColor: DetColors.surface,
              borderColor: DetColors.primary.withValues(alpha: 0.4),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DetSizes.lg),
                    decoration: BoxDecoration(
                      color: DetColors.primaryBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.document_scanner_rounded,
                      size: 40,
                      color: DetColors.primary,
                    ),
                  ),
                  const SizedBox(height: DetSizes.md),
                  Text('Importer un exercice à analyser', style: DetTextStyles.headingMd),
                  const SizedBox(height: 4),
                  Text(
                    'Prenez une photo de votre devoir ou importez un fichier PDF.',
                    textAlign: TextAlign.center,
                    style: DetTextStyles.bodySm.copyWith(color: DetColors.textSecondary),
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
                          label: 'Importer PDF / Image',
                          icon: Icons.upload_file_rounded,
                          variant: DetButtonVariant.outline,
                          onPressed: () => _importDocument('Doc'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: DetSizes.xxl),

            // ── Zone de traitement Socratique pas-à-pas ────────────────────────
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: DetSizes.xxl),
                child: DetLoading(message: 'Analyse pédagogique de l\'énoncé en cours…'),
              )
            else if (_scannedFileName != null) ...[
              DetSectionHeader(title: 'Analyse : $_scannedFileName'),
              const SizedBox(height: DetSizes.md),

              DetCard(
                borderColor: DetColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _socraticSteps[_currentStep]['title']!,
                          style: DetTextStyles.headingSm.copyWith(color: DetColors.primary),
                        ),
                        Text(
                          'Étape ${_currentStep + 1} / ${_socraticSteps.length}',
                          style: DetTextStyles.caption,
                        ),
                      ],
                    ),

                    const SizedBox(height: DetSizes.md),

                    Text(
                      _socraticSteps[_currentStep]['content']!,
                      style: DetTextStyles.bodyLg,
                    ),

                    const SizedBox(height: DetSizes.lg),

                    Container(
                      padding: const EdgeInsets.all(DetSizes.md),
                      decoration: BoxDecoration(
                        color: DetColors.surfaceAlt,
                        borderRadius: DetSizes.borderRadiusMd,
                        border: Border.all(color: DetColors.border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('QUESTION DE RÉFLEXION :', style: DetTextStyles.caption.copyWith(color: DetColors.primary, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            _socraticSteps[_currentStep]['question']!,
                            style: DetTextStyles.bodyMd,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DetSizes.lg),

                    Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: DetButton(
                              label: 'Précédent',
                              variant: DetButtonVariant.outline,
                              onPressed: () {
                                setState(() => _currentStep--);
                              },
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: DetSizes.md),
                        Expanded(
                          child: DetButton(
                            label: _currentStep < _socraticSteps.length - 1 ? 'Étape suivante' : 'Terminer l\'exercice',
                            onPressed: () {
                              if (_currentStep < _socraticSteps.length - 1) {
                                setState(() => _currentStep++);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Exercice résolu et assimilé !'),
                                    backgroundColor: DetColors.accentGreen,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: DetSizes.xl),
          ],
        ),
      ),
    );
  }
}
