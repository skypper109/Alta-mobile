import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/culture_repository.dart';
import '../models/culture_detail_models.dart';
import '../models/culture_item.dart';

// ══════════════════════════════════════════════════════════════════════════════
// PROVIDERS DE DONNÉES CULTURELLES ALIMENTÉS PAR LA BASE DE DONNÉES CENTRALE
// ══════════════════════════════════════════════════════════════════════════════

/// Provider asynchrone des Monuments depuis la base de données
final cultureMonumentsProvider = FutureProvider<List<CultureItem>>((ref) async {
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.getMonumentsAsCultureItems();
});

/// Provider asynchrone des Grands Personnages depuis la base de données
final cultureFiguresProvider = FutureProvider<List<CultureItem>>((ref) async {
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.getFiguresAsCultureItems();
});

/// Provider asynchrone des Villes et Terroirs depuis la base de données
final cultureVillesProvider = FutureProvider<List<CultureItem>>((ref) async {
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.getPlacesAsCultureItems();
});

/// Provider asynchrone des Contes depuis la base de données
final cultureStoriesProvider = FutureProvider<List<CultureItem>>((ref) async {
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.getStoriesAsCultureItems();
});

/// Provider asynchrone des Défis et Devinettes depuis la base de données
final cultureDefisProvider = FutureProvider<List<CultureItem>>((ref) async {
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.getDefisAsCultureItems();
});

/// Provider asynchrone de l'élément à la une (Accueil)
final cultureFeaturedItemProvider = FutureProvider<CultureItem?>((ref) async {
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.getFeaturedItem();
});

/// Provider asynchrone de la fiche détaillée d'un Monument
final monumentDetailProvider = FutureProvider.family<MonumentDetail?, String>((ref, id) async {
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.getMonumentDetail(id);
});

/// Provider asynchrone de la fiche détaillée d'un Personnage Historique
final historicalFigureDetailProvider = FutureProvider.family<HistoricalFigureDetail?, String>((ref, id) async {
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.getFigureDetail(id);
});

/// Provider asynchrone de la fiche détaillée d'une Ville ou Terroir
final placeDetailProvider = FutureProvider.family<PlaceDetail?, String>((ref, id) async {
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.getPlaceDetail(id);
});
