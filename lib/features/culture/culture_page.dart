// ─── AlterniA — Feature: Culture Immersive (Avatar Interactif & Savoir) ────────
// Mode immersif avec Avatar Interactif AlterniA (expressions du visage & onde vocale),
// charte graphique officielle (#314999, #F1851F Orange, #40BBCC, #0B111E),
// bouton constant de fermeture [X] et navigation sub-bar propre et adaptative aux thèmes.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../presentation/common/widgets/alternia_avatar.dart';
import '../../shared/widgets.dart';
import '../profile/user_prefs_notifier.dart';

class CulturePage extends ConsumerStatefulWidget {
  const CulturePage({super.key});

  @override
  ConsumerState<CulturePage> createState() => _CulturePageState();
}

class _CulturePageState extends ConsumerState<CulturePage> {
  int _subTabIndex =
      0; // 0: Avatar Live, 1: Histoire, 2: Inventions, 3: Sagesse
  AvatarState _avatarState = AvatarState.speaking;
  String _liveSpeechText =
      'Bonjour ! Je suis ton Avatar Interactif AlterniA. Pose-moi n\'importe quelle question sur l\'Histoire et les Inventions du Mali !';

  void _enterProtagonistMode(String title) {
    HapticFeedback.heavyImpact();
    setState(() {
      _subTabIndex = 0; // Switch to Avatar Live tab
      _avatarState = AvatarState.speaking;
      if (title.contains('Mansa Moussa')) {
        _liveSpeechText =
            'Je suis Mansa Moussa, l\'Empereur du Mali ! Pose-moi des questions sur mon pèlerinage de 1324 à La Mecque et nos réserves d\'or !';
      } else if (title.contains('Sundiata') || title.contains('Manden')) {
        _liveSpeechText =
            'Je suis Sundiata Keïta, le Lion du Manden ! Interroge-moi sur la Charte du Manden de 1236 et les principes de paix.';
      } else if (title.contains('Dogon') || title.contains('Astronomie')) {
        _liveSpeechText =
            'Nous sommes les astronomes Dogons de Bandiagara ! Questionne-nous sur l\'étoile Sirius B et la cosmogonie.';
      } else if (title.contains('Djenné') || title.contains('Banco')) {
        _liveSpeechText =
            'Je suis le Maître Architecte de Djenné ! Demande-moi les secrets de construction de la Mosquée en banco.';
      } else {
        _liveSpeechText =
            'Je me mets dans la peau du protagoniste de : "$title" ! Pose-moi tes questions en direct !';
      }
    });
  }

  void _onExitCultureMode() {
    HapticFeedback.mediumImpact();
    context.go('/home');
  }

  void _onAvatarTapped() {
    HapticFeedback.heavyImpact();
    setState(() {
      if (_avatarState == AvatarState.speaking) {
        _avatarState = AvatarState.listening;
        _liveSpeechText =
            'J\'écoute attentivement ta question ! Parle maintenant...';
      } else if (_avatarState == AvatarState.listening) {
        _avatarState = AvatarState.thinking;
        _liveSpeechText =
            'Analyse de ta question en cours avec le programme officiel...';
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _avatarState = AvatarState.speaking;
              _liveSpeechText =
                  'Savais-tu que Mansa Moussa a fait rayonner le Mali dans le monde entier en 1324 ?';
            });
          }
        });
      } else {
        _avatarState = AvatarState.speaking;
        _liveSpeechText =
            'Touche mon avatar pour changer d\'état ou poser une question !';
      }
    });
  }

  void _showStoryModal(String title, String category, String fullText,
      IconData icon, Color color) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modalBg = isDark ? AppColors.surface : Colors.white;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: modalBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPri,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(
                  color: isDark ? AppColors.border : const Color(0xFFCBD5E1),
                  height: 1),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    fullText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      height: 1.6,
                      color: textSec,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: '🎭 Incarner ce personnage avec l\'Avatar',
                variant: CustomButtonVariant.accent,
                icon: Icons.theater_comedy_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  _enterProtagonistMode(title);
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: 'Fermer la découverte',
                variant: CustomButtonVariant.outline,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = ref.watch(userPrefsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. BARRE SUPERIEURE AVEC BOUTON FERMETURE [X] CONSTANT ───────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const AlterniaLogo(size: 28, showText: true),
                  const Spacer(),

                  // CONSTANT CLOSE BUTTON [X] WITH ACCENT ORANGE
                  GestureDetector(
                    onTap: _onExitCultureMode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Quitter',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.close_rounded,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.border
                    : const Color(0xFFCBD5E1),
                height: 1),

            // ── 2. SOUS-PAGES DE L'ESPACE CULTURE ───────────────────────────
            Expanded(
              child: IndexedStack(
                index: _subTabIndex,
                children: [
                  _buildInteractiveAvatarMode(),
                  _buildHistoryTab(userPrefs.classShortLabel),
                  _buildInventionsTab(),
                  _buildWisdomTab(),
                ],
              ),
            ),

            // ── 3. BOTTOM NAVBAR PROPRE À LA CULTURE ─────────────────────────
            _buildCultureBottomNavBar(),
          ],
        ),
      ),
    );
  }

  // ── SUB-PAGE 0 : AVATAR INTERACTIF ALTERNIA ──────────────────────────────
  Widget _buildInteractiveAvatarMode() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final speechBg = isDark ? AppColors.surface : Colors.white;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF475569);

    return Column(
      children: [
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          ),
          child: Text(
            'AVATAR INTERACTIF ALTERNIA',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              letterSpacing: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Touche l\'Avatar pour interagir',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: textSec,
          ),
        ),

        const Spacer(),

        // ── AVATAR INTERACTIF ANIMÉ ─────────────────────────────────────────
        AlterniaAvatar(
          size: 190,
          state: _avatarState,
          onTap: _onAvatarTapped,
        ),

        const Spacer(),

        // ── BULLE DE PAROLE DE L'AVATAR ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: speechBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _avatarState == AvatarState.speaking
                    ? AppColors.accent
                    : (isDark ? AppColors.secondary : AppColors.primary),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _avatarState == AvatarState.speaking
                            ? AppColors.accent
                            : AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _avatarState == AvatarState.speaking
                          ? 'ALTERNIA PARLE…'
                          : (_avatarState == AvatarState.listening
                              ? 'ÉCOUTE ACTIVE…'
                              : 'RÉFLEXION…'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _avatarState == AvatarState.speaking
                            ? AppColors.accent
                            : AppColors.secondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _liveSpeechText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.5,
                    color: textPri,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ── SUB-PAGE 1 : HISTOIRE DU MALI ────────────────────────────────────────
  Widget _buildHistoryTab(String classLabel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Histoire & Empires du Mali',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
        ),
        const SizedBox(height: 14),
        _CultureSubCard(
          title: 'L\'Empire du Mali & Mansa Moussa',
          subtitle: 'Le souverain le plus riche de l\'histoire humaine',
          category: 'Empire du Mali (XIIIe-XVe)',
          icon: Icons.account_balance_rounded,
          color: AppColors.accent,
          onTap: () => _showStoryModal(
            'L\'Empire du Mali & Mansa Moussa',
            'Histoire Impériale',
            'Au XIVème siècle, l\'Empire du Mali s\'étendait du fleuve Sénégal jusqu\'à la boucle du Niger. Son empereur le plus célèbre, Mansa Moussa, accomplit en 1324 un pèlerinage légendaire vers La Mecque avec une caravane de 60 000 hommes et des tonnes d\'or pure. Sa générosité à Le Caire provoqua une inflation de l\'or pendant plus de 10 ans ! Tombouctou devint alors la capitale mondiale du savoir africain.',
            Icons.account_balance_rounded,
            AppColors.accent,
          ),
        ),
        const SizedBox(height: 12),
        _CultureSubCard(
          title: 'Les Manuscrits Anciens de Tombouctou',
          subtitle:
              'Des dizaines de milliers de traités scientifiques et philosophiques',
          category: 'Patrimoine Écrit',
          icon: Icons.auto_stories_rounded,
          color: AppColors.secondary,
          onTap: () => _showStoryModal(
            'Les Manuscrits Anciens de Tombouctou',
            'Savoir & Écriture',
            'Bien avant l\'ère moderne, Tombouctou abritait l\'Université de Sankoré et plus de 25 000 étudiants venus de toute l\'Afrique et du Moyen-Orient. Des familles maliennes ont préservé de génération en génération plus de 700 000 manuscrits rédigés en arabe et en langues africaines, portant sur l\'astronomie, la médecine, le droit et les mathématiques.',
            Icons.auto_stories_rounded,
            AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        _CultureSubCard(
          title: 'Sundiata Keïta & la Charte du Manden',
          subtitle:
              'La première Déclaration universelle des Droits de l\'Homme (1236)',
          category: 'Histoire & Droit',
          icon: Icons.gavel_rounded,
          color: AppColors.primaryLight,
          onTap: () => _showStoryModal(
            'Sundiata Keïta & la Charte du Manden',
            'Droits Humains',
            'Proclamée en 1236 après la bataille de Kirina, la Charte du Manden (ou Kouroukan Fouga) est reconnue par l\'UNESCO comme l\'une des plus anciennes constitutions du monde. Elle abolit l\'esclavage, affirme le respect de la vie humaine, le droit à l\'éducation et l\'égalité des femmes bien avant les déclarations occidentales.',
            Icons.gavel_rounded,
            AppColors.primaryLight,
          ),
        ),
      ],
    );
  }

  // ── SUB-PAGE 2 : INVENTIONS & SAVOIR ─────────────────────────────────────
  Widget _buildInventionsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Inventions & Sciences au Mali',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
        ),
        const SizedBox(height: 14),
        _CultureSubCard(
          title: 'L\'Astronomie Ancestrale des Dogons',
          subtitle: 'La connaissance de Sirius B sans télescope moderne',
          category: 'Astrophysique',
          icon: Icons.wb_twilight_rounded,
          color: AppColors.secondary,
          onTap: () => _showStoryModal(
            'L\'Astronomie des Dogons',
            'Science des Étoiles',
            'Le peuple Dogon de la falaise de Bandiagara possédait des connaissances étonnantes sur le système stellaire de Sirius. Des décennies avant les télescopes modernes, ils savaient que Sirius avait une étoile compagnon invisible à l\'œil nu (Sirius B) qui tournait en 50 ans sur une orbite elliptique.',
            Icons.wb_twilight_rounded,
            AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        _CultureSubCard(
          title: 'L\'Architecture Bio-Climatique en Terre (Banco)',
          subtitle:
              'La Grande Mosquée de Djenné, chef-d\'œuvre d\'ingénierie durable',
          category: 'Génie Civil',
          icon: Icons.architecture_rounded,
          color: AppColors.accent,
          onTap: () => _showStoryModal(
            'L\'Architecture en Banco',
            'Ingénierie & Matériaux',
            'La Grande Mosquée de Djenné est le plus grand bâtiment en terre crue au monde. Les bâtisseurs maliens ont mis au point un matériau composite à base d\'argile, de balle de riz et de beurre de karité qui régule naturellement la température intérieure à 22°C même pendant les fortes chaleurs sahéliennes.',
            Icons.architecture_rounded,
            AppColors.accent,
          ),
        ),
      ],
    );
  }

  // ── SUB-PAGE 3 : SAGESSE & TRADITIONS ────────────────────────────────────
  Widget _buildWisdomTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Sagesse, Griots & Proverbes Bambaras',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
        ),
        const SizedBox(height: 14),
        _CultureSubCard(
          title: 'La Kora & la Parole des Griots',
          subtitle: 'L\'instrument à 21 cordes et la mémoire orale',
          category: 'Musique & Art',
          icon: Icons.music_note_rounded,
          color: AppColors.success,
          onTap: () => _showStoryModal(
            'La Kora & la Parole des Griots',
            'Art Oratoire',
            'La Kora est une harpe-luth traditionnelle à 21 cordes faite d\'une demi-calebasse recouverte de peau de vache. Les Griots (Djéli) conservent et chantent les généalogies, les poèmes et les leçons de morale depuis plus de 800 ans.',
            Icons.music_note_rounded,
            AppColors.success,
          ),
        ),
        const SizedBox(height: 12),
        _CultureSubCard(
          title: 'Proverbe Bambara : le trésor du savoir',
          subtitle:
              '« Le savoir est un trésor qui suit son possesseur partout »',
          category: 'Philosophie Africaine',
          icon: Icons.psychology_alt_rounded,
          color: AppColors.accentViolet,
          onTap: () => _showStoryModal(
            'La Sagesse des Proverbes Bambaras',
            'Philosophie',
            'Dans la culture orale malienne, les proverbes sont les clés de la réflexion. Ce proverbe enseigne que la véritable richesse d\'un jeune n\'est ni l\'argent ni les possessions matérielles, mais les connaissances acquises et la bienveillance.',
            Icons.psychology_alt_rounded,
            AppColors.accentViolet,
          ),
        ),
      ],
    );
  }

  // ── BARRE DE NAVIGATION CULTURE DYNAMIQUE THÈME ─────────────────────────
  Widget _buildCultureBottomNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.background : Colors.white;
    final navBorder = isDark ? AppColors.borderDark : const Color(0xFFCBD5E1);
    final unselectedColor = isDark
        ? const Color.fromARGB(255, 98, 114, 134)
        : const Color(0xFF64748B);

    final subItems = const [
      _CultureSubNavItem(icon: Icons.smart_toy_rounded, label: 'Avatar Live'),
      _CultureSubNavItem(icon: Icons.public_rounded, label: 'Histoire'),
      _CultureSubNavItem(icon: Icons.lightbulb_rounded, label: 'Inventions'),
      _CultureSubNavItem(icon: Icons.auto_stories_rounded, label: 'Sagesse'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      height: 58,
      decoration: BoxDecoration(
        color: navBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: navBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary)
                .withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(subItems.length, (index) {
          final isSelected = _subTabIndex == index;
          final item = subItems[index];

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _subTabIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 12 : 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.accentGradient : null,
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 18,
                    color: isSelected ? Colors.white : unselectedColor,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CultureSubNavItem {
  const _CultureSubNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

// ── Culture Sub Card Widget Dynamic Theme ───────────────────────────────────
class _CultureSubCard extends StatelessWidget {
  const _CultureSubCard({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surface : Colors.white;
    final cardBorder =
        isDark ? color.withValues(alpha: 0.3) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? AppColors.textSecondary : const Color(0xFF475569);

    return CustomCard(
      onTap: onTap,
      backgroundColor: cardBg,
      borderColor: cardBorder,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: subtitleColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
              size: 20),
        ],
      ),
    );
  }
}
