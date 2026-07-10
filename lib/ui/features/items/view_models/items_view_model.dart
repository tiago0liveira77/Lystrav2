import 'package:flutter/foundation.dart' hide Category;
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/category_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/domain/models/category.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/domain/models/shopping_list.dart';
import 'package:lystra/ui/features/lists/view_models/lists_view_model.dart';

class ItemsViewModel extends ChangeNotifier {
  ItemsViewModel({
    required ItemRepository itemRepository,
    required CategoryRepository categoryRepository,
    required AuthRepository authRepository,
    required ShoppingListRepository listRepository,
    required ListEntryRepository entryRepository,
  })  : _itemRepository = itemRepository,
        _categoryRepository = categoryRepository,
        _authRepository = authRepository,
        _listRepository = listRepository,
        _entryRepository = entryRepository;

  final ItemRepository _itemRepository;
  final CategoryRepository _categoryRepository;
  final AuthRepository _authRepository;
  final ShoppingListRepository _listRepository;
  final ListEntryRepository _entryRepository;

  List<Item> _allItems = [];
  List<Category> _categories = [];
  List<Category> get categories => List.unmodifiable(_categories);

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  List<Item> get filteredItems => _itemRepository.filter(
        _allItems,
        categoryId: _selectedCategoryId,
        query: _searchQuery,
      );

  String? get _uid => _authRepository.currentUser?.uid;

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;
    _setState(ViewState.loading);
    try {
      _allItems = await _itemRepository.getItems(uid);
      _categories = await _categoryRepository.getCategories(uid);
      _setState(ViewState.loaded);
    } catch (_) {
      _setState(ViewState.error);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<Item?> createItem(
      String name, String categoryId, String unit, {String? emoji}) async {
    final uid = _uid;
    if (uid == null) return null;
    final item = await _itemRepository.createItem(uid, name, categoryId,
        unit: unit, emoji: emoji);
    _allItems = [..._allItems, item]..sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
    return item;
  }

  Future<Category?> createCategory(String name, String colorHex) async {
    final uid = _uid;
    if (uid == null || name.trim().isEmpty) return null;
    final category =
        await _categoryRepository.createCategory(uid, name, colorHex);
    _categories = [..._categories, category]
      ..sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
    return category;
  }

  Future<void> updateItem(Item item) async {
    final uid = _uid;
    if (uid == null) return;
    await _itemRepository.updateItem(uid, item);
    _allItems = _allItems.map((i) => i.id == item.id ? item : i).toList();
    notifyListeners();
  }

  Future<void> deleteItem(String itemId) async {
    final uid = _uid;
    if (uid == null) return;
    await _itemRepository.deleteItem(uid, itemId);
    _allItems.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  Category? categoryFor(String categoryId) =>
      _categories.where((c) => c.id == categoryId).firstOrNull;

  // Quick-add to list helpers
  Future<List<ShoppingList>> getActiveLists() async {
    final uid = _uid;
    if (uid == null) return [];
    return _listRepository.getLists(uid);
  }

  Future<bool> isItemInList(String itemId, String listId) async {
    final uid = _uid;
    if (uid == null) return false;
    final entries = await _entryRepository.getEntries(uid, listId);
    return entries.any((e) => e.itemId == itemId);
  }

  Future<void> addToList(String itemId, String listId) async {
    final uid = _uid;
    if (uid == null) return;
    await _entryRepository.addEntry(uid, listId, itemId);
  }

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }
}
