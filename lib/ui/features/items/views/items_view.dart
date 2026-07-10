import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/ui/core/widgets/empty_state_widget.dart';
import 'package:lystra/ui/core/widgets/skeleton_list_tile.dart';
import 'package:lystra/ui/features/items/view_models/items_view_model.dart';
import 'package:lystra/ui/features/items/views/widgets/category_chip.dart';
import 'package:lystra/ui/features/items/views/widgets/item_form_bottom_sheet.dart';
import 'package:lystra/ui/features/items/views/widgets/list_item_row.dart';
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

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => ItemFormBottomSheet(
        categories: widget.viewModel.categories,
        onSubmit: (name, categoryId, unit) async {
          await widget.viewModel.createItem(name, categoryId, unit);
          if (mounted) Navigator.pop(context); // ignore: use_build_context_synchronously
        },
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
                title: const Text('Items'),
                floating: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(116),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
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
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
              _buildBody(vm),
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
          headline: vm.searchQuery.isEmpty
              ? 'Nenhum item ainda'
              : 'Sem resultados',
          subtext: vm.searchQuery.isEmpty
              ? 'Adiciona itens ao teu catálogo.'
              : 'Tenta outra pesquisa.',
          ctaLabel: vm.searchQuery.isEmpty ? 'Novo item' : null,
          onCta: vm.searchQuery.isEmpty ? _showCreateSheet : null,
        ),
      );
    }

    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final category = vm.categoryFor(item.categoryId);
        return ListItemRow(
          item: item,
          categoryName: category?.name,
          categoryColorHex: category?.colorHex,
          onDelete: () => _confirmDelete(item),
        );
      },
    );
  }

  void _confirmDelete(Item item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar item'),
        content: Text('Apagar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.viewModel.deleteItem(item.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }
}
