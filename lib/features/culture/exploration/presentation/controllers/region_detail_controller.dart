import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/region_detail_data.dart';
import '../../data/repositories/culture_repository.dart';

/// État pour l'écran de détail d'une région
class RegionDetailState {
  final AsyncValue<RegionDetailData> detailAsync;
  final bool isBookmarked;
  final String? currentlyPlayingTestimonyId;
  final bool isAudioPlaying;

  const RegionDetailState({
    required this.detailAsync,
    this.isBookmarked = false,
    this.currentlyPlayingTestimonyId,
    this.isAudioPlaying = false,
  });

  RegionDetailState copyWith({
    AsyncValue<RegionDetailData>? detailAsync,
    bool? isBookmarked,
    String? Function()? currentlyPlayingTestimonyId,
    bool? isAudioPlaying,
  }) {
    return RegionDetailState(
      detailAsync: detailAsync ?? this.detailAsync,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      currentlyPlayingTestimonyId: currentlyPlayingTestimonyId != null
          ? currentlyPlayingTestimonyId()
          : this.currentlyPlayingTestimonyId,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
    );
  }
}

/// Notifier pour la page d'immersion régionale
class RegionDetailNotifier extends StateNotifier<RegionDetailState> {
  final CultureRepository _repository;
  final String regionId;

  RegionDetailNotifier(this._repository, this.regionId)
      : super(const RegionDetailState(detailAsync: AsyncValue.loading())) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    state = state.copyWith(detailAsync: const AsyncValue.loading());
    try {
      final detail = await _repository.getRegionDetailData(regionId);
      if (detail != null) {
        state = state.copyWith(detailAsync: AsyncValue.data(detail));
      } else {
        state = state.copyWith(
          detailAsync: AsyncValue.error(
            'Région introuvable ($regionId)',
            StackTrace.current,
          ),
        );
      }
    } catch (e, st) {
      state = state.copyWith(detailAsync: AsyncValue.error(e, st));
    }
  }

  /// Active/Désactive le signet/favori
  void toggleBookmark() {
    state = state.copyWith(isBookmarked: !state.isBookmarked);
  }

  /// Simule la lecture / pause d'un récit audio
  void toggleAudio(String testimonyId) {
    if (state.currentlyPlayingTestimonyId == testimonyId && state.isAudioPlaying) {
      // Pause
      state = state.copyWith(isAudioPlaying: false);
    } else {
      // Jouer ce témoignage
      state = state.copyWith(
        currentlyPlayingTestimonyId: () => testimonyId,
        isAudioPlaying: true,
      );
    }
  }

  void stopAudio() {
    state = state.copyWith(
      currentlyPlayingTestimonyId: () => null,
      isAudioPlaying: false,
    );
  }
}

/// Provider dynamique basé sur l'identifiant de région
final regionDetailProvider = StateNotifierProvider.autoDispose
    .family<RegionDetailNotifier, RegionDetailState, String>((ref, regionId) {
  final repository = ref.watch(cultureRepositoryProvider);
  return RegionDetailNotifier(repository, regionId);
});
