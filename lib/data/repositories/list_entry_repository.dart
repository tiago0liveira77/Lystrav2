import 'package:lystra/data/models/list_entry_model.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/domain/models/list_entry.dart';

class ListEntryRepository {
  ListEntryRepository({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;
  final Map<String, List<ListEntry>> _cache = {};

  String _path(String uid, String listId, {String? householdId}) =>
      householdId != null
          ? 'households/$householdId/lists/$listId/entries'
          : 'users/$uid/lists/$listId/entries';

  Future<List<ListEntry>> getEntries(String uid, String listId,
      {String? householdId}) async {
    if (_cache.containsKey(listId)) return _cache[listId]!;
    final snap = await _firestore.getCollection(
        _path(uid, listId, householdId: householdId));
    final entries = snap.docs
        .map((d) => ListEntryModel.fromFirestore(d).toDomain())
        .toList()
      ..sort((a, b) => a.addedAt.compareTo(b.addedAt));
    _cache[listId] = entries;
    return entries;
  }

  Future<ListEntry> addEntry(
    String uid,
    String listId,
    String itemId, {
    double quantity = 1.0,
    String? householdId,
  }) async {
    final now = DateTime.now();
    final ref = await _firestore.addDoc(
        _path(uid, listId, householdId: householdId), {
      'listId': listId,
      'itemId': itemId,
      'quantity': quantity,
      'isChecked': false,
      'addedAt': now,
      'addedById': uid,
    });
    final entry = ListEntry(
      id: ref.id,
      listId: listId,
      itemId: itemId,
      quantity: quantity,
      addedAt: now,
      addedById: uid,
    );
    if (_cache.containsKey(listId)) {
      _cache[listId] = [..._cache[listId]!, entry];
    }
    return entry;
  }

  Future<void> toggleEntry(String uid, String listId, String entryId,
      {String? householdId}) async {
    final entries = _cache[listId];
    final entry = entries?.firstWhere((e) => e.id == entryId);
    if (entry == null) return;

    final updated = entry.copyWith(
      isChecked: !entry.isChecked,
      checkedAt: !entry.isChecked ? DateTime.now() : null,
    );
    await _firestore.updateDoc(
      '${_path(uid, listId, householdId: householdId)}/$entryId',
      {'isChecked': updated.isChecked, 'checkedAt': updated.checkedAt},
    );
    _cache[listId] =
        entries!.map((e) => e.id == entryId ? updated : e).toList();
  }

  Future<void> updateQuantity(
      String uid, String listId, String entryId, double quantity,
      {String? householdId}) async {
    await _firestore.updateDoc(
      '${_path(uid, listId, householdId: householdId)}/$entryId',
      {'quantity': quantity},
    );
    _cache[listId] = _cache[listId]
            ?.map((e) => e.id == entryId ? e.copyWith(quantity: quantity) : e)
            .toList() ??
        [];
  }

  Future<void> removeEntry(String uid, String listId, String entryId,
      {String? householdId}) async {
    await _firestore.deleteDoc(
        '${_path(uid, listId, householdId: householdId)}/$entryId');
    _cache[listId]?.removeWhere((e) => e.id == entryId);
  }

  Future<void> resetEntries(String uid, String listId,
      {String? householdId}) async {
    final entries = _cache[listId] ?? [];
    final checked = entries.where((e) => e.isChecked).toList();
    if (checked.isEmpty) return;
    await Future.wait(checked.map((e) => _firestore.updateDoc(
          '${_path(uid, listId, householdId: householdId)}/${e.id}',
          {'isChecked': false, 'checkedAt': null},
        )));
    _cache[listId] = entries
        .map((e) => e.copyWith(isChecked: false, checkedAt: null))
        .toList();
  }

  Stream<List<ListEntry>> watchEntries(String uid, String listId,
      {String? householdId}) {
    return _firestore
        .streamCollection(_path(uid, listId, householdId: householdId))
        .map((snapshot) {
      final entries = snapshot.docs
          .map((d) => ListEntryModel.fromFirestore(d).toDomain())
          .toList()
        ..sort((a, b) => a.addedAt.compareTo(b.addedAt));
      _cache[listId] = entries;
      return entries;
    });
  }

  void invalidateCache(String listId) => _cache.remove(listId);
  void invalidateAll() => _cache.clear();
}
