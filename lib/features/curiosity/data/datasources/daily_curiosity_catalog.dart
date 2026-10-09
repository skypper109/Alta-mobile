import 'package:flutter/material.dart';
import '../models/daily_curiosity_item.dart';

/// Catalogue certifié des Pépites Quotidiennes de Curiosité (Snackable Micro-Learning)
/// Conçu pour susciter une fascination instantanée en 30 secondes de lecture + 20s de micro-défi.
abstract final class DailyCuriosityCatalog {
  static const List<DailyCuriosityItem> items = [
    // ── JOUR 1 : MANSA MOUSSA & LA CHUTE DE L'OR ─────────────────────────────
    DailyCuriosityItem(
      id: 'curiosity_mansa_moussa_or',
      dayNumber: 1,
      hookTitle: 'L\'homme qui a fait chuter le cours mondial de l\'or',
      category: 'Secret d\'Empire',
      readTime: '25 sec',
      storySnippet:
          'En 1324, l\'empereur Mansa Moussa traverse le Caire en route pour La Mecque avec 12 tonnes d\'or pur. Il en distribue avec une telle générosité aux habitants que le cours de l\'or s\'effondre pendant plus de 10 ans sur tout le bassin méditerranéen !',
      fullStory:
          'Estimé par les historiens modernes comme l\'un des hommes les plus riches de toute l\'histoire humaine avec une fortune incalculable, Mansa Moussa voyageait avec une caravane de 60 000 personnes et 80 chameaux chargés d\'or pur. Sa prodigalité involontaire provoqua une inflation galopante en Égypte et au Moyen-Orient, forçant le souverain à emprunter de l\'or à des taux élevés sur le chemin du retour pour rééquilibrer le marché mondial.',
      audioNarrationText:
          'Le saviez-vous ? En 1324, l\'empereur du Mali Mansa Moussa a traversé le Caire avec 12 tonnes d\'or pur. Sa générosité légendaire a inondé les marchés, provoquant la chute du cours de l\'or pendant plus de dix ans en Méditerranée !',
      imageUrl: 'assets/images/culture/personnages/mansa_moussa.jpg',
      imageCredits: 'Archives Historiques du Mali • Atlas Catalan (1375)',
      tomorrowTeaser:
          'Demain : Pourquoi un manuscrit coûtait-il plus cher que de l\'or à Tombouctou ?',
      challenge: CuriosityChallenge(
        question:
          'À son retour, quelle ville mythique Mansa Moussa a-t-il dotée de la splendide Mosquée Djingareyber ?',
        options: [
          'Tombouctou',
          'Alexandrie',
          'Casablanca',
        ],
        correctOptionIndex: 0,
        explanation:
          'Exact ! Tombouctou fut propulsée au rang de métropole universelle de la science, de la spiritualité et du commerce.',
        xpReward: 50,
      ),
      collectorCard: CollectorCardBadge(
        cardTitle: 'L\'Empereur d\'Or',
        rarity: 'Légendaire',
        cardNumber: '01 / 30',
        accentColor: Color(0xFFF59E0B),
      ),
    ),

    // ── JOUR 2 : L'UNIVERSITÉ DE SANKORÉ & LES MANUSCRITS ─────────────────────
    DailyCuriosityItem(
      id: 'curiosity_sankore_livres',
      dayNumber: 2,
      hookTitle: 'Quand un livre valait plus cher que de l\'or pur',
      category: 'Savoirs Sahéliens',
      readTime: '20 sec',
      storySnippet:
          'Au XVIe siècle à Tombouctou, le commerce des livres manuscrits rapportait plus d\'argent que celui de l\'or et du sel ! Plus de 25 000 étudiants venus de toute l\'Afrique et du Moyen-Orient étudiaient simultanément l\'astronomie, la médecine et les lois à l\'Université de Sankoré.',
      fullStory:
          'L\'explorateur Léon l\'Africain écrivait à son retour : « À Tombouctou, on vend des manuscrits en grand nombre venus de Barbarie ; on y tire plus de profit de cette vente que de toutes les autres marchandises ». Aujourd\'hui encore, des centaines de milliers de manuscrits traitant d\'algèbre, d\'optique et de droits humains sont jalousement préservés par les familles lettrées.',
      audioNarrationText:
          'Incroyable mais vrai : à Tombouctou au seizième siècle, le commerce des livres manuscrits rapportait plus de bénéfices que l\'or ou le sel. L\'Université de Sankoré accueillait plus de 25 000 étudiants qui étudiaient les mathématiques et l\'astronomie.',
      imageUrl: 'assets/images/culture/monuments/monument_sankore/wm_san_1.jpg',
      imageCredits: 'Mosquée Sankoré, Tombouctou • Wikimedia Commons',
      tomorrowTeaser:
          'Demain : Le miracle de la climatisation naturelle à Djenné sous 45°C à l\'ombre.',
      challenge: CuriosityChallenge(
        question:
          'Combien d\'étudiants l\'Université de Sankoré accueillait-elle à son apogée médiévale ?',
        options: [
          'Environ 25 000',
          'Moins de 500',
          'Environ 2 000',
        ],
        correctOptionIndex: 0,
        explanation:
          'Absolument ! Plus de 25 000 esprits brillants faisaient de Tombouctou l\'épicentre intellectuel du continent.',
        xpReward: 50,
      ),
      collectorCard: CollectorCardBadge(
        cardTitle: 'Le Phare du Savoir',
        rarity: 'Épique',
        cardNumber: '02 / 30',
        accentColor: Color(0xFF3B82F6),
      ),
    ),

    // ── JOUR 3 : LE MIRACLE CLIMATIQUE DE DJENNÉ ─────────────────────────────
    DailyCuriosityItem(
      id: 'curiosity_djenne_climatisation',
      dayNumber: 3,
      hookTitle: 'Le secret du bâtiment en terre qui reste à 22°C sous 45°C',
      category: 'Génie Écologique',
      readTime: '25 sec',
      storySnippet:
          'La Grande Mosquée de Djenné est le plus vaste édifice en terre crue au monde. Grâce à l\'inertie thermique de son banco mêlé de balle de riz et de beurre de karité, l\'intérieur conserve naturellement une température de 22°C même en pleine canicule saharienne !',
      fullStory:
          'Les Barey Ton, maîtres maçons traditionnels de Djenné, utilisent une science ancestrale de la thermodynamique. Les murs épais absorbent la chaleur écrasante pendant les heures du jour et ne la restituent qu\'au cœur de la nuit fraîche. Ses 90 piliers intérieurs créent des couloirs de convection d\'air qui ventilent continuellement la salle des prières sans un seul watt d\'électricité.',
      audioNarrationText:
          'Comment un géant de terre crue reste-t-il frais sous 45 degrés ? À Djenné, les maçons mélangent l\'argile alluviale avec de la balle de riz et du beurre de karité. Les murs respirent et maintiennent naturellement une température de 22 degrés à l\'intérieur !',
      imageUrl: 'assets/images/culture/monuments/monument_mosquee_djenne/dje_1.webp',
      imageCredits: 'Grande Mosquée de Djenné • Cliché Patrimoine UNESCO',
      tomorrowTeaser:
          'Demain : La première déclaration des droits de l\'homme a été proclamée en 1236 au Mali.',
      challenge: CuriosityChallenge(
        question:
          'Quel nom porte la grande corporation séculaire des maçons traditionnels de Djenné ?',
        options: [
          'Les Barey Ton',
          'Les Tônjons',
          'Les Forgerons Niénégé',
        ],
        correctOptionIndex: 0,
        explanation:
          'Bravo ! Les Barey Ton se transmettent de père en fils les secrets géométriques et alchimiques du banco.',
        xpReward: 50,
      ),
      collectorCard: CollectorCardBadge(
        cardTitle: 'Le Sanctuaire Bio-Climatique',
        rarity: 'Légendaire',
        cardNumber: '03 / 30',
        accentColor: Color(0xFFD97706),
      ),
    ),

    // ── JOUR 4 : LA CHARTE DE KOUROUKAN FOUGA (1236) ─────────────────────────
    DailyCuriosityItem(
      id: 'curiosity_charte_manden_1236',
      dayNumber: 4,
      hookTitle: 'Les Droits de l\'Homme sont nés au Mali en 1236',
      category: 'Révolution Éthique',
      readTime: '30 sec',
      storySnippet:
          'Bien avant la Déclaration de 1789, Soundiata Keïta et les sages réunis à Kangaba proclamaient en 1236 la Charte de Kouroukan Fouga : 44 articles oraux sacralisant la dignité de toute vie humaine, l\'égalité de protection, la défense des femmes et la paix sociale !',
      fullStory:
          'Inscrite au Patrimoine culturel immatériel de l\'UNESCO, la Charte du Manden proclame dès son premier article : « Toute vie humaine est une vie. Une vie n\'est pas supérieure à une autre ». Elle institua également la Sinankunya (parenté à plaisanterie), un mécanisme de médiation sociale génial qui désamorce les tensions entre clans par l\'humour et la bienveillance obligatoire.',
      audioNarrationText:
          'Saviez-vous que la toute première déclaration des droits humains est née à Kangaba en 1236 ? Soundiata Keïta a proclamé la Charte du Manden, 44 lois sacrées interdisant la torture, protégeant les femmes et instaurant l\'égalité de la vie humaine.',
      imageUrl: 'assets/images/culture/personnages/soundiata.jpg',
      imageCredits: 'Mémorial Historique de Kangaba, Manden',
      tomorrowTeaser:
          'Demain : La forteresse de 9 kilomètres qui a stoppé 15 mois de siège militaire.',
      challenge: CuriosityChallenge(
        question:
          'Comment s\'appelle le pacte d\'humour et de paix sociale interethnique né dans le Manden ?',
        options: [
          'La Sinankunya (Parenté à plaisanterie)',
          'Le Béré-Goun',
          'Le Manden Mori',
        ],
        correctOptionIndex: 0,
        explanation:
          'Exact ! La Sinankunya permet de désamorcer n\'importe quel conflit par le rire et la fraternité rituelle.',
        xpReward: 50,
      ),
      collectorCard: CollectorCardBadge(
        cardTitle: 'La Voix de Kouroukan Fouga',
        rarity: 'Légendaire',
        cardNumber: '04 / 30',
        accentColor: Color(0xFF10B981),
      ),
    ),

    // ── JOUR 5 : LE TATA DE SIKASSO & LA CITADELLE INEXPUGNABLE ──────────────
    DailyCuriosityItem(
      id: 'curiosity_tata_sikasso_babemba',
      dayNumber: 5,
      hookTitle: 'La muraille de 9 km qui a résisté 15 mois de siège',
      category: 'Résistance Héroïque',
      readTime: '25 sec',
      storySnippet:
          'Le Tata de Sikasso était une colossale muraille fortifiée en banco et latérite de 9 kilomètres de circonférence, avec des murs de 6 mètres de haut et 3 mètres d\'épaisseur à la base. En 1887, elle a tenu en échec l\'armée de Samory Touré pendant 15 mois consécutifs !',
      fullStory:
          'Conçu en trois enceintes concentriques par les rois Tiéba et Babemba Traoré du Kénédougou, le Tata protégeait les cultures agricoles au centre et abritait des milliers de cavaliers. Babemba préféra se donner la mort en 1898 plutôt que d\'être capturé, léguant la légendaire devise patriotique : « Sayi té malo ye » (Plutôt la mort que la honte !).',
      audioNarrationText:
          'À Sikasso, une muraille de 9 kilomètres haute de 6 mètres a autrefois défendu la ville contre les plus grandes armées. Le roi Babemba Traoré y a mené une résistance héroïque, gravant dans l\'histoire la devise : Plutôt la mort que la honte !',
      imageUrl: 'assets/images/culture/monuments/monument_tata_sikasso/wm_tata_1.jpg',
      imageCredits: 'Vestiges du Tata, Sikasso • Cliché Patrimoine Historique',
      tomorrowTeaser:
          'Demain : La Pyramide mystérieuse de Gao érigée en 1495 par l\'Empereur Askia.',
      challenge: CuriosityChallenge(
        question:
          'Quelle est la devise historique immortalisée par le roi Babemba Traoré à Sikasso ?',
        options: [
          'Plutôt la mort que la honte !',
          'Vaincre ou fuir !',
          'La paix à tout prix !',
        ],
        correctOptionIndex: 0,
        explanation:
          'Précisément ! « Sayi té malo ye » reste le serment d\'honneur et de dignité indéfectible du peuple malien.',
        xpReward: 50,
      ),
      collectorCard: CollectorCardBadge(
        cardTitle: 'Le Bouclier du Kénédougou',
        rarity: 'Épique',
        cardNumber: '05 / 30',
        accentColor: Color(0xFFEF4444),
      ),
    ),

    // ── JOUR 6 : LA PYRAMIDE DES ASKIA À GAO (1495) ──────────────────────────
    DailyCuriosityItem(
      id: 'curiosity_tombeau_askia_gao',
      dayNumber: 6,
      hookTitle: 'La Pyramide sahélienne de 17 mètres dressée au bord du Niger',
      category: 'Mystère Impérial',
      readTime: '20 sec',
      storySnippet:
          'En 1495, l\'empereur Askia Mohammed revient de La Mecque et ordonne la construction à Gao d\'une pyramide à degrés en terre crue de 17 mètres de hauteur. Hérissée de poutres de bois d\'acacia, elle domine le fleuve Niger depuis plus de cinq siècles !',
      fullStory:
          'Cette prouesse technique témoigne du génie d\'ingénierie de l\'Empire Songhoï. La structure pyramidale centrale est encadrée de deux mosquées à toit plat, d\'une nécropole impériale et d\'un espace de prière à ciel ouvert. Les poutres apparentes permettent de l\'escalader périodiquement pour les travaux d\'entretien sans aucun échafaudage métallique.',
      audioNarrationText:
          'Saviez-vous que le Mali possède sa propre pyramide ? À Gao, le Tombeau des Askia s\'élève à 17 mètres de haut depuis l\'an 1495. Cette merveille pyramidale en terre crue a traversé plus de cinq siècles sans jamais s\'effondrer.',
      imageUrl: 'assets/images/culture/monuments/monument_tombeau_askia/wm_tomb_1.jpg',
      imageCredits: 'David Sessoms • Wikimedia Commons (CC BY-SA 2.0)',
      tomorrowTeaser:
          'Demain : Pourquoi chaque minaret en banco porte-t-il un œuf d\'autruche à son sommet ?',
      challenge: CuriosityChallenge(
        question:
          'Quel grand empire ouest-africain a bâti la pyramide du Tombeau des Askia à Gao ?',
        options: [
          'L\'Empire Songhoï',
          'L\'Empire Romain',
          'L\'Empire Ottoman',
        ],
        correctOptionIndex: 0,
        explanation:
          'Exact ! L\'Empire Songhoï régnait avec faste sur Gao, Tombouctou et tout le fleuve Niger au XVe siècle.',
        xpReward: 50,
      ),
      collectorCard: CollectorCardBadge(
        cardTitle: 'La Pyramide du Fleuve',
        rarity: 'Légendaire',
        cardNumber: '06 / 30',
        accentColor: Color(0xFF8B5CF6),
      ),
    ),

    // ── JOUR 7 : LE SECRET DES ŒUFS D'AUTRUCHE ───────────────────────────────
    DailyCuriosityItem(
      id: 'curiosity_oeufs_autruche_minarets',
      dayNumber: 7,
      hookTitle: 'Le secret des véritables œufs d\'autruche sur les toits sacrés',
      category: 'Symbole & Mystère',
      readTime: '25 sec',
      storySnippet:
          'Si vous levez les yeux vers les minarets de Djenné ou de Tombouctou, vous remarquerez au sommet de chaque pointe un véritable œuf d\'autruche scellé dans l\'argile. Ce n\'est pas une simple décoration : c\'est à la fois un paratonnerre naturel et un talisman de fertilité !',
      fullStory:
          'Dans la cosmogonie sahélienne et mandingue, l\'œuf d\'autruche symbolise la pureté, la fécondité et la protection des récoltes. Mais les bâtisseurs avaient aussi remarqué une propriété physique capitale : la coquille ultra-dure et la forme ovoïde protègent le sommet du minaret contre l\'érosion torrentielle des fortes pluies hivernales et absorbent la foudre sans fissurer la terre crue.',
      audioNarrationText:
          'Pourquoi voit-on de vrais œufs d\'autruche au sommet des minarets sahéliens ? En plus d\'être un symbole sacré de protection et de fécondité, la coquille dure de l\'œuf protège la pointe d\'argile contre l\'érosion des pluies violentes !',
      imageUrl: 'assets/images/culture/monuments/monument_djingareyber/wm_djin_1.jpg',
      imageCredits: 'Minaret Djingareyber, Tombouctou • Wikimedia Commons',
      tomorrowTeaser:
          'Demain : Comment Biton Coulibaly a créé une armée invulnérable avec de simples pirogues.',
      challenge: CuriosityChallenge(
        question:
          'Que symbolise traditionnellement l\'œuf d\'autruche au sommet des édifices sahéliens ?',
        options: [
          'La pureté, la fécondité et la protection',
          'La richesse commerciale',
          'L\'appartenance royale uniquement',
        ],
        correctOptionIndex: 0,
        explanation:
          'Parfaitement exact ! Il protège la communauté et sanctifie le point de jonction entre la terre et le ciel.',
        xpReward: 50,
      ),
      collectorCard: CollectorCardBadge(
        cardTitle: 'Le Talisman des Cieux',
        rarity: 'Rare',
        cardNumber: '07 / 30',
        accentColor: Color(0xFFEC4899),
      ),
    ),
  ];

  /// Récupère la pépite du jour calendaire (déterministe et rotative)
  static DailyCuriosityItem getTodayItem() {
    final now = DateTime.now();
    // Utiliser le jour de l'année (1..366)
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % items.length;
    return items[index];
  }

  /// Récupère une pépite par son identifiant
  static DailyCuriosityItem? findById(String id) {
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
