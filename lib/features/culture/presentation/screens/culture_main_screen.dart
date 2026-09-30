import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/culture_theme.dart';
import '../views/culture_decouvrir_view.dart';
import '../views/culture_home_view.dart';
import '../views/culture_jeux_contes_view.dart';
import '../views/culture_passport_view.dart';
import '../widgets/culture_header_bar.dart';
import '../widgets/culture_navigation_tabs.dart';

/// Provider global de l'onglet actif dans l'espace Culture :
/// 0: Accueil, 1: Découverte, 2: Explorer+ (Jeux, Contes, Proverbes), 3: Parcours (Passeport Culturel)
final cultureActiveTabProvider = StateProvider<int>((ref) => 0);

/// Écran maître Culture
/// Intègre la barre supérieure, le filtre régional transversal et les 4 univers principaux :
/// Accueil, Découverte, Explorer+, Passeport
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
    if (widget.initialTabIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(cultureActiveTabProvider.notifier).state =
            widget.initialTabIndex;
      });
    }
  }

  void _onTabSelected(int index) {
    ref.read(cultureActiveTabProvider.notifier).state = index;
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(cultureActiveTabProvider);
    if (_currentTabIndex != activeTab) {
      _currentTabIndex = activeTab;
    }

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
