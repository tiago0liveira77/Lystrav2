import 'package:flutter/foundation.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/category_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/services/seed_data_service.dart';
import 'package:lystra/domain/models/app_user.dart';

enum SeedState { idle, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required AuthRepository authRepository,
    required SeedDataService seedDataService,
    required CategoryRepository categoryRepository,
    required ItemRepository itemRepository,
  })  : _authRepository = authRepository,
        _seedDataService = seedDataService,
        _categoryRepository = categoryRepository,
        _itemRepository = itemRepository;

  final AuthRepository _authRepository;
  final SeedDataService _seedDataService;
  final CategoryRepository _categoryRepository;
  final ItemRepository _itemRepository;

  AppUser? get currentUser => _authRepository.currentUser;

  SeedState _seedState = SeedState.idle;
  SeedState get seedState => _seedState;

  String? _seedMessage;
  String? get seedMessage => _seedMessage;

  Future<void> signOut() => _authRepository.signOut();

  Future<void> loadBaseItems() async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) return;

    _seedState = SeedState.loading;
    _seedMessage = null;
    notifyListeners();

    try {
      final count = await _seedDataService.loadMissingBaseItems(uid);
      // Invalidate caches so Items/Categories tab reloads fresh data
      _categoryRepository.invalidateCache();
      _itemRepository.invalidateCache();

      _seedState = SeedState.success;
      _seedMessage = count > 0
          ? '$count ${count == 1 ? 'item adicionado' : 'items adicionados'} ao teu catálogo.'
          : 'O teu catálogo já está completo.';
    } catch (_) {
      _seedState = SeedState.error;
      _seedMessage = 'Erro ao carregar items. Tenta novamente.';
    }
    notifyListeners();
  }

  void clearSeedMessage() {
    _seedState = SeedState.idle;
    _seedMessage = null;
    notifyListeners();
  }
}
