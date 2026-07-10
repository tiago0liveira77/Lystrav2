import 'package:flutter_test/flutter_test.dart';
import 'package:lystra/domain/models/purchase_record.dart';
import 'package:lystra/data/models/purchase_record_model.dart';

void main() {
  group('PurchaseRecordEntryModel', () {
    test('fromMap / toMap roundtrip', () {
      final map = {
        'itemId': 'item-1',
        'itemName': 'Leite',
        'unit': 'L',
        'quantity': 2.0,
      };
      final model = PurchaseRecordEntryModel.fromMap(map);

      expect(model.itemId, 'item-1');
      expect(model.itemName, 'Leite');
      expect(model.unit, 'L');
      expect(model.quantity, 2.0);
      expect(model.toMap(), map);
    });

    test('fromMap uses defaults for missing fields', () {
      final model = PurchaseRecordEntryModel.fromMap({
        'itemId': 'x',
        'itemName': 'X',
      });
      expect(model.unit, 'un');
      expect(model.quantity, 1.0);
    });

    test('toDomain / fromDomain roundtrip', () {
      const entry = PurchaseRecordEntry(
        itemId: 'i1',
        itemName: 'Pão',
        unit: 'un',
        quantity: 3.0,
      );
      final model = PurchaseRecordEntryModel.fromDomain(entry);
      final domain = model.toDomain();

      expect(domain.itemId, entry.itemId);
      expect(domain.itemName, entry.itemName);
      expect(domain.quantity, entry.quantity);
    });
  });

  group('PurchaseRecordModel.fromDomain / toDomain', () {
    final now = DateTime(2026, 7, 10, 12, 0);

    test('fromDomain preserves all fields', () {
      final record = PurchaseRecord(
        id: 'r1',
        listId: 'l1',
        listName: 'Lidl',
        completedAt: DateTime(2026, 7, 10, 12, 0),
        ownerId: 'u1',
        entries: const [
          PurchaseRecordEntry(
              itemId: 'i1', itemName: 'Leite', unit: 'L', quantity: 2),
        ],
      );
      final model = PurchaseRecordModel.fromDomain(record);

      expect(model.id, 'r1');
      expect(model.listName, 'Lidl');
      expect(model.entries.length, 1);
      expect(model.entries.first.itemName, 'Leite');

      final domain = model.toDomain();
      expect(domain.id, record.id);
      expect(domain.listName, record.listName);
      expect(domain.entries.first.quantity, 2.0);
    });

    test('toFirestore excludes id', () {
      final model = PurchaseRecordModel(
        id: 'r1',
        listId: 'l1',
        listName: 'Test',
        completedAt: now,
        ownerId: 'u1',
        entries: const [],
      );
      final map = model.toFirestore();

      expect(map.containsKey('id'), isFalse);
      expect(map['listName'], 'Test');
      expect(map['entries'], isEmpty);
    });
  });
}
