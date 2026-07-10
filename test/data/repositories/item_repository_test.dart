import 'package:flutter_test/flutter_test.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:mockito/annotations.dart';

import 'item_repository_test.mocks.dart';

@GenerateMocks([FirestoreService])
void main() {
  late ItemRepository repo;

  final items = [
    const Item(id: '1', name: 'Leite', categoryId: 'dairy', unit: 'L', ownerId: 'u1'),
    const Item(id: '2', name: 'Pão', categoryId: 'bakery', unit: 'un', ownerId: 'u1'),
    const Item(id: '3', name: 'Iogurte', categoryId: 'dairy', unit: 'un', ownerId: 'u1'),
  ];

  setUp(() {
    repo = ItemRepository(firestoreService: MockFirestoreService());
  });

  group('filter()', () {
    test('returns all items when no filter applied', () {
      expect(repo.filter(items).length, 3);
    });

    test('filters by categoryId', () {
      final result = repo.filter(items, categoryId: 'dairy');
      expect(result.length, 2);
      expect(result.map((i) => i.id).toList(), containsAll(['1', '3']));
    });

    test('filters by query (case-insensitive)', () {
      final result = repo.filter(items, query: 'leite');
      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('combines category and query filters', () {
      final result = repo.filter(items, categoryId: 'dairy', query: 'io');
      expect(result.length, 1);
      expect(result.first.name, 'Iogurte');
    });

    test('returns empty when no match', () {
      expect(repo.filter(items, query: 'xyz'), isEmpty);
    });
  });
}
