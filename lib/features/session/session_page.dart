// ─── DetAI — Feature: Session — Page Futuristic Cyber-HUD ──────────────────
// Interface d'exception : Dashboard Socratique Cyber-Néon temps réel connecté à Gemini AI.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../shared/painters.dart';
import '../device/device_notifier.dart';
import 'session_entity.dart';
import 'session_notifier.dart';

// ══════════════════════════════════════════════════════════════════════════════
// PAGE PRINCIPALE — DASHBOARD SOCRATIQUE FUTURISTE
// ══════════════════════════════════════════════════════════════════════════════

class SessionMonitorPage extends ConsumerStatefulWidget {
  const SessionMonitorPage({super.key});

  @override
  ConsumerState<SessionMonitorPage> createState() => _SessionMonitorPageState();
}

class _SessionMonitorPageState extends ConsumerState<SessionMonitorPage>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final AnimationController _holoCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _holoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurveTween(curve: Curves.easeInOut).animate(_pulseCtrl),
    );
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _holoCtrl.dispose();
    _pulseCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionNotifierProvider);
    final device  = ref.watch(deviceNotifierProvider);

    ref.listen(sessionNotifierProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) < next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: DetColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. En-tête HUD Futuriste ──────────────────────────────────
            _CyberHudHeader(
              aiState:     session.aiState,
              isConnected: device.isConnected,
              deviceName:  device.connectedDevice?.name,
              onClear:     () => ref.read(sessionNotifierProvider.notifier).clearMessages(),
            ),

            // ── 2. Core Orbe Holo & Visualiseur Sonore ────────────────────
            _CyberKineticHeader(
              amplitudes:  session.amplitudes,
              aiState:     session.aiState,
              waveAnim:    _waveCtrl,
              holoAnim:    _holoCtrl,
              pulseAnim:   _pulseAnim,
            ),

            // ── 3. Brique d'état Neural Core ──────────────────────────────
            _NeuralStateHUD(
              state:     session.aiState,
              pulseAnim: _pulseAnim,
            ),

            // ── 4. Flux de transcription Cyber-Glass ──────────────────────
            Expanded(
              child: _FuturisticTranscriptFeed(
                messages:   session.messages,
                scrollCtrl: _scrollCtrl,
                isConnected: device.isConnected,
              ),
            ),

            // ── 5. Console de saisie interactive Gemini ───────────────────
            _CyberConsoleInput(
              onSend: (text) =>
                  ref.read(sessionNotifierProvider.notifier).sendStudentMessage(text),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: DetDurations.normal,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CYBER HUD HEADER
// ══════════════════════════════════════════════════════════════════════════════

class _CyberHudHeader extends StatelessWidget {
  const _CyberHudHeader({
    required this.aiState,
    required this.isConnected,
    this.deviceName,
    required this.onClear,
  });

  final AiState   aiState;
  final bool      isConnected;
  final String?   deviceName;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DetSizes.lg,
        vertical: DetSizes.md,
      ),
      decoration: BoxDecoration(
        color: DetColors.surface.withValues(alpha: 0.8),
        border: const Border(
          bottom: BorderSide(color: DetColors.border, width: DetSizes.borderWidth),
        ),
      ),
      child: Row(
        children: [
          // Titre avec logo Néon
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(
                  color: DetColors.accentGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: DetColors.accentGreen, blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: DetSizes.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DETAI SOCRATIC CORE',
                    style: DetTextStyles.headingSm.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    deviceName ?? 'ALTERNIA LOCAL IA • PROGRAMME MALI',
                    style: DetTextStyles.codeSm.copyWith(color: DetColors.accentCyan),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Badge Latence
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DetColors.surfaceAlt,
              borderRadius: DetSizes.borderRadiusSm,
              border: Border.all(color: DetColors.border, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 12, color: DetColors.accentGreen),
                const SizedBox(width: 2),
                Text('18ms', style: DetTextStyles.codeSm.copyWith(color: DetColors.accentGreen)),
              ],
            ),
          ),

          const SizedBox(width: DetSizes.sm),

          // Bouton Clear
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onClear();
            },
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: DetColors.surfaceAlt,
                borderRadius: DetSizes.borderRadiusSm,
                border: Border.all(color: DetColors.border, width: DetSizes.borderWidth),
              ),
              child: const Icon(
                Icons.delete_sweep_outlined,
                size: 18,
                color: DetColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CYBER KINETIC HEADER (Orbe Holo + Waveform)
// ══════════════════════════════════════════════════════════════════════════════

class _CyberKineticHeader extends StatelessWidget {
  const _CyberKineticHeader({
    required this.amplitudes,
    required this.aiState,
    required this.waveAnim,
    required this.holoAnim,
    required this.pulseAnim,
  });

  final List<double>      amplitudes;
  final AiState           aiState;
  final Animation<double> waveAnim;
  final Animation<double> holoAnim;
  final Animation<double> pulseAnim;

  Color get _coreColor => switch (aiState) {
    AiState.listening => DetColors.accentGreen,
    AiState.thinking  => DetColors.accentCyan,
    AiState.speaking  => DetColors.accentOrange,
    AiState.idle      => DetColors.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: DetColors.surface,
        border: const Border(
          bottom: BorderSide(color: DetColors.border, width: DetSizes.borderWidth),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Grille cyber
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridBackgroundPainter(color: DetColors.border.withValues(alpha: 0.4)),
            ),
          ),

          // Waveform de fond
          AnimatedBuilder(
            animation: waveAnim,
            builder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: DetSizes.xl),
              child: CustomPaint(
                size: const Size(double.infinity, 90),
                painter: WaveformPainter(
                  samples: amplitudes,
                  color:   _coreColor,
                  isActive: aiState != AiState.idle || amplitudes.isNotEmpty,
                  barWidth: 4.0,
                  barGap:   2.0,
                ),
              ),
            ),
          ),

          // Central Holographic Core Orb
          AnimatedBuilder(
            animation: Listenable.merge([holoAnim, pulseAnim]),
            builder: (_, __) => CustomPaint(
              size: const Size(110, 110),
              painter: HolographicCorePainter(
                progress:   holoAnim.value,
                pulseValue: pulseAnim.value,
                color:      _coreColor,
                isThinking: aiState == AiState.thinking,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NEURAL STATE HUD
// ══════════════════════════════════════════════════════════════════════════════

class _NeuralStateHUD extends StatelessWidget {
  const _NeuralStateHUD({required this.state, required this.pulseAnim});

  final AiState           state;
  final Animation<double> pulseAnim;

  Color get _color => switch (state) {
    AiState.listening => DetColors.accentGreen,
    AiState.thinking  => DetColors.accentCyan,
    AiState.speaking  => DetColors.accentOrange,
    AiState.idle      => DetColors.textMuted,
  };

  IconData get _icon => switch (state) {
    AiState.listening => Icons.graphic_eq_rounded,
    AiState.thinking  => Icons.psychology_rounded,
    AiState.speaking  => Icons.spatial_audio_off_rounded,
    AiState.idle      => Icons.pause_circle_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: DetSizes.lg, vertical: DetSizes.sm + 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(color: _color.withValues(alpha: 0.3), width: DetSizes.borderWidth),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.2 * pulseAnim.value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _color.withValues(alpha: 0.4), blurRadius: 8),
                ],
              ),
              child: Icon(_icon, size: 16, color: _color),
            ),
          ),

          const SizedBox(width: DetSizes.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.label.toUpperCase(),
                  style: DetTextStyles.caption.copyWith(
                    color: _color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  state == AiState.thinking
                      ? 'AlternIA réfléchit avec le programme malien…'
                      : state == AiState.speaking
                          ? 'Synthèse vocale Socratique en cours…'
                          : 'Écoute active du micro DetAI…',
                  style: DetTextStyles.codeSm.copyWith(color: DetColors.textSecondary),
                ),
              ],
            ),
          ),

          if (state == AiState.thinking)
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: DetColors.accentCyan),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FUTURISTIC TRANSCRIPT FEED
// ══════════════════════════════════════════════════════════════════════════════

class _FuturisticTranscriptFeed extends StatelessWidget {
  const _FuturisticTranscriptFeed({
    required this.messages,
    required this.scrollCtrl,
    required this.isConnected,
  });

  final List<SessionMessage> messages;
  final ScrollController     scrollCtrl;
  final bool                 isConnected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(DetSizes.lg),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isAi    = message.speaker == Speaker.ai;

        return Padding(
          padding: const EdgeInsets.only(bottom: DetSizes.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isAi) ...[
                _CyberAvatar(label: 'AI', color: DetColors.accentGreen),
                const SizedBox(width: DetSizes.sm),
              ],

              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(DetSizes.md),
                  decoration: BoxDecoration(
                    color: isAi ? DetColors.surface : DetColors.surfaceAlt,
                    borderRadius: BorderRadius.only(
                      topLeft:     Radius.circular(isAi ? 2 : DetSizes.radiusLg),
                      topRight:    Radius.circular(isAi ? DetSizes.radiusLg : 2),
                      bottomLeft:  const Radius.circular(DetSizes.radiusLg),
                      bottomRight: const Radius.circular(DetSizes.radiusLg),
                    ),
                    border: Border.all(
                      color: isAi
                          ? DetColors.accentGreen.withValues(alpha: 0.35)
                          : DetColors.accentOrange.withValues(alpha: 0.35),
                      width: DetSizes.borderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isAi ? DetColors.accentGreen : DetColors.accentOrange).withValues(alpha: 0.05),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isAi ? 'DetAI • SOCRATIC CORE' : 'ÉLÈVE',
                            style: DetTextStyles.caption.copyWith(
                              color: isAi ? DetColors.accentGreen : DetColors.accentOrange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: DetSizes.sm),
                          Text(
                            _formatTime(message.timestamp),
                            style: DetTextStyles.caption.copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                      const SizedBox(height: DetSizes.xs),
                      Text(
                        message.content,
                        style: isAi
                            ? DetTextStyles.codeMd.copyWith(color: DetColors.textPrimary)
                            : DetTextStyles.bodyMd.copyWith(color: DetColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),

              if (!isAi) ...[
                const SizedBox(width: DetSizes.sm),
                _CyberAvatar(label: 'TU', color: DetColors.accentOrange),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _CyberAvatar extends StatelessWidget {
  const _CyberAvatar({required this.label, required this.color});
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: DetSizes.borderRadiusSm,
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: DetTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CYBER CONSOLE INPUT
// ══════════════════════════════════════════════════════════════════════════════

class _CyberConsoleInput extends StatefulWidget {
  const _CyberConsoleInput({required this.onSend});
  final ValueChanged<String> onSend;

  @override
  State<_CyberConsoleInput> createState() => _CyberConsoleInputState();
}

class _CyberConsoleInputState extends State<_CyberConsoleInput> {
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textCtrl.text;
    if (text.trim().isEmpty) return;
    widget.onSend(text);
    _textCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DetSizes.md),
      decoration: BoxDecoration(
        color: DetColors.surface.withValues(alpha: 0.9),
        border: const Border(
          top: BorderSide(color: DetColors.border, width: DetSizes.borderWidth),
        ),
      ),
      child: Column(
        children: [
          // Chips de suggestions Socratiques rapides
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickChip(
                  label: '📐 Mathématiques',
                  onTap: () => widget.onSend('Comment résoudre une équation de second degré ?'),
                ),
                const SizedBox(width: 6),
                _QuickChip(
                  label: '⚡ Physique',
                  onTap: () => widget.onSend('Explique-moi la relation fondamentale de la dynamique.'),
                ),
                const SizedBox(width: 6),
                _QuickChip(
                  label: '🧬 SVT',
                  onTap: () => widget.onSend('Quel est le rôle de la réplication de l\'ADN ?'),
                ),
                const SizedBox(width: 6),
                _QuickChip(
                  label: '💡 Indice socratique',
                  onTap: () => widget.onSend('Donne-moi un premier indice pour commencer.'),
                ),
              ],
            ),
          ),

          const SizedBox(height: DetSizes.md),

          // Saisie console
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  style: DetTextStyles.bodyMd.copyWith(color: DetColors.textPrimary),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Pose ta question au Professeur AlternIA…',
                    hintStyle: DetTextStyles.bodySm.copyWith(color: DetColors.textMuted),
                    filled: true,
                    fillColor: DetColors.surfaceAlt,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DetSizes.md,
                      vertical: DetSizes.sm + 2,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: DetSizes.borderRadiusMd,
                      borderSide: const BorderSide(color: DetColors.border, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: DetSizes.borderRadiusMd,
                      borderSide: const BorderSide(color: DetColors.accentGreen, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DetSizes.sm),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _submit();
                },
                child: Container(
                  height: 48, width: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AltaColors.primary, AltaColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: DetSizes.borderRadiusMd,
                    boxShadow: const [
                      BoxShadow(color: DetColors.accentGreen, blurRadius: 8),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    size: 20,
                    color: DetColors.background,
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

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String       label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: DetColors.surfaceAlt,
          borderRadius: DetSizes.borderRadiusSm,
          border: Border.all(color: DetColors.border, width: 1),
        ),
        child: Text(label, style: DetTextStyles.caption.copyWith(color: DetColors.textSecondary)),
      ),
    );
  }
}

class _CyberGridBackgroundPainter extends CustomPainter {
  const _CyberGridBackgroundPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
