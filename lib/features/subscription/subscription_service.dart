import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../profile/user_prefs_notifier.dart';

class SubscriptionOfferItem {
  final String id;
  final String titre;
  final String description;
  final int prixFcfa;
  final String prixFcfaLabel;
  final int dureeJours;
  final List<String> avantages;

  const SubscriptionOfferItem({
    required this.id,
    required this.titre,
    required this.description,
    required this.prixFcfa,
    required this.prixFcfaLabel,
    required this.dureeJours,
    required this.avantages,
  });

  factory SubscriptionOfferItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionOfferItem(
      id: json['id'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      prixFcfa: (json['prix_fcfa'] as num?)?.toInt() ?? 0,
      prixFcfaLabel: json['prix_fcfa_label'] as String? ?? '0 FCFA',
      dureeJours: (json['duree_jours'] as num?)?.toInt() ?? 30,
      avantages: (json['avantages'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class SubscriptionState {
  final bool estPremium;
  final String statut;
  final String offreTitre;
  final int joursRestants;
  final String? dateExpiration;
  final String message;
  final List<SubscriptionOfferItem> offres;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.estPremium = false,
    this.statut = 'STANDARD',
    this.offreTitre = 'Formule Gratuite',
    this.joursRestants = 0,
    this.dateExpiration,
    this.message = 'Compte standard',
    this.offres = const [],
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    bool? estPremium,
    String? statut,
    String? offreTitre,
    int? joursRestants,
    String? dateExpiration,
    String? message,
    List<SubscriptionOfferItem>? offres,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      estPremium: estPremium ?? this.estPremium,
      statut: statut ?? this.statut,
      offreTitre: offreTitre ?? this.offreTitre,
      joursRestants: joursRestants ?? this.joursRestants,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      message: message ?? this.message,
      offres: offres ?? this.offres,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final Ref _ref;
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 4)));

  SubscriptionNotifier(this._ref) : super(const SubscriptionState()) {
    refresh();
  }

  String get _studentId {
    final name = _ref.read(userPrefsProvider).name.trim();
    return name.isNotEmpty ? name : 'eleve_defaut';
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.wait([
      fetchStatus(),
      fetchOffres(),
    ]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> fetchStatus() async {
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.get(
          '$base/api/abonnements/status',
          queryParameters: {'student_id': _studentId},
        );
        if (res.statusCode == 200 && res.data is Map) {
          final d = res.data as Map<String, dynamic>;
          state = state.copyWith(
            estPremium: d['est_premium'] as bool? ?? false,
            statut: d['statut'] as String? ?? 'STANDARD',
            offreTitre: d['offre_titre'] as String? ?? 'Formule Gratuite',
            joursRestants: (d['jours_restants'] as num?)?.toInt() ?? 0,
            dateExpiration: d['date_expiration'] as String?,
            message: d['message'] as String? ?? '',
          );
          return;
        }
      } catch (_) {}
    }
  }

  Future<void> fetchOffres() async {
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.get('$base/api/abonnements/offres');
        if (res.statusCode == 200 && res.data is List) {
          final list = (res.data as List)
              .map((e) => SubscriptionOfferItem.fromJson(e as Map<String, dynamic>))
              .toList();
          state = state.copyWith(offres: list);
          return;
        }
      } catch (_) {}
    }
  }

  Future<bool> subscribe(String offreId) async {
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.post(
          '$base/api/abonnements/souscrire',
          data: {
            'apprenant_id': _studentId,
            'offre_id': offreId,
            'moyen_paiement': 'MOBILE_MONEY',
          },
        );
        if (res.statusCode == 200) {
          await refresh();
          return true;
        }
      } catch (e) {
        if (e is DioException && e.response?.data is Map) {
          final detail = e.response?.data['detail'] as String?;
          state = state.copyWith(error: detail ?? 'Erreur lors de la souscription.');
        }
      }
    }
    return false;
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref);
});
