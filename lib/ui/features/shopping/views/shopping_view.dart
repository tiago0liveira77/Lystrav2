import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lystra/core/di/service_locator.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/ui/core/widgets/skeleton_list_tile.dart';
import 'package:lystra/ui/features/shopping/view_models/shopping_view_model.dart';
import 'package:lystra/ui/features/shopping/views/widgets/shopping_item_row.dart';

class ShoppingView extends StatefulWidget {
  const ShoppingView({super.key, required this.listId});

  final String listId;

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
      entryRepository: sl<ListEntryRepository>(),
      listRepository: sl<ShoppingListRepository>(),
      itemRepository: sl<ItemRepository>(),
      authRepository: sl<AuthRepository>(),
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
      builder: (_) => AlertDialog(
        title: const Text('Terminar compras'),
        content: const Text(
            'Marca esta lista como concluída e guarda o histórico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
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
                  onPressed: () => context.go('/lists'),
                ),
                title: Text(_vm.list?.name ?? ''),
                actions: [
                  if (_vm.isComplete)
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
              if (_vm.checkedEntries.isNotEmpty)
                _buildCheckedSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemList() {
    final byCategory = _vm.entriesByCategory;
    if (byCategory.isEmpty && _vm.checkedEntries.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Lista vazia',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      );
    }

    final categoryIds = byCategory.keys.toList();
    return SliverList.builder(
      itemCount: categoryIds.length,
      itemBuilder: (_, i) {
        final catId = categoryIds[i];
        final entries = byCategory[catId]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
              child: Text(
                catId == 'uncategorized' ? 'Sem categoria' : catId,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            ...entries.map((entry) {
              final item = _vm.itemFor(entry.itemId);
              if (item == null) return const SizedBox.shrink();
              return ShoppingItemRow(
                key: ValueKey(entry.id),
                entry: entry,
                item: item,
                onToggle: () => _vm.toggleEntry(entry.id),
                onRemove: () => _vm.removeEntry(entry.id),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCheckedSection() {
    return SliverToBoxAdapter(
      child: ExpansionTile(
        title: Text(
          'Marcados (${_vm.checkedEntries.length})',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        initiallyExpanded: false,
        children: _vm.checkedEntries.map((entry) {
          final item = _vm.itemFor(entry.itemId);
          if (item == null) return const SizedBox.shrink();
          return ShoppingItemRow(
            key: ValueKey('checked_${entry.id}'),
            entry: entry,
            item: item,
            onToggle: () => _vm.toggleEntry(entry.id),
            onRemove: () => _vm.removeEntry(entry.id),
          );
        }).toList(),
      ),
    );
  }
}
