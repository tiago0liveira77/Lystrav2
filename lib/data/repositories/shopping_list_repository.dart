import 'package:lystra/data/models/shopping_list_model.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/domain/models/shopping_list.dart';

class ShoppingListRepository {
  ShoppingListRepository({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;

  // Separate caches for personal and household lists
  List<ShoppingList>? _personalCache;
  final Map<String, List<ShoppingList>> _householdCache = {};

  String _personalPath(String uid) => 'users/$uid/lists';
  String _householdPath(String householdId) =>
      'households/$householdId/lists';

  // Returns the correct path for a list (personal or household)
  String _listDocPath(String uid, String listId,
          {String? householdId}) =>
      householdId != null
          ? '${_householdPath(householdId)}/$listId'
          : '${_personalPath(uid)}/$listId';

  // --- Personal lists ---

  Future<List<ShoppingList>> getLists(String uid) async {
    if (_personalCache != null) return _personalCache!;
    final snap = await _firestore.getCollection(_personalPath(uid));
    _personalCache = snap.docs
        .map((d) => ShoppingListModel.fromFirestore(d).toDomain())
        .where((l) => !l.isArchived)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _personalCache!;
  }

  Future<ShoppingList> createList(String uid, String name) async {
    final now = DateTime.now();
    final ref = await _firestore.addDoc(_personalPath(uid), {
      'name': name.trim(),
      'ownerId': uid,
      'memberIds': <String>[],
      'createdAt': now,
      'isArchived': false,
    });
    final list = ShoppingList(
        id: ref.id, name: name.trim(), ownerId: uid, createdAt: now);
    if (_personalCache != null) _personalCache = [list, ..._personalCache!];
    return list;
  }

  // --- Household lists ---

  Future<List<ShoppingList>> getHouseholdLists(String householdId) async {
    if (_householdCache.containsKey(householdId)) {
      return _householdCache[householdId]!;
    }
    final snap =
        await _firestore.getCollection(_householdPath(householdId));
    final lists = snap.docs
        .map((d) => ShoppingListModel.fromFirestore(d).toDomain())
        .where((l) => !l.isArchived)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _householdCache[householdId] = lists;
    return lists;
  }

  Future<ShoppingList> createHouseholdList(
      String householdId, String uid, String name) async {
    final now = DateTime.now();
    final ref = await _firestore.addDoc(_householdPath(householdId), {
      'name': name.trim(),
      'ownerId': uid,
      'memberIds': <String>[],
      'createdAt': now,
      'isArchived': false,
      'householdId': householdId,
    });
    final list = ShoppingList(
      id: ref.id,
      name: name.trim(),
      ownerId: uid,
      createdAt: now,
      householdId: householdId,
    );
    if (_householdCache.containsKey(householdId)) {
      _householdCache[householdId] = [list, ..._householdCache[householdId]!];
    }
    return list;
  }

  // --- Shared update / archive / delete (work for both types) ---

  Future<void> updateList(String uid, ShoppingList list) async {
    final updated = list.copyWith(updatedAt: DateTime.now());
    await _firestore.updateDoc(
      _listDocPath(uid, list.id, householdId: list.householdId),
      ShoppingListModel.fromDomain(updated).toFirestore(),
    );
    _updateInCache(updated);
  }

  Future<void> archiveList(String uid, String listId,
      {String? householdId}) async {
    await _firestore.updateDoc(
      _listDocPath(uid, listId, householdId: householdId),
      {'isArchived': true},
    );
    _removeFromCache(listId, householdId: householdId);
  }

  Future<void> deleteList(String uid, String listId,
      {String? householdId}) async {
    await _firestore.deleteDoc(
        _listDocPath(uid, listId, householdId: householdId));
    _removeFromCache(listId, householdId: householdId);
  }

  void _updateInCache(ShoppingList updated) {
    if (updated.householdId != null) {
      final key = updated.householdId!;
      _householdCache[key] = _householdCache[key]
              ?.map((l) => l.id == updated.id ? updated : l)
              .toList() ??
          [];
    } else {
      _personalCache =
          _personalCache?.map((l) => l.id == updated.id ? updated : l).toList();
    }
  }

  void _removeFromCache(String listId, {String? householdId}) {
    if (householdId != null) {
      _householdCache[householdId] =
          _householdCache[householdId]?.where((l) => l.id != listId).toList() ??
              [];
    } else {
      _personalCache =
          _personalCache?.where((l) => l.id != listId).toList();
    }
  }

  void invalidateCache() {
    _personalCache = null;
    _householdCache.clear();
  }

  void invalidateHouseholdCache(String householdId) =>
      _householdCache.remove(householdId);
}
