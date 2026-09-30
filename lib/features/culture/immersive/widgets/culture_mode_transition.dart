import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transition fluide et instantanée pour l'espace Culture sans lenteur ni animation de zoom
class CultureModeTransition {
  CultureModeTransition._();

  static const Duration portalDuration = Duration.zero;

  /// Crée une [CustomTransitionPage] pour GoRouter sans animation parasite
  static CustomTransitionPage<T> buildPage<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = Duration.zero,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  /// Construction directe sans mise à l'échelle ni décalage
  static Widget buildPortalTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return child;
  }
}

/// Conteneur direct pour basculer instantanément sans animation
class CulturePortalSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const CulturePortalSwitcher({
    super.key,
    required this.child,
    this.duration = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
