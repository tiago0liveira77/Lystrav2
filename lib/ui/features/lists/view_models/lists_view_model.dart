import 'package:flutter/foundation.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/domain/models/shopping_list.dart';

enum ViewState { initial, loading, loaded, error }

class ListsViewModel extends ChangeNotifier {
  ListsViewModel({
    required ShoppingListRepository listRepository,
    required AuthRepository authRepository,
  })  : _listRepository = listRepository,
        _authRepository = authRepository;

  final ShoppingListRepository _listRepository;
  final AuthRepository _authRepository;

  List<ShoppingList> _lists = [];
  List<ShoppingList> get lists => List.unmodifiable(_lists);

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? get _uid => _authRepository.currentUser?.uid;

  Future<void> loadLists() async {
    final uid = _uid;
    if (uid == null) return;
    _setState(ViewState.loading);
    try {
      _lists = await _listRepository.getLists(uid);
      _setState(ViewState.loaded);
    } catch (e) {
      _errorMessage = 'Erro ao carregar listas.';
      _setState(ViewState.error);
    }
  }

  Future<ShoppingList?> createList(String name) async {
    final uid = _uid;
    if (uid == null || name.trim().isEmpty) return null;
    try {
      final list = await _listRepository.createList(uid, name);
      _lists = [list, ..._lists];
      notifyListeners();
      return list;
    } catch (_) {
      return null;
    }
  }

  Future<void> renameList(ShoppingList list, String newName) async {
    final uid = _uid;
    if (uid == null || newName.trim().isEmpty) return;
    final updated = list.copyWith(name: newName.trim());
    await _listRepository.updateList(uid, updated);
    _lists = _lists.map((l) => l.id == list.id ? updated : l).toList();
    notifyListeners();
  }

  Future<void> deleteList(String listId) async {
    final uid = _uid;
    if (uid == null) return;
    await _listRepository.deleteList(uid, listId);
    _lists.removeWhere((l) => l.id == listId);
    notifyListeners();
  }

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }
}
