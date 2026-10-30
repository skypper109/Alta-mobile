import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/vivienne_tts_service.dart';
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
    try {
      VivienneTtsService.instance.stop();
    } catch (_) {}

    ref.read(cultureActiveTabProvider.notifier).state = index;
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  void dispose() {
    try {
      VivienneTtsService.instance.stop();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(cultureActiveTabProvider);
    if (_currentTabIndex != activeTab) {
      _currentTabIndex = activeTab;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      backgroundColor: isDark
          ? CultureTheme.darkBackground
          : CultureTheme.lightBackground,
      body: SafeArea(
        bottom: false,
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
          ],
        ),
      ),
      // ── 3. BOUTON FLOTTANT DE CONTRIBUTION AU PATRIMOINE ───────────
      floatingActionButton: _CultureFloatingContribuerButton(
        isDark: isDark,
        isTablet: isTablet,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ── 4. BARRE DE NAVIGATION EN BAS (alignée avec l'éducation) ────
      bottomNavigationBar: CultureNavigationTabs(
        selectedIndex: _currentTabIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

/// Bouton d'action flottant premium pour Contribuer au Patrimoine
/// Positionné élégamment au-dessus de la barre de navigation sans gêner le contenu
class _CultureFloatingContribuerButton extends StatelessWidget {
  final bool isDark;
  final bool isTablet;

  const _CultureFloatingContribuerButton({
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF10B981);

    return Tooltip(
      message: 'Contribuer au Patrimoine malien',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/culture/contribuer');
          },
          borderRadius: BorderRadius.circular(isTablet ? 32 : 28),
          child: Container(
            height: isTablet ? 50 : 44,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 18 : 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: emeraldGreen,
              borderRadius: BorderRadius.circular(isTablet ? 32 : 28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: emeraldGreen.withValues(alpha: isDark ? 0.45 : 0.35),
                  blurRadius: isTablet ? 16 : 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: isTablet ? 25 : 21,
                  color: Colors.white,
                ),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  'Contribuer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isTablet ? 14.5 : 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
