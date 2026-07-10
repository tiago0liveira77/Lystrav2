import 'package:lystra/data/models/item_model.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/domain/models/item.dart';

class ItemRepository {
  ItemRepository({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;
  List<Item>? _cache;

  String _path(String uid) => 'users/$uid/items';

  Future<List<Item>> getItems(String uid) async {
    if (_cache != null) return _cache!;
    final snapshot = await _firestore.getCollection(_path(uid));
    _cache = snapshot.docs
        .map((d) => ItemModel.fromFirestore(d).toDomain())
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _cache!;
  }

  List<Item> filter(
    List<Item> items, {
    String? categoryId,
    String query = '',
  }) {
    return items.where((item) {
      final matchesCategory =
          categoryId == null || item.categoryId == categoryId;
      final matchesQuery =
          query.isEmpty || item.name.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<Item> createItem(String uid, String name, String categoryId,
      {String unit = 'un', String? emoji}) async {
    final ref = await _firestore.addDoc(_path(uid), {
      'name': name.trim(),
      'categoryId': categoryId,
      'unit': unit,
      'ownerId': uid,
      if (emoji != null) 'emoji': emoji,
    });
    final item = Item(
      id: ref.id,
      name: name.trim(),
      categoryId: categoryId,
      unit: unit,
      ownerId: uid,
      emoji: emoji,
    );
    if (_cache != null) _cache = [..._cache!, item];
    return item;
  }

  Future<void> updateItem(String uid, Item item) async {
    await _firestore.updateDoc(
      'users/$uid/items/${item.id}',
      ItemModel.fromDomain(item).toFirestore(),
    );
    _cache = _cache?.map((i) => i.id == item.id ? item : i).toList();
  }

  Future<void> deleteItem(String uid, String itemId) async {
    await _firestore.deleteDoc('users/$uid/items/$itemId');
    _cache?.removeWhere((i) => i.id == itemId);
  }

  void invalidateCache() => _cache = null;
}
