library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/common/providers/theme_provider.dart';
import 'presentation/router/app_router.dart';

class AlterniaApp extends ConsumerWidget {
  const AlterniaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'AlternIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final isLargeTablet = screenWidth >= 900;
        final isTablet = screenWidth >= 600;

        // Échelle typographique adaptative :
        // Sur tablette, agrandit et zoome vigoureusement (+20% à +25%)
        // l'ensemble des textes et interfaces pour une lisibilité impeccable.
        final double scaleFactor = isLargeTablet ? 1.25 : (isTablet ? 1.20 : 1.0);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(scaleFactor),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Alias de rétrocompatibilité
typedef DetAiApp = AlterniaApp;
