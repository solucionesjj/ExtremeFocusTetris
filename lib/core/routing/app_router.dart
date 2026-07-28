import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/presentation/about_screen.dart';
import '../../features/game/presentation/game_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/statistics/presentation/statistics_screen.dart';
import '../constants/app_durations.dart';
import 'routes.dart';

/// Navigation graph — spec.md section 10.1. Pause and Game Over are
/// overlays drawn on top of the Game screen (spec.md 10.2), not separate
/// routes.
///
/// A factory rather than a top-level singleton: [ExtremeFocusTetrisApp]
/// creates exactly one instance per app run (held in `State.initState`),
/// which is what keeps navigation stable across rebuilds in production
/// while still giving every widget test its own isolated router instead
/// of leaking `GoRouter`'s current location across tests in the same file.
GoRouter createAppRouter() => GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      pageBuilder: (context, state) => _fadePage(const SplashScreen(), state),
    ),
    GoRoute(
      path: Routes.home,
      pageBuilder: (context, state) => _fadePage(const HomeScreen(), state),
    ),
    GoRoute(
      path: Routes.game,
      pageBuilder: (context, state) => _fadePage(
        GameScreen(focusMode: (state.extra as bool?) ?? false),
        state,
      ),
    ),
    GoRoute(
      path: Routes.settings,
      pageBuilder: (context, state) => _menuPage(const SettingsScreen(), state),
    ),
    GoRoute(
      path: Routes.statistics,
      pageBuilder: (context, state) => _menuPage(const StatisticsScreen(), state),
    ),
    GoRoute(
      path: Routes.about,
      pageBuilder: (context, state) => _menuPage(const AboutScreen(), state),
    ),
  ],
);

/// Entrada de pantalla (push): fade — spec.md section 7.
CustomTransitionPage<void> _fadePage(Widget child, GoRouterState state) => CustomTransitionPage(
  key: state.pageKey,
  child: child,
  transitionDuration: AppDurations.screenEnter,
  reverseTransitionDuration: AppDurations.screenExit,
  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
    child: child,
  ),
);

/// Transiciones de menú (Settings/Statistics/About): fade + slide vertical
/// leve — spec.md section 7.
CustomTransitionPage<void> _menuPage(Widget child, GoRouterState state) => CustomTransitionPage(
  key: state.pageKey,
  child: child,
  transitionDuration: AppDurations.menuTransition,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);
