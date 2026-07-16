import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/user_repository.dart';
import 'package:lystra/domain/models/app_user.dart';

/// Singleton that holds the current user's extended Firestore data.
/// Auto-loads on auth state changes so no external call is required.
class UserState extends ChangeNotifier {
  UserState({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository {
    _authSub = authRepository.authStateChanges.listen(_onAuthChanged);
  }

  final UserRepository _userRepository;
  StreamSubscription<AppUser?>? _authSub;

  AppUser? _user;
  AppUser? get user => _user;
  bool get isPremium => _user?.isPremium ?? false;
  String? get householdId => _user?.householdId;
  bool get isLoaded => _user != null;

  Future<void> _onAuthChanged(AppUser? authUser) async {
    if (authUser == null) {
      _user = null;
      notifyListeners();
      return;
    }
    // Firebase Auth is authoritative for identity (email, displayName).
    // Firestore holds app-specific fields (isPremium, householdId).
    final fromFirestore = await _userRepository.getUser(authUser.uid);
    _user = authUser.copyWith(
      isPremium: fromFirestore?.isPremium ?? false,
      householdId: fromFirestore?.householdId,
    );
    notifyListeners();
  }

  /// Called by app_router after sign-in to ensure user data is ready
  /// before navigation. No-op if already loaded for the same uid.
  Future<void> loadForUser(AppUser authUser) async {
    if (_user?.uid == authUser.uid) return;
    await _onAuthChanged(authUser);
  }

  /// Called by app_router on sign-out.
  void clear() {
    _user = null;
    notifyListeners();
  }

  void updatePremium(bool value) {
    if (_user == null) return;
    _user = _user!.copyWith(isPremium: value);
    notifyListeners();
  }

  void updateHouseholdId(String? id) {
    if (_user == null) return;
    _user = _user!.copyWith(householdId: id);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
