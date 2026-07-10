import 'package:flutter/foundation.dart' hide Category;
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/category_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/repositories/purchase_record_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/domain/models/category.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/domain/models/list_entry.dart';
import 'package:lystra/domain/models/purchase_record.dart';
import 'package:lystra/domain/models/shopping_list.dart';

class ShoppingViewModel extends ChangeNotifier {
  ShoppingViewModel({
    required String listId,
    required ListEntryRepository entryRepository,
    required ShoppingListRepository listRepository,
    required ItemRepository itemRepository,
    required AuthRepository authRepository,
    required PurchaseRecordRepository purchaseRecordRepository,
    required CategoryRepository categoryRepository,
  })  : _listId = listId,
        _entryRepository = entryRepository,
        _listRepository = listRepository,
        _itemRepository = itemRepository,
        _authRepository = authRepository,
        _purchaseRecordRepository = purchaseRecordRepository,
        _categoryRepository = categoryRepository;

  final String _listId;
  final ListEntryRepository _entryRepository;
  final ShoppingListRepository _listRepository;
  final ItemRepository _itemRepository;
  final AuthRepository _authRepository;
  final PurchaseRecordRepository _purchaseRecordRepository;
  final CategoryRepository _categoryRepository;

  ShoppingList? _list;
  ShoppingList? get list => _list;

  List<ListEntry> _entries = [];
  List<Item> _items = [];
  List<Category> _categories = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isFinishing = false;
  bool get isFinishing => _isFinishing;

  String? get _uid => _authRepository.currentUser?.uid;

  List<ListEntry> get entries => List.unmodifiable(_entries);
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

  Category? categoryFor(String categoryId) =>
      _categories.where((c) => c.id == categoryId).firstOrNull;

  ListEntry? entryForItem(String itemId) =>
      _entries.where((e) => e.itemId == itemId).firstOrNull;

  List<Item> get allItems => List.unmodifiable(_items);

  List<Category> get categories => List.unmodifiable(_categories);

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
        _categoryRepository.getCategories(uid),
      ]);
      final lists = results[0] as List<ShoppingList>;
      _list = lists.where((l) => l.id == _listId).firstOrNull;
      _entries = results[1] as List<ListEntry>;
      _items = results[2] as List<Item>;
      _categories = results[3] as List<Category>;
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

  // Adds item if not in list; increments quantity if already present.
  Future<void> addOrIncrement(String itemId) async {
    final existing = entryForItem(itemId);
    if (existing != null) {
      await updateQuantity(existing.id, existing.quantity + 1);
    } else {
      await addItem(itemId);
    }
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
    final list = _list;
    if (uid == null || list == null) return false;
    _isFinishing = true;
    notifyListeners();
    try {
      final recordEntries = checkedEntries.map((entry) {
        final item = itemFor(entry.itemId);
        return PurchaseRecordEntry(
          itemId: entry.itemId,
          itemName: item?.name ?? 'Item desconhecido',
          unit: item?.unit ?? 'un',
          quantity: entry.quantity,
        );
      }).toList();

      final record = PurchaseRecord(
        id: '',
        listId: list.id,
        listName: list.name,
        completedAt: DateTime.now(),
        ownerId: uid,
        entries: recordEntries,
      );

      await _purchaseRecordRepository.createRecord(uid, record);
      // Reset entries to unchecked — list stays visible and reusable
      await _entryRepository.resetEntries(uid, _listId);
      _entries = _entries
          .map((e) => e.copyWith(isChecked: false, checkedAt: null))
          .toList();
      return true;
    } catch (_) {
      return false;
    } finally {
      _isFinishing = false;
      notifyListeners();
    }
  }
}
