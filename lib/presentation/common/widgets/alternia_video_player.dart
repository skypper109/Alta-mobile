import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_colors.dart';

class AlterniaVideoPlayer extends StatefulWidget {
  const AlterniaVideoPlayer({
    super.key,
    required this.videoUrl,
    this.fallbackImagePath,
    this.onTap,
    this.onError,
    this.onCompleted,
  });

  final String videoUrl;
  final String? fallbackImagePath;
  final VoidCallback? onTap;
  final VoidCallback? onError;
  final VoidCallback? onCompleted;

  @override
  State<AlterniaVideoPlayer> createState() => _AlterniaVideoPlayerState();
}

class _AlterniaVideoPlayerState extends State<AlterniaVideoPlayer> {
  VideoPlayerController? _videoCtrl;
  Timer? _initTimeoutTimer;
  bool _hasError = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(AlterniaVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      _initVideo();
    }
  }

  void _initVideo() {
    _initTimeoutTimer?.cancel();
    _videoCtrl?.removeListener(_onVideoUpdate);
    _videoCtrl?.dispose();
    _videoCtrl = null;
    _hasError = false;
    _isCompleted = false;

    // Timeout de sécurité de 5 secondes : si la vidéo ne peut pas se charger, basculer sur l'avatar
    _initTimeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && (_videoCtrl == null || !_videoCtrl!.value.isInitialized)) {
        debugPrint('[AlterniaVideoPlayer] Timeout chargement vidéo (5s) → bascule avatar');
        setState(() => _hasError = true);
        widget.onError?.call();
      }
    });

    try {
      _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..initialize().then((_) {
          _initTimeoutTimer?.cancel();
          if (!mounted) return;
          _videoCtrl?.addListener(_onVideoUpdate);
          _videoCtrl?.setVolume(1.0);
          _videoCtrl?.setLooping(false);
          _videoCtrl?.play();
          setState(() {});
        }).catchError((e) {
          _initTimeoutTimer?.cancel();
          debugPrint('[AlterniaVideoPlayer] Erreur lecture vidéo Simli: $e');
          if (mounted) {
            setState(() => _hasError = true);
            widget.onError?.call();
          }
        });
    } catch (e) {
      _initTimeoutTimer?.cancel();
      debugPrint('[AlterniaVideoPlayer] Exception contrôleur: $e');
      setState(() => _hasError = true);
      widget.onError?.call();
    }
  }

  void _onVideoUpdate() {
    if (_videoCtrl != null && _videoCtrl!.value.isInitialized) {
      final pos = _videoCtrl!.value.position;
      final dur = _videoCtrl!.value.duration;
      if (dur > Duration.zero && pos >= dur && !_isCompleted) {
        _isCompleted = true;
        widget.onCompleted?.call();
      }
    }
  }

  @override
  void dispose() {
    _initTimeoutTimer?.cancel();
    _videoCtrl?.removeListener(_onVideoUpdate);
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si la vidéo a échoué ou n'est pas encore initialisée
    if (_hasError || _videoCtrl == null || !_videoCtrl!.value.isInitialized) {
      return Container(
        height: 220,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.fallbackImagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Image.asset(
                  widget.fallbackImagePath!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Préparation du flux Simli…',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap ?? () {
        if (_videoCtrl != null && _videoCtrl!.value.isInitialized) {
          if (_videoCtrl!.value.isPlaying) {
            _videoCtrl!.pause();
          } else {
            if (_videoCtrl!.value.position >= _videoCtrl!.value.duration) {
              _videoCtrl!.seekTo(Duration.zero);
            }
            _videoCtrl!.play();
          }
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: _videoCtrl!.value.aspectRatio,
          child: VideoPlayer(_videoCtrl!),
        ),
      ),
    );
  }
}
