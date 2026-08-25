import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/mali_region.dart';
import '../../data/repositories/culture_repository.dart';

/// État du contrôleur d'exploration culturelle
class CultureExplorationState {
  final AsyncValue<List<MaliRegion>> regionsAsync;
  final MaliRegion? selectedRegion;
  final String searchQuery;

  const CultureExplorationState({
    required this.regionsAsync,
    this.selectedRegion,
    this.searchQuery = '',
  });

  bool get isLoading => regionsAsync.isLoading;
  bool get hasError => regionsAsync.hasError;
  List<MaliRegion> get regions => regionsAsync.valueOrNull ?? [];

  List<MaliRegion> get filteredRegions {
    if (searchQuery.trim().isEmpty) return regions;
    final query = searchQuery.trim().toLowerCase();
    return regions.where((r) {
      return r.nom.toLowerCase().contains(query) ||
          r.surnom.toLowerCase().contains(query) ||
          r.chefLieu.toLowerCase().contains(query) ||
          r.pointsForts.any((p) => p.toLowerCase().contains(query));
    }).toList();
  }

  CultureExplorationState copyWith({
    AsyncValue<List<MaliRegion>>? regionsAsync,
    MaliRegion? Function()? selectedRegion,
    String? searchQuery,
  }) {
    return CultureExplorationState(
      regionsAsync: regionsAsync ?? this.regionsAsync,
      selectedRegion:
          selectedRegion != null ? selectedRegion() : this.selectedRegion,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier Riverpod gérant la logique d'exploration des régions
class CultureExplorationNotifier extends StateNotifier<CultureExplorationState> {
  final CultureRepository _repository;

  CultureExplorationNotifier(this._repository)
      : super(const CultureExplorationState(regionsAsync: AsyncValue.loading())) {
    loadRegions();
  }

  /// Charge les régions depuis le Repository
  Future<void> loadRegions() async {
    state = state.copyWith(regionsAsync: const AsyncValue.loading());
    try {
      final regions = await _repository.getRegions();
      state = state.copyWith(
        regionsAsync: AsyncValue.data(regions),
        // Par défaut, aucune région sélectionnée pour inciter à l'exploration
        selectedRegion: () => null,
      );
    } catch (e, st) {
      state = state.copyWith(
        regionsAsync: AsyncValue.error(e, st),
      );
    }
  }

  /// Sélectionne une région par son identifiant ou la désélectionne si déjà active
  void selectRegion(String? id) {
    if (id == null) {
      state = state.copyWith(selectedRegion: () => null);
      return;
    }

    final currentSelectedId = state.selectedRegion?.id;
    if (currentSelectedId == id) {
      // Toggle désélection si tap à nouveau sur la même région
      state = state.copyWith(selectedRegion: () => null);
      return;
    }

    final found = state.regions.where((r) => r.id == id).firstOrNull;
    state = state.copyWith(selectedRegion: () => found);
  }

  /// Met à jour la recherche
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Réinitialise la sélection
  void clearSelection() {
    state = state.copyWith(selectedRegion: () => null);
  }
}

/// Provider pour le contrôleur d'exploration
final cultureExplorationProvider =
    StateNotifierProvider<CultureExplorationNotifier, CultureExplorationState>((ref) {
  final repository = ref.watch(cultureRepositoryProvider);
  return CultureExplorationNotifier(repository);
});
