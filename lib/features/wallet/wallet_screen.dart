import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import 'wallet_service.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showWithdrawalModalSheet(BuildContext context, WalletState wallet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WithdrawalModalSheet(wallet: wallet),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final cardBg = isDark ? AppColors.surface : Colors.white;
    final borderCol = isDark ? AppColors.border : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Portefeuille Éducatif',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textPri,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(walletProvider.notifier).refreshAll();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletProvider.notifier).refreshAll(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // ── 1. CARTE HERO DU SOLDE ET CONVERSION FCFA ─────────────────
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF314999), Color(0xFF1E2D64)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF314999).withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.monetization_on_rounded,
                              size: 20,
                              color: Color(0xFFF1851F),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SOLDE DISPONIBLE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '1 pièce = 2 FCFA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        wallet.soldePiecesLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pièces',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF1851F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '≈ ${wallet.valeurFcfaLabel} convertibles en Mobile Money',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF40BBCC),
                    ),
                  ),
                  if (wallet.piecesReservees > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_clock_rounded,
                              size: 14, color: Colors.amberAccent),
                          const SizedBox(width: 6),
                          Text(
                            '${wallet.piecesReservees} pièces réservées pour retrait en cours',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _showWithdrawalModalSheet(context, wallet);
                      },
                      icon: const Icon(Icons.send_to_mobile_rounded, size: 18),
                      label: Text(
                        'Demander un Retrait Mobile Money',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1851F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 2. ONGLETS TRANSACTIONS & RETRAITS ─────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderCol),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: isDark ? Colors.white : AppColors.primary,
                unselectedLabelColor: textSec,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
                tabs: const [
                  Tab(text: 'Historique des Pièces'),
                  Tab(text: 'Mes Retraits'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // VUE 1 : HISTORIQUE DES TRANSACTIONS
                  wallet.transactions.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune transaction enregistrée.',
                            style: GoogleFonts.plusJakartaSans(color: textSec),
                          ),
                        )
                      : ListView.separated(
                          itemCount: wallet.transactions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final tx = wallet.transactions[idx];
                            final isCredit = tx.montant > 0;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderCol),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isCredit
                                          ? AppColors.success
                                              .withValues(alpha: 0.15)
                                          : AppColors.error
                                              .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isCredit
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded,
                                      size: 16,
                                      color: isCredit
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.description,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: textPri,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Origine : ${tx.origine}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            color: textSec,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        tx.montantLabel,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: isCredit
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ),
                                      Text(
                                        'Solde : ${tx.soldeApres}',
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
                          },
                        ),

                  // VUE 2 : DEMANDES DE RETRAIT
                  wallet.demandesRetrait.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune demande de retrait effectuée.',
                            style: GoogleFonts.plusJakartaSans(color: textSec),
                          ),
                        )
                      : ListView.separated(
                          itemCount: wallet.demandesRetrait.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final ret = wallet.demandesRetrait[idx];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderCol),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ret.montantFcfaLabel,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: textPri,
                                        ),
                                      ),
                                      _StatusBadge(statut: ret.statut),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${ret.operateurLabel} • ${ret.numeroTelephone}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: textSec,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Titulaire : ${ret.nomTitulaire} • Réf : ${ret.ref}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      color: textSec,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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

class _StatusBadge extends StatelessWidget {
  final String statut;
  const _StatusBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = statut;

    switch (statut.toUpperCase()) {
      case 'PAYEE':
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        label = 'PAYÉ';
        break;
      case 'EN_ATTENTE':
        bg = Colors.amber.withValues(alpha: 0.15);
        fg = Colors.amber.shade800;
        label = 'EN ATTENTE';
        break;
      case 'EN_VERIFICATION':
        bg = AppColors.secondary.withValues(alpha: 0.15);
        fg = AppColors.secondary;
        label = 'VÉRIFICATION';
        break;
      case 'REJETEE':
      case 'ECHEC':
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        label = 'REJETÉ';
        break;
      default:
        bg = Colors.grey.withValues(alpha: 0.15);
        fg = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _WithdrawalModalSheet extends ConsumerStatefulWidget {
  final WalletState wallet;
  const _WithdrawalModalSheet({required this.wallet});

  @override
  ConsumerState<_WithdrawalModalSheet> createState() =>
      _WithdrawalModalSheetState();
}

class _WithdrawalModalSheetState extends ConsumerState<_WithdrawalModalSheet> {
  String _selectedOperateur = 'ORANGE_MONEY';
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _piecesController = TextEditingController(text: '100');
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _piecesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
    });

    final pieces = int.tryParse(_piecesController.text.trim()) ?? 0;
    if (pieces < 100) {
      setState(() => _errorMessage = 'Le seuil minimal est de 100 pièces.');
      return;
    }
    if (pieces > widget.wallet.soldePieces) {
      setState(() => _errorMessage = 'Solde insuffisant en pièces.');
      return;
    }
    if (_phoneController.text.trim().length < 8) {
      setState(() => _errorMessage =
          'Veuillez renseigner un numéro de téléphone valide.');
      return;
    }
    if (_nameController.text.trim().length < 3) {
      setState(() => _errorMessage =
          'Veuillez renseigner le nom complet du titulaire.');
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await ref.read(walletProvider.notifier).demandWithdrawal(
          pieces: pieces,
          operateur: _selectedOperateur,
          numeroTelephone: _phoneController.text.trim(),
          nomTitulaire: _nameController.text.trim(),
        );

    setState(() => _isSubmitting = false);
    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Demande de retrait enregistrée avec succès. Pièces réservées !'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? AppColors.surface : Colors.white;

    final pieces = int.tryParse(_piecesController.text.trim()) ?? 0;
    final montantFcfa = pieces * 2;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Retrait Mobile Money (Mali)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vos pièces sont converties en francs CFA et envoyées sur votre numéro.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),

          // Choix d'opérateur
          Row(
            children: [
              _OperateurChoiceChip(
                label: 'Orange Money',
                code: 'ORANGE_MONEY',
                isSelected: _selectedOperateur == 'ORANGE_MONEY',
                onSelect: (c) => setState(() => _selectedOperateur = c),
              ),
              const SizedBox(width: 8),
              _OperateurChoiceChip(
                label: 'Moov Money',
                code: 'MOOV_MONEY',
                isSelected: _selectedOperateur == 'MOOV_MONEY',
                onSelect: (c) => setState(() => _selectedOperateur = c),
              ),
              const SizedBox(width: 8),
              _OperateurChoiceChip(
                label: 'Wave',
                code: 'WAVE',
                isSelected: _selectedOperateur == 'WAVE',
                onSelect: (c) => setState(() => _selectedOperateur = c),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _piecesController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Nombre de pièces à convertir (min 100)',
              suffixText: '≈ $montantFcfa FCFA',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro Mobile Money (ex: 76 12 34 56)',
              prefixText: '+223 ',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom et prénom du titulaire du compte',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.error, fontSize: 11),
            ),
          ],

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      'Confirmer le Retrait de $montantFcfa FCFA',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperateurChoiceChip extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final ValueChanged<String> onSelect;

  const _OperateurChoiceChip({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onSelect(code);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
