import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/culture/core/controllers/culture_intro_controller.dart';
import '../../features/culture/immersive/widgets/culture_mode_transition.dart';
import '../../features/culture/presentation/screens/culture_intro_screen.dart';
import '../../features/culture/presentation/screens/culture_main_screen.dart';

/// Écran d'accueil de l'espace Culture
///
/// Intègre le portail immersif [CultureIntroScreen] avec la transition cinématographique
/// [CultureModeTransition] (1500ms) pour faire vivre le passage d'Éducation vers Culture,
/// puis bascule vers l'espace complet [CultureMainScreen].
class CultureScreen extends ConsumerWidget {
  const CultureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSeenIntro = ref.watch(cultureIntroControllerProvider);

    return CulturePortalSwitcher(
      duration: CultureModeTransition.portalDuration,
      child: hasSeenIntro
          ? const KeyedSubtree(
              key: ValueKey('culture_main_screen'),
              child: CultureMainScreen(),
            )
          : KeyedSubtree(
              key: const ValueKey('culture_intro_screen'),
              child: CultureIntroScreen(
                onStartExploration: () {
                  ref.read(cultureIntroControllerProvider.notifier).markAsSeen();
                },
              ),
            ),
    );
  }
}
