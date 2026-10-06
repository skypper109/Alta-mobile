import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/culture_theme.dart';
import '../controllers/monument_scanner_controller.dart';
import '../models/monument_scan_models.dart';
import '../widgets/monument_demo_targets_strip.dart';
import '../widgets/monument_scan_result_sheet.dart';
import '../widgets/monument_unrecognized_sheet.dart';
import '../widgets/monument_viewfinder_overlay.dart';
import '../widgets/culture_offline_packs_modal.dart';

/// Écran principal du Scanner IA de Lieux & Monuments
/// 100% Plein Écran immersif : flux caméra direct, viseur HUD, capture instantanée et détection Edge AI.
class MonumentScannerScreen extends ConsumerStatefulWidget {
  const MonumentScannerScreen({super.key});

  @override
  ConsumerState<MonumentScannerScreen> createState() =>
      _MonumentScannerScreenState();
}

class _MonumentScannerScreenState extends ConsumerState<MonumentScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraLoading = true;
  String? _cameraErrorMessage;
  bool _isTakingPicture = false;
  bool _showShutterFlash = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = _cameraController;

    if (state == AppLifecycleState.paused) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
      _cameraController = null;
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController == null || !_isCameraInitialized) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isCameraInitialized = false;
    final controller = _cameraController;
    _cameraController = null;
    controller?.dispose();
    super.dispose();
  }

  /// Initialisation directe de l'objectif caméra (caméra arrière par défaut)
  Future<void> _initializeCamera() async {
    if (!mounted) return;

    setState(() {
      _isCameraLoading = true;
      _cameraErrorMessage = null;
    });

    try {
      final oldController = _cameraController;
      if (oldController != null) {
        _cameraController = null;
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
          });
        }
        await oldController.dispose();
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _isCameraLoading = false;
            _isCameraInitialized = false;
            _cameraErrorMessage = 'Aucune caméra disponible sur cet appareil';
          });
        }
        return;
      }

      // Sélectionner la caméra arrière en priorité
      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      // Forcer l'orientation portrait et éteindre le flash au démarrage
      try {
        await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      } catch (_) {}

      try {
        await controller.setFlashMode(FlashMode.off);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _isCameraLoading = false;
        });
      } else {
        await controller.dispose();
      }
    } catch (e) {
      debugPrint('Erreur d\'initialisation de la caméra: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isCameraLoading = false;
          _cameraErrorMessage = 'Impossible d\'accéder à la caméra';
        });
      }
    }
  }

  /// Capture photo instantanée depuis le flux caméra intégré
  Future<void> _onCapturePressed(
    MonumentScannerController controller,
    ScannerState scannerState,
  ) async {
    if (scannerState.isAnalyzing || _isTakingPicture) return;

    // Si la caméra en direct est prête, on capture directement l'image
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_cameraController!.value.isTakingPicture) {
      try {
        setState(() {
          _isTakingPicture = true;
          _showShutterFlash = true;
        });
        HapticFeedback.heavyImpact();

        // Effet visuel ultra-rapide de déclencheur (shutter flash)
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _showShutterFlash = false;
            });
          }
        });

        final XFile photo = await _cameraController!.takePicture();

        if (mounted) {
          setState(() {
            _isTakingPicture = false;
          });
        }

        await controller.scanCapturedPath(photo.path);
      } catch (e) {
        debugPrint('Erreur lors de la capture directe: $e');
        if (mounted) {
          setState(() {
            _isTakingPicture = false;
            _showShutterFlash = false;
          });
        }
        // Fallback gracieux sur le sélecteur standard
        await controller.captureWithCamera();
      }
    } else {
      // Fallback si la caméra native n'est pas encore initialisée
      await controller.captureWithCamera();
    }
  }

  /// Bascule de la torche / flash caméra
  Future<void> _toggleFlash(
    MonumentScannerController controller,
    ScannerState scannerState,
  ) async {
    final nextFlash = !scannerState.isFlashOn;
    controller.toggleFlash();

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.setFlashMode(
          nextFlash ? FlashMode.torch : FlashMode.off,
        );
      } catch (e) {
        debugPrint('Erreur bascule flash: $e');
      }
    }
  }

  /// Réinitialisation du scanner et retour au flux caméra direct
  Future<void> _onReset(MonumentScannerController controller) async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.setFlashMode(FlashMode.off);
      } catch (_) {}
    }
    controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(monumentScannerControllerProvider);
    final controller = ref.read(monumentScannerControllerProvider.notifier);
    final topPadding = MediaQuery.paddingOf(context).top;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.stopAudioNarration();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. ARRIÈRE-PLAN CAMÉRA DIRECTE / IMAGE (100% DU PLEIN ÉCRAN) ──
              Positioned.fill(
                child: _buildCameraBackground(scannerState),
              ),

              // Voile d'analyse subtil actif pendant la recherche IA
              if (scannerState.isAnalyzing)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                ),

              // Effet flash du déclencheur photo
              if (_showShutterFlash)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),

              // Dégradé supérieur pour contraster la barre de navigation
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topPadding + 80,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.70),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── 2. VISEUR HUD DE VISION NUMÉRIQUE (ZONE CENTRALE DÉDIÉE) ─────
              if (!scannerState.isRecognized)
                Positioned(
                  top: topPadding + 60,
                  bottom: 220,
                  left: 0,
                  right: 0,
                  child: MonumentViewfinderOverlay(
                    scannerState: scannerState,
                    onReset: () => _onReset(controller),
                  ),
                ),

              // ── 3. BARRE SUPÉRIEURE DE NAVIGATION ET COMMANDES ─────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Bouton retour
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            controller.stopAudioNarration();
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/culture');
                            }
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Titre du scanner
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Scanner de Monuments',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Découverte du Patrimoine',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Statut autonome
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Autonome',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Bouton Packs Hors Ligne
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            CultureOfflinePacksModal.show(context);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CultureTheme.accentOrange
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Icon(
                              Icons.cloud_download_rounded,
                              size: 18,
                              color: CultureTheme.accentOrange,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Bouton Flash
                        GestureDetector(
                          onTap: () => _toggleFlash(controller, scannerState),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: scannerState.isFlashOn
                                  ? CultureTheme.accentOrange
                                  : Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Icon(
                              scannerState.isFlashOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              size: 18,
                              color: scannerState.isFlashOn
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 4. BANDEAU DE DÉMONSTRATION DIRECTE & COMMANDES AU VRAI BAS ───
              if (!scannerState.isRecognized && !scannerState.isUnrecognized)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.only(top: 14, bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                            Colors.black,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Strip des cibles de démo pour tests jury / sans appareil
                          MonumentDemoTargetsStrip(
                            activeTargetId: scannerState.activeDemoTargetId,
                            onSelectTarget: controller.scanDemoTarget,
                          ),

                          const SizedBox(height: 14),

                          // Barre des 3 boutons de capture
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Bouton Importer de la galerie
                                _buildCircleButton(
                                  icon: Icons.photo_library_rounded,
                                  label: 'Galerie',
                                  onTap: controller.pickFromGallery,
                                ),

                                // Gros déclencheur caméra central
                                GestureDetector(
                                  onTap: (scannerState.isAnalyzing ||
                                          _isTakingPicture)
                                      ? null
                                      : () => _onCapturePressed(
                                          controller, scannerState),
                                  child: Container(
                                    width: 74,
                                    height: 74,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: CultureTheme.accentOrange,
                                        width: 3.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: CultureTheme.accentOrange
                                              .withValues(alpha: 0.4),
                                          blurRadius: 14,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: _isTakingPicture
                                            ? const SizedBox(
                                                width: 26,
                                                height: 26,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: CultureTheme
                                                      .darkBackground,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.camera_alt_rounded,
                                                size: 32,
                                                color: CultureTheme
                                                    .darkBackground,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Bouton Réinitialiser / Réessayer
                                _buildCircleButton(
                                  icon: Icons.refresh_rounded,
                                  label: 'Nouveau',
                                  onTap: () => _onReset(controller),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── 5. FEUILLE DE RÉSULTAT QUAND UN MONUMENT EST IDENTIFIÉ ─────────
              if (scannerState.isRecognized && scannerState.result != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: topPadding + 50,
                  child: MonumentScanResultSheet(
                    result: scannerState.result!,
                    isAudioPlaying: scannerState.isAudioPlaying,
                    onToggleAudio: controller.toggleAudioNarration,
                    onResetScan: () => _onReset(controller),
                  ),
                ),

              // ── 6. FEUILLE QUAND LE MONUMENT N'EST PAS RECONNU (< 45%) ────────
              if (scannerState.isUnrecognized)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MonumentUnrecognizedSheet(
                    onRetry: () => _onReset(controller),
                    onPickGallery: controller.pickFromGallery,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construction de l'arrière-plan :
  /// 1. Si une photo est sélectionnée/capturée : affichage de l'image.
  /// 2. Sinon, flux caméra en direct plein écran.
  /// 3. Fallback gracieux si caméra en cours d'initialisation ou indisponible.
  Widget _buildCameraBackground(ScannerState state) {
    // Si une photo a été capturée ou choisie en démo
    if (state.selectedImagePath != null) {
      final path = state.selectedImagePath!;
      if (path.startsWith('assets/')) {
        return Image.asset(path, fit: BoxFit.cover);
      } else {
        return Image.file(File(path), fit: BoxFit.cover);
      }
    }

    // Flux Caméra en direct plein écran
    final controller = _cameraController;
    if (controller != null &&
        _isCameraInitialized &&
        controller.value.isInitialized) {
      final previewSize = controller.value.previewSize;
      final previewWidth = previewSize != null
          ? (previewSize.width > previewSize.height
              ? previewSize.height
              : previewSize.width)
          : 720.0;
      final previewHeight = previewSize != null
          ? (previewSize.width > previewSize.height
              ? previewSize.width
              : previewSize.height)
          : 1280.0;

      return ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: CameraPreview(controller),
            ),
          ),
        ),
      );
    }

    // Caméra en cours de chargement
    if (_isCameraLoading) {
      return Container(
        color: const Color(0xFF0F131A),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CultureTheme.accentOrange,
              ),
              SizedBox(height: 16),
              Text(
                'Activation de la caméra...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Fallback si la caméra n'a pas pu être initialisée (simulateur ou permission)
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F131A),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _cameraErrorMessage ??
                    'Pointez la caméra vers un monument ou un site',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
            if (_cameraErrorMessage != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _initializeCamera,
                icon: const Icon(Icons.refresh_rounded,
                    size: 16, color: CultureTheme.accentOrange),
                label: Text(
                  'Réessayer la caméra',
                  style: GoogleFonts.plusJakartaSans(
                    color: CultureTheme.accentOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String label,
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
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
