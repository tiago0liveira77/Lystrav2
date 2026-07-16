import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/user_repository.dart';
import 'package:lystra/data/services/seed_data_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required AuthRepository authRepository,
    required SeedDataService seedDataService,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _seedDataService = seedDataService,
        _userRepository = userRepository;

  final AuthRepository _authRepository;
  final SeedDataService _seedDataService;
  final UserRepository _userRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authRepository.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e.code);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(
      String email, String password, String displayName) async {
    _setLoading(true);
    try {
      final user =
          await _authRepository.registerWithEmail(email, password, displayName);
      // Firestore setup — non-fatal: auth succeeded, user can still sign in.
      // On next sign-in, UserState will retry loading the user document.
      try {
        await _userRepository.createOrUpdate(user);
        await _seedDataService.seedIfFirstTime(user.uid);
      } catch (_) {
        // Setup failed but Firebase Auth account exists — don't block the user.
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e.code);
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Ocorreu um erro. Tenta novamente.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() => _authRepository.signOut();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  String _mapError(String code) => switch (code) {
        'user-not-found' => 'Email não encontrado.',
        'wrong-password' || 'invalid-credential' => 'Password incorreta.',
        'email-already-in-use' => 'Este email já está em uso.',
        'weak-password' => 'A password é demasiado fraca.',
        'invalid-email' => 'Email inválido.',
        'too-many-requests' => 'Demasiadas tentativas. Tenta mais tarde.',
        _ => 'Ocorreu um erro. Tenta novamente.',
      };
}
