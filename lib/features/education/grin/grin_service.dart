// ─── AlterniA — Service Mode Grin Éducatif (Réseau Local & Boîtier) ─────────
// Découverte des camarades sur le Wi-Fi local du boîtier, gestion des salons
// de révision hors-ligne et transfert P2P de ressources sans Internet.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

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
    _initSampleGrinData();
  }

  final _logger = Logger();

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

  Future<void> scanLocalGrin() async {
    state = state.copyWith(isScanning: true);
    await Future.delayed(const Duration(milliseconds: 900));
    state = state.copyWith(isScanning: false);
  }

  GrinRoom createLocalRoom({
    required String title,
    required String hostName,
    required String hostClass,
    required String subject,
  }) {
    final pin = (1000 + (DateTime.now().millisecond % 9000)).toString();
    final newRoom = GrinRoom(
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

    state = state.copyWith(
      rooms: [newRoom, ...state.rooms],
      activeRoomId: newRoom.id,
    );
    _logger.i('[GrinService] Salon local créé : ${newRoom.title} (PIN: $pin)');
    return newRoom;
  }
}

final grinServiceProvider =
    StateNotifierProvider<GrinServiceNotifier, GrinState>((ref) {
  return GrinServiceNotifier();
});
