import 'package:flutter/material.dart';

// ═════════════════════════════════════════════════════════════════════════════
// ── MODÈLES DÉCLARATIFS DU MOTEUR NARRATIF IMMERSIF (STORY EXPERIENCE ENGINE)
// ═════════════════════════════════════════════════════════════════════════════

/// Script complet d'un récit culturel (Épopée, Légende, Monument ou Terroir)
class StoryExperienceScript {
  final String id;
  final String title;
  final String subtitle;
  final String origin;
  final String category; // 'Grandes Figures', 'Monuments', 'Villes', 'Contes'
  final String? regionId;
  final String regionName;
  final String defaultMusicAsset;
  final List<StorySceneModel> scenes;

  const StoryExperienceScript({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.origin,
    required this.category,
    this.regionId,
    required this.regionName,
    this.defaultMusicAsset = '',
    required this.scenes,
  });

  int get totalScenes => scenes.length;

  StorySceneModel? getSceneByIndex(int index) {
    if (index >= 0 && index < scenes.length) return scenes[index];
    return null;
  }
}

/// Types de scènes narratives composables
enum SceneType {
  landscapeNarrative, // Décor de fond, ciel en mouvement, contemplation
  characterIntro,     // Entrée en scène d'un personnage (enfant, guerrier, souverain)
  animatedMap,        // Carte interactive du Mali qui se trace
  conflictAction,     // Événement dramatique, silhouettes d'ombres, bataille
  baahIntervention,   // Baah intervient comme témoin / passeur de sagesse
  interactiveChoice,  // Dilemme ou question socratique posée à l'élève
  epilogueStamp,      // Conclusion solennelle & estampillage du passeport
}

/// Modèle d'une scène individuelle
class StorySceneModel {
  final String id;
  final int index;
  final String title;
  final SceneType type;
  final Duration estimatedDuration;
  final CameraMotion camera;
  final List<StageLayer> layers;
  final String narrativeText;
  final String? spokenAudioText;
  final ActorPresence? actor;
  final BaahPresence? baah;
  final MapDirective? mapData;
  final List<StoryInteractiveOption>? choices;
  final String? ambientSoundtrack;
  final String? culturalSecret; // Clé de sagesse / proverbe révélé

  const StorySceneModel({
    required this.id,
    required this.index,
    required this.title,
    required this.type,
    this.estimatedDuration = const Duration(seconds: 8),
    this.camera = const CameraMotion(preset: CameraPreset.slowZoomInCenter),
    required this.layers,
    required this.narrativeText,
    this.spokenAudioText,
    this.actor,
    this.baah,
    this.mapData,
    this.choices,
    this.ambientSoundtrack,
    this.culturalSecret,
  });
}

// ── DIRECTIVES DE CAMÉRA CINÉMATIQUE ──────────────────────────────────────────

enum CameraPreset {
  panLeftToRight,
  panRightToLeft,
  slowZoomInCenter,
  slowZoomInFocus,
  dramaticPullBack,
  epicBattleShake,
  staticSteady,
}

class CameraMotion {
  final CameraPreset preset;
  final Alignment focusAlignment;
  final double beginScale;
  final double endScale;
  final Duration duration;
  final Curve curve;

  const CameraMotion({
    required this.preset,
    this.focusAlignment = Alignment.center,
    this.beginScale = 1.0,
    this.endScale = 1.12,
    this.duration = const Duration(seconds: 8),
    this.curve = Curves.easeInOutSine,
  });
}

// ── PLANS VISUELS DU DÉCOR (PARALLAX STAGE LAYERS) ───────────────────────────

enum LayerMovement {
  fixed,
  driftHorizontal,    // Nuages, ciel, brume dérivant lentement
  floatingParticles,  // Braises de veillée, poussière d'or de Mansa Moussa
  birdsCrossing,      // Nuée d'oiseaux migrateurs traversant l'écran
  fadeSlideIn,        // Silhouettes ou éléments surgissant sur scène
}

class StageLayer {
  final String assetPath;
  final int zIndex; // 0: Ciel / Lointain, 1: Décor moyen, 2: Premier plan / FX
  final LayerMovement movement;
  final double speed;
  final Alignment alignment;
  final double opacity;
  final BoxFit fit;
  final Color? colorFilter;

  const StageLayer({
    required this.assetPath,
    required this.zIndex,
    this.movement = LayerMovement.fixed,
    this.speed = 1.0,
    this.alignment = Alignment.center,
    this.opacity = 1.0,
    this.fit = BoxFit.cover,
    this.colorFilter,
  });
}

// ── PRÉSENCE D'ACTEURS DÉCOUPÉS ──────────────────────────────────────────────

enum ActorEntrance {
  walkFromLeft,
  walkFromRight,
  fadeCenter,
  silhouetteRise,
  popWithGlow,
}

class ActorPresence {
  final String name;
  final String role;
  final String assetPath;
  final Alignment position;
  final ActorEntrance entrance;
  final String? emotionTag;
  final Color accentColor;

  const ActorPresence({
    required this.name,
    required this.role,
    required this.assetPath,
    this.position = Alignment.center,
    this.entrance = ActorEntrance.fadeCenter,
    this.emotionTag,
    this.accentColor = const Color(0xFFF1851F),
  });
}

// ── INCRUSTATION PONCTUELLE DE BAAH ──────────────────────────────────────────

enum BaahMood {
  wiseContemplation,
  enthusiasticNarrator,
  curiousQuestioner,
  solemnWitness,
}

class BaahPresence {
  final BaahMood mood;
  final Alignment position;
  final String speechBubble;
  final bool requiresUserTap;
  final String? highlightWord;

  const BaahPresence({
    this.mood = BaahMood.solemnWitness,
    this.position = const Alignment(0.75, 0.55),
    required this.speechBubble,
    this.requiresUserTap = false,
    this.highlightWord,
  });
}

// ── DIRECTIVE DE CARTE ANIMÉE ────────────────────────────────────────────────

class MapDirective {
  final List<String> activeKingdomIds; // Ex: 'manden', 'sosso', 'songhai'
  final List<Offset> militaryPath;     // Points géométriques de marche
  final String focalCityId;           // Ex: 'kirina', 'kangaba', 'koulikoro'
  final String mapCaption;
  final bool pulseBorder;

  const MapDirective({
    required this.activeKingdomIds,
    this.militaryPath = const [],
    required this.focalCityId,
    this.mapCaption = 'Royaumes et chemins d\'alliance du Manden',
    this.pulseBorder = true,
  });
}

// ── DILEMMES & CHOIX INTERACTIFS ──────────────────────────────────────────────

class StoryInteractiveOption {
  final String id;
  final String label;
  final String? description;
  final String trait; // Ex: 'Voie de la Sagesse', 'Esprit du Sinankunya'
  final int? targetSceneIndex;
  final IconData icon;

  const StoryInteractiveOption({
    required this.id,
    required this.label,
    this.description,
    required this.trait,
    this.targetSceneIndex,
    this.icon = Icons.auto_awesome_rounded,
  });
}
