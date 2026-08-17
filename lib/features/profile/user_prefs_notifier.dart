// ─── DetAI — Core: User Preferences & Class Level State (Système Malien) ──────
// Gestion permanente du nom, du niveau scolaire malien et de l'état d'onboarding.
library;

import 'package:alternia/core/malian_school_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileState {
  const UserProfileState({
    required this.name,
    required this.studentClassId,
    required this.hasCompletedOnboarding,
    required this.isLoading,
  });

  final String name;

  /// Identifiant de la classe malienne ('10eme', '11eme_ses', 'tse', etc.)
  final String studentClassId;

  final bool hasCompletedOnboarding;
  final bool isLoading;

  /// Accès rapide à l'objet complet MalianClass
  MalianClass? get malianClass => classById(studentClassId);

  /// Libellé court affiché dans les badges (ex: 'TSE')
  String get classShortLabel =>
      malianClass?.shortLabel ?? studentClassId.toUpperCase();

  /// Libellé complet (ex: 'TSE — Terminale Science Exacte')
  String get classFullLabel => malianClass?.label ?? studentClassId;

  /// Matières de la classe
  List<String> get subjects => malianClass?.subjects ?? [];

  UserProfileState copyWith({
    String? name,
    String? studentClassId,
    bool? hasCompletedOnboarding,
    bool? isLoading,
  }) {
    return UserProfileState(
      name: name ?? this.name,
      studentClassId: studentClassId ?? this.studentClassId,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserPrefsNotifier extends StateNotifier<UserProfileState> {
  UserPrefsNotifier()
      : super(const UserProfileState(
          name: '',
          studentClassId: defaultClassId,
          hasCompletedOnboarding: false,
          isLoading: true,
        )) {
    _loadFromPrefs();
  }

  static const String _keyName = 'det_user_name';
  static const String _keyClassId = 'det_user_class_id';
  static const String _keyOnboarding = 'det_user_onboarding_completed';

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_keyName) ?? '';
      final classId = prefs.getString(_keyClassId) ?? defaultClassId;
      final hasCompleted = prefs.getBool(_keyOnboarding) ?? false;

      state = UserProfileState(
        name: name,
        studentClassId: classId,
        hasCompletedOnboarding: hasCompleted,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> saveRegistration({
    required String name,
    required String classId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyName, name.trim());
      await prefs.setString(_keyClassId, classId.trim());
      await prefs.setBool(_keyOnboarding, true);

      state = UserProfileState(
        name: name.trim(),
        studentClassId: classId.trim(),
        hasCompletedOnboarding: true,
        isLoading: false,
      );
    } catch (_) {}
  }

  Future<void> updateClass(String newClassId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyClassId, newClassId.trim());
      state = state.copyWith(studentClassId: newClassId.trim());
    } catch (_) {}
  }

  Future<void> updateName(String newName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyName, newName.trim());
      state = state.copyWith(name: newName.trim());
    } catch (_) {}
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboarding, false);
      state = state.copyWith(hasCompletedOnboarding: false);
    } catch (_) {}
  }
}

final userPrefsProvider =
    StateNotifierProvider<UserPrefsNotifier, UserProfileState>((ref) {
  return UserPrefsNotifier();
});
