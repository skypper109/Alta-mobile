import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/datasources/culture_repository.dart';
import '../../core/theme/culture_theme.dart';

/// Modal de gestion des Packs Culturels Téléchargeables Hors Ligne
class CultureOfflinePacksModal extends ConsumerStatefulWidget {
  const CultureOfflinePacksModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CultureOfflinePacksModal(),
    );
  }

  @override
  ConsumerState<CultureOfflinePacksModal> createState() => _CultureOfflinePacksModalState();
}

class _CultureOfflinePacksModalState extends ConsumerState<CultureOfflinePacksModal> {
  List<String> _installedPacks = ['pack_bamako_capitale'];
  String? _downloadingPackId;
  double _downloadProgress = 0.0;

  final List<Map<String, dynamic>> _availablePacks = [
    {
      'id': 'pack_bamako_capitale',
      'title': 'Pack Bamako — Capitale & Monuments',
      'description': '12 monuments complets (Indépendance, Tour de l\'Afrique, Paix, Héros, Musée National...), narrations audio et coordonnées GPS.',
      'sizeMo': 14.8,
      'elementsCount': 12,
      'isPriority': true,
    },
    {
      'id': 'pack_mali_patrimoine_mondial',
      'title': 'Pack Trésors UNESCO du Mali',
      'description': 'Grande Mosquée de Djenné, Tombeau des Askia de Gao, Mosquées de Tombouctou et Sanctuaire Kamablon de Kangaba.',
      'sizeMo': 22.4,
      'elementsCount': 8,
      'isPriority': false,
    },
    {
      'id': 'pack_tombouctou_savoir',
      'title': 'Pack Tombouctou — Cité des Saints',
      'description': 'Bibliothèques de manuscrits, astronomie médiévale africaine et sanctuaires de Sankoré et Djingareyber.',
      'sizeMo': 18.2,
      'elementsCount': 6,
      'isPriority': false,
    },
    {
      'id': 'pack_sud_resistances',
      'title': 'Pack Sud & Résistances',
      'description': 'La forteresse du Tata de Sikasso, le Fort de Médine à Kayes et les Monts Mandingues.',
      'sizeMo': 16.5,
      'elementsCount': 8,
      'isPriority': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadInstalled();
  }

  Future<void> _loadInstalled() async {
    final repo = ref.read(cultureRepositoryProvider);
    final installed = await repo.getInstalledPackIds();
    if (mounted) {
      setState(() => _installedPacks = installed);
    }
  }

  Future<void> _downloadPack(String packId) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _downloadingPackId = packId;
      _downloadProgress = 0.1;
    });

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _downloadProgress = i / 10.0);
    }

    final repo = ref.read(cultureRepositoryProvider);
    await repo.installPack(packId);

    if (mounted) {
      setState(() {
        _installedPacks.add(packId);
        _downloadingPackId = null;
        _downloadProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: CultureTheme.accentOrange,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Pack hors ligne installé avec succès !',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 4.5,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cloud_download_rounded,
                    color: CultureTheme.accentOrange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Packs Hors Ligne CultureLens',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      Text(
                        'Explorez le patrimoine même sans connexion Internet',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: subtitleColor),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _availablePacks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final pack = _availablePacks[index];
                final id = pack['id'] as String;
                final isInstalled = _installedPacks.contains(id);
                final isDownloading = _downloadingPackId == id;
                final isPriority = pack['isPriority'] == true;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isPriority
                          ? CultureTheme.accentOrange.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.2),
                      width: isPriority ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isPriority)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: CultureTheme.accentOrange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'PRIORITAIRE BAMAKO',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              pack['title'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${pack['sizeMo']} Mo',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: subtitleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pack['description'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: subtitleColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Barre de progression si téléchargement en cours
                      if (isDownloading) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _downloadProgress,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation(CultureTheme.accentOrange),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Téléchargement du pack en cours : ${(_downloadProgress * 100).toInt()}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isInstalled ? Icons.check_circle_rounded : Icons.offline_pin_outlined,
                                  size: 16,
                                  color: isInstalled ? Colors.green : subtitleColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isInstalled ? 'Pack installé hors ligne' : '${pack['elementsCount']} sites inclus',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isInstalled ? Colors.green : subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: isInstalled ? null : () => _downloadPack(id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInstalled ? Colors.grey.shade700 : CultureTheme.accentOrange,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: Text(
                                isInstalled ? 'Installé' : 'Télécharger',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isInstalled ? Colors.white70 : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
