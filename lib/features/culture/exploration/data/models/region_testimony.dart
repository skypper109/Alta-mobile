/// Modèle représentant un récit oral, témoignage ou conte de la région (Mémoire vivante)
class RegionTestimony {
  final String id;
  final String conteur;
  final String qualiteConteur; // ex: 'Doyen des forgerons', 'Griot du Kénédougou', 'Potière de Kalabougou'
  final String lieu;
  final String titreHistoire;
  final String duree; // ex: '3 min', '5 min'
  final String extrait;
  final String? avatarUrl;
  final String? audioUrl;
  final String? epoqueOuAnnee;

  const RegionTestimony({
    required this.id,
    required this.conteur,
    required this.qualiteConteur,
    required this.lieu,
    required this.titreHistoire,
    required this.duree,
    required this.extrait,
    this.avatarUrl,
    this.audioUrl,
    this.epoqueOuAnnee,
  });

  factory RegionTestimony.fromJson(Map<String, dynamic> json) {
    return RegionTestimony(
      id: json['id'] as String,
      conteur: json['conteur'] as String,
      qualiteConteur: json['qualite_conteur'] as String? ?? 'Conteur traditionnel',
      lieu: json['lieu'] as String? ?? '',
      titreHistoire: json['titre_histoire'] as String,
      duree: json['duree'] as String? ?? '3 min',
      extrait: json['extrait'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      epoqueOuAnnee: json['epoque'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conteur': conteur,
      'qualite_conteur': qualiteConteur,
      'lieu': lieu,
      'titre_histoire': titreHistoire,
      'duree': duree,
      'extrait': extrait,
      'avatar_url': avatarUrl,
      'audio_url': audioUrl,
      'epoque': epoqueOuAnnee,
    };
  }
}
