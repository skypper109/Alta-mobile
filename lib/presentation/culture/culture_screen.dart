import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/culture/immersive/widgets/culture_mode_transition.dart';
import '../../features/culture/presentation/screens/culture_main_screen.dart';

/// Écran d'accueil de l'espace Culture
///
/// Accède directement à [CultureMainScreen] avec la transition portail immersive.
/// Lit le provider [cultureActiveTabProvider] pour respecter l'onglet demandé
/// par les écrans qui redirigent vers /culture (ex : « Voir mon Passeport »).
class CultureScreen extends ConsumerWidget {
  const CultureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestedTab = ref.read(cultureActiveTabProvider);
    return CulturePortalSwitcher(
      duration: CultureModeTransition.portalDuration,
      child: KeyedSubtree(
        key: ValueKey('culture_main_screen_$requestedTab'),
        child: CultureMainScreen(initialTabIndex: requestedTab),
      ),
    );
  }
}
