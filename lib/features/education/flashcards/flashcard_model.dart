// ─── AlterniA — Modèle Flashcard & Méthode Leitner (Répétition Espacée) ─────
// Système d'ancrage mnésique à long terme pour les examens maliens (DEF & Baccalauréat).
library;

class Flashcard {
  final String id;
  final String subject;
  final String classLevel;
  final String front; // Question, terme, formule ou date
  final String back; // Réponse, définition, méthode ou démonstration
  final String concept;
  final int box; // Boîte Leitner (1 à 5)
  final DateTime nextReviewDate;
  final DateTime? lastReviewedDate;
  final int repetitionCount;

  const Flashcard({
    required this.id,
    required this.subject,
    required this.classLevel,
    required this.front,
    required this.back,
    required this.concept,
    this.box = 1,
    required this.nextReviewDate,
    this.lastReviewedDate,
    this.repetitionCount = 0,
  });

  bool get isDueToday {
    final now = DateTime.now();
    return nextReviewDate.isBefore(now) ||
        (nextReviewDate.year == now.year &&
            nextReviewDate.month == now.month &&
            nextReviewDate.day == now.day);
  }

  Flashcard copyWith({
    String? id,
    String? subject,
    String? classLevel,
    String? front,
    String? back,
    String? concept,
    int? box,
    DateTime? nextReviewDate,
    DateTime? lastReviewedDate,
    int? repetitionCount,
  }) {
    return Flashcard(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      classLevel: classLevel ?? this.classLevel,
      front: front ?? this.front,
      back: back ?? this.back,
      concept: concept ?? this.concept,
      box: box ?? this.box,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewedDate: lastReviewedDate ?? this.lastReviewedDate,
      repetitionCount: repetitionCount ?? this.repetitionCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'classLevel': classLevel,
        'front': front,
        'back': back,
        'concept': concept,
        'box': box,
        'nextReviewDate': nextReviewDate.toIso8601String(),
        'lastReviewedDate': lastReviewedDate?.toIso8601String(),
        'repetitionCount': repetitionCount,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'] as String,
        subject: json['subject'] as String? ?? 'Général',
        classLevel: json['classLevel'] as String? ?? '12eme',
        front: json['front'] as String,
        back: json['back'] as String,
        concept: json['concept'] as String? ?? 'Révision',
        box: (json['box'] as num?)?.toInt() ?? 1,
        nextReviewDate: DateTime.tryParse(json['nextReviewDate'] as String? ?? '') ??
            DateTime.now(),
        lastReviewedDate: json['lastReviewedDate'] != null
            ? DateTime.tryParse(json['lastReviewedDate'] as String)
            : null,
        repetitionCount: (json['repetitionCount'] as num?)?.toInt() ?? 0,
      );
}

class FlashcardBank {
  static List<Flashcard> getInitialCards() {
    final now = DateTime.now();

    return [
      // ── MATHÉMATIQUES ──────────────────────────────────────────────────────
      Flashcard(
        id: 'fc_math_1',
        subject: 'Mathématiques',
        classLevel: '12eme',
        concept: 'Dérivées Usuelles',
        front: 'Quelle est la dérivée de la fonction f(x) = ln(x) sur ]0, +∞[ ?',
        back: 'f\'(x) = 1 / x.\n\nFormule générale pour une fonction u(x) : (ln(u))\' = u\' / u.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_math_2',
        subject: 'Mathématiques',
        classLevel: '11eme',
        concept: 'Équations du 2nd Degré',
        front: 'Que vaut le discriminant Δ pour l\'équation ax² + bx + c = 0 ?',
        back: 'Δ = b² - 4ac.\n\n• Si Δ > 0 : Deux racines réelles distinctes x = (-b ± √Δ) / 2a.\n• Si Δ = 0 : Une racine double x = -b / 2a.\n• Si Δ < 0 : Aucune racine dans ℝ (racines complexes dans ℂ).',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_math_3',
        subject: 'Mathématiques',
        classLevel: '12eme',
        concept: 'Exponentielle',
        front: 'Donner la dérivée de f(x) = e^(u(x)).',
        back: 'f\'(x) = u\'(x) · e^(u(x)).\n\nPropriété clé : e^0 = 1 et e^(a+b) = e^a · e^b.',
        box: 1,
        nextReviewDate: now,
      ),

      // ── PHYSIQUE - CHIMIE ─────────────────────────────────────────────────
      Flashcard(
        id: 'fc_pc_1',
        subject: 'Physique-Chimie',
        classLevel: '12eme',
        concept: 'Électromagnétisme & Électricité',
        front: 'Énoncer la Loi d\'Ohm pour un conducteur ohmique.',
        back: 'U = R · I\n\n• U : tension électrique en Volts (V)\n• R : résistance en Ohms (Ω)\n• I : intensité du courant en Ampères (A).',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_pc_2',
        subject: 'Physique-Chimie',
        classLevel: '12eme',
        concept: 'Mécanique Newtonienne',
        front: 'Énoncer la 2ème Loi de Newton (Principe fondamental de la dynamique).',
        back: 'Σ F_ext = m · a\n\nLa somme vectorielle des forces extérieures appliquées à un point matériel est égale au produit de sa masse par son accélération.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_pc_3',
        subject: 'Physique-Chimie',
        classLevel: '11eme',
        concept: 'Chimie des Solutions',
        front: 'Quelle est la relation entre le pH et la concentration en ions oxonium [H3O+] ?',
        back: 'pH = -log([H3O+])\n\nEt inversement : [H3O+] = 10^(-pH) mol/L.\nÀ 25°C, pH < 7 = acide, pH = 7 = neutre, pH > 7 = basique.',
        box: 1,
        nextReviewDate: now,
      ),

      // ── BIOLOGIE / SVT ────────────────────────────────────────────────────
      Flashcard(
        id: 'fc_svt_1',
        subject: 'Biologie',
        classLevel: '12eme',
        concept: 'Génétique Moléculaire',
        front: 'Quelles sont les 4 bases azotées constitutives de l\'ADN ?',
        back: 'Adénine (A), Thymine (T), Guanine (G), Cytosine (C).\n\nComplémentarité des bases : A s\'associe avec T (2 liaisons H) et G s\'associe avec C (3 liaisons H).',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_svt_2',
        subject: 'Biologie',
        classLevel: '11eme',
        concept: 'Immunologie',
        front: 'Quelle est la différence entre lymphocyte B et lymphocyte T ?',
        back: '• Lymphocytes B : Responsables de l\'immunité humorale (sécrétion d\'anticorps circulants).\n• Lymphocytes T (notamment T4 et T8 cytotoxiques) : Responsables de l\'immunité à médiation cellulaire.',
        box: 1,
        nextReviewDate: now,
      ),

      // ── HISTOIRE & GÉOGRAPHIE DU MALI ─────────────────────────────────────
      Flashcard(
        id: 'fc_hg_1',
        subject: 'Histoire-Géographie',
        classLevel: '10eme',
        concept: 'Histoire Nationale du Mali',
        front: 'À quelle date le Mali a-t-il proclamé son indépendance et qui en fut le 1er Président ?',
        back: 'Le 22 septembre 1960.\n\nLe premier président de la République du Mali indépendant fut Modibo Keïta.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_hg_2',
        subject: 'Histoire-Géographie',
        classLevel: '11eme',
        concept: 'Empires Soudanais',
        front: 'Quel empereur a fondé l\'Empire du Mali au XIIIe siècle et à quelle bataille ?',
        back: 'Soundiata Keïta, après sa victoire historique à la bataille de Kirina en 1235 contre Soumaoro Kanté (roi du Sosso), scellée par la Charte de Kouroukan Fouga.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_hg_3',
        subject: 'Histoire-Géographie',
        classLevel: '12eme',
        concept: 'Hydrographie du Mali',
        front: 'Quels sont les deux grands fleuves qui arrosent le Mali ?',
        back: '1. Le fleuve Niger (Djoliba), long de 4 200 km (dont ~1 700 km au Mali avec sa boucle intérieure).\n2. Le fleuve Sénégal (formé à Bafoulabé par la confluence du Bafing et du Bakoy).',
        box: 1,
        nextReviewDate: now,
      ),

      // ── PHILOSOPHIE (BAC MALIEN) ──────────────────────────────────────────
      Flashcard(
        id: 'fc_philo_1',
        subject: 'Philosophie',
        classLevel: '12eme',
        concept: 'La Conscience & le Sujet',
        front: 'Quelle est la célèbre formule du Cogito cartésien de René Descartes ?',
        back: '« Cogito, ergo sum » (« Je pense, donc je suis »).\n\nFormulée dans le Discours de la méthode (1637), elle établit le doute méthodique comme fondement certain de la conscience réflexive.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_philo_2',
        subject: 'Philosophie',
        classLevel: '12eme',
        concept: 'L\'État et la Justice',
        front: 'Selon Jean-Jacques Rousseau, sur quoi repose la légitimité de l\'État ?',
        back: 'Sur le « Contrat Social » (1762) et la Volonté Générale, où chaque citoyen renonce à sa liberté naturelle pour acquérir la liberté civile.',
        box: 1,
        nextReviewDate: now,
      ),
    ];
  }
}
