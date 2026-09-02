import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transitions immersives, douces et véloces pour les écrans Culture (280ms)
/// Combine un fondu (Fade) avec un micro-déplacement vertical (Slide) et un micro-scale.
class CulturalTransition {
  CulturalTransition._();

  static const Duration defaultDuration = Duration(milliseconds: 280);

  /// Crée une [CustomTransitionPage] compatible avec GoRouter
  static CustomTransitionPage<T> buildPage<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = defaultDuration,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return buildTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  /// Fonction de transition réutilisable pour [PageRouteBuilder] ou [CustomTransitionPage]
  static Widget buildTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    final slide = Tween<Offset>(
      begin: const Offset(0.0, 0.03),
      end: Offset.zero,
    ).animate(curvedAnimation);
    final scale = Tween<double>(begin: 0.985, end: 1.0).animate(curvedAnimation);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(
          scale: scale,
          child: child,
        ),
      ),
    );
  }
}
