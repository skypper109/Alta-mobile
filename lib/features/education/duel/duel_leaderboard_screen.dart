// ─── AlterniA — Classement Scolaire National & Lycées ─────────────────────────
// Classements par nation, par lycée malien, par filière et par genre.
// Design système officiel : couleurs solides, zéro dégradé, zéro sticker.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import '../../profile/gamification_notifier.dart';
import '../../profile/user_prefs_notifier.dart';
import 'duel_service.dart';

enum LeaderboardScope {
  national,
  bySchool,
}

enum LeaderboardGenderFilter {
  all,
  girls,
  boys,
}

class MalianRankedStudent {
  final int rank;
  final String name;
  final String school;
  final String city;
  final String classLevel;
  final String gender; // 'F' ou 'M'
  final int xp;
  final int coins;
  final int wins;
  final int totalDuels;

  const MalianRankedStudent({
    required this.rank,
    required this.name,
    required this.school,
    required this.city,
    required this.classLevel,
    required this.gender,
    required this.xp,
    required this.coins,
    required this.wins,
    required this.totalDuels,
  });

  double get winRate => totalDuels > 0 ? (wins / totalDuels) * 100 : 0.0;
}

class DuelLeaderboardScreen extends ConsumerStatefulWidget {
  const DuelLeaderboardScreen({super.key});

  @override
  ConsumerState<DuelLeaderboardScreen> createState() =>
      _DuelLeaderboardScreenState();
}

class _DuelLeaderboardScreenState extends ConsumerState<DuelLeaderboardScreen> {
  LeaderboardScope _scope = LeaderboardScope.national;
  LeaderboardGenderFilter _genderFilter = LeaderboardGenderFilter.all;
  String _selectedSchool = 'Tous les lycées';

  final List<String> _malianSchools = [
    'Tous les lycées',
    'Lycée Askia Mohamed (Bamako)',
    'Lycée Ba Aminata Diallo (Bamako)',
    'Lycée Technique de Bamako',
    'Lycée Progrès de Ségou',
    'Lycée Hamadoun Dicko (Sévaré / Mopti)',
    'Lycée Dougoukolo Konaré (Kayes)',
    'Lycée Public de Sikasso',
    'Lycée Mahamane Alassane Haïdara (Tombouctou)',
  ];

  List<MalianRankedStudent> _liveStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLiveLeaderboard();
  }

  Future<void> _loadLiveLeaderboard() async {
    setState(() => _isLoading = true);
    final raw = await duelServiceProvider.fetchLeaderboard();
    if (raw.isNotEmpty && mounted) {
      setState(() {
        _liveStudents = raw
            .map((m) => MalianRankedStudent(
                  rank: m['rank'] ?? 1,
                  name: m['name'] ?? 'Élève',
                  school: m['school'] ?? 'Lycée Malien',
                  city: m['city'] ?? 'Bamako',
                  classLevel: m['class_level'] ?? 'TSExp',
                  gender: m['gender'] ?? 'M',
                  xp: m['xp'] ?? 5000,
                  coins: m['coins'] ?? 200,
                  wins: m['wins'] ?? 20,
                  totalDuels: m['total_duels'] ?? 25,
                ))
            .toList();
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  static const List<MalianRankedStudent> _defaultStudentsBank = [
    MalianRankedStudent(
      rank: 1,
      name: 'Sory  Diallo',
      school: 'Lycée Askia Mohamed (Bamako)',
      city: 'Bamako',
      classLevel: 'TSExp',
      gender: 'M',
      xp: 13275,
      coins: 520,
      wins: 39,
      totalDuels: 46,
    ),
    MalianRankedStudent(
      rank: 2,
      name: 'Fatoumata Diarra',
      school: 'Lycée Ba Aminata Diallo (Bamako)',
      city: 'Bamako',
      classLevel: 'TSE',
      gender: 'F',
      xp: 12758,
      coins: 480,
      wins: 38,
      totalDuels: 41,
    ),
    MalianRankedStudent(
      rank: 3,
      name: 'Amadou Konaté',
      school: 'Lycée Askia Mohamed (Bamako)',
      city: 'Bamako',
      classLevel: 'TSE',
      gender: 'M',
      xp: 11670,
      coins: 420,
      wins: 34,
      totalDuels: 39,
    ),
    MalianRankedStudent(
      rank: 3,
      name: 'Aïssata Traoré',
      school: 'Lycée Public de Sikasso',
      city: 'Sikasso',
      classLevel: 'TSExp',
      gender: 'F',
      xp: 8150,
      coins: 390,
      wins: 31,
      totalDuels: 35,
    ),
    MalianRankedStudent(
      rank: 4,
      name: 'Ousmane Coulibaly',
      school: 'Lycée Hamadoun Dicko (Sévaré / Mopti)',
      city: 'Mopti',
      classLevel: 'TSE',
      gender: 'M',
      xp: 7640,
      coins: 360,
      wins: 29,
      totalDuels: 34,
    ),
    MalianRankedStudent(
      rank: 5,
      name: 'Kadiatou Fofana',
      school: 'Lycée Ba Aminata Diallo (Bamako)',
      city: 'Bamako',
      classLevel: '11eme Sc',
      gender: 'F',
      xp: 7210,
      coins: 340,
      wins: 27,
      totalDuels: 32,
    ),
    MalianRankedStudent(
      rank: 6,
      name: 'Boubacar Sanogo',
      school: 'Lycée Progrès de Ségou',
      city: 'Ségou',
      classLevel: 'TSE',
      gender: 'M',
      xp: 6890,
      coins: 310,
      wins: 25,
      totalDuels: 30,
    ),
    MalianRankedStudent(
      rank: 7,
      name: 'Mariam Touré',
      school: 'Lycée Mahamane Alassane Haïdara (Tombouctou)',
      city: 'Tombouctou',
      classLevel: 'TSS',
      gender: 'F',
      xp: 6420,
      coins: 290,
      wins: 23,
      totalDuels: 28,
    ),
    MalianRankedStudent(
      rank: 8,
      name: 'Ibrahim Cissé',
      school: 'Lycée Dougoukolo Konaré (Kayes)',
      city: 'Kayes',
      classLevel: '11eme Sc',
      gender: 'M',
      xp: 5980,
      coins: 270,
      wins: 21,
      totalDuels: 26,
    ),
    MalianRankedStudent(
      rank: 9,
      name: 'Aminata Samaké',
      school: 'Lycée Technique de Bamako',
      city: 'Bamako',
      classLevel: '12eme STI',
      gender: 'F',
      xp: 5640,
      coins: 250,
      wins: 19,
      totalDuels: 24,
    ),
    MalianRankedStudent(
      rank: 10,
      name: 'Moussa Diallo',
      school: 'Lycée Askia Mohamed (Bamako)',
      city: 'Bamako',
      classLevel: 'TSE',
      gender: 'M',
      xp: 5210,
      coins: 240,
      wins: 18,
      totalDuels: 23,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userPrefs = ref.watch(userPrefsProvider);
    final gamification = ref.watch(gamificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AltaColors.backgroundDark : AltaColors.backgroundLight;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    // Filtrage dynamique (priorité à alta_db en direct)
    final activeList =
        _liveStudents.isNotEmpty ? _liveStudents : _defaultStudentsBank;
    var filtered = activeList.where((s) {
      if (_genderFilter == LeaderboardGenderFilter.girls && s.gender != 'F') {
        return false;
      }
      if (_genderFilter == LeaderboardGenderFilter.boys && s.gender != 'M') {
        return false;
      }
      if (_scope == LeaderboardScope.bySchool &&
          _selectedSchool != 'Tous les lycées') {
        if (!s.school.toLowerCase().contains(_selectedSchool.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: textPri, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'CLASSEMENT SCOLAIRE NATIONAL',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AltaColors.secondary,
          ),
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AltaColors.secondary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded,
                    color: AltaColors.secondary),
            tooltip: 'Actualiser depuis alta_db',
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadLiveLeaderboard();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. BARRE DE FILTRES SUPÉRIEURE ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: cardBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélecteur Portée : National vs Par Lycée
                  Row(
                    children: [
                      Expanded(
                        child: _ScopeTabButton(
                          title: 'National Mali',
                          icon: Icons.public_rounded,
                          isSelected: _scope == LeaderboardScope.national,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _scope = LeaderboardScope.national);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ScopeTabButton(
                          title: 'Par Lycée',
                          icon: Icons.school_rounded,
                          isSelected: _scope == LeaderboardScope.bySchool,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _scope = LeaderboardScope.bySchool);
                          },
                        ),
                      ),
                    ],
                  ),

                  // Menu déroulant Lycée si sélectionné
                  if (_scope == LeaderboardScope.bySchool) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AltaColors.surfaceAltDark
                            : AltaColors.surfaceAltLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderCol),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSchool,
                          isExpanded: true,
                          dropdownColor: cardBg,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textPri,
                          ),
                          items: _malianSchools.map((s) {
                            return DropdownMenuItem<String>(
                              value: s,
                              child: Text(s, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedSchool = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Filtre par Genre (Tous, Filles, Garçons)
                  Row(
                    children: [
                      Text(
                        'Genre :',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textSec,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _GenderChip(
                        label: 'Tous',
                        icon: Icons.groups_rounded,
                        isSelected:
                            _genderFilter == LeaderboardGenderFilter.all,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() =>
                              _genderFilter = LeaderboardGenderFilter.all);
                        },
                      ),
                      const SizedBox(width: 6),
                      _GenderChip(
                        label: 'Filles',
                        icon: Icons.female_rounded,
                        isSelected:
                            _genderFilter == LeaderboardGenderFilter.girls,
                        color: const Color(0xFFEC4899),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() =>
                              _genderFilter = LeaderboardGenderFilter.girls);
                        },
                      ),
                      const SizedBox(width: 6),
                      _GenderChip(
                        label: 'Garçons',
                        icon: Icons.male_rounded,
                        isSelected:
                            _genderFilter == LeaderboardGenderFilter.boys,
                        color: const Color(0xFF3B82F6),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() =>
                              _genderFilter = LeaderboardGenderFilter.boys);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: borderCol),

            // ── 2. LISTE DU CLASSEMENT ─────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_search_rounded,
                              size: 48, color: textSec),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun élève trouvé pour ces critères',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: textSec,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, idx) {
                        final st = filtered[idx];
                        return _StudentRankTile(
                          student: st,
                          isTop3: st.rank <= 3,
                        );
                      },
                    ),
            ),

            // ── 3. BANDEAU FIXE INFÉRIEUR : TON CLASSEMENT ACTUEL ────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(top: BorderSide(color: borderCol)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AltaColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#12',
                      style: GoogleFonts.spaceMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userPrefs.name.isNotEmpty
                              ? '${userPrefs.name} (Toi)'
                              : 'Toi (Élève AlterniA)',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: textPri,
                          ),
                        ),
                        Text(
                          '${userPrefs.classShortLabel} • ${gamification.xp} XP • ${gamification.coins} Pièces',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AltaColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AltaColors.primary,
                      backgroundColor:
                          AltaColors.primary.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.flash_on_rounded, size: 16),
                    label: const Text('Défier'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeTabButton extends StatelessWidget {
  const _ScopeTabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AltaColors.primary
              : Theme.of(context).brightness == Brightness.dark
                  ? AltaColors.surfaceAltDark
                  : AltaColors.surfaceAltLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AltaColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color = AltaColors.secondary,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark
                  ? AltaColors.surfaceAltDark
                  : AltaColors.surfaceAltLight),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentRankTile extends StatelessWidget {
  const _StudentRankTile({
    required this.student,
    required this.isTop3,
  });

  final MalianRankedStudent student;
  final bool isTop3;

  Color _rankColor() {
    switch (student.rank) {
      case 1:
        return const Color(0xFFEAB308); // Or
      case 2:
        return const Color(0xFF94A3B8); // Argent
      case 3:
        return const Color(0xFFD97706); // Bronze
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop3 ? _rankColor() : borderCol,
          width: isTop3 ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Badge Rang
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isTop3
                  ? _rankColor().withValues(alpha: 0.18)
                  : (isDark
                      ? AltaColors.surfaceAltDark
                      : AltaColors.surfaceAltLight),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isTop3 ? _rankColor() : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '#${student.rank}',
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: isTop3 ? _rankColor() : textPri,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Détails Élève
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        student.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: textPri,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: student.gender == 'F'
                            ? const Color(0xFFEC4899).withValues(alpha: 0.15)
                            : const Color(0xFF3B82F6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        student.gender == 'F' ? 'Fille' : 'Garçon',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: student.gender == 'F'
                              ? const Color(0xFFEC4899)
                              : const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AltaColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        student.classLevel,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AltaColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  student.school,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: textSec,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Score et victoires
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${student.xp} XP',
                style: GoogleFonts.spaceMono(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: AltaColors.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${student.wins} victoires',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: textSec,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
