import 'package:firebase_auth/firebase_auth.dart';
import 'package:lystra/data/services/firebase_auth_service.dart';
import 'package:lystra/domain/models/app_user.dart';

class AuthRepository {
  AuthRepository({required FirebaseAuthService authService})
      : _authService = authService;

  final FirebaseAuthService _authService;

  Stream<AppUser?> get authStateChanges => _authService.authStateChanges.map(
        (user) => user == null ? null : _mapUser(user),
      );

  AppUser? get currentUser {
    final user = _authService.currentUser;
    return user == null ? null : _mapUser(user);
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    final credential =
        await _authService.signInWithEmail(email.trim(), password);
    return _mapUser(credential.user!);
  }

  Future<AppUser> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final credential =
        await _authService.registerWithEmail(email.trim(), password);
    await _authService.updateDisplayName(displayName.trim());
    return _mapUser(credential.user!).copyWith(displayName: displayName.trim());
  }

  Future<void> signOut() => _authService.signOut();

  AppUser _mapUser(User user) => AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
}
