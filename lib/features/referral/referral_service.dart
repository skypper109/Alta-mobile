import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../profile/user_prefs_notifier.dart';

class ReferralHistoryItem {
  final String id;
  final String statut;
  final String? date;

  const ReferralHistoryItem({
    required this.id,
    required this.statut,
    this.date,
  });

  factory ReferralHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryItem(
      id: json['id'] as String? ?? '',
      statut: json['statut'] as String? ?? 'VALIDE',
      date: json['date'] as String?,
    );
  }
}

class ReferralState {
  final String code;
  final String lienPartage;
  final int totalFilleuls;
  final int filleulsActifs;
  final int piecesGagnees;
  final int seuilRequisPremium;
  final double progressionRatio;
  final int restePourPremium;
  final int recompenseParFilleul;
  final List<ReferralHistoryItem> historique;
  final bool isLoading;
  final String? error;

  const ReferralState({
    this.code = 'DIA-240',
    this.lienPartage = 'https://alterniamali.com/rejoindre?ref=DIA-240',
    this.totalFilleuls = 0,
    this.filleulsActifs = 0,
    this.piecesGagnees = 0,
    this.seuilRequisPremium = 5,
    this.progressionRatio = 0.0,
    this.restePourPremium = 5,
    this.recompenseParFilleul = 50,
    this.historique = const [],
    this.isLoading = false,
    this.error,
  });

  ReferralState copyWith({
    String? code,
    String? lienPartage,
    int? totalFilleuls,
    int? filleulsActifs,
    int? piecesGagnees,
    int? seuilRequisPremium,
    double? progressionRatio,
    int? restePourPremium,
    int? recompenseParFilleul,
    List<ReferralHistoryItem>? historique,
    bool? isLoading,
    String? error,
  }) {
    return ReferralState(
      code: code ?? this.code,
      lienPartage: lienPartage ?? this.lienPartage,
      totalFilleuls: totalFilleuls ?? this.totalFilleuls,
      filleulsActifs: filleulsActifs ?? this.filleulsActifs,
      piecesGagnees: piecesGagnees ?? this.piecesGagnees,
      seuilRequisPremium: seuilRequisPremium ?? this.seuilRequisPremium,
      progressionRatio: progressionRatio ?? this.progressionRatio,
      restePourPremium: restePourPremium ?? this.restePourPremium,
      recompenseParFilleul: recompenseParFilleul ?? this.recompenseParFilleul,
      historique: historique ?? this.historique,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReferralNotifier extends StateNotifier<ReferralState> {
  final Ref _ref;
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 4)));

  ReferralNotifier(this._ref) : super(const ReferralState()) {
    fetchSummary();
  }

  String get _studentId {
    final name = _ref.read(userPrefsProvider).name.trim();
    return name.isNotEmpty ? name : 'eleve_defaut';
  }

  String get _studentName {
    final name = _ref.read(userPrefsProvider).name.trim();
    return name.isNotEmpty ? name : 'Élève';
  }

  Future<void> fetchSummary() async {
    state = state.copyWith(isLoading: true, error: null);
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.get(
          '$base/api/parrainage/summary',
          queryParameters: {
            'student_id': _studentId,
            'student_name': _studentName,
          },
        );
        if (res.statusCode == 200 && res.data is Map) {
          AltaApiConfig.setActiveBaseUrl(base);
          final d = res.data as Map<String, dynamic>;
          final hist = (d['historique_filleuls'] as List? ?? [])
              .map((e) => ReferralHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList();

          state = state.copyWith(
            code: d['code'] as String? ?? state.code,
            lienPartage: d['lien_partage'] as String? ?? state.lienPartage,
            totalFilleuls: (d['total_filleuls'] as num?)?.toInt() ?? 0,
            filleulsActifs: (d['filleuls_actifs'] as num?)?.toInt() ?? 0,
            piecesGagnees: (d['pieces_gagnees'] as num?)?.toInt() ?? 0,
            seuilRequisPremium: (d['seuil_requis_premium'] as num?)?.toInt() ?? 5,
            progressionRatio: (d['progression_ratio'] as num?)?.toDouble() ?? 0.0,
            restePourPremium: (d['reste_pour_premium'] as num?)?.toInt() ?? 5,
            recompenseParFilleul: (d['recompense_par_filleul'] as num?)?.toInt() ?? 50,
            historique: hist,
            isLoading: false,
          );
          return;
        }
      } catch (_) {}
    }
    state = state.copyWith(isLoading: false);
  }

  Future<bool> redeemReferralCode(String code) async {
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.post(
          '$base/api/parrainage/valider',
          data: {
            'filleul_id': _studentId,
            'code_parrainage': code.trim().toUpperCase(),
          },
        );
        if (res.statusCode == 200) {
          AltaApiConfig.setActiveBaseUrl(base);
          await fetchSummary();
          return true;
        }
      } catch (e) {
        if (e is DioException && e.response?.data is Map) {
          final detail = e.response?.data['detail'] as String?;
          state = state.copyWith(error: detail ?? 'Code invalide ou déjà utilisé.');
        }
      }
    }
    return false;
  }
}

final referralProvider = StateNotifierProvider<ReferralNotifier, ReferralState>((ref) {
  return ReferralNotifier(ref);
});
