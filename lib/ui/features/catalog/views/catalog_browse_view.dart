import 'package:flutter/material.dart';
import 'package:lystra/core/di/service_locator.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/category_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/services/catalog_data.dart';
import 'package:lystra/ui/features/catalog/view_models/catalog_view_model.dart';

class CatalogBrowseView extends StatefulWidget {
  const CatalogBrowseView({super.key});

  @override
  State<CatalogBrowseView> createState() => _CatalogBrowseViewState();
}

class _CatalogBrowseViewState extends State<CatalogBrowseView> {
  late final CatalogViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = CatalogViewModel(
      itemRepository: sl<ItemRepository>(),
      categoryRepository: sl<CategoryRepository>(),
      authRepository: sl<AuthRepository>(),
    );
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('Catálogo'),
                actions: [
                  if (_vm.addedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: Chip(
                        avatar: Icon(Icons.check,
                            size: 16, color: scheme.onPrimary),
                        label: Text('${_vm.addedCount} adicionados',
                            style: textTheme.labelSmall
                                ?.copyWith(color: scheme.onPrimary)),
                        backgroundColor: scheme.primary,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),

              // Category filter chips
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryFilterDelegate(
                  categories: _vm.categories,
                  selectedIndex: _vm.selectedCategoryIndex,
                  onSelect: _vm.selectCategory,
                  surfaceColor: scheme.surface,
                ),
              ),

              if (_vm.state == CatalogLoadState.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_vm.state == CatalogLoadState.error)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: AppSpacing.md),
                        Text('Erro ao carregar catálogo',
                            style: textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton(
                          onPressed: _vm.load,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._buildCatalogSections(context, scheme, textTheme),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildCatalogSections(
      BuildContext context, ColorScheme scheme, TextTheme textTheme) {
    final slivers = <Widget>[];

    for (final cat in _vm.filteredCategories) {
      final catColor = _hexColor(cat.colorHex) ?? scheme.primary;
      final allOwned = cat.items.every((i) => _vm.isOwned(i.name));
      final anyAdding = cat.items.any((i) => _vm.isAdding(i.name));

      // Category header
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.lg, AppSpacing.sm, AppSpacing.xs),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: catColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  cat.name,
                  style: textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (allOwned)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        size: 16, color: scheme.primary),
                    const SizedBox(width: 4),
                    Text('Todos adicionados',
                        style: textTheme.labelSmall
                            ?.copyWith(color: scheme.primary)),
                  ],
                )
              else
                TextButton.icon(
                  onPressed:
                      anyAdding ? null : () => _vm.addCategory(cat),
                  icon: anyAdding
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: scheme.primary))
                      : const Icon(Icons.add, size: 16),
                  label: const Text('Adicionar todos'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ),
      ));

      // Items in this category
      slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final item = cat.items[i];
            final owned = _vm.isOwned(item.name);
            final adding = _vm.isAdding(item.name);

            return _CatalogItemTile(
              item: item,
              catColor: catColor,
              owned: owned,
              adding: adding,
              onAdd: owned || adding
                  ? null
                  : () => _vm.addItem(item, cat),
            );
          },
          childCount: cat.items.length,
        ),
      ));
    }

    return slivers;
  }

  Color? _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }
}

class _CatalogItemTile extends StatelessWidget {
  const _CatalogItemTile({
    required this.item,
    required this.catColor,
    required this.owned,
    required this.adding,
    required this.onAdd,
  });

  final CatalogItem item;
  final Color catColor;
  final bool owned;
  final bool adding;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 0),
      leading: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
        ),
      ),
      title: Text(
        item.name,
        style: textTheme.titleMedium?.copyWith(
          color: owned ? scheme.onSurfaceVariant : scheme.onSurface,
        ),
      ),
      subtitle: Text(
        item.unit,
        style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      trailing: owned
          ? Icon(Icons.check_circle, color: scheme.primary, size: 22)
          : adding
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: scheme.primary))
              : FilledButton.tonal(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Adicionar'),
                ),
    );
  }
}

// Pinned header for category filter chips
class _CategoryFilterDelegate extends SliverPersistentHeaderDelegate {
  _CategoryFilterDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
    required this.surfaceColor,
  });

  final List<CatalogCategory> categories;
  final int? selectedIndex;
  final void Function(int?) onSelect;
  final Color surfaceColor;

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: surfaceColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        children: [
          _FilterChip(
            label: 'Todos',
            selected: selectedIndex == null,
            onTap: () => onSelect(null),
          ),
          ...categories.asMap().entries.map((e) => _FilterChip(
                label: e.value.name,
                colorHex: e.value.colorHex,
                selected: selectedIndex == e.key,
                onTap: () => onSelect(e.key),
              )),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryFilterDelegate old) =>
      old.selectedIndex != selectedIndex;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.colorHex,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? colorHex;

  Color? get _color {
    if (colorHex == null) return null;
    try {
      return Color(int.parse(colorHex!.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _color ?? scheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        avatar: colorHex != null
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        showCheckmark: colorHex == null,
      ),
    );
  }
}
