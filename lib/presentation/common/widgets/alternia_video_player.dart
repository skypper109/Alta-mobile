import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_colors.dart';

class AlterniaVideoPlayer extends StatefulWidget {
  const AlterniaVideoPlayer({
    super.key,
    required this.videoUrl,
    this.onTap,
  });

  final String videoUrl;
  final VoidCallback? onTap;

  @override
  State<AlterniaVideoPlayer> createState() => _AlterniaVideoPlayerState();
}

class _AlterniaVideoPlayerState extends State<AlterniaVideoPlayer> {
  VideoPlayerController? _videoCtrl;

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
    _videoCtrl?.dispose();
    _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _videoCtrl?.setVolume(1.0);
        _videoCtrl?.play();
        _videoCtrl?.setLooping(false);
        if (mounted) setState(() {});
      }).catchError((e) {
        debugPrint('Erreur lecture video Simli: $e');
      });
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoCtrl == null || !_videoCtrl!.value.isInitialized) {
      return Container(
        height: 250,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
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
