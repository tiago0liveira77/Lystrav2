import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lystra/domain/models/purchase_record.dart';

class PurchaseRecordEntryModel {
  const PurchaseRecordEntryModel({
    required this.itemId,
    required this.itemName,
    required this.unit,
    this.quantity = 1.0,
  });

  final String itemId;
  final String itemName;
  final String unit;
  final double quantity;

  factory PurchaseRecordEntryModel.fromMap(Map<String, dynamic> map) =>
      PurchaseRecordEntryModel(
        itemId: map['itemId'] as String? ?? '',
        itemName: map['itemName'] as String? ?? '',
        unit: map['unit'] as String? ?? 'un',
        quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      );

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'itemName': itemName,
        'unit': unit,
        'quantity': quantity,
      };

  PurchaseRecordEntry toDomain() => PurchaseRecordEntry(
        itemId: itemId,
        itemName: itemName,
        unit: unit,
        quantity: quantity,
      );

  factory PurchaseRecordEntryModel.fromDomain(PurchaseRecordEntry entry) =>
      PurchaseRecordEntryModel(
        itemId: entry.itemId,
        itemName: entry.itemName,
        unit: entry.unit,
        quantity: entry.quantity,
      );
}

class PurchaseRecordModel {
  const PurchaseRecordModel({
    required this.id,
    required this.listId,
    required this.listName,
    required this.completedAt,
    required this.ownerId,
    required this.entries,
  });

  final String id;
  final String listId;
  final String listName;
  final DateTime completedAt;
  final String ownerId;
  final List<PurchaseRecordEntryModel> entries;

  factory PurchaseRecordModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawEntries =
        (data['entries'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];
    return PurchaseRecordModel(
      id: doc.id,
      listId: data['listId'] as String? ?? '',
      listName: data['listName'] as String? ?? '',
      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ownerId: data['ownerId'] as String? ?? '',
      entries:
          rawEntries.map((e) => PurchaseRecordEntryModel.fromMap(e)).toList(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'listId': listId,
        'listName': listName,
        'completedAt': completedAt,
        'ownerId': ownerId,
        'entries': entries.map((e) => e.toMap()).toList(),
      };

  PurchaseRecord toDomain() => PurchaseRecord(
        id: id,
        listId: listId,
        listName: listName,
        completedAt: completedAt,
        ownerId: ownerId,
        entries: entries.map((e) => e.toDomain()).toList(),
      );

  factory PurchaseRecordModel.fromDomain(PurchaseRecord record) =>
      PurchaseRecordModel(
        id: record.id,
        listId: record.listId,
        listName: record.listName,
        completedAt: record.completedAt,
        ownerId: record.ownerId,
        entries: record.entries
            .map((e) => PurchaseRecordEntryModel.fromDomain(e))
            .toList(),
      );
}
