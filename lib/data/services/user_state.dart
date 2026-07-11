import 'package:flutter/foundation.dart';
import 'package:lystra/data/repositories/user_repository.dart';
import 'package:lystra/domain/models/app_user.dart';

/// Singleton that holds the current user's extended Firestore data
/// (isPremium, householdId). Persists across navigation and tab changes.
class UserState extends ChangeNotifier {
  UserState({required UserRepository userRepository})
      : _userRepository = userRepository;

  final UserRepository _userRepository;

  AppUser? _user;
  AppUser? get user => _user;
  bool get isPremium => _user?.isPremium ?? false;
  String? get householdId => _user?.householdId;
  bool get isLoaded => _user != null;

  /// Call once after successful sign-in/register.
  Future<void> loadForUser(AppUser authUser) async {
    final fromFirestore = await _userRepository.getUser(authUser.uid);
    _user = fromFirestore ?? authUser;
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

  void clear() {
    _user = null;
    notifyListeners();
  }
}
