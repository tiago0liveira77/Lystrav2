class TemplateItem {
  const TemplateItem({
    required this.name,
    required this.emoji,
    required this.unit,
  });
  final String name;
  final String emoji;
  final String unit;
}

class TemplateCategory {
  const TemplateCategory({
    required this.name,
    required this.colorHex,
    required this.items,
  });
  final String name;
  final String colorHex;
  final List<TemplateItem> items;
}

class ListTemplate {
  const ListTemplate({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.categories,
  });
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<TemplateCategory> categories;

  int get totalItems =>
      categories.fold(0, (sum, c) => sum + c.items.length);
}

const listTemplates = [
  ListTemplate(
    id: 'camping',
    name: 'Campismo',
    emoji: '⛺',
    description: 'Tudo para uma escapadela ao ar livre',
    categories: [
      TemplateCategory(
        name: 'Abrigo',
        colorHex: '#8B5CF6',
        items: [
          TemplateItem(name: 'Tenda', emoji: '⛺', unit: 'un'),
          TemplateItem(name: 'Base do chão', emoji: '🟫', unit: 'un'),
          TemplateItem(name: 'Estacas', emoji: '📍', unit: 'cx'),
          TemplateItem(name: 'Martelo', emoji: '🔨', unit: 'un'),
          TemplateItem(name: 'Cordas', emoji: '🪢', unit: 'un'),
          TemplateItem(name: 'Colchão insuflável', emoji: '💨', unit: 'un'),
          TemplateItem(name: 'Colchão dobrável', emoji: '🛏️', unit: 'un'),
          TemplateItem(name: 'Saco de cama', emoji: '😴', unit: 'un'),
          TemplateItem(name: 'Colchonete', emoji: '🛏️', unit: 'un'),
          TemplateItem(name: 'Almofada', emoji: '🛌', unit: 'un'),
        ],
      ),
      TemplateCategory(
        name: 'Cozinha de Campismo',
        colorHex: '#F59E0B',
        items: [
          TemplateItem(name: 'Campingaz', emoji: '🔥', unit: 'un'),
          TemplateItem(name: 'Gás', emoji: '⛽', unit: 'un'),
          TemplateItem(name: 'Tacho', emoji: '🫕', unit: 'un'),
          TemplateItem(name: 'Pratos', emoji: '🍽️', unit: 'cx'),
          TemplateItem(name: 'Talheres', emoji: '🍴', unit: 'cx'),
          TemplateItem(name: 'Copos', emoji: '🥤', unit: 'cx'),
          TemplateItem(name: 'Guardanapos', emoji: '🧻', unit: 'cx'),
          TemplateItem(name: 'Panos de cozinha', emoji: '🧺', unit: 'un'),
          TemplateItem(name: 'Esponja', emoji: '🧽', unit: 'un'),
          TemplateItem(name: 'Detergente loiça', emoji: '🫧', unit: 'un'),
          TemplateItem(name: 'Isqueiro', emoji: '🔥', unit: 'un'),
          TemplateItem(name: 'Geleira', emoji: '❄️', unit: 'un'),
          TemplateItem(name: 'Sacos do lixo', emoji: '🗑️', unit: 'un'),
          TemplateItem(name: 'Garrafas de água', emoji: '💧', unit: 'cx'),
          TemplateItem(name: 'Tesoura', emoji: '✂️', unit: 'un'),
          TemplateItem(name: 'Facas', emoji: '🔪', unit: 'cx'),
          TemplateItem(name: 'Pinças', emoji: '🪝', unit: 'un'),
          TemplateItem(name: 'Grelha', emoji: '🔥', unit: 'un'),
          TemplateItem(name: 'Acendalhas', emoji: '🪵', unit: 'cx'),
          TemplateItem(name: 'Panos da grelha', emoji: '🧺', unit: 'un'),
        ],
      ),
      TemplateCategory(
        name: 'Higiene',
        colorHex: '#EC4899',
        items: [
          TemplateItem(name: 'Escova de dentes', emoji: '🪥', unit: 'un'),
          TemplateItem(name: 'Pasta de dentes', emoji: '🪥', unit: 'un'),
          TemplateItem(name: 'Escova de cabelo', emoji: '💆', unit: 'un'),
          TemplateItem(name: 'Champô', emoji: '🧴', unit: 'un'),
          TemplateItem(name: 'Gel de banho', emoji: '🧴', unit: 'un'),
          TemplateItem(name: 'Creme pós-sol', emoji: '🧴', unit: 'un'),
          TemplateItem(name: 'Repelente', emoji: '🦟', unit: 'un'),
          TemplateItem(name: 'Sabão das mãos', emoji: '🧼', unit: 'un'),
          TemplateItem(name: 'Toalha', emoji: '🏊', unit: 'un'),
          TemplateItem(name: 'Papel higiénico', emoji: '🧻', unit: 'un'),
        ],
      ),
      TemplateCategory(
        name: 'Equipamento',
        colorHex: '#374151',
        items: [
          TemplateItem(name: 'Lanterna', emoji: '🔦', unit: 'un'),
          TemplateItem(name: 'Pilhas', emoji: '🔋', unit: 'cx'),
          TemplateItem(name: 'Canivete', emoji: '🔪', unit: 'un'),
          TemplateItem(name: 'Kit de primeiros socorros', emoji: '🩹', unit: 'un'),
          TemplateItem(name: 'Power bank', emoji: '🔋', unit: 'un'),
          TemplateItem(name: 'Carregadores', emoji: '🔌', unit: 'cx'),
          TemplateItem(name: 'Cabo arranque carro', emoji: '🚗', unit: 'un'),
          TemplateItem(name: 'Adaptador geleira', emoji: '🔌', unit: 'un'),
          TemplateItem(name: 'Caixa de ferramentas', emoji: '🧰', unit: 'un'),
          TemplateItem(name: 'Extensão elétrica', emoji: '🔌', unit: 'un'),
        ],
      ),
      TemplateCategory(
        name: 'Vestuário e Lazer',
        colorHex: '#6366F1',
        items: [
          TemplateItem(name: 'Mochila pequena', emoji: '🎒', unit: 'un'),
          TemplateItem(name: 'Ventoinha portátil', emoji: '🌬️', unit: 'un'),
          TemplateItem(name: 'Comprimidos', emoji: '💊', unit: 'cx'),
          TemplateItem(name: 'Roupa', emoji: '👕', unit: 'cx'),
          TemplateItem(name: 'Sacos de roupa suja', emoji: '👜', unit: 'un'),
          TemplateItem(name: 'Casacos', emoji: '🧥', unit: 'un'),
          TemplateItem(name: 'Mesa de campismo', emoji: '🪑', unit: 'un'),
          TemplateItem(name: 'Cadeiras de campismo', emoji: '🪑', unit: 'cx'),
          TemplateItem(name: 'Corda de estender', emoji: '🪢', unit: 'un'),
          TemplateItem(name: 'Molas', emoji: '📎', unit: 'cx'),
          TemplateItem(name: 'Vassoura e pá', emoji: '🧹', unit: 'un'),
          TemplateItem(name: 'Cartas de jogar', emoji: '🃏', unit: 'cx'),
          TemplateItem(name: 'Livros', emoji: '📚', unit: 'un'),
          TemplateItem(name: 'Marcadores', emoji: '🖊️', unit: 'cx'),
          TemplateItem(name: 'Lápis, borracha e caneta', emoji: '✏️', unit: 'cx'),
        ],
      ),
      TemplateCategory(
        name: 'Praia',
        colorHex: '#0EA5E9',
        items: [
          TemplateItem(name: 'Protetor solar', emoji: '☀️', unit: 'un'),
          TemplateItem(name: 'Toalhas de praia', emoji: '🏖️', unit: 'un'),
          TemplateItem(name: 'Boné', emoji: '🧢', unit: 'un'),
          TemplateItem(name: 'Chinelos', emoji: '👡', unit: 'un'),
          TemplateItem(name: 'Biquíni', emoji: '👙', unit: 'un'),
          TemplateItem(name: 'Calções de banho', emoji: '🩲', unit: 'un'),
        ],
      ),
      TemplateCategory(
        name: 'Alimentação',
        colorHex: '#2D9B4E',
        items: [
          TemplateItem(name: 'Massa', emoji: '🍝', unit: 'un'),
          TemplateItem(name: 'Bolachas', emoji: '🍪', unit: 'cx'),
          TemplateItem(name: 'Sumos', emoji: '🥤', unit: 'L'),
          TemplateItem(name: 'Limão', emoji: '🍋', unit: 'un'),
          TemplateItem(name: 'Leite', emoji: '🥛', unit: 'L'),
          TemplateItem(name: 'Gelo', emoji: '🧊', unit: 'cx'),
          TemplateItem(name: 'Água com gás', emoji: '💧', unit: 'L'),
          TemplateItem(name: 'Atum em lata', emoji: '🐡', unit: 'cx'),
          TemplateItem(name: 'Salsichas', emoji: '🌭', unit: 'un'),
          TemplateItem(name: 'Batatas', emoji: '🥔', unit: 'kg'),
          TemplateItem(name: 'Snacks de milho', emoji: '🌽', unit: 'cx'),
          TemplateItem(name: 'Cereais', emoji: '🌾', unit: 'cx'),
          TemplateItem(name: 'Sal', emoji: '🧂', unit: 'un'),
          TemplateItem(name: 'Azeite', emoji: '🫒', unit: 'L'),
          TemplateItem(name: 'Carvão', emoji: '🪵', unit: 'cx'),
          TemplateItem(name: 'Água', emoji: '💧', unit: 'L'),
        ],
      ),
    ],
  ),
];
