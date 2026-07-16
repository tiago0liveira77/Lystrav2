import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/category_repository.dart';
import 'package:lystra/data/repositories/household_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/repositories/purchase_record_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/data/repositories/user_repository.dart';
import 'package:lystra/data/services/seed_data_service.dart';
import 'package:lystra/data/services/user_state.dart';
import 'package:lystra/domain/models/app_user.dart';
import 'package:lystra/domain/models/household.dart';

enum SeedState { idle, loading, success, error }

enum HouseholdState { idle, loading, error }

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required UserState userState,
    required HouseholdRepository householdRepository,
    required SeedDataService seedDataService,
    required CategoryRepository categoryRepository,
    required ItemRepository itemRepository,
    required ShoppingListRepository listRepository,
    required ListEntryRepository entryRepository,
    required PurchaseRecordRepository recordRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _userState = userState,
        _householdRepository = householdRepository,
        _seedDataService = seedDataService,
        _categoryRepository = categoryRepository,
        _itemRepository = itemRepository,
        _listRepository = listRepository,
        _entryRepository = entryRepository,
        _recordRepository = recordRepository {
    // Rebuild whenever UserState loads/changes (async from Firestore)
    _userState.addListener(_onUserStateChanged);
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final UserState _userState;
  final HouseholdRepository _householdRepository;
  final SeedDataService _seedDataService;
  final CategoryRepository _categoryRepository;
  final ItemRepository _itemRepository;
  final ShoppingListRepository _listRepository;
  final ListEntryRepository _entryRepository;
  final PurchaseRecordRepository _recordRepository;

  AppUser? get currentUser => _userState.user ?? _authRepository.currentUser;
  bool get isPremium => _userState.isPremium;
  String? get householdId => _userState.householdId;

  Household? _household;
  Household? get household => _household;

  StreamSubscription<Household>? _householdSub;

  SeedState _seedState = SeedState.idle;
  SeedState get seedState => _seedState;
  String? _seedMessage;
  String? get seedMessage => _seedMessage;

  HouseholdState _householdState = HouseholdState.idle;
  HouseholdState get householdState => _householdState;
  String? _householdError;
  String? get householdError => _householdError;

  // --- Lifecycle ---

  void _onUserStateChanged() {
    // Subscribe to household stream when householdId appears (async load from Firestore)
    if (_userState.householdId != null && _household == null &&
        _householdSub == null) {
      _subscribeToHousehold(_userState.householdId!);
    }
    // If householdId was cleared (leave/dissolve)
    if (_userState.householdId == null && _household != null) {
      _householdSub?.cancel();
      _householdSub = null;
      _household = null;
    }
    notifyListeners();
  }

  Future<void> loadUserData() async {
    if (_userState.householdId != null && _householdSub == null) {
      _subscribeToHousehold(_userState.householdId!);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _userState.removeListener(_onUserStateChanged);
    _householdSub?.cancel();
    super.dispose();
  }

  // --- Auth ---

  Future<void> signOut() async {
    _householdSub?.cancel();
    // Clear all in-memory caches before signing out so a subsequent user on
    // the same device never sees a previous user's data.
    _itemRepository.invalidateCache();
    _categoryRepository.invalidateCache();
    _listRepository.invalidateCache();
    _entryRepository.invalidateAll();
    _recordRepository.invalidateCache();
    await _authRepository.signOut();
  }

  // --- Premium (toggle para testes) ---

  Future<void> togglePremium(bool value) async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) return;
    await _userRepository.setPremium(uid, value);
    _userState.updatePremium(value);
    notifyListeners();
  }

  // --- Household ---

  void _subscribeToHousehold(String householdId) {
    _householdSub?.cancel();
    _householdSub =
        _householdRepository.watchHousehold(householdId).listen((h) {
      _household = h;
      notifyListeners();
    });
  }

  Future<void> createHousehold(String name) async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null || name.trim().isEmpty) return;
    _setHouseholdState(HouseholdState.loading);
    try {
      final household = await _householdRepository.createHousehold(uid, name);
      await _userRepository.setHouseholdId(uid, household.id);
      _userState.updateHouseholdId(household.id);
      _household = household;
      _subscribeToHousehold(household.id);
      _setHouseholdState(HouseholdState.idle);
    } catch (_) {
      _householdError = 'Erro ao criar household.';
      _setHouseholdState(HouseholdState.error);
    }
  }

  Future<void> joinHousehold(String inviteCode) async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null || inviteCode.trim().isEmpty) return;
    _setHouseholdState(HouseholdState.loading);
    try {
      final found =
          await _householdRepository.findByInviteCode(inviteCode.trim());
      if (found == null) {
        _householdError = 'Código inválido. Tenta novamente.';
        _setHouseholdState(HouseholdState.error);
        return;
      }
      final joined = await _householdRepository.joinHousehold(uid, found);
      await _userRepository.setHouseholdId(uid, joined.id);
      _userState.updateHouseholdId(joined.id);
      _household = joined;
      _subscribeToHousehold(joined.id);
      _setHouseholdState(HouseholdState.idle);
    } catch (_) {
      _householdError = 'Erro ao entrar no household.';
      _setHouseholdState(HouseholdState.error);
    }
  }

  Future<void> leaveHousehold() async {
    final uid = _authRepository.currentUser?.uid;
    final h = _household;
    if (uid == null || h == null) return;
    _setHouseholdState(HouseholdState.loading);
    try {
      await _householdRepository.leaveHousehold(uid, h);
      await _userRepository.setHouseholdId(uid, null);
      _userState.updateHouseholdId(null);
      _householdSub?.cancel();
      _household = null;
      _setHouseholdState(HouseholdState.idle);
    } catch (_) {
      _householdError = 'Erro ao sair do household.';
      _setHouseholdState(HouseholdState.error);
    }
  }

  void clearHouseholdError() {
    _householdError = null;
    _setHouseholdState(HouseholdState.idle);
  }

  void _setHouseholdState(HouseholdState s) {
    _householdState = s;
    notifyListeners();
  }

  // --- Catalogue seed ---

  Future<void> loadBaseItems() async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) return;
    _seedState = SeedState.loading;
    _seedMessage = null;
    notifyListeners();
    try {
      final count = await _seedDataService.loadMissingBaseItems(uid);
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
