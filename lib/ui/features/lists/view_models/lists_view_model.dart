import 'package:flutter/foundation.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/data/services/user_state.dart';
import 'package:lystra/domain/models/list_entry.dart';
import 'package:lystra/domain/models/shopping_list.dart';

enum ViewState { initial, loading, loaded, error }

class ListsViewModel extends ChangeNotifier {
  ListsViewModel({
    required ShoppingListRepository listRepository,
    required AuthRepository authRepository,
    required ListEntryRepository entryRepository,
    required UserState userState,
  })  : _listRepository = listRepository,
        _authRepository = authRepository,
        _entryRepository = entryRepository,
        _userState = userState {
    // Reload household lists if UserState loads householdId after initial loadLists()
    _userState.addListener(_onUserStateChanged);
  }

  final ShoppingListRepository _listRepository;
  final AuthRepository _authRepository;
  final ListEntryRepository _entryRepository;
  final UserState _userState;

  List<ShoppingList> _personalLists = [];
  List<ShoppingList> _householdLists = [];

  List<ShoppingList> get personalLists => List.unmodifiable(_personalLists);
  List<ShoppingList> get householdLists => List.unmodifiable(_householdLists);
  List<ShoppingList> get allLists => [..._personalLists, ..._householdLists];

  final Map<String, List<ListEntry>> _entriesPerList = {};

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _lastHouseholdId;

  String? get _uid => _authRepository.currentUser?.uid;
  String? get _householdId => _userState.householdId;
  bool get isInHousehold => _householdId != null;

  void _onUserStateChanged() {
    final newHid = _userState.householdId;
    if (newHid != _lastHouseholdId) {
      _lastHouseholdId = newHid;
      final uid = _uid;
      if (uid != null && _state == ViewState.loaded) {
        // Household changed — reload household lists
        _reloadHouseholdLists(uid, newHid);
      }
    }
    notifyListeners();
  }

  Future<void> _reloadHouseholdLists(String uid, String? householdId) async {
    if (householdId == null) {
      _householdLists = [];
    } else {
      try {
        _householdLists = await _listRepository.getHouseholdLists(householdId);
        await _loadEntryCounts(uid);
      } catch (_) {}
    }
    notifyListeners();
  }

  int totalCountFor(String listId) => _entriesPerList[listId]?.length ?? 0;
  int checkedCountFor(String listId) =>
      _entriesPerList[listId]?.where((e) => e.isChecked).length ?? 0;

  Future<void> loadLists() async {
    final uid = _uid;
    if (uid == null) return;
    _setState(ViewState.loading);
    try {
      _personalLists = await _listRepository.getLists(uid);

      if (_householdId != null) {
        _householdLists =
            await _listRepository.getHouseholdLists(_householdId!);
      } else {
        _householdLists = [];
      }

      _setState(ViewState.loaded);
      await _loadEntryCounts(uid);
    } catch (e) {
      _errorMessage = 'Erro ao carregar listas.';
      _setState(ViewState.error);
    }
  }

  Future<void> _loadEntryCounts(String uid) async {
    final all = allLists;
    if (all.isEmpty) return;
    await Future.wait(all.map((list) async {
      try {
        _entriesPerList[list.id] = await _entryRepository.getEntries(
          uid,
          list.id,
          householdId: list.householdId,
        );
      } catch (_) {}
    }));
    notifyListeners();
  }

  // --- Personal list CRUD ---

  Future<ShoppingList?> createPersonalList(String name) async {
    final uid = _uid;
    if (uid == null || name.trim().isEmpty) return null;
    try {
      final list = await _listRepository.createList(uid, name);
      _personalLists = [list, ..._personalLists];
      _entriesPerList[list.id] = [];
      notifyListeners();
      return list;
    } catch (_) {
      return null;
    }
  }

  // --- Household list CRUD ---

  Future<ShoppingList?> createHouseholdList(String name) async {
    final uid = _uid;
    final householdId = _householdId;
    if (uid == null || householdId == null || name.trim().isEmpty) return null;
    try {
      final list =
          await _listRepository.createHouseholdList(householdId, uid, name);
      _householdLists = [list, ..._householdLists];
      _entriesPerList[list.id] = [];
      notifyListeners();
      return list;
    } catch (_) {
      return null;
    }
  }

  // --- Shared update / delete ---

  Future<void> renameList(ShoppingList list, String newName) async {
    final uid = _uid;
    if (uid == null || newName.trim().isEmpty) return;
    final updated = list.copyWith(name: newName.trim());
    await _listRepository.updateList(uid, updated);
    _replaceInCache(updated);
    notifyListeners();
  }

  Future<void> deleteList(ShoppingList list) async {
    final uid = _uid;
    if (uid == null) return;
    await _listRepository.deleteList(uid, list.id,
        householdId: list.householdId);
    _removeFromCache(list);
    _entriesPerList.remove(list.id);
    notifyListeners();
  }

  void _replaceInCache(ShoppingList updated) {
    if (updated.householdId != null) {
      _householdLists = _householdLists
          .map((l) => l.id == updated.id ? updated : l)
          .toList();
    } else {
      _personalLists = _personalLists
          .map((l) => l.id == updated.id ? updated : l)
          .toList();
    }
  }

  void _removeFromCache(ShoppingList list) {
    if (list.householdId != null) {
      _householdLists = _householdLists.where((l) => l.id != list.id).toList();
    } else {
      _personalLists = _personalLists.where((l) => l.id != list.id).toList();
    }
  }

  void _setState(ViewState s) {
    _state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _userState.removeListener(_onUserStateChanged);
    super.dispose();
  }
}
