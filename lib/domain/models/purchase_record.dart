import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_record.freezed.dart';

@freezed
abstract class PurchaseRecord with _$PurchaseRecord {
  const factory PurchaseRecord({
    required String id,
    required String listId,
    required String listName,
    required DateTime completedAt,
    required String ownerId,
    @Default([]) List<PurchaseRecordEntry> entries,
  }) = _PurchaseRecord;
}

@freezed
abstract class PurchaseRecordEntry with _$PurchaseRecordEntry {
  const factory PurchaseRecordEntry({
    required String itemId,
    required String itemName,
    required String unit,
    @Default(1.0) double quantity,
  }) = _PurchaseRecordEntry;
}
