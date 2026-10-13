enum DuelMode {
  vsAi, // Contre le Professeur Henri (IA AlterniA ou Bot hors-ligne)
  matchmakingMali, // Défi instantané même classe dans tout le Mali
  createRoomWithCode, // Créer une salle avec code de validation (PIN)
  joinRoomWithCode, // Rejoindre une salle avec le code de validation
  passAndPlay, // À deux sur le même téléphone (Duel de Camarades)
}

enum DuelDifficulty {
  decouverte, // Facile
  intermediaire, // Épreuve type
  expert, // Niveau Bac / Concours
}

class DuelQuestion {
  final String id;
  final String subject;
  final String classLevel;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String tip;
  final String source; // 'ia_alternia', 'curriculum_mali_certifie', 'banque_locale'

  const DuelQuestion({
    required this.id,
    required this.subject,
    required this.classLevel,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.tip,
    this.source = 'ia_alternia',
  });

  factory DuelQuestion.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    return DuelQuestion(
      id: json['id']?.toString() ?? 'q_${DateTime.now().millisecondsSinceEpoch}',
      subject: json['subject']?.toString() ?? 'Général',
      classLevel: json['class_level']?.toString() ?? '12eme',
      questionText: (json['question'] ?? json['questionText'] ?? '').toString(),
      options: opts,
      correctOptionIndex: int.tryParse(
              (json['correct_index'] ?? json['correctOptionIndex'] ?? 0).toString()) ??
          0,
      explanation: json['explanation']?.toString() ?? 'Explication officielle.',
      tip: json['tip']?.toString() ?? 'Astuce de révision.',
      source: json['source']?.toString() ?? 'ia_alternia',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'class_level': classLevel,
      'question': questionText,
      'options': options,
      'correct_index': correctOptionIndex,
      'explanation': explanation,
      'tip': tip,
      'source': source,
    };
  }
}


class DuelBank {
  static const List<DuelQuestion> sampleQuestions = [
    // ── MATHÉMATIQUES ──────────────────────────────────────────────────────
    DuelQuestion(
      id: 'math_1',
      subject: 'Mathématiques',
      classLevel: '11eme',
      questionText: 'Pour l\'équation ax² + bx + c = 0, si le discriminant Δ < 0, combien de racines réelles possède l\'équation ?',
      options: ['Aucune racine réelle', 'Une racine double', 'Deux racines distinctes', 'Une infinité'],
      correctOptionIndex: 0,
      explanation: 'Lorsque Δ < 0, l\'équation du second degré n\'admet aucune solution dans l\'ensemble ℝ des nombres réels (ses solutions sont complexes dans ℂ).',
      tip: 'Rappelle-toi : Δ > 0 = 2 racines, Δ = 0 = 1 racine double, Δ < 0 = 0 racine dans ℝ.',
    ),
    DuelQuestion(
      id: 'math_2',
      subject: 'Mathématiques',
      classLevel: '12eme',
      questionText: 'Quelle est la dérivée de la fonction f(x) = ln(x) sur ]0, +∞[ ?',
      options: ['1 / x', '1 / x²', 'e^x', 'x'],
      correctOptionIndex: 0,
      explanation: 'La dérivée usuelle de la fonction logarithme népérien ln(x) est f\'(x) = 1/x pour tout x > 0.',
      tip: 'Formule clé du Bac malien : (ln(u))\' = u\' / u.',
    ),
    DuelQuestion(
      id: 'math_3',
      subject: 'Mathématiques',
      classLevel: '10eme',
      questionText: 'Dans un triangle rectangle, quel théorème permet de calculer la longueur de l\'hypoténuse ?',
      options: ['Théorème de Pythagore', 'Théorème de Thalès', 'Théorème de Gauss', 'Règle de Cramer'],
      correctOptionIndex: 0,
      explanation: 'Le théorème de Pythagore énonce que dans un triangle rectangle, le carré de l\'hypoténuse est égal à la somme des carrés des deux autres côtés.',
      tip: 'BC² = AB² + AC² si l\'angle en A est droit.',
    ),
    DuelQuestion(
      id: 'math_4',
      subject: 'Mathématiques',
      classLevel: '12eme',
      questionText: 'Quelle est la limite de (1/x) quand x tend vers +∞ ?',
      options: ['0', '+∞', '1', 'Indéterminée'],
      correctOptionIndex: 0,
      explanation: 'Quand le dénominateur devient infiniment grand, la fraction 1/x se rapproche infiniment de 0.',
      tip: '1 divisé par un milliard donne un nombre presque nul : limite = 0.',
    ),

    // ── PHYSIQUE-CHIMIE ────────────────────────────────────────────────────
    DuelQuestion(
      id: 'pc_1',
      subject: 'Physique-Chimie',
      classLevel: '11eme',
      questionText: 'Quel est le pH d\'une solution aqueuse parfaitement neutre à 25°C ?',
      options: ['pH = 7', 'pH = 0', 'pH = 14', 'pH = 1'],
      correctOptionIndex: 0,
      explanation: 'À 25°C, l\'eau pure a un produit ionique Ke = 10⁻¹⁴, ce qui donne une concentration [H3O+] = 10⁻⁷ mol/L, soit pH = 7 (neutralité).',
      tip: 'pH < 7 = acide, pH = 7 = neutre, pH > 7 = basique.',
    ),
    DuelQuestion(
      id: 'pc_2',
      subject: 'Physique-Chimie',
      classLevel: '12eme',
      questionText: 'Selon la 2ème loi de Newton (Principe Fondamental de la Dynamique), quelle est la relation reliant la force et l\'accélération ?',
      options: ['ΣF = m · a', 'E = m · c²', 'P = m / g', 'v = d / t'],
      correctOptionIndex: 0,
      explanation: 'La somme vectorielle des forces appliquées à un solide de masse constante m est égale au produit de sa masse par son vecteur accélération : ΣF = m · a.',
      tip: 'La force s\'exprime en Newtons (N) et l\'accélération en m/s².',
    ),
    DuelQuestion(
      id: 'pc_3',
      subject: 'Physique-Chimie',
      classLevel: '10eme',
      questionText: 'Quel gaz est indispensable pour entretenir une combustion ?',
      options: ['Le dioxygène (O₂)', 'Le diazote (N₂)', 'Le dioxyde de carbone (CO₂)', 'L\'hélium (He)'],
      correctOptionIndex: 0,
      explanation: 'Le dioxygène (O₂) joue le rôle de comburant. Sans dioxygène, la flamme s\'éteint immédiatement.',
      tip: 'Triangle du feu : Combustible + Comburant (O₂) + Énergie d\'activation.',
    ),

    // ── SVT (SCIENCES DE LA VIE ET DE LA TERRE) ───────────────────────────
    DuelQuestion(
      id: 'svt_1',
      subject: 'SVT',
      classLevel: '11eme',
      questionText: 'Dans quelle structure cellulaire se déroule la respiration cellulaire aérobie (production d\'ATP) ?',
      options: ['La mitochondrie', 'Le ribosome', 'L\'appareil de Golgi', 'Le noyau'],
      correctOptionIndex: 0,
      explanation: 'La mitochondrie est la véritable centrale énergétique de la cellule où a lieu le cycle de Krebs et la phosphorylation oxydative.',
      tip: 'Mitochondrie = usine à énergie cellulaire (ATP).',
    ),
    DuelQuestion(
      id: 'svt_2',
      subject: 'SVT',
      classLevel: '12eme',
      questionText: 'Combien de chromosomes compte une cellule somatique humaine normale ?',
      options: ['46 chromosomes (23 paires)', '23 chromosomes', '48 chromosomes', '92 chromosomes'],
      correctOptionIndex: 0,
      explanation: 'L\'être humain possède 2n = 46 chromosomes (22 paires d\'autosomes et 1 paire de chromosomes sexuels). Les gamètes (spermatozoïdes, ovocytes) n\'en comptent que 23 (n).',
      tip: 'Cellule somatique = diploïde (2n=46). Gamète = haploïde (n=23).',
    ),

    // ── HISTOIRE-GÉOGRAPHIE DU MALI ────────────────────────────────────────
    DuelQuestion(
      id: 'hg_1',
      subject: 'Histoire-Géo',
      classLevel: '10eme',
      questionText: 'En quelle année la République du Mali a-t-elle proclamé son accession à l\'indépendance ?',
      options: ['22 septembre 1960', '4 avril 1958', '1er janvier 1962', '20 septembre 1965'],
      correctOptionIndex: 0,
      explanation: 'Le 22 septembre 1960, le président Modibo Keïta a proclamé l\'indépendance de la République du Mali lors du congrès extraordinaire de l\'US-RDA.',
      tip: 'Date nationale commémorée chaque année le 22 septembre.',
    ),
    DuelQuestion(
      id: 'hg_2',
      subject: 'Histoire-Géo',
      classLevel: '11eme',
      questionText: 'Quel empereur du Manden a fondé l\'Empire du Mali après la célèbre bataille de Kirina en 1235 ?',
      options: ['Soundiata Keïta', 'Mansa Moussa', 'Sonni Ali Ber', 'Askia Mohammed'],
      correctOptionIndex: 0,
      explanation: 'Soundiata Keïta (Mari Diata) a vaincu le roi sorcier Soumaoro Kanté à Kirina en 1235 et a institué la Charte de Kouroukan Fouga.',
      tip: 'Surnommé le Lion du Manden, héros de l\'épopée fondatrice du Mali.',
    ),
    DuelQuestion(
      id: 'hg_3',
      subject: 'Histoire-Géo',
      classLevel: '12eme',
      questionText: 'Quel fleuve vital traverse le Mali sur plus de 1 700 km, reliant Bamako, Ségou, Mopti et Tombouctou ?',
      options: ['Le fleuve Niger (Djoliba)', 'Le fleuve Sénégal', 'Le fleuve Volta', 'Le fleuve Congo'],
      correctOptionIndex: 0,
      explanation: 'Le fleuve Niger, affectueusement appelé le Djoliba (« fleuve de sang » en bamanankan), est l\'artère vitale économique, agricole et culturelle du Mali.',
      tip: 'Le 3ème plus long fleuve d\'Afrique après le Nil et le Congo.',
    ),

    // ── PHILOSOPHIE ────────────────────────────────────────────────────────
    DuelQuestion(
      id: 'philo_1',
      subject: 'Philosophie',
      classLevel: '12eme',
      questionText: 'À quel philosophe des Lumières attribue-t-on la célèbre maxime : « Je pense, donc je suis » (Cogito ergo sum) ?',
      options: ['René Descartes', 'Jean-Jacques Rousseau', 'Emmanuel Kant', 'Socrate'],
      correctOptionIndex: 0,
      explanation: 'Dans son « Discours de la méthode » (1637), Descartes établit le Cogito comme la première vérité indubitable résistant au doute méthodique.',
      tip: 'Le point de départ du rationalisme moderne.',
    ),
    DuelQuestion(
      id: 'philo_2',
      subject: 'Philosophie',
      classLevel: '12eme',
      questionText: 'La méthode socratique d\'accouchement des esprits par le questionnement s\'appelle :',
      options: ['La maïeutique', 'La dialectique matérialiste', 'Le solipsisme', 'La métaphysique'],
      correctOptionIndex: 0,
      explanation: 'Socrate comparait son art à celui de sa mère Phanarète (sage-femme) : faire accoucher les âmes de la vérité qu\'elles portent déjà en elles.',
      tip: 'AlterniA utilise précisément cette méthode pour guider les élèves !',
    ),
  ];

  static List<DuelQuestion> getQuestionsForSubject(String subject, {String? level, int count = 5}) {
    final filtered = sampleQuestions.where((q) {
      final matchSub = q.subject.toLowerCase().contains(subject.toLowerCase()) ||
          subject.toLowerCase().contains(q.subject.toLowerCase());
      return matchSub;
    }).toList();

    if (filtered.isEmpty) {
      final list = List<DuelQuestion>.from(sampleQuestions)..shuffle();
      return list.take(count).toList();
    }

    filtered.shuffle();
    return filtered.take(count).toList();
  }
}
