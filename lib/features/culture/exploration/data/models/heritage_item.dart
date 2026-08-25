/// Modèle représentant un monument ou site du patrimoine matériel/immatériel
class HeritageItem {
  final String id;
  final String nom;
  final String categorie; // 'Monument', 'Site UNESCO', 'Architecture', 'Sanctuaire'
  final String description;
  final String? imageUrl;
  final bool estUnesco;
  final String? epoque;
  final String? localisation;

  const HeritageItem({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.description,
    this.imageUrl,
    this.estUnesco = false,
    this.epoque,
    this.localisation,
  });

  factory HeritageItem.fromJson(Map<String, dynamic> json) {
    return HeritageItem(
      id: json['id'] as String,
      nom: json['nom'] as String,
      categorie: json['categorie'] as String? ?? 'Monument',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      estUnesco: json['est_unesco'] as bool? ?? false,
      epoque: json['epoque'] as String?,
      localisation: json['localisation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'categorie': categorie,
      'description': description,
      'image_url': imageUrl,
      'est_unesco': estUnesco,
      'epoque': epoque,
      'localisation': localisation,
    };
  }
}
