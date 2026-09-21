import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../exploration/data/datasources/mock_mali_regions.dart';
import '../../exploration/data/models/mali_region.dart';

/// État du filtre régional transversal de Culture
class CultureFilterState {
  final MaliRegion? activeRegion;

  const CultureFilterState({this.activeRegion});

  bool get hasActiveFilter => activeRegion != null;
  String get displayName => activeRegion != null ? activeRegion!.nom : 'Tout le Mali';
  String? get activeRegionId => activeRegion?.id;

  CultureFilterState copyWith({
    MaliRegion? Function()? activeRegion,
  }) {
    return CultureFilterState(
      activeRegion: activeRegion != null ? activeRegion() : this.activeRegion,
    );
  }
}

/// Notifier Riverpod pour piloter la région sélectionnée
class CultureFilterNotifier extends StateNotifier<CultureFilterState> {
  CultureFilterNotifier() : super(const CultureFilterState());

  void selectRegion(MaliRegion? region) {
    state = state.copyWith(activeRegion: () => region);
  }

  void selectRegionById(String? regionId) {
    if (regionId == null || regionId.isEmpty || regionId == 'all') {
      clearFilter();
      return;
    }
    try {
      final region = MockMaliRegions.regions.firstWhere((r) => r.id == regionId);
      state = state.copyWith(activeRegion: () => region);
    } catch (_) {
      clearFilter();
    }
  }

  void toggleRegion(MaliRegion region) {
    if (state.activeRegion?.id == region.id) {
      clearFilter();
    } else {
      selectRegion(region);
    }
  }

  void clearFilter() {
    state = state.copyWith(activeRegion: () => null);
  }
}

/// Provider global pour la région active de Culture
final activeCultureRegionProvider =
    StateNotifierProvider<CultureFilterNotifier, CultureFilterState>((ref) {
  return CultureFilterNotifier();
});
