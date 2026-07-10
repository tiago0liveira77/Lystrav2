import 'package:lystra/data/services/firestore_service.dart';

class _ItemSeed {
  const _ItemSeed(this.name, this.emoji, this.unit);
  final String name;
  final String emoji;
  final String unit;
}

class _CatSeed {
  const _CatSeed({
    required this.name,
    required this.colorHex,
    required this.items,
  });
  final String name;
  final String colorHex;
  final List<_ItemSeed> items;
}

const _seeds = [
  _CatSeed(
    name: 'Frutas',
    colorHex: '#2D9B4E',
    items: [
      _ItemSeed('Maçãs', '🍎', 'kg'),
      _ItemSeed('Bananas', '🍌', 'un'),
      _ItemSeed('Laranjas', '🍊', 'kg'),
      _ItemSeed('Morangos', '🍓', 'cx'),
      _ItemSeed('Uvas', '🍇', 'kg'),
      _ItemSeed('Pêras', '🍐', 'kg'),
    ],
  ),
  _CatSeed(
    name: 'Legumes',
    colorHex: '#1B8C5E',
    items: [
      _ItemSeed('Tomates', '🍅', 'kg'),
      _ItemSeed('Alface', '🥬', 'un'),
      _ItemSeed('Cenouras', '🥕', 'kg'),
      _ItemSeed('Batatas', '🥔', 'kg'),
      _ItemSeed('Cebolas', '🧅', 'kg'),
      _ItemSeed('Alho', '🧄', 'un'),
      _ItemSeed('Pepino', '🥒', 'un'),
      _ItemSeed('Brócolos', '🥦', 'un'),
    ],
  ),
  _CatSeed(
    name: 'Lacticínios',
    colorHex: '#3D5A8A',
    items: [
      _ItemSeed('Leite', '🥛', 'L'),
      _ItemSeed('Queijo', '🧀', 'kg'),
      _ItemSeed('Iogurte', '🍶', 'un'),
      _ItemSeed('Manteiga', '🧈', 'un'),
      _ItemSeed('Natas', '🥛', 'L'),
    ],
  ),
  _CatSeed(
    name: 'Carnes',
    colorHex: '#DC2626',
    items: [
      _ItemSeed('Frango', '🍗', 'kg'),
      _ItemSeed('Carne Picada', '🥩', 'kg'),
      _ItemSeed('Bifes', '🥩', 'kg'),
      _ItemSeed('Salsichas', '🌭', 'un'),
    ],
  ),
  _CatSeed(
    name: 'Peixe & Mar',
    colorHex: '#0EA5E9',
    items: [
      _ItemSeed('Bacalhau', '🐟', 'kg'),
      _ItemSeed('Salmão', '🐠', 'kg'),
      _ItemSeed('Sardinha em Lata', '🐟', 'cx'),
      _ItemSeed('Atum em Lata', '🐡', 'cx'),
    ],
  ),
  _CatSeed(
    name: 'Padaria',
    colorHex: '#F59E0B',
    items: [
      _ItemSeed('Pão', '🍞', 'un'),
      _ItemSeed('Pão de Forma', '🍞', 'un'),
      _ItemSeed('Croissants', '🥐', 'un'),
    ],
  ),
  _CatSeed(
    name: 'Mercearia',
    colorHex: '#6B7280',
    items: [
      _ItemSeed('Arroz', '🌾', 'kg'),
      _ItemSeed('Massa', '🍝', 'un'),
      _ItemSeed('Azeite', '🫒', 'L'),
      _ItemSeed('Sal', '🧂', 'un'),
      _ItemSeed('Açúcar', '🍚', 'kg'),
      _ItemSeed('Café', '☕', 'un'),
      _ItemSeed('Feijão', '🫘', 'cx'),
      _ItemSeed('Grão', '🫘', 'cx'),
      _ItemSeed('Tomate Pelado', '🍅', 'cx'),
      _ItemSeed('Farinha', '🌾', 'kg'),
    ],
  ),
  _CatSeed(
    name: 'Bebidas',
    colorHex: '#8B5CF6',
    items: [
      _ItemSeed('Água', '💧', 'L'),
      _ItemSeed('Sumo de Laranja', '🍊', 'L'),
      _ItemSeed('Refrigerante', '🥤', 'un'),
      _ItemSeed('Cerveja', '🍺', 'un'),
    ],
  ),
  _CatSeed(
    name: 'Higiene',
    colorHex: '#EC4899',
    items: [
      _ItemSeed('Champô', '🧴', 'un'),
      _ItemSeed('Gel de Banho', '🧴', 'un'),
      _ItemSeed('Pasta de Dentes', '🪥', 'un'),
      _ItemSeed('Papel Higiénico', '🧻', 'un'),
      _ItemSeed('Desodorizante', '🧴', 'un'),
    ],
  ),
  _CatSeed(
    name: 'Limpeza',
    colorHex: '#F97316',
    items: [
      _ItemSeed('Detergente Roupa', '🧺', 'un'),
      _ItemSeed('Detergente Louça', '🫧', 'un'),
      _ItemSeed('Lixívia', '🧴', 'un'),
      _ItemSeed('Sacos do Lixo', '🗑️', 'un'),
    ],
  ),
];

class SeedDataService {
  SeedDataService({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;

  String _catPath(String uid) => 'users/$uid/categories';
  String _itemPath(String uid) => 'users/$uid/items';

  // Called after first registration — skips if user already has items.
  Future<void> seedIfFirstTime(String uid) async {
    final existing = await _firestore.getCollection(_itemPath(uid));
    if (existing.docs.isNotEmpty) return;
    await _createAll(uid, existingCatNames: {}, existingItemNames: {});
  }

  // Called from settings — adds only items/categories not yet present.
  // Returns the number of new items created.
  Future<int> loadMissingBaseItems(String uid) async {
    final [catSnap, itemSnap] = await Future.wait([
      _firestore.getCollection(_catPath(uid)),
      _firestore.getCollection(_itemPath(uid)),
    ]);

    final existingCatNames = {
      for (final d in catSnap.docs)
        (d.data()['name'] as String? ?? ''): d.id,
    };
    final existingItemNames = {
      for (final d in itemSnap.docs) d.data()['name'] as String? ?? '',
    };

    return _createAll(
      uid,
      existingCatNames: existingCatNames,
      existingItemNames: existingItemNames,
    );
  }

  Future<int> _createAll(
    String uid, {
    required Map<String, String> existingCatNames,
    required Set<String> existingItemNames,
  }) async {
    int created = 0;

    for (final cat in _seeds) {
      // Find or create category
      final String catId;
      if (existingCatNames.containsKey(cat.name)) {
        catId = existingCatNames[cat.name]!;
      } else {
        final ref = await _firestore.addDoc(_catPath(uid), {
          'name': cat.name,
          'colorHex': cat.colorHex,
        });
        catId = ref.id;
        existingCatNames[cat.name] = catId;
      }

      // Create missing items in parallel
      final missingItems =
          cat.items.where((i) => !existingItemNames.contains(i.name)).toList();

      if (missingItems.isNotEmpty) {
        await Future.wait(missingItems.map((item) async {
          await _firestore.addDoc(_itemPath(uid), {
            'name': item.name,
            'categoryId': catId,
            'unit': item.unit,
            'ownerId': uid,
            'emoji': item.emoji,
          });
          existingItemNames.add(item.name);
        }));
        created += missingItems.length;
      }
    }

    return created;
  }
}
