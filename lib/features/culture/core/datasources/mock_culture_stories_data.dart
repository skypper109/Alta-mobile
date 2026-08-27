import 'package:flutter/material.dart';
import '../models/culture_detail_models.dart';
import '../models/culture_story_models.dart';

/// Recueil authentique et scénarisé des Contes & Récits Interactifs du Mali
abstract final class MockCultureStoriesData {
  static const List<InteractiveStory> stories = [
    // ── 1. ZOUMANA LE LIÈVRE ET NAMORI L'HYÈNE (TOUT LE MALI / MANDEN) ──────
    InteractiveStory(
      id: 'conte_lievre_hyene',
      title: 'Zoumana le Lièvre et Namori l\'Hyène',
      subtitle: 'La ruse de l\'esprit face à la force et la gourmandise',
      origin: 'Tradition Orale Mandingue',
      regionId: null,
      regionName: 'Tout le Mali',
      tag: 'Fable Mandingue',
      photoUrl: 'assets/images/culture/villes/djenne_ville.jpg',
      photoCredits: 'Contes des Veillées Sahéliennes • Archives Nationales du Mali',
      summary:
          'Lors d\'une grande sécheresse sur la savane, les animaux décident de creuser un puits commun. Tandis que Namori l\'hyène cherche à s\'accaparer les réserves par la force, le lièvre Zoumana use d\'intelligence et de ruse pour préserver la justice du village.',
      narrator: 'Griot Mamadou Kouyaté (Kangaba)',
      audioDuration: '5 min 40',
      readingDuration: '3 min 30',
      isFeatured: true,
      progress: 0.45,
      moral:
          '« La force sans réflexion creuse son propre piège ; la sagesse et la mesure triomphent toujours de la cupidité. »',
      connectedItems: [
        ConnectedItemRef(
          id: 'perso_soundiata',
          title: 'Soundiata Keïta',
          subtitle: 'Garant de la justice et de la parole donnée',
          type: ConnectedItemType.personnage,
          tag: 'Mansa',
          regionName: 'Koulikoro',
          icon: Icons.person_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_segou_koro',
          title: 'Ségou-Koro',
          subtitle: 'Berceau des veillées au bord du Djoliba',
          type: ConnectedItemType.ville,
          tag: 'Cité Royale',
          regionName: 'Ségou',
          icon: Icons.location_city_rounded,
        ),
      ],
      scenes: [
        StoryScene(
          id: 'scene_1',
          sceneNumber: 1,
          title: 'La Grande Soif de la Savane',
          atmosphere: 'Crépuscule rougeoyant • Bruit du vent dans les herbes dorées',
          narrativeText:
              'Le soleil s\'enfonce à l\'horizon du Manden. La poussière ocre flotte dans l\'air chaud et l\'harmattan souffle sur la terre aride. Les animaux du village se rassemblent autour du sage patriarche. L\'eau vient à manquer.\n\nZoumana le Lièvre s\'avance au milieu du cercle. Namori l\'Hyène, la gueule béante et l\'œil avide, grogne déjà dans l\'ombre en réclamant la part du lion.',
          culturalInsight:
              '💡 Dans la tradition mandingue, les veillées de contes débutent toujours après la tombée de la nuit par la formule rituelle : « Conte, conte, conte ! Que le conte soit beau ! »',
          choices: [
            StoryChoice(
              id: 'c1_a',
              label: 'A — Proposer d\'unir les forces pour creuser un grand puits',
              description: 'La voie du travail solidaire et de la fraternité villageoise.',
              nextSceneId: 'scene_2_puits',
              trait: 'Voie de l\'Entraide',
              icon: Icons.handshake_rounded,
            ),
            StoryChoice(
              id: 'c1_b',
              label: 'B — Observer Namori en silence pour déjouer ses plans',
              description: 'La voie de la prudence et de l\'analyse stratégique.',
              nextSceneId: 'scene_2_ruse',
              trait: 'Voie de la Prudence',
              icon: Icons.visibility_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'scene_2_puits',
          sceneNumber: 2,
          title: 'L\'Effort Commun et la Trahison de la Nuit',
          atmosphere: 'Nuit noire éclairée par la pleine lune • Murmure de l\'eau fraîche',
          narrativeText:
              'Après des heures d\'effort où chacun a sué sur la terre dure, l\'eau jaillit enfin, claire et pure comme un miroir d\'argent.\n\nMais la nuit venue, alors que tous dorment, des pas lourds s\'approchent. Namori s\'est faufilée pour voler la réserve d\'eau et tromper ses frères. Zoumana, posté derrière un buisson d\'épineux, la voit approcher.',
          culturalInsight:
              '💡 La solidarité communautaire (Sinankunya et Gwa) est sacralisée dans la Charte de Kouroukan Fouga de 1236.',
          choices: [
            StoryChoice(
              id: 'c2_a',
              label: 'A — Enduire une calebasse de miel doré pour piéger Namori',
              description: 'Attirer l\'hyène par sa propre gourmandise insatiable.',
              nextSceneId: 'scene_3_piege_miel',
              trait: 'Ruse Mandingue',
              icon: Icons.emoji_objects_rounded,
            ),
            StoryChoice(
              id: 'c2_b',
              label: 'B — Imiter la voix redoutable du génie gardien de la nuit',
              description: 'Utiliser la terreur sacrée pour faire fuir l\'intruse.',
              nextSceneId: 'scene_3_voix_genie',
              trait: 'Audace & Esprit',
              icon: Icons.record_voice_over_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'scene_2_ruse',
          sceneNumber: 2,
          title: 'La Traque dans l\'Ombre',
          atmosphere: 'Silence pesant de la brousse • Cri lointain d\'un oiseau nocturne',
          narrativeText:
              'En restant dissimulé, Zoumana découvre la cachette où Namori dissimule la calebasse sacrée du village. L\'hyène compte s\'enfuir avant l\'aube vers les collines de grès.\n\nZoumana doit agir avec promptitude avant que la caravane des chasseurs ne passe.',
          culturalInsight:
              '💡 Le lièvre incarne dans les contes ouest-africains le triomphe de la vivacité d\'esprit sur la force brute incontrôlée.',
          choices: [
            StoryChoice(
              id: 'c2_c',
              label: 'A — Remplacer discrètement l\'eau par du sable magique',
              description: 'Une leçon d\'illusion pour désorienter la voleuse.',
              nextSceneId: 'scene_3_piege_miel',
              trait: 'Voie de l\'Illusion',
              icon: Icons.auto_fix_high_rounded,
            ),
            StoryChoice(
              id: 'c2_d',
              label: 'B — Alerter le chef des chasseurs Dozo avec le cor de guerre',
              description: 'Faire appel à l\'autorité morale et coutumière.',
              nextSceneId: 'scene_3_voix_genie',
              trait: 'Voie Coutumière',
              icon: Icons.shield_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'scene_3_piege_miel',
          sceneNumber: 3,
          title: 'Le Piège de la Gourmandise',
          atmosphere: 'Clarté de l\'aube naissante • Éclats de rire des oiseaux du fleuve',
          narrativeText:
              'Attirée par l\'odeur du miel, Namori plonge la tête la première dans le piège ! Ses pattes restent collées, et ses grognements ridicules réveillent tout le village assemblé.\n\nLe sage du village s\'avance sous les acclamations. Devant la honte de l\'hyène et le sourire calme de Zoumana, la vérité éclate au grand jour.',
          culturalInsight:
              '💡 Les fables traditionnelles ne visent pas la punition violente mais la honte éducative et le rétablissement de l\'harmonie.',
          isEpilogue: true,
        ),
        StoryScene(
          id: 'scene_3_voix_genie',
          sceneNumber: 3,
          title: 'La Fuite Éperdue et le Jugement du Conseil',
          atmosphere: 'Aurore dorée • Brume matinale sur les berges',
          narrativeText:
              'Croyant entendre la voix des aïeux courroucés, Namori trébuche, lâche son butin et s\'enfuit à toutes jambes vers la forêt lointaine ! L\'eau du puits est sauvée pour tous les enfants du village.\n\nZoumana est salué par les anciens comme le gardien de la paix et de la justice.',
          culturalInsight:
              '💡 La parole juste (Kuma Kuma) est considérée comme l\'arme la plus noble dans la culture malienne.',
          isEpilogue: true,
        ),
      ],
    ),

    // ── 2. LA LÉGENDE DU SERPENT WAGADOU BIDA (KAYES / KOUMBI SALEH) ─────────
    InteractiveStory(
      id: 'conte_wagadou_bida',
      title: 'La Légende du Serpent Wagadou Bida',
      subtitle: 'Le mythe fondateur de l\'Empire du Ghana & le pacte sacré',
      origin: 'Épopée Soninké de l\'Ancien Ghana',
      regionId: 'kayes',
      regionName: 'Kayes',
      tag: 'Récit Mythique Fondateur',
      photoUrl: 'assets/images/culture/monuments/fort_medine.jpg',
      photoCredits: 'Tradition Soninké • Archives Régionales de Kayes',
      summary:
          'À Koumbi Saleh, le pacte conclu avec le serpent sacré Wagadou Bida garantissait pluie abondante et pépites d\'or sur l\'empire. Mais un jour, un jeune guerrier épris de justice et d\'amour décide de défier le destin.',
      narrator: 'Diénéba Diabaté (Griots du Haut-Sénégal)',
      audioDuration: '7 min 15',
      readingDuration: '4 min 30',
      isFeatured: false,
      progress: 0.0,
      moral:
          '« Les pactes qui exigent des sacrifices injustes portent en eux le germe de leur propre chute. La véritable prospérité repose sur le courage et la liberté. »',
      connectedItems: [
        ConnectedItemRef(
          id: 'monument_fort_medine',
          title: 'Fort de Médine',
          subtitle: 'Gardien des mémoires du Haut-Sénégal',
          type: ConnectedItemType.monument,
          tag: 'Haut-Sénégal',
          regionName: 'Kayes',
          icon: Icons.fort_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_djenne',
          title: 'Djenné',
          subtitle: 'Carrefour des grandes caravanes transsahariennes',
          type: ConnectedItemType.ville,
          tag: 'UNESCO',
          regionName: 'Mopti',
          icon: Icons.location_city_rounded,
        ),
      ],
      scenes: [
        StoryScene(
          id: 'wb_scene_1',
          sceneNumber: 1,
          title: 'L\'Ombre sur Koumbi Saleh',
          atmosphere: 'Ciel d\'orage grondant sur les remparts de pierre de Koumbi Saleh',
          narrativeText:
              'Chaque année, le serpent géant Wagadou Bida exigeait un tribut sacré pour faire pleuvoir des pépites d\'or sur le royaume du Wagadou. Mais cette année, la jeune Sia, renommée pour sa pureté et sa bravoure, est désignée.\n\nSon fiancé, le preux cavalier Mamadou Lamine, refuse de courber l\'échine devant la fatalité.',
          culturalInsight:
              '💡 L\'Empire du Ghana (Wagadou), fondé au IVe siècle, était surnommé « le pays de l\'or » par les chroniqueurs arabes.',
          choices: [
            StoryChoice(
              id: 'wb_c1_a',
              label: 'A — Forger une lame sacrée auprès du grand maître du fer',
              description: 'Chercher la puissance des forgerons gardiens du secret des métaux.',
              nextSceneId: 'wb_scene_2_forge',
              trait: 'Voie du Fer',
              icon: Icons.shield_rounded,
            ),
            StoryChoice(
              id: 'wb_c1_b',
              label: 'B — Consulter les devins au sanctuaire de la source sacrée',
              description: 'Comprendre la faiblesse secrète du monstre légendaire.',
              nextSceneId: 'wb_scene_2_oracle',
              trait: 'Voie des Savoirs',
              icon: Icons.psychology_alt_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'wb_scene_2_forge',
          sceneNumber: 2,
          title: 'Le Sabre aux Sept Trempes',
          atmosphere: 'Fournaise rougeoyante • Sons cadencés de l\'enclume ancestrale',
          narrativeText:
              'Le chef des forgerons forge un sabre étincelant trempé dans les eaux mystiques du fleuve Sénégal. « Cette lame tranchera l\'illusion de la peur, Mamadou. Mais sois prêt à affronter la colère des éléments ! »\n\nMamadou monte son étalon blanc et galope jusqu\'au puits sacré.',
          culturalInsight:
              '💡 Les Numuw (forgerons) jouissaient d\'un statut quasi-sacré au Mali, maîtres de la transformation et médiateurs du monde spirituel.',
          choices: [
            StoryChoice(
              id: 'wb_c2_a',
              label: 'A — Affronter le serpent dès qu\'il surgit du puits',
              description: 'Le choc frontal héroïque au nom de la liberté.',
              nextSceneId: 'wb_scene_3_victoire',
              trait: 'Bravoure Absolue',
              icon: Icons.flash_on_rounded,
            ),
            StoryChoice(
              id: 'wb_c2_b',
              label: 'B — Rompre la chaîne magique qui lie le peuple au pacte',
              description: 'Délivrer d\'abord les esprits avant d\'abattre l\'idole.',
              nextSceneId: 'wb_scene_3_victoire',
              trait: 'Libérateur',
              icon: Icons.lock_open_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'wb_scene_2_oracle',
          sceneNumber: 2,
          title: 'La Prophétie des Sept Têtes',
          atmosphere: 'Vapeurs d\'encens • Murmures rituels des devins du Wagadou',
          narrativeText:
              'Les anciens devins révèlent : « Le serpent n\'a de pouvoir que par la crainte qu\'il inspire. Tranche ses têtes sans hésitation, et le peuple découvrira que sa vraie richesse n\'est pas dans l\'or, mais dans sa volonté ! »',
          culturalInsight:
              '💡 Le mythe de Wagadou Bida symbolise la fin de l\'ère des tributs archaïques et l\'essor des grands empires marchands.',
          choices: [
            StoryChoice(
              id: 'wb_c2_c',
              label: 'A — Galoper vers le puits et trancher les têtes du monstre',
              description: 'L\'action décisive guidée par la sagesse des devins.',
              nextSceneId: 'wb_scene_3_victoire',
              trait: 'Accomplissement',
              icon: Icons.stars_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'wb_scene_3_victoire',
          sceneNumber: 3,
          title: 'La Libération du Wagadou',
          atmosphere: 'Soleil éclatant dissipant les ténèbres • Chants de délivrance',
          narrativeText:
              'D\'un geste magistral, Mamadou abat le monstre et sauve Sia sous les clameurs de joie du peuple de Koumbi Saleh !\n\nBien que la pluie d\'or cesse, les Soninkés se tournent vers le commerce, l\'agriculture et la sagesse, bâtissant une réputation de bâtisseurs qui traversera les siècles.',
          culturalInsight:
              '💡 La mémoire de Wagadou Bida est encore chantée de nos jours par les griots Geseru à Kayes et dans tout le Sahel.',
          isEpilogue: true,
        ),
      ],
    ),

    // ── 3. LE FORGERON ET L'OISEAU DU DJOLIBA (SÉGOU) ────────────────────────
    InteractiveStory(
      id: 'conte_forgeron_oiseau',
      title: 'Le Forgeron et l\'Oiseau du Djoliba',
      subtitle: 'Secret de la forge sacrée et respect des esprits du fleuve',
      origin: 'Tradition Bambara de Ségou',
      regionId: 'segou',
      regionName: 'Ségou',
      tag: 'Conte Initiatique',
      photoUrl: 'assets/images/culture/villes/segou_koro.jpg',
      photoCredits: 'Contes des 4 444 Balanzans • Archives Culturelles de Ségou',
      summary:
          'Sur les rives du fleuve Niger à Ségou-Koro, le jeune apprenti forgeron Fodé entend le chant envoûtant d\'un oiseau aux plumes d\'argent. Pour percer le secret du métal indestructible, il doit choisir entre la soif de puissance et l\'harmonie avec les esprits de l\'eau.',
      narrator: 'Balla Fasséké Diabaté',
      audioDuration: '6 min 10',
      readingDuration: '4 min 00',
      isFeatured: false,
      progress: 0.15,
      moral:
          '« La maîtrise d\'un art ne réside pas dans la domination, mais dans l\'écoute respectueuse des forces de la nature. »',
      connectedItems: [
        ConnectedItemRef(
          id: 'perso_biton_coulibaly',
          title: 'Biton Coulibaly',
          subtitle: 'Fondateur du Royaume de Ségou',
          type: ConnectedItemType.personnage,
          tag: 'Royaume de Ségou',
          regionName: 'Ségou',
          icon: Icons.military_tech_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_segou_koro',
          title: 'Ségou-Koro',
          subtitle: 'Cité royale aux 4 444 Balanzans',
          type: ConnectedItemType.ville,
          tag: 'Cité Royale',
          regionName: 'Ségou',
          icon: Icons.location_city_rounded,
        ),
      ],
      scenes: [
        StoryScene(
          id: 'fo_scene_1',
          sceneNumber: 1,
          title: 'Le Chant au Coucher du Soleil',
          atmosphere: 'Reflets d\'or sur les eaux calmes du fleuve Djoliba • Brise tiède',
          narrativeText:
              'Assis au bord de l\'eau après une longue journée à souffler sur les braises, Fodé contemple le Djoliba. Soudain, perché sur la branche d\'un balanzan centenaire, un oiseau étincelant entonne une mélodie qui fait vibrer le métal de ses outils.\n\n« Forgeron, dit l\'oiseau, cherches-tu le secret qui rend le fer aussi souple que l\'eau et aussi dur que le diamant ? »',
          culturalInsight:
              '💡 Le fleuve Niger est appelé Djoliba (« le fleuve de sang / de vie ») en langue bambara et mandingue.',
          choices: [
            StoryChoice(
              id: 'fo_c1_a',
              label: 'A — Répondre avec humilité et offrir une calebasse de lait frais',
              description: 'Montrer le respect des lois de l\'hospitalité et de la courtoisie.',
              nextSceneId: 'fo_scene_2_secret',
              trait: 'Voie de l\'Humilité',
              icon: Icons.favorite_rounded,
            ),
            StoryChoice(
              id: 'fo_c1_b',
              label: 'B — Demander immédiatement la formule secrète du métal royal',
              description: 'Poursuivre la quête de gloire pour impressionner la cour de Ségou.',
              nextSceneId: 'fo_scene_2_epreuve',
              trait: 'Voie de l\'Ambition',
              icon: Icons.auto_awesome_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'fo_scene_2_secret',
          sceneNumber: 2,
          title: 'L\'Alliance du Feu et de l\'Eau',
          atmosphere: 'Clarté lunaire scintillante sur le fleuve • Flamme bleue apaisante',
          narrativeText:
              'Touché par la bienveillance de Fodé, l\'oiseau plonge dans les flots et en ressort tenant une braise aquatique. « Ne frappe jamais le fer avec colère. Tempère-le avec patience, en pensant à la vie qu\'il protégera. »\n\nFodé regagne l\'atelier pour forger son premier chef-d\'œuvre.',
          culturalInsight:
              '💡 À Ségou, la corporation des forgerons fabriquait tant les armes de défense des Tônjons que les houes agricoles nourricières.',
          choices: [
            StoryChoice(
              id: 'fo_c2_a',
              label: 'A — Forger une houe sacrée pour féconder la terre des paysans',
              description: 'Consacrer son art au bien-être de la communauté.',
              nextSceneId: 'fo_scene_3_epilogue_paix',
              trait: 'Bâtisseur de Paix',
              icon: Icons.agriculture_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'fo_scene_2_epreuve',
          sceneNumber: 2,
          title: 'L\'Épreuve de la Flamme Noire',
          atmosphere: 'Tonnere sourd • Tourbillon d\'étincelles vives',
          narrativeText:
              'L\'oiseau s\'élève et déclenche un feu ardent. « L\'ambition sans sagesse consume celui qui la porte ! Prouve que ton cœur ne brûle pas d\'orgueil avant de toucher à ce secret. »',
          culturalInsight:
              '💡 Les mythes initiatiques du Komo enseignent que la connaissance spirituelle précède toujours la maîtrise technique.',
          choices: [
            StoryChoice(
              id: 'fo_c2_b',
              label: 'A — S\'agenouiller et reconnaître ses limites devant les esprits',
              description: 'La sagesse du repentir qui ouvre les portes du savoir.',
              nextSceneId: 'fo_scene_3_epilogue_paix',
              trait: 'Sagesse Retrouvée',
              icon: Icons.psychology_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'fo_scene_3_epilogue_paix',
          sceneNumber: 3,
          title: 'Le Maître Forgeron du Royaume',
          atmosphere: 'Chants des balafons au lever du jour à Ségou-Koro',
          narrativeText:
              'Fodé devient le plus respecté des forgerons du Royaume de Ségou. Ses ouvrages, façonnés avec respect et amour du peuple, ne rouilleront jamais.\n\nChaque soir, il dépose une pincée de grains au bord du fleuve en mémoire de l\'oiseau du Djoliba.',
          culturalInsight:
              '💡 Les Balanzans (acacias sacrés de Ségou) sont réputés abriter les esprits protecteurs de la cité.',
          isEpilogue: true,
        ),
      ],
    ),

    // ── 4. LE CHASSEUR DOZO ET LE BAOBAB SACRÉ (KOULIKORO / MANDEN) ──────────
    InteractiveStory(
      id: 'conte_baobab_chasseur',
      title: 'Le Chasseur Dozo et le Secret du Baobab Sacré',
      subtitle: 'La sagesse de la confrérie des chasseurs et le respect de la faune',
      origin: 'Tradition des Maîtres Chasseurs Dozo',
      regionId: 'koulikoro',
      regionName: 'Koulikoro',
      tag: 'Conte Initiatique Dozo',
      photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
      photoCredits: 'Confrérie Dozo du Manden • Mémorial de Siby',
      summary:
          'Dans les collines sacrées du Manden, le jeune chasseur Moussa s\'égare au cœur de la forêt touffue. Arrivé au pied d\'un gigantesque baobab millénaire, il rencontre un vieil aveugle qui lui propose trois maximes initiatiques pour retrouver son chemin.',
      narrator: 'Dozo-kuntigui Sékou Traoré',
      audioDuration: '5 min 50',
      readingDuration: '3 min 45',
      isFeatured: false,
      progress: 0.0,
      moral:
          '« La nature donne à celui qui demande avec respect et retire tout à celui qui prend avec avidité. »',
      connectedItems: [
        ConnectedItemRef(
          id: 'perso_soundiata',
          title: 'Soundiata Keïta',
          subtitle: 'Le Grand Chasseur du Manden',
          type: ConnectedItemType.personnage,
          tag: 'Mansa Bâtisseur',
          regionName: 'Koulikoro',
          icon: Icons.person_rounded,
        ),
      ],
      scenes: [
        StoryScene(
          id: 'bd_scene_1',
          sceneNumber: 1,
          title: 'L\'Étoile Perdue dans la Forêt',
          atmosphere: 'Crépuscule sous les grands arbres • Bruissement des feuilles de baobab',
          narrativeText:
              'Le jeune Moussa porte l\'habit de toile ocre des chasseurs Dozo orné de cauris. La nuit tombe vite sur la falaise de Siby. Face à lui se dresse le tronc colossal d\'un baobab creux où brille une petite lueur chaleureuse.',
          culturalInsight:
              '💡 La confrérie des Dozos est l\'une des plus anciennes institutions éthiques d\'Afrique, fondée sur la protection de la communauté et de l\'environnement.',
          choices: [
            StoryChoice(
              id: 'bd_c1_a',
              label: 'A — Saluer respectueusement selon le code sacré des Dozos',
              description: '« I ni sogoma, mon père, que la bénédiction soit sur ce seuil. »',
              nextSceneId: 'bd_scene_2_sage',
              trait: 'Code d\'Honneur Dozo',
              icon: Icons.stars_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'bd_scene_2_sage',
          sceneNumber: 2,
          title: 'L\'Enseignement des Trois Racines',
          atmosphere: 'Lueur douce du foyer intérieur • Parfum d\'écorces aromatiques',
          narrativeText:
              'Le sage aveugle sourit dans la pénombre : « Tu as su saluer avant de demander. Choisis maintenant l\'offrande que tu porteras à ton village à ton retour. »',
          culturalInsight:
              '💡 Les Dozos prêtent serment de ne jamais prélever dans la nature plus que le strict besoin de subsistance.',
          choices: [
            StoryChoice(
              id: 'bd_c2_a',
              label: 'A — Emporter la graine de baobab pour reboiser la vallée',
              description: 'Prendre soin des générations futures.',
              nextSceneId: 'bd_scene_3_fin',
              trait: 'Protecteur de la Terre',
              icon: Icons.park_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'bd_scene_3_fin',
          sceneNumber: 3,
          title: 'Le Retour Triomphal au Village',
          atmosphere: 'Lumière éclatante du matin sur les collines du Manden',
          narrativeText:
              'Guidé par la bénédiction du sage, Moussa retrouve son village. Les graines semées donneront une forêt protectrice qui nourrira et abritera le Manden pendant des siècles.',
          culturalInsight:
              '💡 Le baobab (Sira) est considéré au Mali comme l\'arbre de la vie et de la palabre.',
          isEpilogue: true,
        ),
      ],
    ),

    // ── 5. LE GÉNIE DES SABLES ET LA CARAVANE PERDUE (TOMBOUCTOU) ────────────
    InteractiveStory(
      id: 'conte_caravane_sable',
      title: 'Le Génie des Sables et la Caravane Perdue',
      subtitle: 'L\'hospitalité saharienne et les secrets des manuscrits de Tombouctou',
      origin: 'Légende des Caravanes du Sahara',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      tag: 'Légende Sahélienne',
      photoUrl: 'assets/images/culture/villes/tombouctou_ville.jpg',
      photoCredits: 'Récits des Caravanes Transsahariennes • Bibliothèque Ahmed Baba',
      summary:
          'Au cœur du désert au nord de Tombouctou, une tempête de sable sépare le jeune chamelier Bilal de sa caravane de sel. Il découvre dans les dunes une mystérieuse tente bleue où réside le gardien des étoiles.',
      narrator: 'Sidi Baba Cissé (Tombouctou)',
      audioDuration: '6 min 45',
      readingDuration: '4 min 15',
      isFeatured: false,
      progress: 0.0,
      moral:
          '« Dans l\'immensité du désert, l\'étoile la plus brillante qui guide l\'homme est celle de la générosité et de la quête de connaissance. »',
      connectedItems: [
        ConnectedItemRef(
          id: 'monument_djingareyber',
          title: 'Mosquée Djingareyber',
          subtitle: 'Chef-d\'œuvre commandé par Mansa Moussa',
          type: ConnectedItemType.monument,
          tag: 'Patrimoine Majeur',
          regionName: 'Tombouctou',
          icon: Icons.domain_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_tombouctou',
          title: 'Tombouctou',
          subtitle: 'La Cité des 333 Saints & des Savoirs',
          type: ConnectedItemType.ville,
          tag: 'Savoirs Sahéliens',
          regionName: 'Tombouctou',
          icon: Icons.menu_book_rounded,
        ),
      ],
      scenes: [
        StoryScene(
          id: 'cs_scene_1',
          sceneNumber: 1,
          title: 'La Nuit du Grand Vent de Sable',
          atmosphere: 'Dunes mouvantes sous la voûte céleste piquée de mille étoiles',
          narrativeText:
              'Le vent s\'est tu subitement sur l\'Erg. Bilal aperçoit des lanternes suspendues à l\'entrée d\'une tente en peau de chameau. Un thé fumant à la menthe l\'attend sur un tapis d\'indigo.',
          culturalInsight:
              '💡 L\'hospitalité (Diyafa) dans le désert malien est une règle sacrée : tout voyageur a droit à l\'eau, au thé et à l\'abri sans condition.',
          choices: [
            StoryChoice(
              id: 'cs_c1_a',
              label: 'A — Accepter le thé des trois verres et partager son histoire',
              description: 'Le premier amer comme la vie, le deuxième doux comme l\'amour, le troisième suave comme la mort.',
              nextSceneId: 'cs_scene_2_etoiles',
              trait: 'Respect du Rituel',
              icon: Icons.coffee_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'cs_scene_2_etoiles',
          sceneNumber: 2,
          title: 'La Carte Céleste des Savants',
          atmosphere: 'Ciel bleu nuit immaculé • Tracé lumineux des constellations',
          narrativeText:
              'Le gardien déroule un vieux parchemin calligraphié à l\'encre de suie et d\'or. « Voici la carte que les astronomes de Sankoré ont dessinée il y a six cents ans. Regarde la constellation du Scorpion, elle t\'indique la porte de Tombouctou. »',
          culturalInsight:
              '💡 Les manuscrits de Tombouctou couvrent des domaines savants tels que l\'astronomie, les mathématiques, la médecine et le droit.',
          choices: [
            StoryChoice(
              id: 'cs_c2_a',
              label: 'A — Mémoriser le tracé des étoiles pour guider la caravane',
              description: 'La science mise au service de la vie humaine.',
              nextSceneId: 'cs_scene_3_fin',
              trait: 'Transmission du Savoir',
              icon: Icons.auto_stories_rounded,
            ),
          ],
        ),
        StoryScene(
          id: 'cs_scene_3_fin',
          sceneNumber: 3,
          title: 'Les Portes de la Cité aux 333 Saints',
          atmosphere: 'Matin radieux • Silhouette majestueuse de la mosquée Djingareyber',
          narrativeText:
              'À l\'aube, Bilal conduit sa caravane saine et sauve jusqu\'aux marchés parfumés de Tombouctou. Il remet le parchemin aux maîtres de la bibliothèque de Sankoré, perpétuant ainsi la chaîne sacrée de la mémoire.',
          culturalInsight:
              '💡 Tombouctou abritait plus de 25 000 étudiants au XVIe siècle au sein de l\'Université de Sankoré.',
          isEpilogue: true,
        ),
      ],
    ),
  ];

  /// Récupère un conte par son ID
  static InteractiveStory getStoryById(String id) {
    return stories.firstWhere(
      (s) => s.id == id,
      orElse: () => stories.first,
    );
  }

  /// Filtre les contes par région
  static List<InteractiveStory> getFiltered({String? regionId, String? query}) {
    return stories.where((story) {
      final matchesReg = story.matchesRegion(regionId);
      if (!matchesReg) return false;

      if (query == null || query.trim().isEmpty) return true;
      final q = query.trim().toLowerCase();
      return story.title.toLowerCase().contains(q) ||
          story.subtitle.toLowerCase().contains(q) ||
          story.summary.toLowerCase().contains(q) ||
          story.regionName.toLowerCase().contains(q) ||
          story.origin.toLowerCase().contains(q) ||
          story.tag.toLowerCase().contains(q);
    }).toList();
  }
}
