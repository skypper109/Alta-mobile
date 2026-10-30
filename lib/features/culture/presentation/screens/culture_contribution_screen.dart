import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/controllers/culture_data_providers.dart';
import '../../core/datasources/culture_repository.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/theme/culture_theme.dart';
import '../../exploration/data/datasources/mock_mali_regions.dart';
import '../../immersive/immersive.dart';
import '../../../profile/gamification_notifier.dart';
import '../../../profile/user_prefs_notifier.dart';

/// Définition des 6 piliers culturels pour la contribution
enum CulturalCategory {
  proverbe(
    id: 'proverbe',
    label: 'Proverbe',
    subLabel: 'Sagesse & Maximes ancestrales',
    icon: Icons.format_quote_rounded,
    color: Color(0xFF10B981),
  ),
  devinette(
    id: 'devinette',
    label: 'Devinette',
    subLabel: 'Énigmes & Jeux d\'esprit (N\'dankoun)',
    icon: Icons.lightbulb_rounded,
    color: Color(0xFFF59E0B),
  ),
  conte(
    id: 'conte',
    label: 'Conte & Fable',
    subLabel: 'Récits oraux du soir (Kotéba)',
    icon: Icons.auto_stories_rounded,
    color: Color(0xFFEC4899),
  ),
  monument(
    id: 'monument',
    label: 'Monument & Site',
    subLabel: 'Édifices, sanctuaires & lieux sacrés',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF3B82F6),
  ),
  personnage(
    id: 'personnage',
    label: 'Grand Personnage',
    subLabel: 'Héros, reines, savants & rois',
    icon: Icons.shield_rounded,
    color: Color(0xFF8B5CF6),
  ),
  lieu(
    id: 'lieu',
    label: 'Ville & Terroir',
    subLabel: 'Cités historiques & villages fondateurs',
    icon: Icons.location_city_rounded,
    color: Color(0xFF06B6D4),
  ),
  patronyme(
    id: 'patronyme',
    label: 'Patronyme (Jamu)',
    subLabel: 'Noms de famille, totems & senankouya',
    icon: Icons.family_restroom_rounded,
    color: Color(0xFFE11D48),
  );

  final String id;
  final String label;
  final String subLabel;
  final IconData icon;
  final Color color;

  const CulturalCategory({
    required this.id,
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.color,
  });
}

/// Écran complet de contribution citoyenne à tous les contenus culturels du Mali
class CultureContributionScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const CultureContributionScreen({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<CultureContributionScreen> createState() =>
      _CultureContributionScreenState();
}

class _CultureContributionScreenState
    extends ConsumerState<CultureContributionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CulturalCategory _selectedCategory;

  final _formKey = GlobalKey<FormState>();

  // Contrôleurs généraux
  final _titreCtrl = TextEditingController();
  final _texteCtrl = TextEditingController();
  final _texteOriginalCtrl = TextEditingController();
  final _significationCtrl = TextEditingController();
  final _moraleCtrl = TextEditingController();
  final _origineCtrl = TextEditingController(text: 'Tradition Mandingue');
  final _sourceTemoinCtrl = TextEditingController();
  final _auteurNomCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();

  // Contrôleurs spécifiques
  final _totemCtrl = TextEditingController();
  final _senankouyaCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _epoqueCtrl = TextEditingController();

  String _selectedRegionId = 'bamako';
  String _selectedAuteurRole = 'Apprenant';
  bool _isSubmitting = false;

  final List<String> _auteurRoles = [
    'Apprenant',
    'Parent',
    'Enseignant',
    'Griot / Sage',
    'Chercheur',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _selectedCategory = CulturalCategory.values.firstWhere(
      (c) => c.id == widget.initialCategory,
      orElse: () => CulturalCategory.proverbe,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userName = ref.read(userPrefsProvider).name.trim();
      if (userName.isNotEmpty && _auteurNomCtrl.text.trim().isEmpty) {
        _auteurNomCtrl.text = userName;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titreCtrl.dispose();
    _texteCtrl.dispose();
    _texteOriginalCtrl.dispose();
    _significationCtrl.dispose();
    _moraleCtrl.dispose();
    _origineCtrl.dispose();
    _sourceTemoinCtrl.dispose();
    _auteurNomCtrl.dispose();
    _photoUrlCtrl.dispose();
    _totemCtrl.dispose();
    _senankouyaCtrl.dispose();
    _villeCtrl.dispose();
    _epoqueCtrl.dispose();
    super.dispose();
  }

  String _getRegionName(String id) {
    try {
      final reg = MockMaliRegions.regions.firstWhere((r) => r.id == id);
      return reg.nom;
    } catch (_) {
      return 'Tout le Mali';
    }
  }

  Future<void> _submitContribution() async {
    if (!_formKey.currentState!.validate()) {
      CulturalHaptics.warning();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir les champs obligatoires (*)'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    CulturalHaptics.cardPress();

    final repo = ref.read(cultureRepositoryProvider);

    final donneesExtra = <String, dynamic>{};
    if (_selectedCategory == CulturalCategory.patronyme) {
      if (_totemCtrl.text.isNotEmpty) donneesExtra['totem'] = _totemCtrl.text.trim();
      if (_senankouyaCtrl.text.isNotEmpty) {
        donneesExtra['senankouya'] = _senankouyaCtrl.text.trim();
      }
    } else if (_selectedCategory == CulturalCategory.monument) {
      if (_villeCtrl.text.isNotEmpty) donneesExtra['ville'] = _villeCtrl.text.trim();
      if (_epoqueCtrl.text.isNotEmpty) donneesExtra['epoque'] = _epoqueCtrl.text.trim();
    } else if (_selectedCategory == CulturalCategory.personnage) {
      if (_epoqueCtrl.text.isNotEmpty) donneesExtra['periode'] = _epoqueCtrl.text.trim();
    } else if (_selectedCategory == CulturalCategory.lieu) {
      if (_epoqueCtrl.text.isNotEmpty) donneesExtra['fondation'] = _epoqueCtrl.text.trim();
    }

    final userPrefs = ref.read(userPrefsProvider);
    final profileName = userPrefs.name.trim();
    final authorName = _auteurNomCtrl.text.trim().isNotEmpty
        ? _auteurNomCtrl.text.trim()
        : (profileName.isNotEmpty ? profileName : 'Gardien AlterniA');

    final payload = <String, dynamic>{
      'type_contenu': _selectedCategory.id,
      'titre': _titreCtrl.text.trim().isNotEmpty ? _titreCtrl.text.trim() : null,
      'texte': _texteCtrl.text.trim(),
      'texte_original': _texteOriginalCtrl.text.trim().isNotEmpty
          ? _texteOriginalCtrl.text.trim()
          : null,
      'signification': _significationCtrl.text.trim(),
      'morale': _moraleCtrl.text.trim().isNotEmpty ? _moraleCtrl.text.trim() : null,
      'origine': _origineCtrl.text.trim().isNotEmpty
          ? _origineCtrl.text.trim()
          : 'Tradition Orale',
      'theme': 'Patrimoine & Culture Vivante',
      'region_id': _selectedRegionId,
      'region_nom': _getRegionName(_selectedRegionId),
      'source_temoin': _sourceTemoinCtrl.text.trim().isNotEmpty
          ? _sourceTemoinCtrl.text.trim()
          : null,
      'photo_url': _photoUrlCtrl.text.trim().isNotEmpty
          ? _photoUrlCtrl.text.trim()
          : null,
      'donnees_supplementaires': donneesExtra,
      'donneesSupplementaires': donneesExtra,
      'auteur_id': profileName.isNotEmpty ? profileName : authorName,
      'auteur_nom': authorName,
      'auteur_role': _selectedAuteurRole,
      'xp_attribues': 50,
      'pieces_attribuees': 25,
    };

    final result = await repo.submitContribution(payload);

    // Rafraîchir immédiatement la liste des contributions pour que l'onglet Historique soit à jour
    ref.invalidate(culturalContributionsProvider);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result != null) {
      CulturalHaptics.celebration();
      _showSuccessDialog();
    } else {
      CulturalHaptics.warning();
      _showSuccessDialog(isOfflineQueued: true);
    }
  }

  void _showSuccessDialog({bool isOfflineQueued = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isOfflineQueued
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981))
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOfflineQueued
                    ? Icons.cloud_upload_rounded
                    : Icons.check_circle_rounded,
                color: isOfflineQueued
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF10B981),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isOfflineQueued
                    ? 'Enregistrée pour le Super Admin !'
                    : 'Envoyée au Super Admin !',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOfflineQueued
                  ? 'Votre contribution est enregistrée avec le statut « En attente » et sera transmise automatiquement au Super Admin dès la connexion au serveur pour vérification (acceptation ou rejet).'
                  : 'Merci pour votre transmission précieuse. Votre contribution a été envoyée au Super Admin pour vérification (acceptation ou rejet). Vous pouvez suivre son statut dans l\'onglet « Historique ».',
              style: GoogleFonts.inter(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded,
                      color: CultureTheme.accentOrange, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '+50 XP et +25 Pièces dès validation officielle dans votre portefeuille !',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetForm();
              _tabController.animateTo(1); // Basculer vers l'onglet "Mes contributions"
            },
            child: Text(
              'Voir mes contributions',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: CultureTheme.accentOrange,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CultureTheme.accentOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Terminer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _titreCtrl.clear();
    _texteCtrl.clear();
    _texteOriginalCtrl.clear();
    _significationCtrl.clear();
    _moraleCtrl.clear();
    _sourceTemoinCtrl.clear();
    _photoUrlCtrl.clear();
    _totemCtrl.clear();
    _senankouyaCtrl.clear();
    _villeCtrl.clear();
    _epoqueCtrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? CultureTheme.darkBackground
        : CultureTheme.lightBackground;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contribuer au Patrimoine',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: titleColor,
              ),
            ),
            Text(
              'Enrichir le Sanctuaire Culturel du Mali',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: CultureTheme.accentOrange,
          unselectedLabelColor:
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          indicatorColor: CultureTheme.accentOrange,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Nouveau Savoir', icon: Icon(Icons.edit_note_rounded)),
            Tab(text: 'Historique', icon: Icon(Icons.history_edu_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormView(isDark, cardBg, borderCol, titleColor),
          _buildHistoryView(isDark, cardBg, borderCol, titleColor),
        ],
      ),
    );
  }

  Widget _buildFormView(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final hintColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    final hPad = CultureResponsive.horizontalPadding(context);
    final isTablet = CultureResponsive.isTablet(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
      child: CultureResponsive.constrainedCentered(
        maxWidth: CultureResponsive.kMaxFormWidth,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // ── Bannière Gardien du Savoir ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CultureTheme.accentOrange.withValues(alpha: isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CultureTheme.accentOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_user_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sauvegardez la Mémoire Vivante',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tout citoyen, parent ou apprenant peut transmettre un savoir oral ou historique. Chaque soumission validée vous rapporte 50 XP et 25 Pièces !',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Choix du Pilier Culturel (6 Catégories) ───────────────────────
            Text(
              '1. Quel domaine culturel souhaitez-vous enrichir ? *',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: CulturalCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        CulturalHaptics.tabSwitch();
                        setState(() => _selectedCategory = cat);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color
                              : (isDark ? CultureTheme.darkSurface : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? cat.color : borderCol,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: cat.color.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat.icon,
                              size: 18,
                              color: isSelected ? Colors.white : cat.color,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cat.label,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : textColor,
                                  ),
                                ),
                                Text(
                                  cat.subLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.85)
                                        : hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Formulaire dynamique selon la catégorie ───────────────────────
            _buildDynamicCategoryFields(isDark, cardBg, borderCol, textColor, hintColor),

            const SizedBox(height: 24),

            // ── Métadonnées Générales : Région & Source ───────────────────────
            Text(
              '3. Origine & Attestation du Savoir',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // Sélection de la région & du rôle
            if (isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildRegionDropdown(isDark, cardBg, borderCol, textColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRoleDropdown(isDark, cardBg, borderCol, textColor),
                  ),
                ],
              )
            else ...[
              _buildRegionDropdown(isDark, cardBg, borderCol, textColor),
              const SizedBox(height: 12),
              _buildRoleDropdown(isDark, cardBg, borderCol, textColor),
            ],

            const SizedBox(height: 14),

            // Témoin / Source du savoir
            Text(
              'Qui vous a transmis cette histoire ou sagesse ?',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _sourceTemoinCtrl,
              style: TextStyle(color: textColor),
              decoration: _inputDecoration(
                isDark,
                borderCol,
                cardBg,
                Icons.record_voice_over_rounded,
                hint: 'Ex: Ma grand-mère à Ségou, le doyen du village...',
              ),
            ),

            const SizedBox(height: 14),

            // Nom du contributeur
            Text(
              'Votre nom ou pseudo (apparaîtra dans les crédits officiels)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _auteurNomCtrl,
              style: TextStyle(color: textColor),
              decoration: _inputDecoration(
                isDark,
                borderCol,
                cardBg,
                Icons.person_outline_rounded,
                hint: 'Ex: Amadou Diarra',
              ),
            ),

            const SizedBox(height: 32),

            // ── Bouton de Soumission ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitContribution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CultureTheme.accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: CultureTheme.accentOrange.withValues(alpha: 0.4),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_rounded, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Transmettre au Conseil des Sages',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildDynamicCategoryFields(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color textColor,
    Color hintColor,
  ) {
    final isTablet = CultureResponsive.isTablet(context);
    switch (_selectedCategory) {
      case CulturalCategory.proverbe:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Contenu du Proverbe',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _texteCtrl,
              label: 'Proverbe en français *',
              hint: 'Ex: Petit à petit, l\'oiseau fait son nid...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 2,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _texteOriginalCtrl,
              label: 'Version en langue locale (Bambara, Peul, etc.)',
              hint: 'Ex: Dɔɔnin dɔɔnin, kɔnɔnin b\'a ɲaa da...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _significationCtrl,
              label: 'Signification & Enseignement *',
              hint: 'Expliquez le sens profond et quand on l\'utilise...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 3,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
          ],
        );

      case CulturalCategory.devinette:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. L\'Énigme & sa Réponse (N\'dankoun)',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _texteCtrl,
              label: 'L\'énigme / La question posée *',
              hint: 'Ex: Je marche à 4 pattes le matin, 2 à midi et 3 le soir. Qui suis-je ?',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 2,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _moraleCtrl,
              label: 'La réponse à l\'énigme *',
              hint: 'Ex: L\'être humain au cours de sa vie...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _significationCtrl,
              label: 'Explication ou leçon d\'esprit *',
              hint: 'Pourquoi cette réponse ? Quelle réflexion apporte-t-elle ?',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 3,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
          ],
        );

      case CulturalCategory.conte:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Le Récit du Conte & sa Morale',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _titreCtrl,
              label: 'Titre du conte *',
              hint: 'Ex: Le Lièvre rusé et l\'Hyène gloutonne',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _texteCtrl,
              label: 'Histoire complète / Récit oral *',
              hint: 'Racontez l\'histoire du début à la fin...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 6,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _significationCtrl,
              label: 'Résumé court *',
              hint: 'En deux phrases, que raconte ce conte ?',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 2,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _moraleCtrl,
              label: 'Morale transmise aux enfants *',
              hint: 'Quelle leçon de vie nos aïeux transmettent-ils ici ?',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
          ],
        );

      case CulturalCategory.monument:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Description du Monument ou Site Sacré',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _titreCtrl,
              label: 'Nom du Monument / Site Historique *',
              hint: 'Ex: Mosquée de Djenné, Puits de Kalaban...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            if (isTablet)
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _villeCtrl,
                      label: 'Ville / Village *',
                      hint: 'Ex: Djenné, Bandiagara...',
                      isDark: isDark,
                      borderCol: borderCol,
                      cardBg: cardBg,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _epoqueCtrl,
                      label: 'Époque / Siècle',
                      hint: 'Ex: XIIIe siècle, 1905...',
                      isDark: isDark,
                      borderCol: borderCol,
                      cardBg: cardBg,
                      textColor: textColor,
                    ),
                  ),
                ],
              )
            else ...[
              _buildField(
                controller: _villeCtrl,
                label: 'Ville / Village *',
                hint: 'Ex: Djenné, Bandiagara...',
                isDark: isDark,
                borderCol: borderCol,
                cardBg: cardBg,
                textColor: textColor,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _epoqueCtrl,
                label: 'Époque / Siècle',
                hint: 'Ex: XIIIe siècle, 1905...',
                isDark: isDark,
                borderCol: borderCol,
                cardBg: cardBg,
                textColor: textColor,
              ),
            ],
            const SizedBox(height: 12),
            _buildField(
              controller: _texteCtrl,
              label: 'Récit historique & Importance sacrée *',
              hint: 'Pourquoi ce lieu est-il légendaire et précieux ?',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 4,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _significationCtrl,
              label: 'Secrets, mystères ou particularités architecturales *',
              hint: 'Qu\'est-ce qui rend ce monument unique ?',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 2,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
          ],
        );

      case CulturalCategory.personnage:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Fiche du Grand Personnage',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _titreCtrl,
              label: 'Nom de la figure historique *',
              hint: 'Ex: Kankou Moussa, Reine Amina, Firhoun...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            if (isTablet)
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _moraleCtrl,
                      label: 'Titre honorifique *',
                      hint: 'Ex: Le Roi Bâtisseur, Guerrière...',
                      isDark: isDark,
                      borderCol: borderCol,
                      cardBg: cardBg,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _epoqueCtrl,
                      label: 'Période / Siècle *',
                      hint: 'Ex: XIVe siècle (1312-1337)...',
                      isDark: isDark,
                      borderCol: borderCol,
                      cardBg: cardBg,
                      textColor: textColor,
                    ),
                  ),
                ],
              )
            else ...[
              _buildField(
                controller: _moraleCtrl,
                label: 'Titre honorifique *',
                hint: 'Ex: Le Roi Bâtisseur, Guerrière...',
                isDark: isDark,
                borderCol: borderCol,
                cardBg: cardBg,
                textColor: textColor,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _epoqueCtrl,
                label: 'Période / Siècle *',
                hint: 'Ex: XIVe siècle (1312-1337)...',
                isDark: isDark,
                borderCol: borderCol,
                cardBg: cardBg,
                textColor: textColor,
              ),
            ],
            const SizedBox(height: 12),
            _buildField(
              controller: _texteCtrl,
              label: 'Biographie & Faits d\'armes *',
              hint: 'Racontez ses victoires, réformes ou créations majeures...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 4,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _texteOriginalCtrl,
              label: 'Citation célèbre ou devise',
              hint: 'Ex: La parole d\'un noble est un serment sacré...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _significationCtrl,
              label: 'Héritage laissé au Mali moderne *',
              hint: 'Pourquoi devons-nous nous souvenir de lui/elle aujourd\'hui ?',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 2,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
          ],
        );

      case CulturalCategory.lieu:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Mémoire de la Ville ou du Terroir',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _titreCtrl,
              label: 'Nom de la Cité ou du Village *',
              hint: 'Ex: Kangaba, Hombori, Bafoulabé...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _epoqueCtrl,
              label: 'Récit de fondation par les anciens',
              hint: 'Ex: Fondée au XIe siècle par des chasseurs...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _texteCtrl,
              label: 'Histoire & Particularités culturelles *',
              hint: 'Racontez l\'histoire, les coutumes et les fêtes du village...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 4,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _significationCtrl,
              label: 'Ce qui rend ce terroir sacré *',
              hint: 'Forêts sacrées, pactes ancestraux, foire hebdomadaire...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 2,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
          ],
        );

      case CulturalCategory.patronyme:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Généalogie du Patronyme (Jamu)',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _titreCtrl,
              label: 'Nom de famille (Jamu) *',
              hint: 'Ex: Keïta, Coulibaly, Touré, Maïga...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            if (isTablet)
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _totemCtrl,
                      label: 'Totem ancestral (Tana)',
                      hint: 'Ex: Silure, Crocodile, Léopard...',
                      isDark: isDark,
                      borderCol: borderCol,
                      cardBg: cardBg,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _senankouyaCtrl,
                      label: 'Senankouya (Cousins à plaisanterie)',
                      hint: 'Ex: Traoré & Diarra, Kouyaté & Keïta...',
                      isDark: isDark,
                      borderCol: borderCol,
                      cardBg: cardBg,
                      textColor: textColor,
                    ),
                  ),
                ],
              )
            else ...[
              _buildField(
                controller: _totemCtrl,
                label: 'Totem ancestral (Tana)',
                hint: 'Ex: Silure, Crocodile, Léopard...',
                isDark: isDark,
                borderCol: borderCol,
                cardBg: cardBg,
                textColor: textColor,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _senankouyaCtrl,
                label: 'Senankouya (Cousins à plaisanterie)',
                hint: 'Ex: Traoré & Diarra, Kouyaté & Keïta...',
                isDark: isDark,
                borderCol: borderCol,
                cardBg: cardBg,
                textColor: textColor,
              ),
            ],
            const SizedBox(height: 12),
            _buildField(
              controller: _texteOriginalCtrl,
              label: 'Devise ou Louange clanique',
              hint: 'Ex: Manden Mori, N\'golo Kounou...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _significationCtrl,
              label: 'Signification & Origine du clan *',
              hint: 'Que signifie ce nom et de quel royaume provient-il ?',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 2,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _texteCtrl,
              label: 'Anecdote ou histoire de la lignée *',
              hint: 'Racontez une histoire transmise sur les porteurs de ce nom...',
              isDark: isDark,
              borderCol: borderCol,
              cardBg: cardBg,
              textColor: textColor,
              maxLines: 3,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Champ requis' : null,
            ),
          ],
        );
    }
  }

  Widget _buildRegionDropdown(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Région du Mali *',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedRegionId,
          isExpanded: true,
          dropdownColor: cardBg,
          decoration: _inputDecoration(
            isDark,
            borderCol,
            cardBg,
            Icons.place_rounded,
          ),
          items: MockMaliRegions.regions.map((reg) {
            return DropdownMenuItem(
              value: reg.id,
              child: Text(
                reg.nom,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedRegionId = val);
          },
        ),
      ],
    );
  }

  Widget _buildRoleDropdown(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Votre Rôle',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedAuteurRole,
          isExpanded: true,
          dropdownColor: cardBg,
          decoration: _inputDecoration(
            isDark,
            borderCol,
            cardBg,
            Icons.badge_rounded,
          ),
          items: _auteurRoles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(
                role,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedAuteurRole = val);
          },
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    required Color borderCol,
    required Color cardBg,
    required Color textColor,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: _inputDecoration(isDark, borderCol, cardBg, null, hint: hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    bool isDark,
    Color borderCol,
    Color cardBg,
    IconData? prefixIcon, {
    String? hint,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: cardBg,
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        fontSize: 13,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon,
              size: 20,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderCol, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: CultureTheme.accentOrange, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
    );
  }

  // ── 2ème Onglet : Historique des Contributions ──────────────────────────────
  Widget _buildHistoryView(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color titleColor,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final contributionsAsync = ref.watch(
      culturalContributionsProvider(const ContributionFilter()),
    );

    return contributionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CultureTheme.accentOrange),
      ),
      error: (e, _) => Center(
        child: Text(
          'Impossible de charger l\'historique.',
          style: GoogleFonts.inter(color: textColor),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_edu_rounded,
                    size: 64,
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune contribution soumise pour l\'instant',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Partagez un proverbe, un conte ou l\'histoire d\'un monument pour devenir Gardien du Savoir !',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final hPad = CultureResponsive.horizontalPadding(context);
        final isTablet = CultureResponsive.isTablet(context);

        Widget buildContributionCard(Map<String, dynamic> item) {
          final statut = (item['statut'] ?? 'EN_ATTENTE').toString().toUpperCase();
            final type = (item['typeContenu'] ?? item['type_contenu'] ?? 'proverbe')
                .toString();
            final titre = item['titre'] ?? item['texte'] ?? 'Contribution';
            final signification = item['signification'] ?? '';
            final auteur = item['auteurNom'] ?? item['auteur_nom'] ?? 'Anonyme';
            final motif = item['motifModeration'] ?? item['motif_moderation'];

            Color statutColor;
            String statutLabel;
            IconData statutIcon;

            if (statut == 'APPROUVE') {
              statutColor = const Color(0xFF10B981);
              statutLabel = 'Validé (+50 XP, +25 Pièces)';
              statutIcon = Icons.verified_rounded;
            } else if (statut == 'REJETE') {
              statutColor = const Color(0xFFEF4444);
              statutLabel = 'Rejeté';
              statutIcon = Icons.cancel_rounded;
            } else {
              statutColor = const Color(0xFFF59E0B);
              statutLabel = 'En attente de relecture';
              statutIcon = Icons.hourglass_top_rounded;
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statutColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statutColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statutIcon, size: 14, color: statutColor),
                            const SizedBox(width: 6),
                            Text(
                              statutLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statutColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        type.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: CultureTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    titre,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (signification.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      signification,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                  if (motif != null && motif.toString().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (statut == 'APPROUVE'
                                ? const Color(0xFF10B981)
                                : Colors.redAccent)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (statut == 'APPROUVE'
                                  ? const Color(0xFF10B981)
                                  : Colors.redAccent)
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        statut == 'APPROUVE'
                            ? 'Message du Super Admin : $motif'
                            : 'Motif du refus (Super Admin) : $motif',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: statut == 'APPROUVE'
                              ? const Color(0xFF10B981)
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        'Par $auteur',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
        }

        Future<void> refreshHistory() async {
          ref.invalidate(culturalContributionsProvider);
          await ref.read(
            culturalContributionsProvider(const ContributionFilter()).future,
          );
          await ref
              .read(culturePassportProvider.notifier)
              .syncWithBackend();
          await ref
              .read(gamificationProvider.notifier)
              .fetchStatsFromBackend();
        }

        if (isTablet) {
          return RefreshIndicator(
            color: CultureTheme.accentOrange,
            onRefresh: refreshHistory,
            child: CultureResponsive.constrainedCentered(
              maxWidth: CultureResponsive.kMaxContentWidth,
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 2.1,
                ),
                itemBuilder: (context, idx) =>
                    buildContributionCard(items[idx]),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: CultureTheme.accentOrange,
          onRefresh: refreshHistory,
          child: CultureResponsive.constrainedCentered(
            maxWidth: CultureResponsive.kMaxFormWidth,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, idx) =>
                  buildContributionCard(items[idx]),
            ),
          ),
        );
      },
    );
  }
}
