import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/culture_theme.dart';

/// Transition portail dédiée : Éducation → Culture
///
/// Durée : 1500 ms (entre 1200 et 1800 ms selon la spécification)
/// Animation :
/// - Fondu progressif et immersif (Fade)
/// - Mise à l'échelle cinématique douce (Scale 0.94 → 1.0)
/// - Voile de passage sombre unifié sans dégradé pour sceller l'immersion
/// - STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
class CultureModeTransition {
  CultureModeTransition._();

  /// Durée officielle de passage de portail (1500 ms)
  static const Duration portalDuration = Duration(milliseconds: 1500);

  /// Crée une [CustomTransitionPage] pour GoRouter avec la transition portail
  static CustomTransitionPage<T> buildPage<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = portalDuration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return buildPortalTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  /// Fonction de construction de transition réutilisable
  static Widget buildPortalTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    // Courbe d'entrée douce et solennelle
    final portalCurved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );

    // Fondu profond
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(portalCurved);

    // Expansion d'entrée dans le portail
    final scaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(portalCurved);

    // Léger décalage vertical cinématographique
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.02),
      end: Offset.zero,
    ).animate(portalCurved);

    return Container(
      color: CultureTheme.darkBackground,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Conteneur animé pour basculer en douceur entre le portail d'intro et le contenu principal
class CulturePortalSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const CulturePortalSwitcher({
    super.key,
    required this.child,
    this.duration = CultureModeTransition.portalDuration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (Widget widget, Animation<double> animation) {
        final scale = Tween<double>(begin: 0.96, end: 1.0).animate(animation);
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(animation);

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: widget,
          ),
        );
      },
      child: child,
    );
  }
}
