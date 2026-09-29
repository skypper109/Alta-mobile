import 'package:flutter/material.dart';
import '../../core/datasources/mock_culture_details_data.dart';
import '../../core/datasources/mock_culture_stories_data.dart';
import '../models/story_experience_models.dart';

/// Registre central fournissant les scripts d'expériences narratives
abstract final class StoryScriptRegistry {
  /// Script phare : Soundiata Keïta (L'Épopée du Manden)
  static final StoryExperienceScript soundiataScript = StoryExperienceScript(
    id: 'perso_soundiata',
    title: 'Soundiata Keïta : Le Réveil du Lion',
    subtitle: 'Du Manden des origines à la Charte de Kouroukan Fouga',
    origin: 'Épopée du Manden • Tradition des Maîtres de la Parole',
    category: 'Grandes Figures',
    regionId: 'koulikoro',
    regionName: 'Koulikoro / Manden',
    scenes: [
      // ── SCÈNE 1 : LE VILLAGE DU MANDÉ (DÉCOR EN MOUVEMENT, CIEL DÉRIVANT) ──
      const StorySceneModel(
        id: 'sc1_mande_village',
        index: 0,
        title: 'L\'Aube du Manden',
        type: SceneType.landscapeNarrative,
        estimatedDuration: Duration(seconds: 8),
        camera: CameraMotion(
          preset: CameraPreset.slowZoomInCenter,
          beginScale: 1.0,
          endScale: 1.12,
          duration: Duration(seconds: 8),
        ),
        layers: [
          StageLayer(
            assetPath: 'assets/images/culture/contes/manden_baobab_stage.jpg',
            zIndex: 0,
            movement: LayerMovement.driftHorizontal,
            speed: 0.4,
          ),
          StageLayer(
            assetPath: 'assets/images/culture/contes/manden_baobab_stage.jpg',
            zIndex: 1,
            opacity: 0.95,
          ),
          StageLayer(
            assetPath: 'assets/images/culture/villes/segou_koro.jpg',
            zIndex: 2,
            movement: LayerMovement.birdsCrossing,
          ),
        ],
        narrativeText:
            'Au cœur du Mandé millénaire, sous le souffle brûlant de l\'harmattan, une prophétie silencieuse veillait sur la terre rouge.',
        culturalSecret:
            '💡 Les devins avaient prédit au roi Naré Maghann Konaté que la femme la plus laide du royaume mettrait au monde le plus grand roi d\'Afrique.',
      ),

      // ── SCÈNE 2 : SOUNDIATA ENFANT (APPARITION DE L'ACTEUR) ────────────────
      const StorySceneModel(
        id: 'sc2_soundiata_child',
        index: 1,
        title: 'L\'Enfant aux Jambes Inertes',
        type: SceneType.characterIntro,
        estimatedDuration: Duration(seconds: 9),
        camera: CameraMotion(
          preset: CameraPreset.panLeftToRight,
          beginScale: 1.04,
          endScale: 1.16,
          duration: Duration(seconds: 9),
        ),
        layers: [
          StageLayer(
            assetPath: 'assets/images/culture/contes/manden_baobab_stage.jpg',
            zIndex: 0,
          ),
        ],
        actor: ActorPresence(
          name: 'Soundiata (Mari Djata)',
          role: 'L\'Héritier Blessé',
          assetPath: 'assets/images/culture/personnages/soundiata.jpg',
          position: Alignment(-0.35, 0.20),
          entrance: ActorEntrance.walkFromLeft,
        ),
        narrativeText:
            'Né sans la force de marcher, le jeune Mari Djata rampait dans la cour royale. Alors que la première épouse du roi l\'humiliait, sa mère Sogolon pleura.\n\nCe jour-là, l\'enfant brisa la barre de fer des forgerons et se leva comme un baobab.',
        culturalSecret:
            '💡 Le baobab déraciné par Soundiata pour sa mère symbolise la transcendance de l\'adversité dans la mémoire mandingue.',
      ),

      // ── SCÈNE 3 : LA CARTE ANIMÉE DES ROYAUMES DU MALI ANCIEN ──────────────
      const StorySceneModel(
        id: 'sc3_ancient_map',
        index: 2,
        title: 'La Marche de l\'Alliance',
        type: SceneType.animatedMap,
        estimatedDuration: Duration(seconds: 10),
        camera: CameraMotion(
          preset: CameraPreset.slowZoomInFocus,
          focusAlignment: Alignment(0.1, -0.2),
          beginScale: 1.0,
          endScale: 1.18,
          duration: Duration(seconds: 10),
        ),
        layers: [],
        mapData: MapDirective(
          activeKingdomIds: ['manden', 'sosso', 'wagadou'],
          focalCityId: 'kirina',
          mapCaption: 'Frontières du Manden & Route de Kirina (1235)',
        ),
        narrativeText:
            'Tandis que le roi forgeron Soumaoro Kanté terrorisait les provinces depuis le Sosso, les chefs de clans réclamèrent le retour d\'exil de Soundiata.',
        culturalSecret:
            '💡 L\'alliance forgée entre les douze royaumes fondateurs a donné naissance à la grande confédération impériale.',
      ),

      // ── SCÈNE 4 : LA BATAILLE DE KIRINA (SILHOUETTES EN MOUVEMENT) ──────────
      const StorySceneModel(
        id: 'sc4_battle_kirina',
        index: 3,
        title: 'Le Choc de Kirina',
        type: SceneType.conflictAction,
        estimatedDuration: Duration(seconds: 8),
        camera: CameraMotion(
          preset: CameraPreset.epicBattleShake,
          beginScale: 1.08,
          endScale: 1.18,
          duration: Duration(seconds: 8),
        ),
        layers: [
          StageLayer(
            assetPath: 'assets/images/culture/contes/savane_crepuscule_stage.jpg',
            zIndex: 0,
          ),
        ],
        narrativeText:
            'En 1235, dans la plaine de Kirina, les armées s\'affrontèrent. L\'arc blanc de Soundiata décocha la flèche sacrée qui perça le secret d\'invulnérabilité de Soumaoro.',
        culturalSecret:
            '💡 La flèche munie d\'un ergot de coq blanc est restée dans l\'épopée le symbole de la vérité dissipant l\'illusion de l\'oppresseur.',
      ),

      // ── SCÈNE 5 : BAAH INTERVIENT COMME TÉMOIN DE LA LÉGENDE ───────────────
      const StorySceneModel(
        id: 'sc5_baah_testimony',
        index: 4,
        title: 'La Charte Sacrée',
        type: SceneType.baahIntervention,
        estimatedDuration: Duration(seconds: 9),
        camera: CameraMotion(
          preset: CameraPreset.slowZoomInCenter,
          beginScale: 1.0,
          endScale: 1.08,
          duration: Duration(seconds: 9),
        ),
        layers: [
          StageLayer(
            assetPath: 'assets/images/culture/contes/manden_baobab_stage.jpg',
            zIndex: 0,
          ),
          StageLayer(
            assetPath: 'assets/images/culture/personnages/soundiata.jpg',
            zIndex: 1,
            opacity: 0.90,
          ),
        ],
        baah: BaahPresence(
          mood: BaahMood.solemnWitness,
          position: Alignment(0.72, 0.58),
          speechBubble:
              '« Et c\'est ainsi que naquit la légende. Sous le grand baobab de Kouroukan Fouga, Soundiata et les anciens rédigèrent l\'une des premières déclarations des droits de l\'Homme au monde ! »',
        ),
        narrativeText:
            '« Toute vie humaine est une vie. Un tort causé à une vie exige réparation. » La Charte de Kouroukan Fouga de 1236 scella la dignité humaine pour les siècles à venir.',
        culturalSecret:
            '💡 La Charte de Kouroukan Fouga a été inscrite en 2009 au Patrimoine Culturel Immatériel de l\'Humanité par l\'UNESCO.',
      ),

      // ── SCÈNE 6 : QUESTION D'IMMERSION ET ENGAGEMENT DE L'ÉLÈVE ────────────
      const StorySceneModel(
        id: 'sc6_dilemma',
        index: 5,
        title: 'Le Choix du Gardien',
        type: SceneType.interactiveChoice,
        estimatedDuration: Duration(seconds: 14),
        camera: CameraMotion(preset: CameraPreset.staticSteady),
        layers: [
          StageLayer(
            assetPath: 'assets/images/culture/personnages/soundiata.jpg',
            zIndex: 0,
          ),
        ],
        narrativeText:
            'Si tu avais siégé sous le grand arbre de Kouroukan Fouga en 1236, quel principe aurais-tu fait graver en premier ?',
        choices: [
          StoryInteractiveOption(
            id: 'opt_sanctite',
            label: 'La sanctification de la vie et le respect absolu de la dignité humaine',
            trait: 'Sagesse de Sogolon',
            icon: Icons.favorite_rounded,
          ),
          StoryInteractiveOption(
            id: 'opt_fraternite',
            label: 'La fraternité sacrée (Sinankunya) et la tolérance entre les peuples',
            trait: 'Pacte du Manden',
            icon: Icons.handshake_rounded,
          ),
        ],
      ),
    ],
  );

  /// Script : Mansa Moussa (L'Empereur d'Or)
  static final StoryExperienceScript mansaMoussaScript = StoryExperienceScript(
    id: 'perso_mansa_moussa',
    title: 'Mansa Moussa : L\'Empereur d\'Or',
    subtitle: 'La marche du Mali qui illumina les universités du monde',
    origin: 'Chronique de Tombouctou et de Méditerranée',
    category: 'Grandes Figures',
    regionId: 'tombouctou',
    regionName: 'Tombouctou',
    scenes: [
      const StorySceneModel(
        id: 'mm_sc1_dunes',
        index: 0,
        title: 'L\'Empire à son Zénith',
        type: SceneType.landscapeNarrative,
        estimatedDuration: Duration(seconds: 8),
        camera: CameraMotion(
          preset: CameraPreset.panLeftToRight,
          beginScale: 1.02,
          endScale: 1.14,
          duration: Duration(seconds: 8),
        ),
        layers: [
          StageLayer(
            assetPath: 'assets/images/culture/villes/gao_dune_rose.jpg',
            zIndex: 0,
            movement: LayerMovement.driftHorizontal,
          ),
          StageLayer(
            assetPath: 'assets/images/culture/contes/tombouctou_dunes_stage.jpg',
            zIndex: 1,
          ),
        ],
        narrativeText:
            'En 1324, le souverain du Mali quitta le Djoliba à la tête d\'une caravane légendaire de soixante mille hommes et de milliers de chameaux chargés d\'or pur.',
        culturalSecret:
            '💡 Mansa Moussa fit construire sur sa route des mosquées et fonda l\'université de Sankoré à son retour.',
      ),
      const StorySceneModel(
        id: 'mm_sc2_tombouctou',
        index: 1,
        title: 'Le Siècle des Savoirs',
        type: SceneType.baahIntervention,
        estimatedDuration: Duration(seconds: 9),
        camera: CameraMotion(preset: CameraPreset.slowZoomInCenter),
        layers: [
          StageLayer(
            assetPath: 'assets/images/culture/monuments/mosquee_djingareyber.jpg',
            zIndex: 0,
          ),
        ],
        baah: BaahPresence(
          mood: BaahMood.enthusiasticNarrator,
          speechBubble:
              '« Mansa Moussa disait : "Le sel vient du nord, l\'or vient du sud, mais les paroles de Dieu et les trésors de la sagesse ne se trouvent qu\'à Tombouctou !" »',
        ),
        narrativeText:
            'L\'architecte Abou Ishaq es-Sahéli bâtit pour lui la mosquée Djingareyber en banco et bois de rônier, sanctuaire de paix qui défie le désert depuis sept siècles.',
      ),
    ],
  );

  /// Récupérer un script par ID ou générer un script automatique pour n'importe quel élément
  static StoryExperienceScript getScriptForId(String id) {
    if (id == 'perso_soundiata' || id == 'soundiata') {
      return soundiataScript;
    }
    if (id == 'perso_mansa_moussa' || id == 'mansa_moussa') {
      return mansaMoussaScript;
    }

    // Recherche dans les contes existants
    try {
      final story = MockCultureStoriesData.getStoryById(id);
      return _fromInteractiveStory(story);
    } catch (_) {}

    // Recherche dans les figures historiques
    try {
      final figure = MockCultureDetailsData.getFigureById(id);
      return _fromHistoricalFigure(figure);
    } catch (_) {}

    // Fallback par défaut sur Soundiata
    return soundiataScript;
  }

  static StoryExperienceScript _fromInteractiveStory(dynamic story) {
    return StoryExperienceScript(
      id: story.id,
      title: story.title,
      subtitle: story.subtitle,
      origin: story.origin,
      category: 'Contes',
      regionId: story.regionId,
      regionName: story.regionName,
      scenes: List.generate(story.scenes.length, (i) {
        final sc = story.scenes[i];
        return StorySceneModel(
          id: sc.id,
          index: i,
          title: sc.title,
          type: sc.isEpilogue ? SceneType.epilogueStamp : SceneType.landscapeNarrative,
          camera: CameraMotion(
            preset: i.isEven ? CameraPreset.slowZoomInCenter : CameraPreset.panLeftToRight,
          ),
          layers: [
            StageLayer(
              assetPath: story.photoUrl,
              zIndex: 0,
            ),
          ],
          narrativeText: sc.narrativeText,
          culturalSecret: sc.culturalInsight,
          choices: sc.choices != null && sc.choices.isNotEmpty
              ? sc.choices
                  .map<StoryInteractiveOption>((c) => StoryInteractiveOption(
                        id: c.id,
                        label: c.label,
                        trait: c.trait ?? 'Voie du Récit',
                      ))
                  .toList()
              : null,
        );
      }),
    );
  }

  static StoryExperienceScript _fromHistoricalFigure(dynamic figure) {
    return StoryExperienceScript(
      id: figure.id,
      title: figure.name,
      subtitle: figure.titleHonorifique,
      origin: 'Histoire Vivante du Mali • ${figure.period}',
      category: 'Grandes Figures',
      regionId: figure.regionId,
      regionName: figure.regionName,
      scenes: [
        StorySceneModel(
          id: '${figure.id}_intro',
          index: 0,
          title: figure.titleHonorifique,
          type: SceneType.landscapeNarrative,
          layers: [
            StageLayer(assetPath: figure.photoUrl, zIndex: 0),
          ],
          narrativeText: figure.resume,
          culturalSecret: figure.citationHistorique,
        ),
        ...List.generate(figure.chapters.length, (i) {
          final ch = figure.chapters[i];
          return StorySceneModel(
            id: '${figure.id}_ch_$i',
            index: i + 1,
            title: ch.title,
            type: i == 0 ? SceneType.characterIntro : SceneType.landscapeNarrative,
            camera: CameraMotion(
              preset: i.isEven ? CameraPreset.slowZoomInCenter : CameraPreset.panLeftToRight,
            ),
            layers: [
              StageLayer(assetPath: figure.photoUrl, zIndex: 0),
            ],
            narrativeText: ch.content,
            culturalSecret: ch.quote != null ? '« ${ch.quote} »' : null,
          );
        }),
      ],
    );
  }
}
