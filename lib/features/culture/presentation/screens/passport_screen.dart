import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../views/culture_passport_view.dart';

/// Écran Maître : Passeport Culturel & Mémoire de l'Odyssée
/// Utilisé lors de la navigation directe (/culture/passport) depuis les quiz, défis ou profil.
/// Intègre la vue unifiée avec bouton retour, carte d'identité initiatique XP et trésors gravés.
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI AlterniA.
class PassportScreen extends ConsumerWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: SafeArea(
        bottom: false,
        child: CulturePassportView(showBackButton: true),
      ),
    );
  }
}
