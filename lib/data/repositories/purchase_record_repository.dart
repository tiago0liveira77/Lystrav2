import 'package:lystra/data/models/purchase_record_model.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/domain/models/purchase_record.dart';

class PurchaseRecordRepository {
  PurchaseRecordRepository({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;
  List<PurchaseRecord>? _cache;

  String _path(String uid) => 'users/$uid/purchase_records';

  Future<List<PurchaseRecord>> getRecords(String uid) async {
    if (_cache != null) return _cache!;
    final snapshot = await _firestore.getCollection(_path(uid));
    _cache = snapshot.docs
        .map((d) => PurchaseRecordModel.fromFirestore(d).toDomain())
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return _cache!;
  }

  Future<PurchaseRecord> createRecord(
      String uid, PurchaseRecord record) async {
    final model = PurchaseRecordModel.fromDomain(record);
    final ref = await _firestore.addDoc(_path(uid), model.toFirestore());
    final saved = record.copyWith(id: ref.id);
    _cache?.insert(0, saved);
    return saved;
  }

  Future<void> deleteRecord(String uid, String recordId) async {
    await _firestore.deleteDoc('${_path(uid)}/$recordId');
    _cache?.removeWhere((r) => r.id == recordId);
  }

  void invalidateCache() => _cache = null;
}
