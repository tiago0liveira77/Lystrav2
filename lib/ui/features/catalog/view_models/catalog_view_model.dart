import 'package:flutter/foundation.dart' hide Category;
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/category_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/services/catalog_data.dart';

enum CatalogLoadState { loading, loaded, error }

class CatalogViewModel extends ChangeNotifier {
  CatalogViewModel({
    required ItemRepository itemRepository,
    required CategoryRepository categoryRepository,
    required AuthRepository authRepository,
  })  : _itemRepo = itemRepository,
        _categoryRepo = categoryRepository,
        _authRepo = authRepository;

  final ItemRepository _itemRepo;
  final CategoryRepository _categoryRepo;
  final AuthRepository _authRepo;

  CatalogLoadState _state = CatalogLoadState.loading;
  CatalogLoadState get state => _state;

  // Names of items the user already owns (lower-case for comparison)
  final Set<String> _ownedNames = {};

  // Names currently being added
  final Set<String> _adding = {};

  // Selected category filter (null = all)
  int? _selectedCategoryIndex;
  int? get selectedCategoryIndex => _selectedCategoryIndex;

  // How many items were added this session (used by caller to refresh)
  int _addedCount = 0;
  int get addedCount => _addedCount;

  // Resolved category IDs by catalog name (cache to avoid duplicate lookups)
  final Map<String, String> _catIdCache = {};

  String? get _uid => _authRepo.currentUser?.uid;

  List<CatalogCategory> get categories => catalogData;

  List<CatalogCategory> get filteredCategories =>
      _selectedCategoryIndex == null
          ? catalogData
          : [catalogData[_selectedCategoryIndex!]];

  bool isOwned(String itemName) =>
      _ownedNames.contains(itemName.toLowerCase());

  bool isAdding(String itemName) => _adding.contains(itemName.toLowerCase());

  void selectCategory(int? index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;
    _state = CatalogLoadState.loading;
    notifyListeners();
    try {
      final items = await _itemRepo.getItems(uid);
      _ownedNames
        ..clear()
        ..addAll(items.map((i) => i.name.toLowerCase()));
      _state = CatalogLoadState.loaded;
    } catch (_) {
      _state = CatalogLoadState.error;
    }
    notifyListeners();
  }

  Future<void> addItem(CatalogItem item, CatalogCategory cat) async {
    final uid = _uid;
    if (uid == null || isOwned(item.name) || isAdding(item.name)) return;

    final key = item.name.toLowerCase();
    _adding.add(key);
    notifyListeners();

    try {
      final catId = await _resolveCategory(uid, cat);
      await _itemRepo.createItem(uid, item.name, catId,
          unit: item.unit, emoji: item.emoji);
      _ownedNames.add(key);
      _addedCount++;
    } finally {
      _adding.remove(key);
      notifyListeners();
    }
  }

  Future<void> addCategory(CatalogCategory cat) async {
    final uid = _uid;
    if (uid == null) return;

    final missing =
        cat.items.where((i) => !isOwned(i.name) && !isAdding(i.name)).toList();
    if (missing.isEmpty) return;

    for (final item in missing) {
      _adding.add(item.name.toLowerCase());
    }
    notifyListeners();

    try {
      final catId = await _resolveCategory(uid, cat);
      await Future.wait(missing.map((item) async {
        await _itemRepo.createItem(uid, item.name, catId,
            unit: item.unit, emoji: item.emoji);
        _ownedNames.add(item.name.toLowerCase());
        _addedCount++;
      }));
    } finally {
      for (final item in missing) {
        _adding.remove(item.name.toLowerCase());
      }
      notifyListeners();
    }
  }

  Future<String> _resolveCategory(String uid, CatalogCategory cat) async {
    if (_catIdCache.containsKey(cat.name)) return _catIdCache[cat.name]!;

    final existing = await _categoryRepo.getCategories(uid);
    final match = existing
        .where((c) => c.name.toLowerCase() == cat.name.toLowerCase())
        .firstOrNull;

    final String catId;
    if (match != null) {
      catId = match.id;
    } else {
      final created =
          await _categoryRepo.createCategory(uid, cat.name, cat.colorHex);
      catId = created.id;
    }

    _catIdCache[cat.name] = catId;
    return catId;
  }
}
