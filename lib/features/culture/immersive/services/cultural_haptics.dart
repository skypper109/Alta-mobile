import 'package:flutter/services.dart';

/// Moteur de retours haptiques culturels haute précision (Haptic Engine)
/// Calibre des sensations tactiles distinctes et immersives pour Alta-mobile :
/// - Frappe de sceau patrimonial / Tamponnage physique (double impact cadencé)
/// - Pression élastique et relâchement des cartes d'art
/// - Clic de sélection des filtres et terroirs
/// - Déclenchement audio et célébrations
class CulturalHaptics {
  CulturalHaptics._();

  /// Sensation de frappe de sceau ou tampon physique sur papier artisanal.
  /// Simule le coup sec du tampon puis le rebond de l'encre.
  static Future<void> stamp() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Pression tactile sur une carte interactive (début de l'appui).
  static void cardPress() {
    HapticFeedback.lightImpact();
  }

  /// Relâchement ressort de la carte (déclenchement de l'action).
  static void cardRelease() {
    HapticFeedback.selectionClick();
  }

  /// Changement d'onglet, de région ou de filtre thématique.
  static void tabSwitch() {
    HapticFeedback.selectionClick();
  }

  /// Bascule de mise en favori / enregistrement patrimonial.
  static void bookmarkToggle(bool isBookmarked) {
    if (isBookmarked) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  /// Célébration d'étape ou déblocage d'un jalon de découverte.
  static Future<void> celebration() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  /// Démarrage ou pause de l'écoute du Griot / narrateur audio.
  static void audioToggle() {
    HapticFeedback.mediumImpact();
  }
}
