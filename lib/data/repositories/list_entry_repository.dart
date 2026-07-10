import 'package:lystra/data/models/list_entry_model.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/domain/models/list_entry.dart';

class ListEntryRepository {
  ListEntryRepository({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;
  final Map<String, List<ListEntry>> _cache = {};

  String _path(String uid, String listId) =>
      'users/$uid/lists/$listId/entries';

  Future<List<ListEntry>> getEntries(String uid, String listId) async {
    if (_cache.containsKey(listId)) return _cache[listId]!;
    final snapshot =
        await _firestore.getCollection(_path(uid, listId));
    final entries = snapshot.docs
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
  }) async {
    final now = DateTime.now();
    final ref = await _firestore.addDoc(_path(uid, listId), {
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
    _cache[listId]?.add(entry);
    return entry;
  }

  Future<void> toggleEntry(String uid, String listId, String entryId) async {
    final entries = _cache[listId];
    final entry = entries?.firstWhere((e) => e.id == entryId);
    if (entry == null) return;

    final updated = entry.copyWith(
      isChecked: !entry.isChecked,
      checkedAt: !entry.isChecked ? DateTime.now() : null,
    );
    await _firestore.updateDoc(
      '${_path(uid, listId)}/$entryId',
      {'isChecked': updated.isChecked, 'checkedAt': updated.checkedAt},
    );
    _cache[listId] = entries!.map((e) => e.id == entryId ? updated : e).toList();
  }

  Future<void> updateQuantity(
      String uid, String listId, String entryId, double quantity) async {
    await _firestore.updateDoc(
      '${_path(uid, listId)}/$entryId',
      {'quantity': quantity},
    );
    _cache[listId] = _cache[listId]
            ?.map((e) => e.id == entryId ? e.copyWith(quantity: quantity) : e)
            .toList() ??
        [];
  }

  Future<void> removeEntry(
      String uid, String listId, String entryId) async {
    await _firestore.deleteDoc('${_path(uid, listId)}/$entryId');
    _cache[listId]?.removeWhere((e) => e.id == entryId);
  }

  void invalidateCache(String listId) => _cache.remove(listId);
  void invalidateAll() => _cache.clear();
}
