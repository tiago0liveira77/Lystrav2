import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lystra/core/router/shell_scaffold.dart';
import 'package:lystra/core/di/service_locator.dart';
import 'package:lystra/ui/features/auth/views/login_view.dart';
import 'package:lystra/ui/features/auth/views/register_view.dart';
import 'package:lystra/ui/features/auth/view_models/auth_view_model.dart';
import 'package:lystra/ui/features/lists/views/lists_view.dart';
import 'package:lystra/ui/features/lists/view_models/lists_view_model.dart';
import 'package:lystra/ui/features/items/views/items_view.dart';
import 'package:lystra/ui/features/items/view_models/items_view_model.dart';
import 'package:lystra/ui/features/history/views/history_view.dart';
import 'package:lystra/ui/features/profile/views/profile_view.dart';
import 'package:lystra/ui/features/shopping/views/shopping_view.dart';

// Bridges Firebase auth state stream into a ChangeNotifier so GoRouter
// re-evaluates its redirect function on every auth state change.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authRefresh = _AuthRefreshNotifier();

final appRouter = GoRouter(
  initialLocation: '/lists',
  redirect: _authGuard,
  refreshListenable: _authRefresh,
  routes: [
    GoRoute(
      path: '/auth/login',
      builder: (_, __) => LoginView(viewModel: sl<AuthViewModel>()),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (_, __) => RegisterView(viewModel: sl<AuthViewModel>()),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellScaffold(
        location: state.matchedLocation,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/lists',
          builder: (_, __) => ListsView(viewModel: sl<ListsViewModel>()),
        ),
        GoRoute(
          path: '/items',
          builder: (_, __) => ItemsView(viewModel: sl<ItemsViewModel>()),
        ),
        GoRoute(
          path: '/history',
          builder: (_, __) => const HistoryView(),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const ProfileView(),
        ),
      ],
    ),
    // Shopping mode — full screen, outside shell (no NavigationBar)
    GoRoute(
      path: '/lists/:listId/shop',
      builder: (_, state) => ShoppingView(
        listId: state.pathParameters['listId']!,
      ),
    ),
  ],
);

String? _authGuard(BuildContext context, GoRouterState state) {
  final isLoggedIn = FirebaseAuth.instance.currentUser != null;
  final isAuthRoute = state.matchedLocation.startsWith('/auth');

  if (!isLoggedIn && !isAuthRoute) return '/auth/login';
  if (isLoggedIn && isAuthRoute) return '/lists';
  return null;
}
