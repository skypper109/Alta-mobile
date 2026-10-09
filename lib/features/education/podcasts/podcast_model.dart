import 'package:flutter/material.dart';

class PodcastChapter {
  final String title;
  final int timestampSeconds;

  const PodcastChapter({
    required this.title,
    required this.timestampSeconds,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'timestamp_seconds': timestampSeconds,
      };

  factory PodcastChapter.fromJson(Map<String, dynamic> json) => PodcastChapter(
        title: json['title'] as String? ?? 'Chapitre',
        timestampSeconds:
            (json['timestamp_seconds'] ?? json['timestampSeconds'] ?? 0)
                as int,
      );
}

class RevisionPodcast {
  final String id;
  final String title;
  final String subject;
  final String classLevel;
  final int durationMinutes;
  final String summary;
  final String narrator;
  final List<PodcastChapter> chapters;
  final List<String> keyTakeaways;
  final String fullScript;
  final IconData icon;
  final Color accentColor;
  final String? audioUrl;
  final bool isCustomGenerated;

  const RevisionPodcast({
    required this.id,
    required this.title,
    required this.subject,
    required this.classLevel,
    required this.durationMinutes,
    required this.summary,
    required this.narrator,
    required this.chapters,
    required this.keyTakeaways,
    required this.fullScript,
    required this.icon,
    required this.accentColor,
    this.audioUrl,
    this.isCustomGenerated = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'class_level': classLevel,
        'duration_minutes': durationMinutes,
        'summary': summary,
        'narrator': narrator,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'key_takeaways': keyTakeaways,
        'full_script': fullScript,
        'audio_url': audioUrl,
        'is_custom_generated': isCustomGenerated,
      };

  factory RevisionPodcast.fromJson(Map<String, dynamic> json) {
    final sub = (json['subject'] as String? ?? 'Général');
    return RevisionPodcast(
      id: json['id'] as String? ??
          'pod_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Cours Audio AlternIA',
      subject: sub,
      classLevel: json['class_level'] as String? ??
          json['classLevel'] as String? ??
          'Tous niveaux',
      durationMinutes:
          (json['duration_minutes'] ?? json['durationMinutes'] ?? 6) as int,
      summary: json['summary'] as String? ?? '',
      narrator: json['narrator'] as String? ?? 'Professeur IA (AlternIA)',
      chapters: (json['chapters'] as List<dynamic>? ?? [])
          .map((c) => PodcastChapter.fromJson(c as Map<String, dynamic>))
          .toList(),
      keyTakeaways: (json['key_takeaways'] as List<dynamic>? ??
              json['keyTakeaways'] as List<dynamic>? ??
              [])
          .map((k) => k.toString())
          .toList(),
      fullScript: json['full_script'] as String? ??
          json['fullScript'] as String? ??
          '',
      icon: iconForSubject(sub),
      accentColor: colorForSubject(sub),
      audioUrl: json['audio_url'] as String?,
      isCustomGenerated: json['is_custom_generated'] as bool? ?? true,
    );
  }

  static IconData iconForSubject(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return Icons.calculate_rounded;
    if (s.contains('phys') || s.contains('chim')) return Icons.science_rounded;
    if (s.contains('hist') || s.contains('géo')) return Icons.public_rounded;
    if (s.contains('philo')) return Icons.psychology_rounded;
    if (s.contains('svt') || s.contains('biol')) return Icons.biotech_rounded;
    if (s.contains('fran') || s.contains('litt')) {
      return Icons.menu_book_rounded;
    }
    return Icons.headphones_rounded;
  }

  static Color colorForSubject(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return const Color(0xFF314999);
    if (s.contains('phys') || s.contains('chim')) return const Color(0xFF0284C7);
    if (s.contains('hist') || s.contains('géo')) return const Color(0xFFF1851F);
    if (s.contains('philo')) return const Color(0xFF40BBCC);
    if (s.contains('svt')) return const Color(0xFF059669);
    return const Color(0xFF314999);
  }
}

class PodcastCatalog {
  static const List<RevisionPodcast> podcasts = [
    // ── MATHÉMATIQUES ──────────────────────────────────────────────────────
    RevisionPodcast(
      id: 'pod_math_1',
      title: 'Dompter les Dérivées et les Équations du 2nd Degré',
      subject: 'Mathématiques',
      classLevel: '11eme / 12eme',
      durationMinutes: 6,
      narrator: 'Professeur Henri (AlternIA)',
      icon: Icons.calculate_rounded,
      accentColor: Color(0xFF314999),
      summary:
          'Comprends enfin le sens géométrique de la dérivée comme pente de la tangente et révise les formules de factorisation rapides du discriminant pour le Bac.',
      chapters: [
        PodcastChapter(title: 'Introduction & Le sens de la dérivée', timestampSeconds: 0),
        PodcastChapter(title: 'Le secret du discriminant Delta', timestampSeconds: 90),
        PodcastChapter(title: 'Tableau de signes et variations', timestampSeconds: 210),
        PodcastChapter(title: 'Conclusion & Réflexe du candidat au Bac', timestampSeconds: 300),
      ],
      keyTakeaways: [
        'La dérivée f\'(x) représente la pente de la droite tangente à la courbe en un point.',
        'Si f\'(x) > 0 sur un intervalle, alors la fonction f est strictement croissante.',
        'Pour ax² + bx + c = 0 : Δ = b² - 4ac. Si Δ > 0 : x = (-b ± √Δ)/(2a).',
        'Le sommet de la parabole a pour abscisse x = -b / (2a).',
      ],
      fullScript: '''
Bienvenue dans ce podcast de révision AlternIA. Installe-toi confortablement, respire un grand coup, et parlons des fonctions et des dérivées.

Imagine une voiture qui roule sur la route de Koulikoro. Sa position change avec le temps. Si tu regardes ton compteur de vitesse à un instant précis, ce que tu lis, c'est exactement la dérivée de ta position par rapport au temps : c'est la vitesse instantanée.

En mathématiques pour le Bac malien, la dérivée f prime de x mesure à quelle vitesse une fonction varie. Quand la dérivée est positive, la courbe monte : la fonction est croissante. Quand la dérivée est négative, la courbe descend : la fonction est décroissante. Et quand la dérivée s'annule, tu as trouvé un sommet ou un creux, c'est-à-dire un extremum local.

Parlons maintenant du fameux discriminant Delta pour les équations du second degré.
Rappelle-toi toujours de la formule universelle : Delta = b au carré moins 4 a c.
Trois cas se présentent :
Premier cas : Delta est strictement positif. Tu as deux racines réelles distinctes.
Deuxième cas : Delta est nul. Tu as une racine double : moins b sur deux a.
Troisième cas : Delta est strictement négatif. Il n'y a aucune solution dans l'ensemble des réels.

Garde cette règle d'or pour tes épreuves : toujours calculer la dérivée, factoriser son expression, dresser le tableau de signes, et en déduire les variations sans précipitation. Bonnes révisions avec AlternIA !
''',
    ),

    // ── PHYSIQUE-CHIMIE ────────────────────────────────────────────────────
    RevisionPodcast(
      id: 'pod_pc_1',
      title: 'Lois de Newton & Mécanique Céleste au Bac',
      subject: 'Physique-Chimie',
      classLevel: '12eme',
      durationMinutes: 7,
      narrator: 'Professeur Henri (AlternIA)',
      icon: Icons.science_rounded,
      accentColor: Color(0xFF0284C7),
      summary:
          'Tout le cours sur les forces, les vecteurs accélérations et les satellites de télécommunication résumé de façon limpide.',
      chapters: [
        PodcastChapter(title: 'La 1ère loi : L\'inertie', timestampSeconds: 0),
        PodcastChapter(title: 'La 2ème loi fondamentale : F = m·a', timestampSeconds: 110),
        PodcastChapter(title: 'Mouvement d\'un satellite circulaire', timestampSeconds: 230),
      ],
      keyTakeaways: [
        '1ère loi de Newton (Principe d\'inertie) : dans un référentiel galiléen, si ΣF = 0, le centre d\'inertie est au repos ou en MRU.',
        '2ème loi (PFD) : ΣF_ext = m · a_G.',
        'Dans un mouvement circulaire uniforme : l\'accélération est purement centripète a = v² / R.',
        'La vitesse d\'un satellite en orbite circulaire : v = √(G · M / r). Elle ne dépend pas de la masse du satellite !',
      ],
      fullScript: '''
Bonjour cher élève d'AlternIA. Aujourd'hui, nous plongeons dans les lois fondamentales de la mécanique classique établies par Isaac Newton.

La première loi, le principe d'inertie, stipule que si aucune force ne s'exerce sur un objet, ou si les forces se compensent parfaitement, l'objet continue sur sa trajectoire en ligne droite à vitesse constante. C'est pour cela qu'il faut attacher sa ceinture en Sotrama : si le véhicule freine brutalement, ton corps continue naturellement son mouvement en avant.

La deuxième loi de Newton est la reine des sujets de physique au Baccalauréat. Elle affirme que la somme des forces extérieures est égale au produit de la masse par le vecteur accélération : sigma des forces égale m a.

Pour résoudre n'importe quel exercice au Bac, suis toujours ces quatre étapes méthodiques :
Un : Définir le système étudié.
Deux : Préciser le référentiel d'étude, généralement le référentiel terrestre supposé galiléen.
Trois : Faire le bilan complet des forces qui agissent sur le solide, par exemple le poids et la réaction du support.
Quatre : Appliquer la deuxième loi de Newton et projeter sur les axes du repère d'espace.

Pour un satellite en orbite autour de la Terre, la seule force est l'attraction gravitationnelle. L'accélération est dirigée vers le centre de la Terre, et la vitesse orbitale est donnée par v = racine carrée de G fois la masse de la Terre divisée par le rayon de l'orbite. Remarque bien : la masse du satellite n'intervient pas ! Un satellite de dix kilos et un satellite d'une tonne vont à la même vitesse sur la même orbite.
''',
    ),

    // ── HISTOIRE & TRADITIONS DU MALI ───────────────────────────────────────
    RevisionPodcast(
      id: 'pod_hg_1',
      title: 'L\'Épopée Mandingue : Soundiata & la Charte de Kouroukan Fouga',
      subject: 'Histoire-Géo',
      classLevel: 'Toutes Classes',
      durationMinutes: 8,
      narrator: 'Le Vieux Sage Griot (AlternIA)',
      icon: Icons.auto_stories_rounded,
      accentColor: Color(0xFFD97706),
      summary:
          'Un voyage immersif au cœur du 13ème siècle pour comprendre la naissance de l\'Empire du Mali et la première déclaration des droits de l\'homme au monde.',
      chapters: [
        PodcastChapter(title: 'L\'enfance difficile de Soundiata', timestampSeconds: 0),
        PodcastChapter(title: 'L\'exil et l\'apprentissage du commandement', timestampSeconds: 120),
        PodcastChapter(title: 'La victoire de Kirina en 1235', timestampSeconds: 260),
        PodcastChapter(title: 'La Charte de Kouroukan Fouga', timestampSeconds: 360),
      ],
      keyTakeaways: [
        'Soundiata Keïta, né infirme, a surmonté le handicap pour unifier les douze royaumes du Manden.',
        'La bataille historique de Kirina en 1235 marque la défaite de Soumaoro Kanté.',
        'En 1236, la Charte de Kouroukan Fouga proclame l\'inviolabilité de la vie humaine, la paix sociale, les droits des femmes et la protection de la nature.',
        'Classée au patrimoine immatériel de l\'UNESCO, elle est considérée comme la doyenne des constitutions démocratiques.',
      ],
      fullScript: '''
Écoute, enfant du Mali. Prête l'oreille à la voix des ancêtres et au souffle du fleuve Djoliba.

En ce temps-là, au début du treizième siècle, le Manden vivait sous la domination impitoyable de Soumaoro Kanté, le roi de Sosso. Mais les prophéties avaient annoncé qu'un grand roi naîtrait de l'union de Naré Maghann Konaté et de Sogolon Kondé, la femme-buffle. Ce fils, c'était Soundiata Keïta.

Durant toute son enfance, Soundiata ne marchait pas. Ses jambes refusaient de porter son corps. Mais un jour, voyant les larmes de sa mère humiliée, il demanda au forgeron une barre de fer. Dans un effort titanesque, pliant le fer sous sa force naissante, Soundiata se leva ! La nouvelle courut de village en village comme une traînée de poudre : le Lion s'est dressé !

Après des années d'exil et d'alliances stratégiques, la confrontation décisive eut lieu en 1235 dans la plaine de Kirina. Grâce à son courage et à l'aide de sa sœur Nana Triban, Soundiata perça le secret de Soumaoro et remporta la victoire.

Mais la plus grande œuvre de Soundiata ne fut pas la guerre, ce fut la paix. Réunissant tous les chefs de clans à Kouroukan Fouga, il proclama la Charte du Manden. Cette charte extraordinaire énonçait déjà : « Toute vie humaine est une vie. Une vie n'est pas supérieure à une autre. Nul ne doit offenser la femme. La faim n'est pas une fatalité. »
Rappelle-toi toujours d'où tu viens : la dignité, la tolérance et la justice sont inscrites dans la terre même du Mali.
''',
    ),

    // ── PHILOSOPHIE ────────────────────────────────────────────────────────
    RevisionPodcast(
      id: 'pod_philo_1',
      title: 'La Conscience, l\'Inconscient & la Liberté',
      subject: 'Philosophie',
      classLevel: '12eme / Terminale',
      durationMinutes: 7,
      narrator: 'Professeur Henri (AlternIA)',
      icon: Icons.psychology_rounded,
      accentColor: Color(0xFF7C3AED),
      summary:
          'Descartes, Kant et Freud s\'affrontent : sommes-nous maîtres de nos pensées ou le jouet de forces inconscientes ?',
      chapters: [
        PodcastChapter(title: 'Le sujet pensant cartésien', timestampSeconds: 0),
        PodcastChapter(title: 'Le coup de massue de Freud : l\'inconscient', timestampSeconds: 140),
        PodcastChapter(title: 'Peut-on rester libre et responsable ?', timestampSeconds: 270),
      ],
      keyTakeaways: [
        'Descartes pose la conscience comme certitude première : « Je pense, donc je suis ».',
        'Freud brise l\'illusion de transparence : « Le Moi n\'est pas maître dans sa propre maison ».',
        'La liberté selon Sartre : l\'homme est condamné à être libre car l\'existence précède l\'essence.',
        'Conseil dissertation : confronter la maîtrise rationnelle et les déterminismes psychologiques.',
      ],
      fullScript: '''
Bienvenue dans ce cours audio de philosophie pour la Terminale. La question qui nous occupe aujourd'hui est vertigineuse : qui commande en nous ?

Pour René Descartes au dix-septième siècle, la réponse est simple et lumineuse : c'est la conscience. Même si je doute de tout, même si mes sens me trompent, le fait même que je sois en train de douter prouve que je pense, et si je pense, j'existe nécessairement. C'est le Cogito : « Je pense, donc je suis ». L'homme est une chose pensante transparente à elle-même.

Mais à la fin du dix-neuvième siècle, Sigmund Freud vient porter ce qu'il appelle la troisième blessure narcissique de l'humanité. Freud affirme que la conscience n'est que la partie émergée de l'iceberg psychique. En dessous, bouillonne l'inconscient : nos désirs refoulés, nos traumatismes d'enfance, nos pulsions. Pour Freud : « Le Moi n'est pas maître dans sa propre maison ».

Alors, face au sujet du Bac : « L'inconscient ruine-t-il la liberté humaine ? », quelle position adopter ?
Tu ne dois pas choisir aveuglément entre Descartes et Freud. La bonne démarche philosophique consiste à montrer que si nous ne contrôlons pas tous nos déterminismes inconscients, la conscience nous donne le pouvoir d'en prendre connaissance et d'apprendre à nous maîtriser par la réflexion. Être libre, ce n'est pas faire tout ce que l'on veut, c'est comprendre ce qui nous meut pour agir en pleine responsabilité.
''',
    ),

    // ── SVT ────────────────────────────────────────────────────────────────
    RevisionPodcast(
      id: 'pod_svt_1',
      title: 'Génétique & Brassage Chromosomique : La Méiose Expliquée',
      subject: 'SVT',
      classLevel: '11eme / 12eme',
      durationMinutes: 6,
      narrator: 'Professeur Henri (AlternIA)',
      icon: Icons.biotech_rounded,
      accentColor: Color(0xFF059669),
      summary:
          'Comment se créent des individus uniques ? Maîtrise le brassage interchromosomique et intrachromosomique sans hésiter.',
      chapters: [
        PodcastChapter(title: 'Pourquoi sommes-nous tous uniques ?', timestampSeconds: 0),
        PodcastChapter(title: 'La méiose : 1 cellule mère, 4 gamètes', timestampSeconds: 90),
        PodcastChapter(title: 'Le crossing-over intrachromosomique', timestampSeconds: 180),
        PodcastChapter(title: 'La fécondation : l\'amplificateur final', timestampSeconds: 270),
      ],
      keyTakeaways: [
        'La méiose fait passer une cellule diploïde (2n) à 4 cellules haploïdes (n).',
        'Brassage intrachromosomique (Prophase I) : échange de portions de chromatides (crossing-over).',
        'Brassage interchromosomique (Anaphase I) : séparation aléatoire des chromosomes homologues.',
        'La fécondation réunit au hasard deux gamètes parmi des millions de combinaisons possibles.',
      ],
      fullScript: '''
Bonjour à toi ! Aujourd'hui en SVT, nous perçons le mystère de la diversité des êtres vivants. Pourquoi as-tu les yeux de ton grand-père et le sourire de ta mère, tout en étant différent de tes frères et sœurs ?

La réponse réside dans un mécanisme biologique fascinant : la méiose, couplée à la fécondation.

La méiose se déroule exclusivement dans les gonades pour fabriquer les gamètes. Elle comporte deux divisions successives.
Pendant la prophase de la première division se produit un phénomène capital : le brassage intrachromosomique, ou crossing-over. Les chromosomes homologues s'apparient et échangent des segments de chromatides. Des allèles se recombinent pour former de nouveaux arrangements génétiques.

Puis, à l'anaphase un, les chromosomes de chaque paire se séparent au hasard vers l'un ou l'autre pôle de la cellule : c'est le brassage interchromosomique.

Avec vingt-trois paires de chromosomes chez l'humain, le brassage interchromosomique peut à lui seul produire plus de huit millions de spermatozoïdes ou d'ovocytes génétiquement distincts ! Et quand deux gamètes fusionnent lors de la fécondation, les probabilités se multiplient : il y a plus de soixante-dix mille milliards de combinaisons possibles pour un même couple de parents.

Chaque élève qui écoute ce podcast est un chef-d'œuvre mathématique et biologique unique dans tout l'univers. Retiens bien les étapes de la méiose pour ton examen !
''',
    ),
  ];
}
