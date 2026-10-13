// ─── AlterniA — Modèle Mode Grin Éducatif (Réseau Local & Hors-Ligne) ───────
// Entités pour les salons de révision en groupe (Grin), la détection de camarades
// à proximité et le partage P2P sans connexion Internet.
library;

class GrinRoom {
  final String id;
  final String title;
  final String hostName;
  final String hostClass;
  final String subject;
  final int playerCount;
  final int maxPlayers;
  final String pinCode;
  final bool isLocalBoitier; // Hébergé directement sur le Boîtier AlternIA
  final DateTime createdAt;

  const GrinRoom({
    required this.id,
    required this.title,
    required this.hostName,
    required this.hostClass,
    required this.subject,
    this.playerCount = 1,
    this.maxPlayers = 8,
    required this.pinCode,
    this.isLocalBoitier = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hostName': hostName,
        'hostClass': hostClass,
        'subject': subject,
        'playerCount': playerCount,
        'maxPlayers': maxPlayers,
        'pinCode': pinCode,
        'isLocalBoitier': isLocalBoitier,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GrinRoom.fromJson(Map<String, dynamic> json) => GrinRoom(
        id: json['id'] as String,
        title: json['title'] as String,
        hostName: json['hostName'] as String,
        hostClass: json['hostClass'] as String? ?? '12eme',
        subject: json['subject'] as String? ?? 'Général',
        playerCount: (json['playerCount'] as num?)?.toInt() ?? 1,
        maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 8,
        pinCode: json['pinCode'] as String? ?? '1234',
        isLocalBoitier: json['isLocalBoitier'] as bool? ?? true,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class GrinPeer {
  final String id;
  final String name;
  final String className;
  final int scoreSession;
  final bool isConnectedLocal;
  final String deviceModel;

  const GrinPeer({
    required this.id,
    required this.name,
    required this.className,
    this.scoreSession = 0,
    this.isConnectedLocal = true,
    this.deviceModel = 'Android',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'className': className,
        'scoreSession': scoreSession,
        'isConnectedLocal': isConnectedLocal,
        'deviceModel': deviceModel,
      };

  factory GrinPeer.fromJson(Map<String, dynamic> json) => GrinPeer(
        id: json['id'] as String? ?? 'peer_${DateTime.now().millisecondsSinceEpoch}',
        name: json['name'] as String? ?? 'Camarade',
        className: json['className'] as String? ?? 'TSE',
        scoreSession: (json['scoreSession'] as num?)?.toInt() ?? 0,
        isConnectedLocal: json['isConnectedLocal'] as bool? ?? true,
        deviceModel: json['deviceModel'] as String? ?? 'Boîtier AlternIA',
      );
}

class GrinSharedResource {
  final String id;
  final String title;
  final String subject;
  final String type; // 'podcast', 'fiche_cours', 'flashcards'
  final String sizeMb;
  final String sharedBy;

  const GrinSharedResource({
    required this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.sizeMb,
    required this.sharedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'type': type,
        'sizeMb': sizeMb,
        'sharedBy': sharedBy,
      };

  factory GrinSharedResource.fromJson(Map<String, dynamic> json) =>
      GrinSharedResource(
        id: json['id'] as String? ?? 'res_${DateTime.now().millisecondsSinceEpoch}',
        title: json['title'] as String? ?? 'Ressource',
        subject: json['subject'] as String? ?? 'Général',
        type: json['type'] as String? ?? 'fiche_cours',
        sizeMb: json['sizeMb'] as String? ?? '1.0 Mo',
        sharedBy: json['sharedBy'] as String? ?? 'Boîtier AlternIA',
      );
}

