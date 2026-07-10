import 'package:lystra/data/models/shopping_list_model.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/domain/models/shopping_list.dart';

class ShoppingListRepository {
  ShoppingListRepository({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;
  List<ShoppingList>? _cache;

  String _path(String uid) => 'users/$uid/lists';

  Future<List<ShoppingList>> getLists(String uid) async {
    if (_cache != null) return _cache!;
    final snapshot = await _firestore.getCollection(_path(uid));
    _cache = snapshot.docs
        .map((d) => ShoppingListModel.fromFirestore(d).toDomain())
        .where((l) => !l.isArchived)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _cache!;
  }

  Future<ShoppingList> createList(String uid, String name) async {
    final now = DateTime.now();
    final ref = await _firestore.addDoc(_path(uid), {
      'name': name.trim(),
      'ownerId': uid,
      'memberIds': <String>[],
      'createdAt': now,
      'isArchived': false,
    });
    final list = ShoppingList(
      id: ref.id,
      name: name.trim(),
      ownerId: uid,
      createdAt: now,
    );
    _cache?.insert(0, list);
    return list;
  }

  Future<void> updateList(String uid, ShoppingList list) async {
    final updated = list.copyWith(updatedAt: DateTime.now());
    await _firestore.updateDoc(
      'users/$uid/lists/${list.id}',
      ShoppingListModel.fromDomain(updated).toFirestore(),
    );
    _cache = _cache?.map((l) => l.id == list.id ? updated : l).toList();
  }

  Future<void> archiveList(String uid, String listId) async {
    await _firestore
        .updateDoc('users/$uid/lists/$listId', {'isArchived': true});
    _cache?.removeWhere((l) => l.id == listId);
  }

  Future<void> deleteList(String uid, String listId) async {
    await _firestore.deleteDoc('users/$uid/lists/$listId');
    _cache?.removeWhere((l) => l.id == listId);
  }

  void invalidateCache() => _cache = null;
}
