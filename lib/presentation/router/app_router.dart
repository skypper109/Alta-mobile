library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/culture/exploration/data/datasources/mock_mali_regions.dart';
import '../../features/culture/exploration/data/models/mali_region.dart';
import '../../features/culture/exploration/presentation/screens/explore_mali_screen.dart';
import '../../features/culture/exploration/presentation/screens/region_detail_screen.dart';
import '../../features/culture/presentation/screens/challenges_home_screen.dart';
import '../../features/culture/presentation/screens/contes_screen.dart';
import '../../features/culture/core/models/cultural_guide_models.dart';
import '../../features/culture/presentation/screens/cultural_guide_screen.dart';
import '../../features/culture/presentation/screens/culture_monuments_screen.dart';
import '../../features/culture/presentation/screens/culture_personnages_screen.dart';
import '../../features/culture/presentation/screens/culture_villes_screen.dart';
import '../../features/culture/presentation/screens/historical_figure_detail_screen.dart';
import '../../features/culture/presentation/screens/interactive_story_player_screen.dart';
import '../../features/culture/presentation/screens/monument_detail_screen.dart';
import '../../features/culture/presentation/screens/place_detail_screen.dart';
import '../../features/culture/presentation/screens/quiz_culture_screen.dart';
import '../../features/culture/presentation/screens/riddle_screen.dart';
import '../../features/culture/presentation/screens/passport_screen.dart';
import '../../features/culture/presentation/screens/story_detail_screen.dart';
import '../../features/culture/presentation/screens/story_reader_screen.dart';
import '../../features/discussions/holographic_salon_page.dart';
import '../../features/profile/user_prefs_notifier.dart';
import '../../shared/widgets.dart';
import '../culture/culture_screen.dart';
import '../discussions/discussions_screen.dart';
import '../documents/documents_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../profile/profile_screen.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
  final userPrefs = ref.watch(userPrefsProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      if (userPrefs.isLoading) return null;
      final isOnboarding = state.matchedLocation == '/onboarding';
      if (!userPrefs.hasCompletedOnboarding && !isOnboarding) {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DetShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // ── Branch 1 : Home ──────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),

          // ── Branch 2 : Discussions ───────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discussions',
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: const DiscussionsScreen(),
                ),
              ),
            ],
          ),

          // ── Branch 3 : Documents ─────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/documents',
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: const DocumentsScreen(),
                ),
              ),
            ],
          ),

          // ── Branch 4 : Culture ───────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/culture',
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: const CultureScreen(),
                ),
              ),
            ],
          ),

          // ── Branch 5 : Profile ───────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => _fadePage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Modals & Standalone Routes ───────────────────────────────────────
      GoRoute(
        path: '/culture/map',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExploreMaliScreen(),
      ),

      // ── Culture Étape 2 : Écrans Découverte ──────────────────────────────
      GoRoute(
        path: '/culture/personnages',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CulturePersonnagesScreen(),
      ),
      GoRoute(
        path: '/culture/villes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CultureVillesScreen(),
      ),
      GoRoute(
        path: '/culture/monuments',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CultureMonumentsScreen(),
      ),

      // ── Culture Étape 3 : Fiches Immersives de Consultation ──────────────
      GoRoute(
        path: '/culture/personnage/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return HistoricalFigureDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/culture/monument/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MonumentDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/culture/ville/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PlaceDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/culture/region/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final regionId = state.pathParameters['id'] ?? '';
          final extraRegion = state.extra as MaliRegion?;
          final region = extraRegion ??
              MockMaliRegions.regions.firstWhere(
                (r) => r.id == regionId,
                orElse: () => MockMaliRegions.regions.first,
              );
          return RegionDetailScreen(region: region);
        },
      ),

      // ── Culture Étape 4 : Contes & Récits Interactifs ────────────────────
      GoRoute(
        path: '/culture/contes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ContesScreen(),
      ),
      GoRoute(
        path: '/culture/conte/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StoryDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/culture/conte/:id/play',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return InteractiveStoryPlayerScreen(id: id);
        },
      ),
      GoRoute(
        path: '/culture/conte/:id/read',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StoryReaderScreen(id: id);
        },
      ),

      // ── Culture Étape 5 : Défis & Jeux Culturels ─────────────────────────
      GoRoute(
        path: '/culture/defis',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChallengesHomeScreen(),
      ),
      GoRoute(
        path: '/culture/defis/devinettes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return RiddleScreen(riddleId: id);
        },
      ),
      GoRoute(
        path: '/culture/defis/quiz',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QuizCultureScreen(),
      ),
      GoRoute(
        path: '/culture/guide',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final contextData = state.extra is CulturalGuideContext
              ? state.extra as CulturalGuideContext
              : CulturalGuideContext.general;
          return CulturalGuideScreen(contextData: contextData);
        },
      ),
      GoRoute(
        path: '/culture/passport',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PassportScreen(),
      ),
      GoRoute(
        path: '/holo-salon',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HolographicSalonPage(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/exercises',
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (_, __) => '/documents',
      ),
    ],
  );
}

CustomTransitionPage<void> _fadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}
