library;

import 'package:flutter/material.dart';
import '../domain/entities/malian_class.dart';

export '../domain/entities/malian_class.dart';

const List<MalianClass> malianClasses = [
  // ── 10ÈME — Tronc commun ────────────────────────────────────────────────
  MalianClass(
    id: '10eme',
    label: '10ème — Tronc commun',
    shortLabel: '10ème',
    level: '10ème',
    emoji: '📘',
    iconData: Icons.menu_book_rounded,
    description: 'Fondations scientifiques & littéraires (Tronc commun)',
    subjects: [
      'Mathématiques',
      'Physique-Chimie',
      'Sciences Naturelles (SVT)',
      'Histoire-Géographie',
      'Français',
      'Anglais',
      'Éducation Civique & Morale',
      'Éducation Physique & Sportive',
    ],
    suggestedQuestions: [
      'Explique-moi le théorème de Pythagore et ses applications.',
      'Quelles sont les lois de la réflexion de la lumière en Physique ?',
      'Qu\'est-ce que la cellule vivante et son rôle en SVT ?',
      'Comment faire une bonne rédaction argumentative en Français ?',
    ],
    color: 0xFF314999,
  ),

  // ── 11ÈME SES — Science Économique et Sociale ───────────────────────────
  MalianClass(
    id: '11eme_ses',
    label: '11ème SES — Science Économique & Sociale',
    shortLabel: '11SES',
    level: '11ème',
    emoji: '📊',
    iconData: Icons.bar_chart_rounded,
    description: 'Économie, Sociologie & Sciences Sociales',
    subjects: [
      'Économie Générale',
      'Sociologie',
      'Histoire-Géographie',
      'Mathématiques',
      'Français',
      'Anglais',
      'Philosophie',
      'Éducation Civique',
    ],
    suggestedQuestions: [
      'Explique la loi de l\'offre et de la demande en Économie.',
      'Quels sont les facteurs de la stratification sociale en Sociologie ?',
      'Comment calculer le taux de croissance du PIB en SES ?',
      'Quelles sont les grandes causes de la Première Guerre Mondiale ?',
    ],
    color: 0xFF40BBCC,
  ),

  // ── 11ÈME LETTRES — Série Littéraire ────────────────────────────────────
  MalianClass(
    id: '11eme_lettres',
    label: '11ème Lettres — Série Littéraire',
    shortLabel: '11Lettres',
    level: '11ème',
    emoji: '📖',
    iconData: Icons.history_edu_rounded,
    description: 'Littérature, Philosophie & Sciences Humaines',
    subjects: [
      'Littérature & Expression Française',
      'Philosophie',
      'Histoire-Géographie',
      'Anglais',
      'Latin / Langues Africaines',
      'Éducation Civique',
      'Mathématiques (Notions de base)',
      'Arts & Culture',
    ],
    suggestedQuestions: [
      'Qu\'est-ce qu\'une figure de style et donne des exemples littéraires ?',
      'Explique l\'allégorie de la caverne de Platon en Philosophie.',
      'Quels sont les grands mouvements littéraires du 19ème siècle ?',
      'Comment structurer le plan d\'une dissertation littéraire ?',
    ],
    color: 0xFF8B5CF6,
  ),

  // ── 11ÈME SCIENCES — Série Scientifique ─────────────────────────────────
  MalianClass(
    id: '11eme_sciences',
    label: '11ème Sciences — Série Scientifique',
    shortLabel: '11Sciences',
    level: '11ème',
    emoji: '🔬',
    iconData: Icons.science_rounded,
    description: 'Mathématiques, Physique-Chimie & Sciences Naturelles',
    subjects: [
      'Mathématiques',
      'Physique-Chimie',
      'Sciences Naturelles (SVT)',
      'Histoire-Géographie',
      'Français',
      'Anglais',
      'Philosophie',
    ],
    suggestedQuestions: [
      'Comment calculer le domaine de définition d\'une fonction numérique ?',
      'Explique la vitesse moyenne et l\'accélération en cinématique.',
      'Qu\'est-ce qu\'une réaction acido-basique et la notion de pH ?',
      'Explique le mécanisme de la photosynthèse chez les plantes.',
    ],
    color: 0xFF10B981,
  ),

  // ── TSS — Terminale Science Sociale ─────────────────────────────────────
  MalianClass(
    id: 'tss',
    label: 'TSS — Terminale Science Sociale',
    shortLabel: 'TSS',
    level: 'Terminale',
    emoji: '🏛️',
    iconData: Icons.account_balance_rounded,
    description: 'Sociologie, Droit & Sciences Politiques',
    subjects: [
      'Sociologie Générale',
      'Droit & Institutions',
      'Science Politique',
      'Histoire-Géographie',
      'Philosophie',
      'Économie',
      'Français',
      'Anglais',
    ],
    suggestedQuestions: [
      'Quels sont les rôles des institutions politiques dans la Constitution malienne ?',
      'Explique la différence entre sociologie quantitative et qualitative.',
      'Qu\'est-ce que la séparation des pouvoirs selon Montesquieu ?',
      'Quels sont les principes du droit constitutionnel et des libertés publiques ?',
    ],
    color: 0xFFF59E0B,
  ),

  // ── TSEco — Terminale Science Économique ────────────────────────────────
  MalianClass(
    id: 'tseco',
    label: 'TSEco — Terminale Science Économique',
    shortLabel: 'TSEco',
    level: 'Terminale',
    emoji: '💹',
    iconData: Icons.trending_up_rounded,
    description: 'Économie, Comptabilité & Commerce',
    subjects: [
      'Économie Politique',
      'Mathématiques Financières',
      'Comptabilité Générale',
      'Droit Commercial',
      'Histoire-Géographie',
      'Philosophie',
      'Français',
      'Anglais',
    ],
    suggestedQuestions: [
      'Comment établir un bilan comptable et le compte de résultat ?',
      'Explique le rôle des banques centrales et les mécanismes de l\'inflation.',
      'Comment calculer des intérêts composés en mathématiques financières ?',
      'Qu\'est-ce qu\'un contrat commercial et ses conditions de validité ?',
    ],
    color: 0xFF40BBCC,
  ),

  // ── TExp — Terminale Science Expérimentale ──────────────────────────────
  MalianClass(
    id: 'texp',
    label: 'TExp — Terminale Science Expérimentale',
    shortLabel: 'TExp',
    level: 'Terminale',
    emoji: '⚗️',
    iconData: Icons.biotech_rounded,
    description: 'SVT, Physique-Chimie & Sciences du Vivant',
    subjects: [
      'Sciences Naturelles (SVT) avancées',
      'Physique-Chimie appliquée',
      'Mathématiques',
      'Géologie',
      'Histoire-Géographie',
      'Philosophie',
      'Français',
      'Anglais',
    ],
    suggestedQuestions: [
      'Explique les étapes de la réplication de l\'ADN et de la mitose.',
      'Comment équilibrer une équation d\'oxydoréduction en chimie ?',
      'Qu\'est-ce que la dérive des continents et la tectonique des plaques ?',
      'Explique la transmission de l\'influx nerveux au niveau d\'une synapse.',
    ],
    color: 0xFF22C55E,
  ),

  // ── TSE — Terminale Science Exacte ─────────────────────────────────────
  MalianClass(
    id: 'tse',
    label: 'TSE — Terminale Science Exacte',
    shortLabel: 'TSE',
    level: 'Terminale',
    emoji: '🧮',
    iconData: Icons.calculate_rounded,
    description: 'Mathématiques, Physique, Chimie & Informatique',
    subjects: [
      'Mathématiques Avancées',
      'Physique',
      'Chimie',
      'Informatique & Algorithmique',
      'Histoire-Géographie',
      'Philosophie',
      'Français',
      'Anglais',
    ],
    suggestedQuestions: [
      'Explique le calcul des limites et des intégrales de la fonction exponentielle.',
      'Quelles sont les trois lois de Newton et leur application en mécanique ?',
      'Comment déterminer la constante d\'équilibre d\'une réaction chimique ?',
      'Qu\'est-ce qu\'un algorithme de tri et son analyse de complexité ?',
    ],
    color: 0xFFF1851F,
  ),

  // ── TLL — Terminale Lettres & Littérature ──────────────────────────────
  MalianClass(
    id: 'tll',
    label: 'TLL — Terminale Lettres & Littérature',
    shortLabel: 'TLL',
    level: 'Terminale',
    emoji: '✍️',
    iconData: Icons.edit_note_rounded,
    description: 'Littérature, Philosophie & Langues',
    subjects: [
      'Littérature Française & Africaine',
      'Philosophie',
      'Histoire de l\'Art & Culture',
      'Linguistique',
      'Histoire-Géographie',
      'Anglais',
      'Latin / Langues Classiques',
    ],
    suggestedQuestions: [
      'Analyse le mouvement de la Négritude avec Senghor et Césaire.',
      'Qu\'est-ce que le déterminisme et le libre arbitre en Philosophie ?',
      'Explique la structure dramatique de la tragédie classique.',
      'Comment réussir une dissertation philosophique sur la conscience ?',
    ],
    color: 0xFFEC4899,
  ),

  // ── TAL — Terminale Arts & Littérature ─────────────────────────────────
  MalianClass(
    id: 'tal',
    label: 'TAL — Terminale Arts & Littérature',
    shortLabel: 'TAL',
    level: 'Terminale',
    emoji: '🎭',
    iconData: Icons.palette_rounded,
    description: 'Arts, Littérature & Expression Culturelle',
    subjects: [
      'Arts Plastiques & Visuels',
      'Littérature Comparée',
      'Philosophie de l\'Art',
      'Histoire de l\'Art',
      'Culture Africaine & Patrimoniale',
      'Français',
      'Anglais',
    ],
    suggestedQuestions: [
      'Qu\'est-ce que le symbolisme dans l\'art traditionnel africain ?',
      'Explique le rôle de la parole et de la musique dans la culture orale malienne.',
      'Quels sont les éléments d\'analyse esthétique d\'une œuvre d\'art visuel ?',
      'Comment s\'articulent la philosophie et la création artistique ?',
    ],
    color: 0xFFF97316,
  ),
];

const List<String> malianLevels = ['10ème', '11ème', 'Terminale'];

List<MalianClass> classesByLevel(String level) =>
    malianClasses.where((c) => c.level == level).toList();

MalianClass? classById(String id) {
  try {
    return malianClasses.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

const String defaultClassId = 'tse';
