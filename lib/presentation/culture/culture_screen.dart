import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/culture/core/controllers/culture_intro_controller.dart';
import '../../features/culture/immersive/widgets/culture_mode_transition.dart';
import '../../features/culture/presentation/screens/culture_intro_screen.dart';
import '../../features/culture/presentation/screens/culture_main_screen.dart';

/// Écran d'accueil de l'espace Culture
///
/// Intègre le portail immersif [CultureIntroScreen] avec transition douce et fluide
/// pour faire vivre le passage d'Éducation vers Culture,
/// puis bascule vers l'espace complet [CultureMainScreen] sur l'univers choisi.
class CultureScreen extends ConsumerStatefulWidget {
  const CultureScreen({super.key});

  @override
  ConsumerState<CultureScreen> createState() => _CultureScreenState();
}

class _CultureScreenState extends ConsumerState<CultureScreen> {
  int _targetTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hasSeenIntro = ref.watch(cultureIntroControllerProvider);

    return CulturePortalSwitcher(
      duration: CultureModeTransition.portalDuration,
      child: hasSeenIntro
          ? KeyedSubtree(
              key: ValueKey('culture_main_screen_$_targetTabIndex'),
              child: CultureMainScreen(initialTabIndex: _targetTabIndex),
            )
          : KeyedSubtree(
              key: const ValueKey('culture_intro_screen'),
              child: CultureIntroScreen(
                onStartExploration: (tabIndex) {
                  setState(() {
                    _targetTabIndex = tabIndex;
                  });
                  ref.read(cultureIntroControllerProvider.notifier).markAsSeen();
                },
              ),
            ),
    );
  }
}
