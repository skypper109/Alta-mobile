import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../profile/user_prefs_notifier.dart';

class WalletTransactionItem {
  final String id;
  final int montant;
  final String montantLabel;
  final int valeurFcfa;
  final String typeOperation;
  final String origine;
  final String description;
  final int soldeApres;
  final String? date;

  const WalletTransactionItem({
    required this.id,
    required this.montant,
    required this.montantLabel,
    required this.valeurFcfa,
    required this.typeOperation,
    required this.origine,
    required this.description,
    required this.soldeApres,
    this.date,
  });

  factory WalletTransactionItem.fromJson(Map<String, dynamic> json) {
    return WalletTransactionItem(
      id: json['id'] as String? ?? '',
      montant: (json['montant'] as num?)?.toInt() ?? 0,
      montantLabel: json['montant_label'] as String? ?? '0',
      valeurFcfa: (json['valeur_fcfa'] as num?)?.toInt() ?? 0,
      typeOperation: json['type_operation'] as String? ?? 'CREDIT',
      origine: json['origine'] as String? ?? '',
      description: json['description'] as String? ?? '',
      soldeApres: (json['solde_apres'] as num?)?.toInt() ?? 0,
      date: json['date'] as String?,
    );
  }
}

class WithdrawalRequestItem {
  final String id;
  final String ref;
  final int pieces;
  final int montantFcfa;
  final String montantFcfaLabel;
  final String operateur;
  final String operateurLabel;
  final String numeroTelephone;
  final String nomTitulaire;
  final String statut;
  final String? motifRejet;
  final String? dateDemande;
  final String? datePaiement;

  const WithdrawalRequestItem({
    required this.id,
    required this.ref,
    required this.pieces,
    required this.montantFcfa,
    required this.montantFcfaLabel,
    required this.operateur,
    required this.operateurLabel,
    required this.numeroTelephone,
    required this.nomTitulaire,
    required this.statut,
    this.motifRejet,
    this.dateDemande,
    this.datePaiement,
  });

  factory WithdrawalRequestItem.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequestItem(
      id: json['id'] as String? ?? '',
      ref: json['ref'] as String? ?? '',
      pieces: (json['pieces'] as num?)?.toInt() ?? 0,
      montantFcfa: (json['montant_fcfa'] as num?)?.toInt() ?? 0,
      montantFcfaLabel: json['montant_fcfa_label'] as String? ?? '0 FCFA',
      operateur: json['operateur'] as String? ?? '',
      operateurLabel: json['operateur_label'] as String? ?? '',
      numeroTelephone: json['numero_telephone'] as String? ?? '',
      nomTitulaire: json['nom_titulaire'] as String? ?? '',
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
      motifRejet: json['motif_rejet'] as String?,
      dateDemande: json['date_demande'] as String?,
      datePaiement: json['date_paiement'] as String?,
    );
  }
}

class WalletState {
  final int soldePieces;
  final String soldePiecesLabel;
  final int valeurFcfa;
  final String valeurFcfaLabel;
  final int piecesReservees;
  final int piecesRetireesTotal;
  final int tauxConversion;
  final int seuilMinimal;
  final bool isLoading;
  final List<WalletTransactionItem> transactions;
  final List<WithdrawalRequestItem> demandesRetrait;
  final String? error;

  const WalletState({
    this.soldePieces = 0,
    this.soldePiecesLabel = '0',
    this.valeurFcfa = 0,
    this.valeurFcfaLabel = '0 FCFA',
    this.piecesReservees = 0,
    this.piecesRetireesTotal = 0,
    this.tauxConversion = 2,
    this.seuilMinimal = 100,
    this.isLoading = false,
    this.transactions = const [],
    this.demandesRetrait = const [],
    this.error,
  });

  WalletState copyWith({
    int? soldePieces,
    String? soldePiecesLabel,
    int? valeurFcfa,
    String? valeurFcfaLabel,
    int? piecesReservees,
    int? piecesRetireesTotal,
    int? tauxConversion,
    int? seuilMinimal,
    bool? isLoading,
    List<WalletTransactionItem>? transactions,
    List<WithdrawalRequestItem>? demandesRetrait,
    String? error,
  }) {
    return WalletState(
      soldePieces: soldePieces ?? this.soldePieces,
      soldePiecesLabel: soldePiecesLabel ?? this.soldePiecesLabel,
      valeurFcfa: valeurFcfa ?? this.valeurFcfa,
      valeurFcfaLabel: valeurFcfaLabel ?? this.valeurFcfaLabel,
      piecesReservees: piecesReservees ?? this.piecesReservees,
      piecesRetireesTotal: piecesRetireesTotal ?? this.piecesRetireesTotal,
      tauxConversion: tauxConversion ?? this.tauxConversion,
      seuilMinimal: seuilMinimal ?? this.seuilMinimal,
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      demandesRetrait: demandesRetrait ?? this.demandesRetrait,
      error: error,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final Ref _ref;
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 4)));

  WalletNotifier(this._ref) : super(const WalletState()) {
    refreshAll();
  }

  String get _studentId {
    final name = _ref.read(userPrefsProvider).name.trim();
    return name.isNotEmpty ? name : 'eleve_defaut';
  }

  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.wait([
      fetchSummary(),
      fetchTransactions(),
      fetchWithdrawals(),
    ]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> fetchSummary() async {
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.get(
          '$base/api/wallet/summary',
          queryParameters: {'student_id': _studentId},
        );
        if (res.statusCode == 200 && res.data is Map) {
          AltaApiConfig.setActiveBaseUrl(base);
          final d = res.data as Map<String, dynamic>;
          state = state.copyWith(
            soldePieces: (d['solde_pieces'] as num?)?.toInt() ?? state.soldePieces,
            soldePiecesLabel: d['solde_pieces_label'] as String? ?? state.soldePiecesLabel,
            valeurFcfa: (d['valeur_fcfa'] as num?)?.toInt() ?? state.valeurFcfa,
            valeurFcfaLabel: d['valeur_fcfa_label'] as String? ?? state.valeurFcfaLabel,
            piecesReservees: (d['pieces_reservees'] as num?)?.toInt() ?? state.piecesReservees,
            piecesRetireesTotal: (d['pieces_retirees_total'] as num?)?.toInt() ?? state.piecesRetireesTotal,
            tauxConversion: (d['taux_conversion'] as num?)?.toInt() ?? 2,
            seuilMinimal: (d['seuil_minimal_retrait'] as num?)?.toInt() ?? 100,
          );
          break;
        }
      } catch (_) {}
    }
  }

  Future<void> fetchTransactions() async {
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.get(
          '$base/api/wallet/transactions',
          queryParameters: {'student_id': _studentId, 'limit': 30},
        );
        if (res.statusCode == 200 && res.data is List) {
          AltaApiConfig.setActiveBaseUrl(base);
          final list = (res.data as List)
              .map((e) => WalletTransactionItem.fromJson(e as Map<String, dynamic>))
              .toList();
          state = state.copyWith(transactions: list);
          break;
        }
      } catch (_) {}
    }
  }

  Future<void> fetchWithdrawals() async {
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.get(
          '$base/api/retraits/mes-demandes',
          queryParameters: {'apprenant_id': _studentId},
        );
        if (res.statusCode == 200 && res.data is List) {
          AltaApiConfig.setActiveBaseUrl(base);
          final list = (res.data as List)
              .map((e) => WithdrawalRequestItem.fromJson(e as Map<String, dynamic>))
              .toList();
          state = state.copyWith(demandesRetrait: list);
          break;
        }
      } catch (_) {}
    }
  }

  Future<bool> demandWithdrawal({
    required int pieces,
    required String operateur,
    required String numeroTelephone,
    required String nomTitulaire,
  }) async {
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.post(
          '$base/api/retraits/demande',
          data: {
            'apprenant_id': _studentId,
            'pieces': pieces,
            'operateur': operateur,
            'numero_telephone': numeroTelephone,
            'nom_titulaire': nomTitulaire,
          },
        );
        if (res.statusCode == 200) {
          AltaApiConfig.setActiveBaseUrl(base);
          await refreshAll();
          return true;
        }
      } catch (e) {
        if (e is DioException && e.response?.data is Map) {
          final detail = e.response?.data['detail'] as String?;
          state = state.copyWith(error: detail ?? 'Erreur lors de la demande de retrait.');
        }
      }
    }
    return false;
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref);
});
