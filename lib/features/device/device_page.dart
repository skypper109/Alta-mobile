// ─── DetAI — Feature: Device — Page & Widgets ────────────────────────────────
// Écran de découverte et connexion au boîtier DetAI avec animation radar.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/ws_manager.dart';
import '../../shared/painters.dart';
import '../../shared/widgets.dart';
import 'device_entity.dart';
import 'device_notifier.dart';
import 'device_repository.dart';

// ══════════════════════════════════════════════════════════════════════════════
// HELPER BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════════════

void showDeviceModalSheet(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DetColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Expanded(child: DeviceDiscoveryPage()),
          ],
        ),
      );
    },
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// PAGE PRINCIPALE
// ══════════════════════════════════════════════════════════════════════════════

/// Écran de découverte des boîtiers DetAI sur le réseau local.
class DeviceDiscoveryPage extends ConsumerStatefulWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  ConsumerState<DeviceDiscoveryPage> createState() => _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState extends ConsumerState<DeviceDiscoveryPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanCtrl;
  late final Animation<double>   _scanAnim;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_scanCtrl);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceNotifierProvider);

    // Arrête/démarre l'animation selon le scan
    if (state.isScanning) {
      if (!_scanCtrl.isAnimating) _scanCtrl.repeat();
    } else {
      if (_scanCtrl.isAnimating) _scanCtrl.stop();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(state),
      body: SafeArea(
        child: Column(
          children: [
            // ── Zone radar ─────────────────────────────────────────────────
            _RadarZone(animation: _scanAnim, state: state),
            // ── Corps ──────────────────────────────────────────────────────
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(DeviceState state) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(DetSizes.appBarHeight),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: DetColors.border, width: DetSizes.borderWidth),
          ),
        ),
        child: AppBar(
          title: const Text(DetStrings.appName),
          actions: [
            if (state.isConnected)
              Padding(
                padding: const EdgeInsets.only(right: DetSizes.lg),
                child: StatusBrick(
                  label: DetStrings.deviceConnected,
                  color: DetColors.accentGreen,
                  isPulsing: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(DeviceState state) {
    // Erreur seule (aucun device)
    if (state.hasError && state.devices.isEmpty) {
      return DetErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(deviceNotifierProvider.notifier).scanDevices(),
      );
    }

    // État initial (pas encore scanné)
    if (!state.isScanning && state.devices.isEmpty && !state.hasError) {
      return Padding(
        padding: const EdgeInsets.all(DetSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DetEmptyState(
              icon: Icons.wifi_tethering_off_rounded,
              title: 'Aucun boîtier Wi-Fi détecté',
              subtitle: 'Vous pouvez scanner le réseau local ou vous connecter directement au serveur local AlternIA (LLM + RAG Mali).',
            ),
            const SizedBox(height: DetSizes.lg),
            DetButton(
              label: DetStrings.deviceScan,
              icon: Icons.search_rounded,
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(deviceNotifierProvider.notifier).scanDevices();
              },
            ),
            const SizedBox(height: DetSizes.md),
            DetButton(
              label: 'Connecter au Boîtier AlternIA Local',
              icon: Icons.cloud_done_rounded,
              variant: DetButtonVariant.outline,
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref
                    .read(deviceNotifierProvider.notifier)
                    .connectToDevice(DeviceRepository.geminiVirtualDevice);
              },
            ),
          ],
        ),
      );
    }

    // Liste des boîtiers + bouton scan
    return ListView(
      padding: const EdgeInsets.all(DetSizes.lg),
      children: [
        Row(
          children: [
            const Expanded(child: DetSectionHeader(title: 'Boîtiers & Serveurs')),
            StatusBrick(
              label: 'ALTERNIA READY',
              color: DetColors.accentGreen,
            ),
          ],
        ),
        const SizedBox(height: DetSizes.md),

        if (state.isScanning)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: DetSizes.xxl),
            child: DetLoading(message: DetStrings.deviceScanning),
          )
        else ...[
          ...state.devices.map(
            (device) => Padding(
              padding: const EdgeInsets.only(bottom: DetSizes.md),
              child: _DeviceCard(
                device: device,
                isConnected: state.connectedDevice?.id == device.id,
                connectionState: state.connectionState,
                onConnect: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(deviceNotifierProvider.notifier)
                      .connectToDevice(device);
                },
                onOpenSession: () => context.go('/discussions'),
              ),
            ),
          ),

          const SizedBox(height: DetSizes.lg),

          DetButton(
            label: state.devices.isEmpty ? DetStrings.deviceScan : 'Rescanner',
            icon: Icons.refresh_rounded,
            variant: DetButtonVariant.outline,
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(deviceNotifierProvider.notifier).scanDevices();
            },
          ),
        ],

        const SizedBox(height: DetSizes.xxxl),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RADAR ZONE — Animation de scan
// ══════════════════════════════════════════════════════════════════════════════

class _RadarZone extends StatelessWidget {
  const _RadarZone({required this.animation, required this.state});

  final Animation<double> animation;
  final DeviceState       state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: DetColors.surface,
        border: Border(
          bottom: BorderSide(color: DetColors.border, width: DetSizes.borderWidth),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radar animé
          AnimatedBuilder(
            animation: animation,
            builder: (_, __) => CustomPaint(
              size: const Size(180, 180),
              painter: ScanningPainter(
                progress: state.isScanning ? animation.value : 0.0,
                color: state.isConnected
                    ? DetColors.accentGreen
                    : DetColors.accentOrange,
              ),
            ),
          ),

          // Icône centrale
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: DetColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: state.isConnected
                    ? DetColors.accentGreen
                    : DetColors.border,
                width: DetSizes.borderWidth,
              ),
            ),
            child: Icon(
              state.isConnected
                  ? Icons.router_rounded
                  : Icons.wifi_tethering_rounded,
              size: 24,
              color: state.isConnected
                  ? DetColors.accentGreen
                  : DetColors.textMuted,
            ),
          ),

          // Label état
          Positioned(
            bottom: DetSizes.lg,
            child: state.isScanning
                ? StatusBrick(
                    label: DetStrings.deviceScanning,
                    color: DetColors.accentOrange,
                    isPulsing: true,
                  )
                : state.isConnected
                    ? StatusBrick(
                        label: DetStrings.deviceConnected,
                        color: DetColors.accentGreen,
                        isPulsing: true,
                      )
                    : Text(
                        'Prêt à scanner',
                        style: DetTextStyles.bodySm,
                      ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DEVICE CARD — Carte boîtier
// ══════════════════════════════════════════════════════════════════════════════

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.isConnected,
    required this.connectionState,
    required this.onConnect,
    required this.onOpenSession,
  });

  final DeviceEntity      device;
  final bool              isConnected;
  final WsConnectionState connectionState;
  final VoidCallback      onConnect;
  final VoidCallback      onOpenSession;

  @override
  Widget build(BuildContext context) {
    final isConnecting = connectionState == WsConnectionState.connecting;

    return DetCard(
      borderColor: isConnected ? DetColors.accentGreen.withValues(alpha: 0.4) : DetColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ─────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: isConnected ? DetColors.accentGreenBg : DetColors.surfaceAlt,
                  borderRadius: DetSizes.borderRadiusMd,
                  border: Border.all(
                    color: isConnected ? DetColors.accentGreen.withValues(alpha: 0.4) : DetColors.border,
                    width: DetSizes.borderWidth,
                  ),
                ),
                child: Icon(
                  Icons.router_rounded,
                  size: DetSizes.iconMd,
                  color: isConnected ? DetColors.accentGreen : DetColors.textSecondary,
                ),
              ),
              const SizedBox(width: DetSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: DetTextStyles.headingSm),
                    const SizedBox(height: 2),
                    Text(
                      device.ipAddress,
                      style: DetTextStyles.codeSm.copyWith(color: DetColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Signal
              _SignalBars(quality: device.signalQuality),
            ],
          ),

          const SizedBox(height: DetSizes.md),
          const Divider(height: 1),
          const SizedBox(height: DetSizes.md),

          // ── Métadonnées ──────────────────────────────────────────────────
          Row(
            children: [
              _MetaChip(label: 'Port', value: ':${device.port}'),
              const SizedBox(width: DetSizes.sm),
              _MetaChip(label: 'Signal', value: device.signalLabel),
              if (device.firmwareVersion != null) ...[
                const SizedBox(width: DetSizes.sm),
                _MetaChip(label: 'FW', value: device.firmwareVersion!),
              ],
            ],
          ),

          const SizedBox(height: DetSizes.md),

          // ── Actions ──────────────────────────────────────────────────────
          if (isConnected)
            DetButton(
              label: 'Ouvrir la session',
              icon: Icons.graphic_eq_rounded,
              onPressed: onOpenSession,
            )
          else
            DetButton(
              label: isConnecting ? 'Connexion…' : DetStrings.deviceConnect,
              icon: isConnecting ? null : Icons.link_rounded,
              isLoading: isConnecting,
              onPressed: isConnecting ? null : onConnect,
            ),
        ],
      ),
    );
  }
}

/// Indicateur visuel de la qualité du signal (3 barres).
class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.quality});
  final double quality;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final threshold = (i + 1) / 3;
        final active    = quality >= threshold;
        return Container(
          width:  5,
          height: 6.0 + i * 4.0,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: active ? DetColors.accentGreen : DetColors.border,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

/// Chip de métadonnée (label + valeur code mono).
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DetSizes.sm,
        vertical: DetSizes.xs,
      ),
      decoration: BoxDecoration(
        color: DetColors.surfaceAlt,
        borderRadius: DetSizes.borderRadiusSm,
        border: Border.all(color: DetColors.border, width: 1.0),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$label ', style: DetTextStyles.caption),
            TextSpan(
              text: value,
              style: DetTextStyles.codeSm.copyWith(color: DetColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
