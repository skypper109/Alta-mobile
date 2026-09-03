import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrôleur gérant l'affichage du portail immersif Culture
class CultureIntroController extends StateNotifier<bool> {
  static const String _prefKey = 'culture_portal_intro_completed_v1';

  CultureIntroController() : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_prefKey) ?? false;
    } catch (_) {
      state = false;
    }
  }

  /// Marque l'introduction immersive comme complétée
  Future<void> markAsSeen() async {
    state = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);
    } catch (_) {}
  }

  /// Réinitialise l'intro pour la revivre à volonté
  Future<void> replayIntro() async {
    state = false;
  }
}

/// Provider Riverpod de l'état du portail d'introduction Culture
final cultureIntroControllerProvider =
    StateNotifierProvider<CultureIntroController, bool>((ref) {
  return CultureIntroController();
});
