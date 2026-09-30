import 'package:flutter/material.dart';
import '../models/culture_proverb_models.dart';

/// Données culturelles de sagesses, proverbes et maximes des terroirs maliens
class MockCultureProverbsData {
  static const List<CultureProverb> proverbs = [
    // ── 1. MANDEN / KOULIKORO ───────────────────────────────────────────────
    CultureProverb(
      id: 'prov_humilite',
      text: "L'eau chaude n'oublie jamais qu'elle a été froide.",
      originalText: "Ji kalan tɛ ɲina a nɛnɛ kɔ.",
      meaning:
          "Peu importe ton ascension, ta gloire ou ta réussite, n'oublie jamais d'où tu viens et conserve l'humilité du premier jour.",
      moral: "L'humilité face au destin et aux origines",
      origin: "Tradition Orale Bamanan (Manden)",
      theme: "Humilité",
      regionId: "koulikoro",
      regionName: "Koulikoro / Manden",
      xpReward: 45,
      stageImagePath: 'assets/images/culture/contes/manden_baobab_stage.jpg',
      speakerName: 'Le Sage du Baobab',
      speakerRole: 'Doyen des Sages',
      speakerAvatar: 'assets/images/culture/contes/sage_baobab.jpg',
      accentColor: Color(0xFFF1851F),
    ),
    CultureProverb(
      id: 'prov_parole_eau',
      text:
          "La parole est comme l'eau : une fois versée à terre, nul ne peut la ramasser.",
      originalText: "Kuma ye ji ye, n'a bɔra a tɛ se ka sɔrɔ tuguni.",
      meaning:
          "La parole donnée engage l'honneur et la dignité humaine. Il convient de peser chaque propos avant de le prononcer.",
      moral: "La valeur sacrée de la parole donnée",
      origin: "Parole des Griots du Manden",
      theme: "Honneur & Sagesse",
      regionId: "koulikoro",
      regionName: "Koulikoro / Manden",
      xpReward: 40,
      stageImagePath: 'assets/images/culture/contes/savane_crepuscule_stage.jpg',
      speakerName: 'Babani le Griot',
      speakerRole: 'Maître de la Parole',
      speakerAvatar: 'assets/images/culture/griot_sage.jpg',
      accentColor: Color(0xFFE65100),
    ),

    // ── 2. SÉGOU (CITÉ DES BALANZANS) ───────────────────────────────────────
    CultureProverb(
      id: 'prov_experience_segou',
      text:
          "Ce qu'un vieillard voit assis, un jeune homme debout ne peut l'apercevoir.",
      originalText: "Kɔrɔkɛ sigilen fɛn min ye, kamalen lɔnin t'o ye.",
      meaning:
          "L'expérience, le discernement et la sagesse forgés au fil des épreuves de la vie surpassent la simple vivacité ou la force physique de la jeunesse.",
      moral: "L'expérience surpasse la force brute",
      origin: "Royaume Bamanan de Ségou",
      theme: "Sagesse & Respect",
      regionId: "segou",
      regionName: "Ségou",
      xpReward: 50,
      stageImagePath: 'assets/images/culture/contes/segou_djoliba_stage.jpg',
      speakerName: 'Doyen de Balanzan',
      speakerRole: 'Ancien de Ségou',
      speakerAvatar: 'assets/images/culture/contes/sage_baobab.jpg',
      accentColor: Color(0xFF0284C7),
    ),
    CultureProverb(
      id: 'prov_patience_fleuve',
      text:
          "Le fleuve qui coule tranquillement ne craint pas la tempête de sable.",
      originalText: "Ba min be boli dɔɔnin dɔɔnin, o tɛ siran cencen fɔɲɔ ɲɛ.",
      meaning:
          "La persévérance patiente et la constance surmontent toujours les agitations passagères et les tempêtes de l'existence.",
      moral: "La sérénité et la constance victorieuses",
      origin: "Pêcheurs Bozo & Sages du Niger",
      theme: "Patience",
      regionId: "segou",
      regionName: "Ségou",
      xpReward: 45,
      stageImagePath: 'assets/images/culture/contes/segou_djoliba_stage.jpg',
      speakerName: 'Pêcheur Bozo',
      speakerRole: 'Gardien du Djoliba',
      speakerAvatar: 'assets/images/culture/contes/oiseau_djoliba.jpg',
      accentColor: Color(0xFF0D9488),
    ),

    // ── 3. PAYS DOGON / MOPTI (FALAISE DE BANDIAGARA) ───────────────────────
    CultureProverb(
      id: 'prov_solidarite_main',
      text: "Une seule main ne peut pas ramasser la farine.",
      originalText: "Bolo kelen tɛ se ka mugu ta.",
      meaning:
          "L'individualisme est une illusion face aux grands défis ; l'union solidaire et le travail communautaire sont les seuls garants de prospérité.",
      moral: "L'union communautaire fait la force",
      origin: "Tradition Dogon de Bandiagara",
      theme: "Solidarité",
      regionId: "mopti",
      regionName: "Mopti / Pays Dogon",
      xpReward: 40,
      stageImagePath: 'assets/images/culture/contes/savane_crepuscule_stage.jpg',
      speakerName: 'L\'Ancien de la Falaise',
      speakerRole: 'Patriarche du Toguna',
      speakerAvatar: 'assets/images/culture/contes/sage_baobab.jpg',
      accentColor: Color(0xFFD97706),
    ),
    CultureProverb(
      id: 'prov_grain_millet',
      text:
          "Le grain de mil semé dans la paix nourrit tout un village ; semé dans la discorde, il pourrit.",
      originalText: "Hɛrɛ sanyɛ be dugu balo.",
      meaning:
          "L'harmonie sociale et l'entente cordiale constituent le terreau indispensable à toute création de richesse et de sécurité alimentaire.",
      moral: "La concorde sociale engendre l'abondance",
      origin: "Sagesse Rurale du Delta Intérieur",
      theme: "Paix & Harmonie",
      regionId: "mopti",
      regionName: "Mopti",
      xpReward: 45,
      stageImagePath: 'assets/images/culture/contes/savane_crepuscule_stage.jpg',
      speakerName: 'Sagesse du Delta',
      speakerRole: 'Maître du Toguna',
      speakerAvatar: 'assets/images/culture/griot_sage.jpg',
      accentColor: Color(0xFFF59E0B),
    ),

    // ── 4. TOMBOUCTOU (LA CITÉ MYSTIQUE AUX 333 SAINTS) ─────────────────────
    CultureProverb(
      id: 'prov_savoir_tombouctou',
      text:
          "L'encre de l'écolier est plus précieuse que tout l'or des caravanes.",
      originalText: "Al-’ilmu nūr (Le savoir est une lumière inextinguible).",
      meaning:
          "La quête du savoir, la lecture et l'esprit critique illuminent l'humanité bien au-delà de la richesse matérielle éphémère.",
      moral: "La primauté absolue de la connaissance",
      origin: "Université Sankoré de Tombouctou",
      theme: "Savoir & Éducation",
      regionId: "tombouctou",
      regionName: "Tombouctou",
      xpReward: 50,
      stageImagePath: 'assets/images/culture/contes/tombouctou_dunes_stage.jpg',
      speakerName: 'Savant de Sankoré',
      speakerRole: 'Gardien des Manuscrits',
      speakerAvatar: 'assets/images/culture/contes/gardien_etoiles.jpg',
      accentColor: Color(0xFF6366F1),
    ),
    CultureProverb(
      id: 'prov_dunes_vent',
      text:
          "Le vent efface la trace du chameau sur la dune, mais jamais la réputation d'un homme juste.",
      originalText: "Cencen be tɛmɛ, nka tɔgɔ ɲuman tɛ banna.",
      meaning:
          "Les richesses et les pas s'évanouissent dans le désert, mais l'intégrité morale et la justice restent gravées dans la mémoire éternelle.",
      moral: "L'intégrité morale traverse les siècles",
      origin: "Nomades Kel Tamasheq & Caravaniers",
      theme: "Justice & Dignité",
      regionId: "tombouctou",
      regionName: "Tombouctou",
      xpReward: 45,
      stageImagePath: 'assets/images/culture/contes/tombouctou_dunes_stage.jpg',
      speakerName: 'Bilal le Chamelier',
      speakerRole: 'Guide des Azalaïs',
      speakerAvatar: 'assets/images/culture/contes/bilal_chamelier.jpg',
      accentColor: Color(0xFFEAB308),
    ),

    // ── 5. SIKASSO (LE ROYAUME DU KÉNÉDOUGOU) ────────────────────────────────
    CultureProverb(
      id: 'prov_arbre_crocodile',
      text:
          "Même si la bûche séjourne cent ans dans l'eau, elle ne deviendra jamais un crocodile.",
      originalText: "Jiri koro men ji la cogo o cogo, a tɛ kɛ bama ye.",
      meaning:
          "Chacun doit assumer ses véritables racines, sa culture et son identité. Nul artifice ne saurait altérer sa vraie nature.",
      moral: "L'authenticité et la fierté des racines",
      origin: "Tradition Sénoufo / Kénédougou",
      theme: "Vérité & Identité",
      regionId: "sikasso",
      regionName: "Sikasso",
      xpReward: 45,
      stageImagePath: 'assets/images/culture/contes/manden_baobab_stage.jpg',
      speakerName: 'Le Forgeron Dozo',
      speakerRole: 'Initié du Kénédougou',
      speakerAvatar: 'assets/images/culture/contes/fode_forgeron.jpg',
      accentColor: Color(0xFFEA580C),
    ),

    // ── 6. KAYES (TERRE DU KHASSO & WAGADOU) ─────────────────────────────────
    CultureProverb(
      id: 'prov_racines_branches',
      text:
          "L'arbre qui s'élève fier vers les cieux doit la vigueur de ses branches à la profondeur de ses racines.",
      originalText: "Yiri janya be bɔ a dugukolo jukɔrɔ fɔlɔ.",
      meaning:
          "L'élévation spirituelle ou sociale n'est solide que lorsqu'elle est solidement ancrée dans le socle de ses traditions et de ses aïeux.",
      moral: "La grandeur prend racine dans l'héritage",
      origin: "Tradition Khassonké & Soninké",
      theme: "Mémoire & Racines",
      regionId: "kayes",
      regionName: "Kayes",
      xpReward: 40,
      stageImagePath: 'assets/images/culture/contes/wagadou_koumbi_stage.jpg',
      speakerName: 'Griot Khassonké',
      speakerRole: 'Mémoire du Wagadou',
      speakerAvatar: 'assets/images/culture/griot_sage.jpg',
      accentColor: Color(0xFFC026D3),
    ),

    // ── 7. GAO (CITÉ IMPÉRIALE DES ASKIA) ───────────────────────────────────
    CultureProverb(
      id: 'prov_ensemble_loin',
      text:
          "Si tu veux aller vite, marche seul ; mais si tu veux aller loin, marchons ensemble.",
      originalText: "A borey kulu ga bindi (Ensemble nous avançons).",
      meaning:
          "La solitude produit des succès éphémères ; la fraternité et le cheminement commun bâtissent des civilisations durables.",
      moral: "La marche commune bâtit l'avenir",
      origin: "Tradition Impériale Songhaï",
      theme: "Patience & Fraternité",
      regionId: "gao",
      regionName: "Gao",
      xpReward: 45,
      stageImagePath: 'assets/images/culture/contes/savane_crepuscule_stage.jpg',
      speakerName: 'Chroniqueur des Askia',
      speakerRole: 'Gardiens du Tombeau',
      speakerAvatar: 'assets/images/culture/contes/gardien_etoiles.jpg',
      accentColor: Color(0xFF2563EB),
    ),

    // ── 8. BAMAKO / TOUT LE MALI ────────────────────────────────────────────
    CultureProverb(
      id: 'prov_partage_feu',
      text: "Le feu que l'on donne pour allumer le foyer d'autrui n'éteint pas le nôtre.",
      originalText: "Tasuma min be di mɔgɔ ma, o tɛ e ka tasuma faga.",
      meaning:
          "Transmettre son savoir, son entraide ou son affection ne diminue en rien sa propre richesse ; au contraire, cela illumine tout le village.",
      moral: "Le partage enrichit celui qui donne",
      origin: "Sagesse Panafricaine & Malienne",
      theme: "Générosité & Partage",
      regionId: null,
      regionName: "Tout le Mali",
      xpReward: 40,
      stageImagePath: 'assets/images/culture/contes/manden_baobab_stage.jpg',
      speakerName: 'Mère Veilleuse du Foyer',
      speakerRole: 'Sagesse des Mères',
      speakerAvatar: 'assets/images/culture/contes/sage_baobab.jpg',
      accentColor: Color(0xFFF1851F),
    ),
  ];

  /// Filtrer les proverbes par région
  static List<CultureProverb> getFiltered({String? regionId}) {
    if (regionId == null || regionId.isEmpty || regionId == 'all') {
      return proverbs;
    }
    final results = proverbs.where((p) => p.matchesRegion(regionId)).toList();
    return results.isNotEmpty ? results : proverbs;
  }

  /// Proverbe du jour (rotation déterministe basée sur le jour de l'année)
  static CultureProverb get featuredProverb {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return proverbs[dayOfYear % proverbs.length];
  }
}
