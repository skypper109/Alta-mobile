import 'package:flutter/material.dart';
import '../../features/culture/immersive/widgets/culture_mode_transition.dart';
import '../../features/culture/presentation/screens/culture_main_screen.dart';

/// Écran d'accueil de l'espace Culture
///
/// Accède directement à [CultureMainScreen] avec la transition portail immersive.
class CultureScreen extends StatelessWidget {
  const CultureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CulturePortalSwitcher(
      duration: CultureModeTransition.portalDuration,
      child: const KeyedSubtree(
        key: ValueKey('culture_main_screen_0'),
        child: CultureMainScreen(initialTabIndex: 0),
      ),
    );
  }
}
