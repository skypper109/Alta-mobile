/// Modèle représentant un défi culturel régional (+XP gamification)
class RegionalChallenge {
  final String id;
  final String titre;
  final String description;
  final int xpPoints;
  final String difficulte; // 'Facile', 'Moyen', 'Explorateur'
  final String badgeNom;
  final String tempsEstime;

  const RegionalChallenge({
    required this.id,
    required this.titre,
    required this.description,
    this.xpPoints = 50,
    this.difficulte = 'Explorateur',
    required this.badgeNom,
    this.tempsEstime = '5 min',
  });

  factory RegionalChallenge.fromJson(Map<String, dynamic> json) {
    return RegionalChallenge(
      id: json['id'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String? ?? '',
      xpPoints: (json['xp_points'] as num?)?.toInt() ?? 50,
      difficulte: json['difficulte'] as String? ?? 'Explorateur',
      badgeNom: json['badge_nom'] as String? ?? 'Initié',
      tempsEstime: json['temps_estime'] as String? ?? '5 min',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'xp_points': xpPoints,
      'difficulte': difficulte,
      'badge_nom': badgeNom,
      'temps_estime': tempsEstime,
    };
  }
}
