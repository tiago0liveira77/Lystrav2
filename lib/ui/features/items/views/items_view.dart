import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/ui/core/widgets/empty_state_widget.dart';
import 'package:lystra/ui/core/widgets/skeleton_list_tile.dart';
import 'package:lystra/ui/features/items/view_models/items_view_model.dart';
import 'package:lystra/ui/features/items/views/widgets/category_chip.dart';
import 'package:lystra/ui/features/items/views/widgets/item_form_bottom_sheet.dart';
import 'package:lystra/ui/features/items/views/widgets/list_item_row.dart';
import 'package:lystra/ui/features/items/views/widgets/quick_add_to_list_sheet.dart';
import 'package:lystra/ui/features/lists/view_models/lists_view_model.dart';

class ItemsView extends StatefulWidget {
  const ItemsView({super.key, required this.viewModel});

  final ItemsViewModel viewModel;

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  final _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Builds a flat list mixing String (letter headers) and Item objects
  List<dynamic> _buildAlphabeticalEntries(List<Item> items) {
    final result = <dynamic>[];
    String? lastLetter;
    for (final item in items) {
      final letter =
          item.name.isNotEmpty ? item.name[0].toUpperCase() : '#';
      if (letter != lastLetter) {
        result.add(letter);
        lastLetter = letter;
      }
      result.add(item);
    }
    return result;
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => ItemFormBottomSheet(
        categories: widget.viewModel.categories,
        onCreateCategory: (name, colorHex) =>
            widget.viewModel.createCategory(name, colorHex),
        onSubmit: (name, categoryId, unit, emoji) async {
          await widget.viewModel.createItem(name, categoryId, unit,
              emoji: emoji);
          if (mounted) Navigator.pop(context); // ignore: use_build_context_synchronously
        },
      ),
    );
  }

  void _showEditSheet(Item item) {
    final vm = widget.viewModel;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => ItemFormBottomSheet(
        categories: vm.categories,
        onCreateCategory: (name, colorHex) =>
            vm.createCategory(name, colorHex),
        initialName: item.name,
        initialCategoryId: item.categoryId,
        initialUnit: item.unit,
        initialEmoji: item.emoji,
        onSubmit: (name, categoryId, unit, emoji) async {
          await vm.updateItem(item.copyWith(
            name: name,
            categoryId: categoryId,
            unit: unit,
            emoji: emoji,
          ));
          if (mounted) Navigator.pop(context); // ignore: use_build_context_synchronously
        },
        extraActions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              vm.deleteItem(item.id);
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Apagar'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickAddSheet(Item item) {
    final vm = widget.viewModel;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => QuickAddToListSheet(
        item: item,
        getLists: vm.getActiveLists,
        isInList: (listId) => vm.isItemInList(item.id, listId),
        onAdd: (listId) => vm.addToList(item.id, listId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                toolbarHeight: 0,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(
                      vm.categories.isEmpty ? 72 : 112),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md, AppSpacing.sm, AppSpacing.md,
                            AppSpacing.xs),
                        child: SearchBar(
                          controller: _searchController,
                          hintText: 'Pesquisar items...',
                          leading: const Icon(Icons.search),
                          onChanged: vm.setSearchQuery,
                        ),
                      ),
                      if (vm.categories.isNotEmpty)
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md),
                            children: [
                              CategoryChipWidget(
                                label: 'Todos',
                                isSelected: vm.selectedCategoryId == null,
                                onTap: () => vm.setCategory(null),
                              ),
                              ...vm.categories.map(
                                (c) => CategoryChipWidget(
                                  label: c.name,
                                  colorHex: c.colorHex,
                                  isSelected: vm.selectedCategoryId == c.id,
                                  onTap: () => vm.setCategory(c.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ),
                ),
              ),
              _buildBody(vm),
              // Bottom FAB clearance
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        icon: const Icon(Icons.add),
        label: const Text('Novo item'),
      ),
    );
  }

  Widget _buildBody(ItemsViewModel vm) {
    if (vm.state == ViewState.loading || vm.state == ViewState.initial) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const SkeletonListTile(),
          childCount: 6,
        ),
      );
    }

    final items = vm.filteredItems;

    if (items.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          headline:
              vm.searchQuery.isEmpty ? 'Nenhum item ainda' : 'Sem resultados',
          subtext: vm.searchQuery.isEmpty
              ? 'Adiciona itens ao teu catálogo.'
              : 'Tenta outra pesquisa.',
          ctaLabel: vm.searchQuery.isEmpty ? 'Novo item' : null,
          onCta: vm.searchQuery.isEmpty ? _showCreateSheet : null,
        ),
      );
    }

    final entries = _buildAlphabeticalEntries(items);

    return SliverList.builder(
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final entry = entries[i];

        // Letter header
        if (entry is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
            child: Text(
              entry,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          );
        }

        // Item card
        final item = entry as Item;
        final category = vm.categoryFor(item.categoryId);
        return ListItemRow(
          key: ValueKey(item.id),
          item: item,
          categoryName: category?.name,
          categoryColorHex: category?.colorHex,
          onTap: () => _showEditSheet(item),
          onQuickAdd: () => _showQuickAddSheet(item),
        );
      },
    );
  }
}
