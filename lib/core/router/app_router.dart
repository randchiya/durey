import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:durey/screens/splash_screen.dart';
import 'package:durey/screens/home_screen.dart';

/// Application router configuration using go_router
class AppRouter {
  static const String splash = '/';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
