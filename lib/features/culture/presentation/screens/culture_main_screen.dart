import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/culture_theme.dart';
import '../views/culture_decouvrir_view.dart';
import '../views/culture_home_view.dart';
import '../views/culture_jeux_contes_view.dart';
import '../views/culture_passport_view.dart';
import '../widgets/culture_header_bar.dart';
import '../widgets/culture_navigation_tabs.dart';

/// Écran maître Culture
/// Intègre la barre supérieure, le filtre régional transversal et les 4 univers principaux :
/// Accueil, Découverte, Jeux & Contes, Passeport
/// STRICTEMENT SANS DÉGRADÉS selon les règles d'architecture UX/UI
class CultureMainScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const CultureMainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<CultureMainScreen> createState() => _CultureMainScreenState();
}

class _CultureMainScreenState extends ConsumerState<CultureMainScreen> {
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? CultureTheme.darkBackground
          : CultureTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. EN-TÊTE FIXE AVEC MARQUE & FILTRE RÉGIONAL TRANSVERSAL ───
            const CultureHeaderBar(),

            // ── 2. CORPS DE L'UNIVERS SÉLECTIONNÉ ───────────────────────────
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  CultureHomeView(onNavigateToTab: _onTabSelected),
                  const CultureDecouvrirView(),
                  const CultureJeuxContesView(),
                  const CulturePassportView(),
                ],
              ),
            ),

            // ── 3. BARRE DE NAVIGATION EN BAS (comme l'éducation) ────────────
            CultureNavigationTabs(
              selectedIndex: _currentTabIndex,
              onTabSelected: _onTabSelected,
            ),
          ],
        ),
      ),
    );
  }
}
