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
  static List<Flashcard> getInitialCards({String? level}) {
    final now = DateTime.now();

    final allCards = [
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

      // ── DIPLÔME D'ÉTUDES FONDAMENTALES (DEF — 9ÈME ANNÉE) ──────────────────
      Flashcard(
        id: 'fc_def_math_1',
        subject: 'Mathématiques',
        classLevel: 'def',
        concept: 'Théorème de Pythagore',
        front: 'Énoncer le Théorème de Pythagore dans un triangle ABC rectangle en A.',
        back: 'BC² = AB² + AC².\n\nLe carré de l\'hypoténuse est égal à la somme des carrés des côtés de l\'angle droit.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_def_math_2',
        subject: 'Mathématiques',
        classLevel: 'def',
        concept: 'Théorème de Thalès',
        front: 'Quelle est la propriété de Thalès pour deux droites sécantes coupées par deux parallèles (BC) // (MN) ?',
        back: 'AM / AB = AN / AC = MN / BC.\n\nElle permet de calculer des longueurs inconnues dans des triangles emboîtés.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_def_pc_1',
        subject: 'Physique-Chimie',
        classLevel: 'def',
        concept: 'Poids et Masse',
        front: 'Quelle est la formule liant le poids P et la masse m d\'un corps sur Terre ?',
        back: 'P = m · g\n\n• P en Newtons (N)\n• m en kilogrammes (kg)\n• g : intensité de la pesanteur (g ≈ 9,8 N/kg ou 10 N/kg).',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_def_svt_1',
        subject: 'Biologie (SVT)',
        classLevel: 'def',
        concept: 'Défense Immunitaire',
        front: 'Quelles cellules sanguines sont responsables de la défense de l\'organisme ?',
        back: 'Les globules blancs (ou leucocytes).\n\nIls détruisent les bactéries et virus par phagocytose et production d\'anticorps.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_def_fr_1',
        subject: 'Français',
        classLevel: 'def',
        concept: 'Grammaire & Conjugaison',
        front: 'Quand accorde-t-on le participe passé employé avec l\'auxiliaire « avoir » ?',
        back: 'Le participe passé avec « avoir » s\'accorde en genre et en nombre avec le Complément d\'Objet Direct (COD) UNIQUEMENT si celui-ci est placé AVANT le verbe.\n\nExemple : « Les lettres que j\'ai écrites » (COD = que / les lettres, féminin pluriel).',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_def_ecm_1',
        subject: 'Éducation Civique & Morale',
        classLevel: 'def',
        concept: 'Symboles de la République',
        front: 'Quelle est la devise nationale de la République du Mali inscrite dans la Constitution ?',
        back: '« Un Peuple - Un But - Une Foi ».\n\nElle symbolise l\'unité nationale sacrée de tous les citoyens maliens.',
        box: 1,
        nextReviewDate: now,
      ),
      // ── TERMINALE SCIENCE SOCIALE (TSS) ───────────────────────────────────
      Flashcard(
        id: 'fc_tss_socio_1',
        subject: 'Sociologie Générale',
        classLevel: 'tss',
        concept: 'Méthode Sociologique',
        front: 'Quelle est la règle méthodologique fondamentale d\'Émile Durkheim ?',
        back: '« Traiter les faits sociaux comme des choses ».\n\nLes faits sociaux sont extérieurs à l\'individu et exercent une force coercitive (contrainte) sur ses comportements.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_tss_socio_2',
        subject: 'Sociologie Générale',
        classLevel: 'tss',
        concept: 'Socialisation',
        front: 'Quelle est la différence entre socialisation primaire et socialisation secondaire ?',
        back: '• Primaire : pendant l\'enfance, via la famille et l\'école (construction des bases de l\'identité).\n• Secondaire : à l\'âge adulte, via le travail, l\'université et les groupes de pairs.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_tss_socio_3',
        subject: 'Sociologie Générale',
        classLevel: 'tss',
        concept: 'Stratification au Mali',
        front: 'Comment s\'organise traditionnellement la société en milieu mandingue ?',
        back: 'En trois grands groupes statutaires :\n1. Les hommes libres (Horonw)\n2. Les gens de caste ou artisans dépositaires du savoir (Nyamakala : griots, forgerons, cordonniers)\n3. Historiquement les captifs (Jonw).',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_tss_droit_1',
        subject: 'Droit & Institutions',
        classLevel: 'tss',
        concept: 'Séparation des Pouvoirs',
        front: 'Quel est le principe de la séparation des pouvoirs selon Montesquieu ?',
        back: 'La séparation stricte entre pouvoir exécutif (appliquer les lois), législatif (voter les lois) et judiciaire (sanctionner les infractions) pour garantir la liberté des citoyens.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_tss_droit_2',
        subject: 'Droit & Institutions',
        classLevel: 'tss',
        concept: 'Pyramide des Normes',
        front: 'Qu\'est-ce que la pyramide des normes juridiques de Hans Kelsen ?',
        back: 'Une hiérarchie où chaque norme doit respecter la norme supérieure :\nConstitution > Traités internationaux > Lois votées > Règlements & Décrets > Actes administratifs.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_tss_sp_1',
        subject: 'Science Politique',
        classLevel: 'tss',
        concept: 'L\'État & Souveraineté',
        front: 'Quelle est la célèbre définition de l\'État selon le sociologue Max Weber ?',
        back: 'L\'État est l\'institution humaine qui revendique avec succès le « monopole de la violence physique légitime » sur un territoire donné.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_tss_sp_2',
        subject: 'Science Politique',
        classLevel: 'tss',
        concept: 'Intégration Sahélienne (AES)',
        front: 'Qu\'est-ce que l\'Alliance des États du Sahel (AES) créée par le Mali, le Burkina et le Niger ?',
        back: 'Une confédération géopolitique et de sécurité collective visant à mutualiser la défense, la diplomatie et le codéveloppement pour la souveraineté pleine des trois nations sahéliennes.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_tss_philo_1',
        subject: 'Philosophie',
        classLevel: 'tss',
        concept: 'Contrat Social',
        front: 'Selon Jean-Jacques Rousseau, comment s\'exprime la légitimité politique de l\'État ?',
        back: 'Par la « Volonté Générale » dans le cadre du Contrat Social (1762), où l\'obéissance à la loi qu\'on s\'est prescrite est la seule vraie liberté.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_tss_eco_1',
        subject: 'Économie',
        classLevel: 'tss',
        concept: 'PIB & Croissance',
        front: 'Quelle est la définition rigoureuse du Produit Intérieur Brut (PIB) ?',
        back: 'La valeur marchande totale de l\'ensemble des biens et services finaux produits à l\'intérieur d\'un pays au cours d\'une année donnée.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_tss_hg_1',
        subject: 'Histoire-Géographie',
        classLevel: 'tss',
        concept: 'Indépendance Nationale',
        front: 'À quelle date le Mali a-t-il accédé à la souveraineté internationale ?',
        back: 'Le 22 septembre 1960 à Bamako, sous la direction du président Modibo Keïta, après l\'éclatement de la Fédération du Mali.',
        box: 1,
        nextReviewDate: now,
      ),
      Flashcard(
        id: 'fc_tss_fr_1',
        subject: 'Français',
        classLevel: 'tss',
        concept: 'Dissertation Littéraire',
        front: 'Quelles sont les trois parties majeures du plan dialectique ?',
        back: '1. Thèse (développement de l\'opinion proposée)\n2. Antithèse (objections et nuances argumentées)\n3. Synthèse (dépassement vers une vision équilibrée et élargie).',
        box: 1,
        nextReviewDate: now,
      ),
    ];

    if (level != null && level.isNotEmpty) {
      final lvlNorm = level.toLowerCase();
      if (lvlNorm.contains('tss')) {
        final tssCards = allCards
            .where((c) => c.classLevel.toLowerCase() == 'tss')
            .toList();
        if (tssCards.isNotEmpty) return tssCards;
      }
      final filtered = allCards.where((c) {
        final cLvl = c.classLevel.toLowerCase();
        if (lvlNorm.contains('def') && cLvl.contains('def')) return true;
        if ((lvlNorm.contains('12') ||
                lvlNorm.contains('tse') ||
                lvlNorm.contains('tsexp')) &&
            (cLvl.contains('12') ||
                cLvl.contains('tse') ||
                cLvl.contains('tsexp'))) {
          return true;
        }
        if (lvlNorm.contains('11') && cLvl.contains('11')) return true;
        if (lvlNorm.contains('10') && cLvl.contains('10')) return true;
        return false;
      }).toList();
      if (filtered.isNotEmpty) return filtered;
    }

    return allCards;
  }
}
