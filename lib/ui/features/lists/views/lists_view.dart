import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/shopping_list.dart';
import 'package:lystra/ui/core/widgets/empty_state_widget.dart';
import 'package:lystra/ui/core/widgets/skeleton_list_tile.dart';
import 'package:lystra/ui/features/lists/view_models/lists_view_model.dart';
import 'package:lystra/ui/features/lists/views/widgets/list_form_bottom_sheet.dart';
import 'package:lystra/ui/features/lists/views/widgets/shopping_list_card.dart';

class ListsView extends StatefulWidget {
  const ListsView({super.key, required this.viewModel});

  final ListsViewModel viewModel;

  @override
  State<ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<ListsView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadLists();
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => ListFormBottomSheet(
        onSubmit: (name) async {
          final list = await widget.viewModel.createList(name);
          if (list != null && mounted) {
            Navigator.pop(context); // ignore: use_build_context_synchronously
          }
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
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('As minhas listas'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showCreateSheet,
                    tooltip: 'Nova lista',
                  ),
                ],
              ),
              _buildBody(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        icon: const Icon(Icons.add),
        label: const Text('Nova lista'),
      ),
    );
  }

  Widget _buildBody() {
    final vm = widget.viewModel;

    if (vm.state == ViewState.loading || vm.state == ViewState.initial) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const SkeletonCard(),
          childCount: 4,
        ),
      );
    }

    if (vm.state == ViewState.error) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.error_outline,
          headline: 'Algo correu mal',
          subtext: vm.errorMessage ?? 'Tenta novamente.',
          ctaLabel: 'Tentar novamente',
          onCta: vm.loadLists,
        ),
      );
    }

    if (vm.lists.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.shopping_cart_outlined,
          headline: 'Nenhuma lista ainda',
          subtext: 'Cria a tua primeira lista de compras.',
          ctaLabel: 'Nova lista',
          onCta: _showCreateSheet,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverList.separated(
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.sm),
        itemCount: vm.lists.length,
        itemBuilder: (_, i) {
          final list = vm.lists[i];
          return ShoppingListCard(
            shoppingList: list,
            totalCount: vm.totalCountFor(list.id),
            checkedCount: vm.checkedCountFor(list.id),
            onTap: () => context.go('/lists/${list.id}/shop'),
            onDelete: () => _confirmDelete(list),
            onRename: () => _showRenameSheet(list),
          );
        },
      ),
    );
  }

  void _confirmDelete(ShoppingList list) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar lista'),
        content: Text('Tens a certeza que queres apagar "${list.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.viewModel.deleteList(list.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

  void _showRenameSheet(ShoppingList list) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => ListFormBottomSheet(
        initialName: list.name,
        onSubmit: (name) async {
          await widget.viewModel.renameList(list, name);
          if (mounted) Navigator.pop(context); // ignore: use_build_context_synchronously
        },
      ),
    );
  }
}
