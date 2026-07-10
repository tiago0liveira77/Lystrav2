import 'package:flutter/foundation.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/domain/models/list_entry.dart';
import 'package:lystra/domain/models/shopping_list.dart';

class ShoppingViewModel extends ChangeNotifier {
  ShoppingViewModel({
    required String listId,
    required ListEntryRepository entryRepository,
    required ShoppingListRepository listRepository,
    required ItemRepository itemRepository,
    required AuthRepository authRepository,
  })  : _listId = listId,
        _entryRepository = entryRepository,
        _listRepository = listRepository,
        _itemRepository = itemRepository,
        _authRepository = authRepository;

  final String _listId;
  final ListEntryRepository _entryRepository;
  final ShoppingListRepository _listRepository;
  final ItemRepository _itemRepository;
  final AuthRepository _authRepository;

  ShoppingList? _list;
  ShoppingList? get list => _list;

  List<ListEntry> _entries = [];
  List<Item> _items = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isFinishing = false;
  bool get isFinishing => _isFinishing;

  String? get _uid => _authRepository.currentUser?.uid;

  List<ListEntry> get uncheckedEntries =>
      _entries.where((e) => !e.isChecked).toList();
  List<ListEntry> get checkedEntries =>
      _entries.where((e) => e.isChecked).toList();

  double get progress =>
      _entries.isEmpty ? 0 : checkedEntries.length / _entries.length;

  bool get isComplete =>
      _entries.isNotEmpty && checkedEntries.length == _entries.length;

  Map<String, List<ListEntry>> get entriesByCategory {
    final Map<String, List<ListEntry>> map = {};
    for (final entry in uncheckedEntries) {
      final item = itemFor(entry.itemId);
      final categoryId = item?.categoryId ?? 'uncategorized';
      map.putIfAbsent(categoryId, () => []).add(entry);
    }
    return map;
  }

  Item? itemFor(String itemId) =>
      _items.where((i) => i.id == itemId).firstOrNull;

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _listRepository.getLists(uid),
        _entryRepository.getEntries(uid, _listId),
        _itemRepository.getItems(uid),
      ]);
      final lists = results[0] as List<ShoppingList>;
      _list = lists.where((l) => l.id == _listId).firstOrNull;
      _entries = results[1] as List<ListEntry>;
      _items = results[2] as List<Item>;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleEntry(String entryId) async {
    final uid = _uid;
    if (uid == null) return;
    // Optimistic update
    _entries = _entries.map((e) {
      if (e.id != entryId) return e;
      return e.copyWith(
        isChecked: !e.isChecked,
        checkedAt: !e.isChecked ? DateTime.now() : null,
      );
    }).toList();
    notifyListeners();

    await _entryRepository.toggleEntry(uid, _listId, entryId);
  }

  Future<void> addItem(String itemId) async {
    final uid = _uid;
    if (uid == null) return;
    final entry = await _entryRepository.addEntry(uid, _listId, itemId);
    _entries = [..._entries, entry];
    notifyListeners();
  }

  Future<void> removeEntry(String entryId) async {
    final uid = _uid;
    if (uid == null) return;
    _entries.removeWhere((e) => e.id == entryId);
    notifyListeners();
    await _entryRepository.removeEntry(uid, _listId, entryId);
  }

  Future<void> updateQuantity(String entryId, double quantity) async {
    final uid = _uid;
    if (uid == null) return;
    _entries = _entries
        .map((e) => e.id == entryId ? e.copyWith(quantity: quantity) : e)
        .toList();
    notifyListeners();
    await _entryRepository.updateQuantity(uid, _listId, entryId, quantity);
  }

  Future<bool> finishShopping() async {
    final uid = _uid;
    if (uid == null) return false;
    _isFinishing = true;
    notifyListeners();
    try {
      await _listRepository.archiveList(uid, _listId);
      _entryRepository.invalidateCache(_listId);
      return true;
    } catch (_) {
      return false;
    } finally {
      _isFinishing = false;
      notifyListeners();
    }
  }
}
