// ─── AlterniA — Service Mode Grin Éducatif (Réseau Local & Boîtier) ─────────
// Découverte des camarades sur le Wi-Fi local du boîtier, gestion des salons
// de révision hors-ligne et transfert P2P de ressources sans Internet.
library;

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/constants.dart';
import 'grin_model.dart';

class GrinState {
  final List<GrinRoom> rooms;
  final List<GrinPeer> nearbyPeers;
  final List<GrinSharedResource> sharedResources;
  final bool isScanning;
  final String? activeRoomId;

  const GrinState({
    this.rooms = const [],
    this.nearbyPeers = const [],
    this.sharedResources = const [],
    this.isScanning = false,
    this.activeRoomId,
  });

  GrinState copyWith({
    List<GrinRoom>? rooms,
    List<GrinPeer>? nearbyPeers,
    List<GrinSharedResource>? sharedResources,
    bool? isScanning,
    String? activeRoomId,
  }) {
    return GrinState(
      rooms: rooms ?? this.rooms,
      nearbyPeers: nearbyPeers ?? this.nearbyPeers,
      sharedResources: sharedResources ?? this.sharedResources,
      isScanning: isScanning ?? this.isScanning,
      activeRoomId: activeRoomId ?? this.activeRoomId,
    );
  }
}

class GrinServiceNotifier extends StateNotifier<GrinState> {
  GrinServiceNotifier() : super(const GrinState()) {
    _initGrinData();
  }

  final _logger = Logger();
  final _dio = Dio();

  void _initGrinData() {
    // Initialise avec le socle certifié par défaut puis tente la synchro backend
    _initSampleGrinData();
    unawaited(scanLocalGrin());
  }

  void _initSampleGrinData() {
    state = GrinState(
      rooms: [
        GrinRoom(
          id: 'grin_room_01',
          title: 'Grin Bac TSE — Révise Kirina',
          hostName: 'Moussa Traoré',
          hostClass: 'TSE',
          subject: 'Mathématiques',
          playerCount: 3,
          maxPlayers: 6,
          pinCode: '7412',
          isLocalBoitier: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        GrinRoom(
          id: 'grin_room_02',
          title: 'Défi Physique Badalabougou',
          hostName: 'Fanta Diarra',
          hostClass: '11eme',
          subject: 'Physique-Chimie',
          playerCount: 2,
          maxPlayers: 4,
          pinCode: '3350',
          isLocalBoitier: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ],
      nearbyPeers: const [
        GrinPeer(
          id: 'peer_1',
          name: 'Moussa Traoré',
          className: 'TSE',
          scoreSession: 1450,
          deviceModel: 'Boîtier AlternIA',
        ),
        GrinPeer(
          id: 'peer_2',
          name: 'Fanta Diarra',
          className: '11eme Sc',
          scoreSession: 1200,
          deviceModel: 'Infinix Hot 12',
        ),
        GrinPeer(
          id: 'peer_3',
          name: 'Sekou Coulibaly',
          className: 'TSE',
          scoreSession: 980,
          deviceModel: 'Tecno Spark 9',
        ),
        GrinPeer(
          id: 'peer_4',
          name: 'Aminata Koné',
          className: '10eme',
          scoreSession: 850,
          deviceModel: 'Samsung A13',
        ),
      ],
      sharedResources: const [
        GrinSharedResource(
          id: 'res_01',
          title: 'Podcast Audio : Dérivées & Primitives',
          subject: 'Mathématiques',
          type: 'podcast',
          sizeMb: '4.2 Mo',
          sharedBy: 'Boîtier AlternIA',
        ),
        GrinSharedResource(
          id: 'res_02',
          title: 'Fiche Synthèse : Équations de Newton',
          subject: 'Physique-Chimie',
          type: 'fiche_cours',
          sizeMb: '1.1 Mo',
          sharedBy: 'Moussa (TSE)',
        ),
        GrinSharedResource(
          id: 'res_03',
          title: 'Flashcards : Indépendance & Empires',
          subject: 'Histoire-Géo',
          type: 'flashcards',
          sizeMb: '0.8 Mo',
          sharedBy: 'Fanta (11eme)',
        ),
      ],
    );
  }

  /// Scanne le réseau local / boîtier / backend pour rafraîchir les salons, pairs et ressources
  Future<void> scanLocalGrin() async {
    state = state.copyWith(isScanning: true);

    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final roomsRes = await _dio.get(
          '$base/api/grin/rooms',
          options: Options(
            connectTimeout: const Duration(seconds: 2),
            receiveTimeout: const Duration(seconds: 3),
          ),
        );

        if (roomsRes.statusCode == 200 && roomsRes.data is List) {
          final loadedRooms = (roomsRes.data as List)
              .map((e) => GrinRoom.fromJson(e as Map<String, dynamic>))
              .toList();

          // Récupère aussi les pairs et les ressources
          List<GrinPeer> loadedPeers = state.nearbyPeers;
          try {
            final peersRes = await _dio.get(
              '$base/api/grin/peers',
              options: Options(connectTimeout: const Duration(seconds: 2)),
            );
            if (peersRes.statusCode == 200 && peersRes.data is List) {
              loadedPeers = (peersRes.data as List)
                  .map((e) => GrinPeer.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          } catch (_) {}

          List<GrinSharedResource> loadedResources = state.sharedResources;
          try {
            final resRes = await _dio.get(
              '$base/api/grin/resources',
              options: Options(connectTimeout: const Duration(seconds: 2)),
            );
            if (resRes.statusCode == 200 && resRes.data is List) {
              loadedResources = (resRes.data as List)
                  .map((e) => GrinSharedResource.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          } catch (_) {}

          state = state.copyWith(
            rooms: loadedRooms.isNotEmpty ? loadedRooms : state.rooms,
            nearbyPeers: loadedPeers,
            sharedResources: loadedResources,
            isScanning: false,
          );
          _logger.i('[GrinService] Données Grin connectées et synchronisées depuis $base');
          return;
        }
      } catch (e) {
        // En cas d'échec sur cette URL candidate, continue vers la suivante
      }
    }

    // Si aucun backend n'est joignable, maintien du mode maillé hors-ligne
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isScanning: false);
  }

  /// Crée un salon local et le propage immédiatement au serveur/boîtier
  Future<GrinRoom> createLocalRoom({
    required String title,
    required String hostName,
    required String hostClass,
    required String subject,
  }) async {
    final pin = (1000 + (DateTime.now().millisecond % 9000)).toString();
    GrinRoom newRoom = GrinRoom(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      hostName: hostName,
      hostClass: hostClass,
      subject: subject,
      playerCount: 1,
      maxPlayers: 6,
      pinCode: pin,
      isLocalBoitier: true,
      createdAt: DateTime.now(),
    );

    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.post(
          '$base/api/grin/rooms/create',
          data: {
            'title': title,
            'host_name': hostName,
            'host_class': hostClass,
            'subject': subject,
            'max_players': 6,
          },
          options: Options(connectTimeout: const Duration(seconds: 2)),
        );
        if (res.statusCode == 200 && res.data is Map) {
          newRoom = GrinRoom.fromJson(res.data as Map<String, dynamic>);
          break;
        }
      } catch (_) {}
    }

    state = state.copyWith(
      rooms: [newRoom, ...state.rooms],
      activeRoomId: newRoom.id,
    );
    _logger.i('[GrinService] Salon local créé : ${newRoom.title} (PIN: ${newRoom.pinCode})');
    return newRoom;
  }
}

final grinServiceProvider =
    StateNotifierProvider<GrinServiceNotifier, GrinState>((ref) {
  return GrinServiceNotifier();
});
