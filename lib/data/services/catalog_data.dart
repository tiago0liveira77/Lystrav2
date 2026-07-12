class CatalogItem {
  const CatalogItem({
    required this.name,
    required this.emoji,
    required this.unit,
  });
  final String name;
  final String emoji;
  final String unit;
}

class CatalogCategory {
  const CatalogCategory({
    required this.name,
    required this.colorHex,
    required this.items,
  });
  final String name;
  final String colorHex;
  final List<CatalogItem> items;
}

const catalogData = [
  CatalogCategory(
    name: 'Frutas',
    colorHex: '#2D9B4E',
    items: [
      CatalogItem(name: 'Maçãs', emoji: '🍎', unit: 'kg'),
      CatalogItem(name: 'Bananas', emoji: '🍌', unit: 'un'),
      CatalogItem(name: 'Laranjas', emoji: '🍊', unit: 'kg'),
      CatalogItem(name: 'Morangos', emoji: '🍓', unit: 'cx'),
      CatalogItem(name: 'Uvas', emoji: '🍇', unit: 'kg'),
      CatalogItem(name: 'Pêras', emoji: '🍐', unit: 'kg'),
    ],
  ),
  CatalogCategory(
    name: 'Legumes',
    colorHex: '#1B8C5E',
    items: [
      CatalogItem(name: 'Tomates', emoji: '🍅', unit: 'kg'),
      CatalogItem(name: 'Alface', emoji: '🥬', unit: 'un'),
      CatalogItem(name: 'Cenouras', emoji: '🥕', unit: 'kg'),
      CatalogItem(name: 'Batatas', emoji: '🥔', unit: 'kg'),
      CatalogItem(name: 'Cebolas', emoji: '🧅', unit: 'kg'),
      CatalogItem(name: 'Alho', emoji: '🧄', unit: 'un'),
      CatalogItem(name: 'Pepino', emoji: '🥒', unit: 'un'),
      CatalogItem(name: 'Brócolos', emoji: '🥦', unit: 'un'),
    ],
  ),
  CatalogCategory(
    name: 'Lacticínios',
    colorHex: '#3D5A8A',
    items: [
      CatalogItem(name: 'Leite', emoji: '🥛', unit: 'L'),
      CatalogItem(name: 'Queijo', emoji: '🧀', unit: 'kg'),
      CatalogItem(name: 'Iogurte', emoji: '🍶', unit: 'un'),
      CatalogItem(name: 'Manteiga', emoji: '🧈', unit: 'un'),
      CatalogItem(name: 'Natas', emoji: '🥛', unit: 'L'),
    ],
  ),
  CatalogCategory(
    name: 'Carnes',
    colorHex: '#DC2626',
    items: [
      CatalogItem(name: 'Frango', emoji: '🍗', unit: 'kg'),
      CatalogItem(name: 'Carne Picada', emoji: '🥩', unit: 'kg'),
      CatalogItem(name: 'Bifes', emoji: '🥩', unit: 'kg'),
      CatalogItem(name: 'Salsichas', emoji: '🌭', unit: 'un'),
    ],
  ),
  CatalogCategory(
    name: 'Peixe & Mar',
    colorHex: '#0EA5E9',
    items: [
      CatalogItem(name: 'Bacalhau', emoji: '🐟', unit: 'kg'),
      CatalogItem(name: 'Salmão', emoji: '🐠', unit: 'kg'),
      CatalogItem(name: 'Sardinha em Lata', emoji: '🐟', unit: 'cx'),
      CatalogItem(name: 'Atum em Lata', emoji: '🐡', unit: 'cx'),
    ],
  ),
  CatalogCategory(
    name: 'Padaria',
    colorHex: '#F59E0B',
    items: [
      CatalogItem(name: 'Pão', emoji: '🍞', unit: 'un'),
      CatalogItem(name: 'Pão de Forma', emoji: '🍞', unit: 'un'),
      CatalogItem(name: 'Croissants', emoji: '🥐', unit: 'un'),
    ],
  ),
  CatalogCategory(
    name: 'Mercearia',
    colorHex: '#6B7280',
    items: [
      CatalogItem(name: 'Arroz', emoji: '🌾', unit: 'kg'),
      CatalogItem(name: 'Massa', emoji: '🍝', unit: 'un'),
      CatalogItem(name: 'Azeite', emoji: '🫒', unit: 'L'),
      CatalogItem(name: 'Sal', emoji: '🧂', unit: 'un'),
      CatalogItem(name: 'Açúcar', emoji: '🍚', unit: 'kg'),
      CatalogItem(name: 'Café', emoji: '☕', unit: 'un'),
      CatalogItem(name: 'Feijão', emoji: '🫘', unit: 'cx'),
      CatalogItem(name: 'Grão', emoji: '🫘', unit: 'cx'),
      CatalogItem(name: 'Tomate Pelado', emoji: '🍅', unit: 'cx'),
      CatalogItem(name: 'Farinha', emoji: '🌾', unit: 'kg'),
    ],
  ),
  CatalogCategory(
    name: 'Bebidas',
    colorHex: '#8B5CF6',
    items: [
      CatalogItem(name: 'Água', emoji: '💧', unit: 'L'),
      CatalogItem(name: 'Sumo de Laranja', emoji: '🍊', unit: 'L'),
      CatalogItem(name: 'Refrigerante', emoji: '🥤', unit: 'un'),
      CatalogItem(name: 'Cerveja', emoji: '🍺', unit: 'un'),
    ],
  ),
  CatalogCategory(
    name: 'Higiene',
    colorHex: '#EC4899',
    items: [
      CatalogItem(name: 'Champô', emoji: '🧴', unit: 'un'),
      CatalogItem(name: 'Gel de Banho', emoji: '🧴', unit: 'un'),
      CatalogItem(name: 'Pasta de Dentes', emoji: '🪥', unit: 'un'),
      CatalogItem(name: 'Papel Higiénico', emoji: '🧻', unit: 'un'),
      CatalogItem(name: 'Desodorizante', emoji: '🧴', unit: 'un'),
    ],
  ),
  CatalogCategory(
    name: 'Limpeza',
    colorHex: '#F97316',
    items: [
      CatalogItem(name: 'Detergente Roupa', emoji: '🧺', unit: 'un'),
      CatalogItem(name: 'Detergente Louça', emoji: '🫧', unit: 'un'),
      CatalogItem(name: 'Lixívia', emoji: '🧴', unit: 'un'),
      CatalogItem(name: 'Sacos do Lixo', emoji: '🗑️', unit: 'un'),
    ],
  ),
];
