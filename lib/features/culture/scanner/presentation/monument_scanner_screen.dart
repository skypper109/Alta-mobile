import 'dart:io';
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
import '../widgets/monument_viewfinder_overlay.dart';
import '../widgets/culture_offline_packs_modal.dart';


/// Écran principal du Scanner IA de Lieux & Monuments
/// 100% Plein Écran immersif : viseur central HUD, commandes au bas et détection Edge AI.
class MonumentScannerScreen extends ConsumerWidget {
  const MonumentScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // ── 1. ARRIÈRE-PLAN CAMÉRA / IMAGE (100% DU PLEIN ÉCRAN) ──────────
            Positioned.fill(
              child: _buildCameraBackground(scannerState),
            ),

            // Voile sombre subtil pour faire ressortir l'interface HUD
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
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
                  onReset: controller.reset,
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
                              'Vision IA & Patrimoine Malien',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: CultureTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Badge Edge AI (100% Hors-Ligne)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                const Color(0xFF10B981).withValues(alpha: 0.6),
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
                              'Edge AI',
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
                              color: CultureTheme.accentOrange.withValues(alpha: 0.5),
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
                        onTap: controller.toggleFlash,
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
            if (!scannerState.isRecognized)
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
                                onTap: scannerState.isAnalyzing
                                    ? null
                                    : controller.captureWithCamera,
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
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: 32,
                                        color: CultureTheme.darkBackground,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Bouton Réinitialiser / Réessayer
                              _buildCircleButton(
                                icon: Icons.refresh_rounded,
                                label: 'Nouveau',
                                onTap: controller.reset,
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
                  onResetScan: controller.reset,
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCameraBackground(ScannerState state) {
    if (state.selectedImagePath != null) {
      final path = state.selectedImagePath!;
      if (path.startsWith('assets/')) {
        return Image.asset(path, fit: BoxFit.cover);
      } else {
        return Image.file(File(path), fit: BoxFit.cover);
      }
    }

    // Fond par défaut texturé simulation caméra
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F131A),
      ),
      child: Center(
        child: Icon(
          Icons.camera_alt_outlined,
          size: 72,
          color: Colors.white.withValues(alpha: 0.12),
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
