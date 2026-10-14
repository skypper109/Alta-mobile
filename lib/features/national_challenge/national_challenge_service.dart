import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../profile/gamification_notifier.dart';
import '../profile/user_prefs_notifier.dart';
import '../wallet/wallet_service.dart';

class ChallengeQuestionItem {
  final String id;
  final String question;
  final List<String> options;

  const ChallengeQuestionItem({
    required this.id,
    required this.question,
    required this.options,
  });

  factory ChallengeQuestionItem.fromJson(Map<String, dynamic> json) {
    return ChallengeQuestionItem(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class NationalChallengeItem {
  final String id;
  final String titre;
  final String description;
  final String classe;
  final String matiere;
  final int dureeMinutes;
  final String? dateFin;
  final int recompensePremier;
  final int recompenseTop10;
  final int recompenseParticipation;
  final List<ChallengeQuestionItem> questions;

  const NationalChallengeItem({
    required this.id,
    required this.titre,
    required this.description,
    required this.classe,
    required this.matiere,
    required this.dureeMinutes,
    this.dateFin,
    required this.recompensePremier,
    required this.recompenseTop10,
    required this.recompenseParticipation,
    required this.questions,
  });

  factory NationalChallengeItem.fromJson(Map<String, dynamic> json) {
    return NationalChallengeItem(
      id: json['id'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      classe: json['classe'] as String? ?? '12eme',
      matiere: json['matiere'] as String? ?? 'Général',
      dureeMinutes: (json['duree_minutes'] as num?)?.toInt() ?? 15,
      dateFin: json['date_fin'] as String?,
      recompensePremier: (json['recompense_premier'] as num?)?.toInt() ?? 500,
      recompenseTop10: (json['recompense_top10'] as num?)?.toInt() ?? 250,
      recompenseParticipation: (json['recompense_participation'] as num?)?.toInt() ?? 50,
      questions: (json['questions'] as List? ?? [])
          .map((e) => ChallengeQuestionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChallengeResultItem {
  final int score;
  final int totalQuestions;
  final int pourcentage;
  final int piecesGagnees;
  final int xpGagnes;
  final int tempsSecondes;
  final List<dynamic> corrections;

  const ChallengeResultItem({
    required this.score,
    required this.totalQuestions,
    required this.pourcentage,
    required this.piecesGagnees,
    required this.xpGagnes,
    required this.tempsSecondes,
    required this.corrections,
  });

  factory ChallengeResultItem.fromJson(Map<String, dynamic> json) {
    return ChallengeResultItem(
      score: (json['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      pourcentage: (json['pourcentage'] as num?)?.toInt() ?? 0,
      piecesGagnees: (json['pieces_gagnees'] as num?)?.toInt() ?? 0,
      xpGagnes: (json['xp_gagnes'] as num?)?.toInt() ?? 0,
      tempsSecondes: (json['temps_secondes'] as num?)?.toInt() ?? 0,
      corrections: json['corrections'] as List? ?? [],
    );
  }
}

class NationalChallengeState {
  final List<NationalChallengeItem> defis;
  final NationalChallengeItem? defiCourant;
  final ChallengeResultItem? dernierResultat;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const NationalChallengeState({
    this.defis = const [],
    this.defiCourant,
    this.dernierResultat,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  NationalChallengeState copyWith({
    List<NationalChallengeItem>? defis,
    NationalChallengeItem? defiCourant,
    ChallengeResultItem? dernierResultat,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return NationalChallengeState(
      defis: defis ?? this.defis,
      defiCourant: defiCourant ?? this.defiCourant,
      dernierResultat: dernierResultat ?? this.dernierResultat,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class NationalChallengeNotifier extends StateNotifier<NationalChallengeState> {
  final Ref _ref;
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 4)));

  NationalChallengeNotifier(this._ref) : super(const NationalChallengeState()) {
    fetchDefis();
  }

  String get _studentId {
    final name = _ref.read(userPrefsProvider).name.trim();
    return name.isNotEmpty ? name : 'eleve_defaut';
  }

  String get _studentName {
    final name = _ref.read(userPrefsProvider).name.trim();
    return name.isNotEmpty ? name : 'Élève';
  }

  String get _studentClass {
    return _ref.read(userPrefsProvider).studentClassId;
  }

  Future<void> fetchDefis({String? periode}) async {
    state = state.copyWith(isLoading: true, error: null);
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final queryParams = <String, dynamic>{'classe': _studentClass};
        if (periode != null && periode.isNotEmpty) {
          queryParams['periode'] = periode;
        }
        final res = await _dio.get(
          '$base/api/defi-national/actifs',
          queryParameters: queryParams,
        );
        if (res.statusCode == 200 && res.data is List) {
          final list = (res.data as List)
              .map((e) => NationalChallengeItem.fromJson(e as Map<String, dynamic>))
              .toList();
          state = state.copyWith(
            defis: list,
            defiCourant: list.isNotEmpty ? list.first : null,
            isLoading: false,
          );
          return;
        }
      } catch (_) {}
    }
    state = state.copyWith(isLoading: false);
  }

  Future<ChallengeResultItem?> soumettre({
    required String defiId,
    required Map<String, int> reponses,
    required int tempsSec,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.post(
          '$base/api/defi-national/soumettre',
          data: {
            'defi_id': defiId,
            'apprenant_id': _studentId,
            'apprenant_nom': _studentName,
            'apprenant_classe': _studentClass,
            'reponses': reponses,
            'temps_ecoule_sec': tempsSec,
          },
        );
        if (res.statusCode == 200 && res.data is Map) {
          final resItem = ChallengeResultItem.fromJson(res.data as Map<String, dynamic>);
          state = state.copyWith(
            dernierResultat: resItem,
            isSubmitting: false,
          );

          // Rafraîchir les pièces et l'XP
          _ref.read(walletProvider.notifier).refreshAll();
          _ref.read(gamificationProvider.notifier).addXp(resItem.xpGagnes);
          return resItem;
        }
      } catch (e) {
        if (e is DioException && e.response?.data is Map) {
          final detail = e.response?.data['detail'] as String?;
          state = state.copyWith(error: detail ?? 'Erreur lors de la soumission.');
        }
      }
    }
    state = state.copyWith(isSubmitting: false);
    return null;
  }
}

final nationalChallengeProvider =
    StateNotifierProvider<NationalChallengeNotifier, NationalChallengeState>((ref) {
  return NationalChallengeNotifier(ref);
});
