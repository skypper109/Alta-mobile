library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:permission_handler/permission_handler.dart';

import 'app.dart';
import 'core/constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Orientation portrait ────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status bar & Navigation bar ─────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Demande proactive des permissions Caméra et Localisation ─────────────
  _requestStartupPermissions();

  runApp(
    const ProviderScope(
      child: DetAiApp(),
    ),
  );
}

/// Demande les autorisations essentielles dès le premier affichage de l'application
void _requestStartupPermissions() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await [
        Permission.camera,
        Permission.locationWhenInUse,
      ].request();
    } catch (e) {
      debugPrint('Note: permissions initiales : $e');
    }
  });
}
