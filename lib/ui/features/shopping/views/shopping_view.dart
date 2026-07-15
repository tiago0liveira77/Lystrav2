import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lystra/core/di/service_locator.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/category_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/repositories/purchase_record_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/ui/core/widgets/skeleton_list_tile.dart';
import 'package:lystra/ui/features/shopping/view_models/shopping_view_model.dart';
import 'package:lystra/ui/features/shopping/views/widgets/add_to_list_bottom_sheet.dart';
import 'package:lystra/ui/features/shopping/views/widgets/shopping_item_row.dart';

class ShoppingView extends StatefulWidget {
  const ShoppingView({super.key, required this.listId, this.householdId});

  final String listId;
  final String? householdId;

  @override
  State<ShoppingView> createState() => _ShoppingViewState();
}

class _ShoppingViewState extends State<ShoppingView> {
  late final ShoppingViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ShoppingViewModel(
      listId: widget.listId,
      householdId: widget.householdId,
      entryRepository: sl<ListEntryRepository>(),
      listRepository: sl<ShoppingListRepository>(),
      itemRepository: sl<ItemRepository>(),
      authRepository: sl<AuthRepository>(),
      purchaseRecordRepository: sl<PurchaseRecordRepository>(),
      categoryRepository: sl<CategoryRepository>(),
    );
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _confirmFinish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Terminar compras'),
        content: const Text(
            'Marca esta lista como concluída e guarda o histórico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Terminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await _vm.finishShopping();
      if (success && mounted) context.go('/lists');
    }
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddToListBottomSheet(
        allItems: _vm.allItems,
        categories: _vm.categories,
        entryFor: _vm.entryForItem,
        onAddOrIncrement: _vm.addOrIncrement,
        onCreateItem: _vm.createItemAndAdd,
        onCreateCategory: _vm.createCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: Text(_vm.list?.name ?? ''),
                actions: [
                  if (!_vm.isLoading && _vm.entries.isNotEmpty)
                    FilledButton.icon(
                      onPressed: _vm.isFinishing ? null : _confirmFinish,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Terminar'),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                bottom: _vm.isLoading
                    ? null
                    : PreferredSize(
                        preferredSize: const Size.fromHeight(20),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(end: _vm.progress),
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => LinearProgressIndicator(
                                value: v,
                                minHeight: 6,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              if (_vm.isLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const SkeletonListTile(),
                    childCount: 6,
                  ),
                )
              else
                _buildItemList(),
              if (_vm.checkedEntries.isNotEmpty) _buildCheckedSection(),
              const SliverToBoxAdapter(
                child: SizedBox(height: 96),
              ),
            ],
          ),
          floatingActionButton: _vm.isLoading
              ? null
              : FloatingActionButton.extended(
                  onPressed: _showAddItemSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar item'),
                ),
        );
      },
    );
  }

  Widget _buildItemList() {
    final byCategory = _vm.entriesByCategory;
    if (byCategory.isEmpty && _vm.checkedEntries.isEmpty) {
      return SliverFillRemaining(
        key: const ValueKey('shopping-empty'),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64),
              const SizedBox(height: AppSpacing.md),
              Text('Lista vazia',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Toca em "Adicionar item" para começar.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    // Build a flat list of widgets with stable keys for all elements
    final children = <Widget>[];
    for (final catId in byCategory.keys) {
      final catName = catId == 'uncategorized'
          ? 'Sem categoria'
          : (_vm.categoryFor(catId)?.name ?? 'Sem categoria');

      children.add(Padding(
        key: ValueKey('hdr-$catId'),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
        child: Text(
          catName,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ));

      for (final entry in byCategory[catId]!) {
        final item = _vm.itemFor(entry.itemId);
        if (item == null) continue;
        children.add(ShoppingItemRow(
          key: ValueKey(entry.id),
          entry: entry,
          item: item,
          onToggle: () => _vm.toggleEntry(entry.id),
          onRemove: () => _vm.removeEntry(entry.id),
          onIncrease: () => _vm.updateQuantity(entry.id, entry.quantity + 1),
          categoryColorHex: _vm.categoryFor(item.categoryId)?.colorHex,
        ));
      }
    }

    return SliverList(
      key: const ValueKey('shopping-list'),
      delegate: SliverChildListDelegate(children),
    );
  }

  Widget _buildCheckedSection() {
    final checked = _vm.checkedEntries
        .where((e) => _vm.itemFor(e.itemId) != null)
        .toList();
    return SliverToBoxAdapter(
      child: ExpansionTile(
        title: Text(
          'Marcados (${_vm.checkedEntries.length})',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        initiallyExpanded: false,
        children: checked.map((entry) {
          final item = _vm.itemFor(entry.itemId)!;
          return ShoppingItemRow(
            key: ValueKey('checked_${entry.id}'),
            entry: entry,
            item: item,
            onToggle: () => _vm.toggleEntry(entry.id),
            onRemove: () => _vm.removeEntry(entry.id),
            onIncrease: () =>
                _vm.updateQuantity(entry.id, entry.quantity + 1),
            categoryColorHex: _vm.categoryFor(item.categoryId)?.colorHex,
          );
        }).toList(),
      ),
    );
  }
}
