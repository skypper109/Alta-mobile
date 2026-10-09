// ─── AlterniA — Service de Synchronisation Asynchrone « Store & Forward » ────
// Garantit une résilience totale hors-ligne au Mali : toutes les actions (duels,
// flashcards, podcasts, points XP) sont conservées localement et synchronisées
// automatiquement dès qu'un réseau (Wi-Fi, données mobiles ou Boîtier AlternIA) est détecté.
library;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../constants/app_colors.dart';

enum SyncEventType {
  duelCompleted,
  flashcardReviewed,
  podcastListened,
  studyTimeLogged,
  classPreferenceChanged,
}

class SyncEvent {
  final String id;
  final SyncEventType type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final int retryCount;

  const SyncEvent({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncEvent.fromJson(Map<String, dynamic> json) => SyncEvent(
        id: json['id'] as String,
        type: SyncEventType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => SyncEventType.duelCompleted,
        ),
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        timestamp: DateTime.parse(json['timestamp'] as String),
        retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      );
}

class SyncQueueState {
  final List<SyncEvent> pendingEvents;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final String? lastSyncMessage;
  final bool isOnline;

  const SyncQueueState({
    this.pendingEvents = const [],
    this.isSyncing = false,
    this.lastSyncTime,
    this.lastSyncMessage,
    this.isOnline = false,
  });

  int get pendingCount => pendingEvents.length;
  bool get hasPending => pendingEvents.isNotEmpty;

  SyncQueueState copyWith({
    List<SyncEvent>? pendingEvents,
    bool? isSyncing,
    DateTime? lastSyncTime,
    String? lastSyncMessage,
    bool? isOnline,
  }) {
    return SyncQueueState(
      pendingEvents: pendingEvents ?? this.pendingEvents,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncMessage: lastSyncMessage ?? this.lastSyncMessage,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class SyncQueueNotifier extends StateNotifier<SyncQueueState> {
  SyncQueueNotifier() : super(const SyncQueueState()) {
    _loadFromStorage();
    _startPeriodicSyncTimer();
  }

  static const _storageKey = 'alternia_store_and_forward_queue';
  static const _lastSyncKey = 'alternia_store_and_forward_last_sync';
  final _dio = Dio();
  final _logger = Logger();
  Timer? _syncTimer;

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawQueue = prefs.getString(_storageKey);
      final rawLastSync = prefs.getString(_lastSyncKey);

      List<SyncEvent> events = [];
      if (rawQueue != null && rawQueue.isNotEmpty) {
        final decoded = jsonDecode(rawQueue) as List<dynamic>;
        events = decoded
            .map((e) => SyncEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      DateTime? lastSync;
      if (rawLastSync != null && rawLastSync.isNotEmpty) {
        lastSync = DateTime.tryParse(rawLastSync);
      }

      state = state.copyWith(
        pendingEvents: events,
        lastSyncTime: lastSync,
      );

      // Tentative de synchronisation initiale si des éléments sont en attente
      if (events.isNotEmpty) {
        syncNow();
      }
    } catch (e) {
      _logger.w('[SyncQueue] Erreur de chargement de la file d\'attente : $e');
    }
  }

  Future<void> _persistQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.pendingEvents.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
      if (state.lastSyncTime != null) {
        await prefs.setString(_lastSyncKey, state.lastSyncTime!.toIso8601String());
      }
    } catch (e) {
      _logger.e('[SyncQueue] Erreur de persistance de la file d\'attente : $e');
    }
  }

  /// Ajoute un événement dans la file d'attente hors-ligne et tente un envoi immédiat
  Future<void> enqueue(SyncEventType type, Map<String, dynamic> payload) async {
    final event = SyncEvent(
      id: 'sync_${DateTime.now().millisecondsSinceEpoch}_${state.pendingEvents.length}',
      type: type,
      payload: payload,
      timestamp: DateTime.now(),
    );

    final updated = [...state.pendingEvents, event];
    state = state.copyWith(pendingEvents: updated);
    await _persistQueue();
    _logger.i('[SyncQueue] Événement ${type.name} sauvegardé localement (Total en attente: ${updated.length})');

    // Déclenche la synchronisation en arrière-plan sans bloquer l'UI
    unawaited(syncNow());
  }

  /// Déclenche la synchronisation immédiate avec le Cloud ou le Boîtier AlternIA
  Future<bool> syncNow() async {
    if (state.isSyncing) return false;
    if (state.pendingEvents.isEmpty) {
      // Juste vérifier la connectivité
      final online = await _checkConnectivity();
      state = state.copyWith(isOnline: online);
      return true;
    }

    state = state.copyWith(isSyncing: true);

    try {
      final activeUrl = await _findReachableServer();
      if (activeUrl == null) {
        state = state.copyWith(
          isSyncing: false,
          isOnline: false,
          lastSyncMessage: 'Mode hors-ligne : données conservées en sécurité sur le téléphone.',
        );
        return false;
      }

      // Préparation du payload par lot (Batch)
      final batchPayload = {
        'device_type': 'mobile_app',
        'events_count': state.pendingEvents.length,
        'events': state.pendingEvents.map((e) => e.toJson()).toList(),
        'client_time': DateTime.now().toIso8601String(),
      };

      final response = await _dio.post(
        '$activeUrl/api/sync/batch',
        data: batchPayload,
        options: Options(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final now = DateTime.now();
        state = state.copyWith(
          pendingEvents: [],
          isSyncing: false,
          isOnline: true,
          lastSyncTime: now,
          lastSyncMessage: 'Synchronisé avec succès à ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        );
        await _persistQueue();
        _logger.i('[SyncQueue] Synchronisation par lot réussie !');
        return true;
      }
    } catch (e) {
      _logger.d('[SyncQueue] Serveur injoignable, maintien de la file d\'attente locale : $e');
    }

    state = state.copyWith(
      isSyncing: false,
      isOnline: false,
      lastSyncMessage: 'Connexion indisponible. Prochaine tentative automatique.',
    );
    return false;
  }

  Future<String?> _findReachableServer() async {
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.get(
          '$base/api/sync/status',
          options: Options(
            connectTimeout: const Duration(milliseconds: 1500),
            receiveTimeout: const Duration(milliseconds: 1500),
          ),
        );
        if (res.statusCode == 200) return base;
      } catch (_) {
        try {
          final res2 = await _dio.get(
            '$base/api/apprenants',
            options: Options(
              connectTimeout: const Duration(milliseconds: 1500),
              receiveTimeout: const Duration(milliseconds: 1500),
            ),
          );
          if (res2.statusCode == 200) return base;
        } catch (_) {}
      }
    }
    return null;
  }

  Future<bool> _checkConnectivity() async {
    final server = await _findReachableServer();
    return server != null;
  }

  void _startPeriodicSyncTimer() {
    // Vérifie et synchronise toutes les 60 secondes en arrière-plan
    _syncTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (state.pendingEvents.isNotEmpty) {
        syncNow();
      } else {
        _checkConnectivity().then((online) {
          if (mounted) state = state.copyWith(isOnline: online);
        });
      }
    });
  }
}

final syncQueueProvider =
    StateNotifierProvider<SyncQueueNotifier, SyncQueueState>((ref) {
  return SyncQueueNotifier();
});

// ── MODAL SHEET DE GESTION DU STORE & FORWARD ──────────────────────────────
void showSyncStatusModalSheet(BuildContext context) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _SyncStatusSheetContent(),
  );
}

class _SyncStatusSheetContent extends ConsumerWidget {
  const _SyncStatusSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncQueueProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);
    final cardBg = isDark ? const Color(0xFF141C2E) : Colors.white;
    final borderCol = isDark ? const Color(0xFF23314D) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (syncState.hasPending
                          ? AppColors.warning
                          : AppColors.success)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  syncState.hasPending
                      ? Icons.cloud_sync_rounded
                      : Icons.cloud_done_rounded,
                  color: syncState.hasPending
                      ? AppColors.warning
                      : AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Synchronisation Asynchrone',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                    Text(
                      'Technologie Store & Forward (Mali Hors-Ligne)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: textSec,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceAlt : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Actions sauvegardées localement :',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: textPri,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (syncState.hasPending
                                ? AppColors.warning
                                : AppColors.success)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        syncState.hasPending
                            ? '${syncState.pendingCount} en attente'
                            : 'Tout est synchronisé',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: syncState.hasPending
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  syncState.hasPending
                      ? 'Vos duels gagnés, vos flashcards et votre progression sont sauvegardés sur la mémoire de ce téléphone. Dès qu\'une connexion Internet ou le Boîtier AlterniA sera détecté, ils seront envoyés automatiquement.'
                      : 'Vos points XP, vos récompenses et vos scores sont parfaitement synchronisés avec les serveurs et le classement national.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: textSec,
                    height: 1.4,
                  ),
                ),
                if (syncState.lastSyncTime != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Dernière synchronisation réussie : ${syncState.lastSyncTime!.hour.toString().padLeft(2, '0')}:${syncState.lastSyncTime!.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: syncState.isSyncing
                  ? null
                  : () async {
                      HapticFeedback.mediumImpact();
                      final ok = await ref
                          .read(syncQueueProvider.notifier)
                          .syncNow();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Synchronisation terminée avec succès !'
                                  : 'Aucun réseau détecté. Les données restent sauvegardées en local.',
                            ),
                            backgroundColor:
                                ok ? AppColors.success : AppColors.warning,
                          ),
                        );
                      }
                    },
              icon: syncState.isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync_rounded, size: 18),
              label: Text(
                syncState.isSyncing
                    ? 'Synchronisation en cours…'
                    : 'Synchroniser maintenant',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
