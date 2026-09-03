// ─── AlterniA — Page Recherche Culturelle ─────────────────────────────────────
library;

import 'dart:async';
import 'package:alternia/core/culture_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/datasources/mock_mali_regions.dart';
import '../../data/models/mali_region.dart';
import '../../../core/theme/culture_theme.dart';

// ════════════════════════════════════════════════════════════════════
// PROVIDERS
// ════════════════════════════════════════════════════════════════════

final _cultureAiServiceProvider = Provider<CultureAiService>(
  (ref) => CultureAiService(),
);

// ════════════════════════════════════════════════════════════════════
// FILTRES
// ════════════════════════════════════════════════════════════════════

class _SearchFilter {
  final String label;
  final IconData icon;
  final Color color;
  const _SearchFilter(
      {required this.label, required this.icon, required this.color});
}

const _searchFilters = <_SearchFilter>[
  _SearchFilter(
      label: "Tout", icon: Icons.grid_view_rounded, color: Color(0xFF314999)),
  _SearchFilter(
      label: "Régions", icon: Icons.map_rounded, color: Color(0xFFC67C2E)),
  _SearchFilter(
      label: "Monuments",
      icon: Icons.account_balance_rounded,
      color: Color(0xFF10B981)),
  _SearchFilter(
      label: "Histoire",
      icon: Icons.history_edu_rounded,
      color: Color(0xFF6366F1)),
  _SearchFilter(
      label: "Traditions",
      icon: Icons.music_note_rounded,
      color: Color(0xFF8B5CF6)),
];

// ════════════════════════════════════════════════════════════════════
// SUGGESTIONS POPULAIRES
// ════════════════════════════════════════════════════════════════════

const _suggestions = [
  "Soundiata Keita",
  "Mansa Moussa",
  "Tombouctou",
  "Djenne",
  "Contes du lievre",
  "Les 3 Empires",
  "Pays Dogon",
  "Griots du Manden",
  "Tata de Sikasso",
  "Fleuve Niger",
  "Segou",
  "Askia Mohammed",
];

// ════════════════════════════════════════════════════════════════════
// PAGE
// ════════════════════════════════════════════════════════════════════

class CultureSearchPage extends ConsumerStatefulWidget {
  const CultureSearchPage({super.key});
  @override
  ConsumerState<CultureSearchPage> createState() => _CultureSearchPageState();
}

class _CultureSearchPageState extends ConsumerState<CultureSearchPage>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  String _query = "";
  int _selectedFilter = 0;
  bool _isLoading = false;
  CultureSearchResult? _aiResult;
  List<MaliRegion> _regionResults = [];
  List<String> _searchHistory = [];

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _aiResult = null;
        _regionResults = [];
        _isLoading = false;
      });
      return;
    }
    _updateLocalResults(value);
    _debounce = Timer(const Duration(milliseconds: 700),
        () => _triggerAiSearch(value.trim()));
  }

  void _updateLocalResults(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _regionResults = MockMaliRegions.regions
          .where((r) =>
              r.nom.toLowerCase().contains(q) ||
              r.surnom.toLowerCase().contains(q) ||
              r.descriptionCourte.toLowerCase().contains(q) ||
              r.chefLieu.toLowerCase().contains(q) ||
              r.pointsForts.any((p) => p.toLowerCase().contains(q)) ||
              r.symbolesEtTraditions.any((s) => s.toLowerCase().contains(q)))
          .toList();
    });
  }

  Future<void> _triggerAiSearch(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    _fadeCtrl.reset();
    final service = ref.read(_cultureAiServiceProvider);
    final result = await service.culturalSearch(query);
    _refineWithAi(result, query);
    if (mounted) {
      setState(() {
        _aiResult = result;
        _isLoading = false;
        if (!_searchHistory.contains(query)) {
          _searchHistory = [query, ..._searchHistory].take(6).toList();
        }
      });
      _fadeCtrl.forward();
    }
  }

  void _refineWithAi(CultureSearchResult result, String query) {
    final keywords = [...result.keywords, ...query.toLowerCase().split(" ")];
    final refined = MockMaliRegions.regions
        .where((r) => keywords.any((kw) =>
            r.nom.toLowerCase().contains(kw) ||
            r.surnom.toLowerCase().contains(kw) ||
            r.descriptionCourte.toLowerCase().contains(kw) ||
            r.chefLieu.toLowerCase().contains(kw) ||
            r.pointsForts.any((p) => p.toLowerCase().contains(kw)) ||
            r.symbolesEtTraditions.any((s) => s.toLowerCase().contains(kw))))
        .toList();
    final merged = {..._regionResults, ...refined}.toList();
    if (mounted) setState(() => _regionResults = merged);
  }

  void _onSuggestionTap(String s) {
    _controller.text = s;
    _onQueryChanged(s);
    HapticFeedback.selectionClick();
  }

  void _onRegionTap(MaliRegion r) {
    HapticFeedback.mediumImpact();
    context.push("/culture/region/${r.id}", extra: r);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? CultureTheme.darkBackground : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(isDark),
            const SizedBox(height: 6),
            _buildFilterRow(isDark),
            const SizedBox(height: 4),
            Expanded(
                child: _query.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildResultsState(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    final border = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final surface =
        isDark ? CultureTheme.darkSurface : CultureTheme.lightSurfaceAlt;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (context.canPop()) context.pop();
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border)),
              child: Icon(Icons.arrow_back_rounded,
                  size: 20,
                  color: isDark ? Colors.white : CultureTheme.primaryBlue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      size: 20, color: CultureTheme.accentOrange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onQueryChanged,
                      onSubmitted: (v) => _triggerAiSearch(v.trim()),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: "Region, personnage, conte, tradition…",
                        hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      cursorColor: CultureTheme.accentOrange,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        _onQueryChanged("");
                        _focusNode.requestFocus();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.close_rounded,
                            size: 18,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(bool isDark) {
    final border = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final surface = isDark ? CultureTheme.darkSurface : Colors.white;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _searchFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _searchFilters[i];
          final isSelected = _selectedFilter == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? f.color : surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? f.color : border, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.icon,
                      size: 13,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B))),
                  const SizedBox(width: 6),
                  Text(f.label,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final border = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchHistory.isNotEmpty) ...[
            _sectionLabel("Recherches recentes", Icons.history_rounded, isDark),
            const SizedBox(height: 10),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _searchHistory
                    .map((h) => _historyChip(h, isDark, border))
                    .toList()),
            const SizedBox(height: 24),
          ],
          _sectionLabel(
              "Explorations populaires", Icons.trending_up_rounded, isDark),
          const SizedBox(height: 12),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _suggestions.map((s) => _suggestionChip(s, isDark)).toList()),
          const SizedBox(height: 28),
          _buildAiBanner(isDark),
          const SizedBox(height: 24),
          _sectionLabel("Les 19 Regions du Mali", Icons.map_rounded, isDark),
          const SizedBox(height: 12),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MockMaliRegions.regions
                  .map((r) => _regionPill(r, isDark, border))
                  .toList()),
        ],
      ),
    );
  }

  Widget _historyChip(String text, bool isDark, Color border) {
    return GestureDetector(
      onTap: () => _onSuggestionTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
            color: isDark ? CultureTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.history_rounded,
              size: 13,
              color:
                  isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Text(text,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569))),
        ]),
      ),
    );
  }

  Widget _suggestionChip(String text, bool isDark) {
    return GestureDetector(
      onTap: () => _onSuggestionTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              CultureTheme.accentOrange.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: CultureTheme.accentOrange.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.search_rounded,
              size: 13, color: CultureTheme.accentOrange),
          const SizedBox(width: 6),
          Text(text,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: CultureTheme.accentOrange)),
        ]),
      ),
    );
  }

  Widget _regionPill(MaliRegion r, bool isDark, Color border) {
    return GestureDetector(
      onTap: () => _onRegionTap(r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: r.couleurAccent.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: r.couleurAccent.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(r.icone, size: 13, color: r.couleurAccent),
          const SizedBox(width: 6),
          Text(r.nom,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: r.couleurAccent)),
        ]),
      ),
    );
  }

  Widget _buildAiBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CultureTheme.primaryBlue.withValues(alpha: isDark ? 0.14 : 0.06),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: CultureTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: CultureTheme.primaryBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_rounded,
                size: 22, color: CultureTheme.primaryBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Guide Culturel IA — LLM Mali",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: CultureTheme.primaryBlue)),
              const SizedBox(height: 3),
              Text(
                  "Posez n'importe quelle question sur le Mali : histoire, contes, regions, traditions…",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                      height: 1.4)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildResultsState(bool isDark) {
    final border = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            _buildAiLoadingCard(isDark)
          else if (_aiResult != null)
            FadeTransition(
                opacity: _fadeAnim,
                child: _buildAiResultCard(_aiResult!, isDark)),
          const SizedBox(height: 20),
          if (_regionResults.isNotEmpty) ...[
            _sectionLabel(
                "${_regionResults.length} region${_regionResults.length > 1 ? "s" : ""} trouvee${_regionResults.length > 1 ? "s" : ""}",
                Icons.map_rounded,
                isDark),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _regionResults.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _buildRegionCard(
                  _regionResults[i], isDark, border, titleColor, subtitleColor),
            ),
          ] else if (!_isLoading)
            _buildNoResults(isDark, border, subtitleColor),
        ],
      ),
    );
  }

  Widget _buildAiLoadingCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CultureTheme.primaryBlue.withValues(alpha: isDark ? 0.14 : 0.06),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: CultureTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const SizedBox(
              width: 36,
              height: 36,
              child: Padding(
                  padding: EdgeInsets.all(6),
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: CultureTheme.primaryBlue))),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Guide Culturel en train de chercher…",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: CultureTheme.primaryBlue)),
              const SizedBox(height: 3),
              Text("Consultation des archives culturelles du Mali",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8))),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildAiResultCard(CultureSearchResult result, bool isDark) {
    final typeColor = _colorForType(result.resultType);
    final typeIcon = _iconForType(result.resultType);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? CultureTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: typeColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
              color: typeColor.withValues(alpha: isDark ? 0.08 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: Icon(typeIcon, size: 18, color: typeColor)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    result.isFromAi
                        ? "Reponse du Guide Culturel IA"
                        : "Resultat local (hors-ligne)",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: typeColor))),
            Icon(
                result.isFromAi
                    ? Icons.smart_toy_rounded
                    : Icons.wifi_off_rounded,
                size: 15,
                color: typeColor.withValues(alpha: 0.7)),
          ],
        ),
        const SizedBox(height: 12),
        Text(result.aiNarrative,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color:
                    isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                height: 1.65)),
      ]),
    );
  }

  Widget _buildRegionCard(MaliRegion r, bool isDark, Color border,
      Color titleColor, Color subtitleColor) {
    return GestureDetector(
      onTap: () => _onRegionTap(r),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? CultureTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: r.couleurAccent.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: r.couleurAccent.withValues(alpha: 0.3))),
              child: Icon(r.icone, size: 24, color: r.couleurAccent),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                        child: Text(r.nom,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: titleColor))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: r.couleurAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(r.code,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: r.couleurAccent)),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text(r.surnom,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5, color: subtitleColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(r.descriptionCourte,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: subtitleColor, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ])),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                size: 20,
                color:
                    isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(bool isDark, Color border, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color:
              isDark ? CultureTheme.darkSurface : CultureTheme.lightSurfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border)),
      child: Column(children: [
        Icon(Icons.search_off_rounded,
            size: 40,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
        const SizedBox(height: 12),
        Text("Aucune region locale pour cela",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: subtitleColor)),
        const SizedBox(height: 4),
        Text("Le Guide Culturel IA a peut-etre une reponse.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8))),
      ]),
    );
  }

  Widget _sectionLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: CultureTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 12, color: CultureTheme.primaryBlue),
            const SizedBox(width: 5),
            Text(label.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: CultureTheme.primaryBlue)),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Container(
                height: 1,
                color: isDark
                    ? CultureTheme.darkBorder
                    : CultureTheme.lightBorder)),
      ],
    );
  }

  IconData _iconForType(CultureResultType type) {
    switch (type) {
      case CultureResultType.figure:
        return Icons.person_rounded;
      case CultureResultType.monument:
        return Icons.account_balance_rounded;
      case CultureResultType.ville:
        return Icons.location_city_rounded;
      case CultureResultType.conte:
        return Icons.auto_stories_rounded;
      case CultureResultType.devinette:
        return Icons.quiz_rounded;
      case CultureResultType.region:
        return Icons.map_rounded;
      case CultureResultType.general:
        return Icons.smart_toy_rounded;
    }
  }

  Color _colorForType(CultureResultType type) {
    switch (type) {
      case CultureResultType.figure:
        return const Color(0xFF6366F1);
      case CultureResultType.monument:
        return const Color(0xFF10B981);
      case CultureResultType.ville:
        return const Color(0xFF0EA5E9);
      case CultureResultType.conte:
        return CultureTheme.accentOrange;
      case CultureResultType.devinette:
        return const Color(0xFF8B5CF6);
      case CultureResultType.region:
        return CultureTheme.ocreTerre;
      case CultureResultType.general:
        return CultureTheme.primaryBlue;
    }
  }
}
