import 'package:flutter/material.dart';
import '../../../../presentation/common/widgets/alternia_top_header_bar.dart';

/// Barre supérieure unifiée et harmonisée pour la section Culture
/// Logo AlterniA à gauche avec "iA" en orange, et à droite filtre régional + guide IA
class CultureHeaderBar extends StatelessWidget {
  const CultureHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlterniaTopHeaderBar.culture();
  }
}
