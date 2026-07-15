import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/data/services/list_templates_data.dart';
import 'package:lystra/domain/models/shopping_list.dart';
import 'package:lystra/ui/core/widgets/empty_state_widget.dart';
import 'package:lystra/ui/core/widgets/skeleton_list_tile.dart';
import 'package:lystra/ui/features/lists/view_models/lists_view_model.dart';
import 'package:lystra/ui/features/lists/views/widgets/list_form_bottom_sheet.dart';
import 'package:lystra/ui/features/lists/views/widgets/shopping_list_card.dart';
import 'package:lystra/ui/features/lists/views/widgets/template_picker_sheet.dart';

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

  @override
  void didUpdateWidget(ListsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      widget.viewModel.loadLists();
    }
  }

  void _showCreateSheet({bool household = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => ListFormBottomSheet(
        title: household ? 'Nova lista partilhada' : 'Nova lista',
        onSubmit: (name) async {
          final list = household
              ? await widget.viewModel.createHouseholdList(name)
              : await widget.viewModel.createPersonalList(name);
          if (list != null && mounted) {
            Navigator.pop(context); // ignore: use_build_context_synchronously
          }
        },
      ),
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Lista pessoal'),
              subtitle: const Text('Só tu tens acesso'),
              onTap: () {
                Navigator.pop(context);
                _showCreateSheet();
              },
            ),
            if (widget.viewModel.isInHousehold)
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: const Text('Lista partilhada'),
                subtitle: const Text('Visível a todos no household'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateSheet(household: true);
                },
              ),
            ListTile(
              leading: const Icon(Icons.list_alt_rounded),
              title: const Text('A partir de modelo'),
              subtitle: const Text('Lista pré-definida com items incluídos'),
              onTap: () {
                Navigator.pop(context);
                _showTemplatePicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTemplatePicker() async {
    final template = await showModalBottomSheet<ListTemplate>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => const TemplatePickerSheet(),
    );
    if (template == null || !mounted) return;
    await _applyTemplate(template); // ignore: use_build_context_synchronously
  }

  Future<void> _applyTemplate(ListTemplate template) async {
    // The dialog is a StatefulWidget so it owns and disposes the controller
    // at the correct moment — avoids the use-after-dispose race with focus cleanup.
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _ListNameDialog(initialName: template.name),
    );
    if (name == null || name.isEmpty || !mounted) return;

    // Use a SnackBar (not a dialog) for the loading state so there is no
    // navigator route to pop before go_router navigates — avoids the race
    // that causes a black screen.
    // ignore: use_build_context_synchronously
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(minutes: 2),
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('A criar lista de ${template.name.toLowerCase()}...'),
          ],
        ),
      ),
    );

    final result = await widget.viewModel // ignore: use_build_context_synchronously
        .createListFromTemplate(name, template);

    messenger.hideCurrentSnackBar();
    if (!mounted) return;

    if (result == null) return;
    final (list, newItems) = result;
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newItems > 0
            ? 'Lista criada! $newItems items novos no catálogo'
            : 'Lista criada com ${template.totalItems} items'),
      ),
    );
    // ignore: use_build_context_synchronously
    context.push(_shopRoute(list));
  }

  String _shopRoute(ShoppingList list) {
    final base = '/lists/${list.id}/shop';
    return list.householdId != null ? '$base?hid=${list.householdId}' : base;
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
                    onPressed: _showCreateOptions,
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
        onPressed: _showCreateOptions,
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

    if (vm.allLists.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.shopping_cart_outlined,
          headline: 'Nenhuma lista ainda',
          subtext: 'Cria a tua primeira lista de compras.',
          ctaLabel: 'Nova lista',
          onCta: _showCreateOptions,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Personal lists
          if (vm.personalLists.isNotEmpty) ...[
            if (vm.isInHousehold)
              _SectionHeader(
                  Icons.person_outline, 'Pessoais'),
            ...vm.personalLists.map((list) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ShoppingListCard(
                    shoppingList: list,
                    totalCount: vm.totalCountFor(list.id),
                    checkedCount: vm.checkedCountFor(list.id),
                    onTap: () => context.push(_shopRoute(list)),
                    onDelete: () => _confirmDelete(list),
                    onRename: () => _showRenameSheet(list),
                  ),
                )),
          ],

          // Household lists
          if (vm.householdLists.isNotEmpty) ...[
            _SectionHeader(Icons.group_outlined, 'Partilhadas'),
            ...vm.householdLists.map((list) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ShoppingListCard(
                    shoppingList: list,
                    totalCount: vm.totalCountFor(list.id),
                    checkedCount: vm.checkedCountFor(list.id),
                    onTap: () => context.push(_shopRoute(list)),
                    onDelete: () => _confirmDelete(list),
                    onRename: () => _showRenameSheet(list),
                  ),
                )),
          ],
        ]),
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
              widget.viewModel.deleteList(list);
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
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

class _ListNameDialog extends StatefulWidget {
  const _ListNameDialog({required this.initialName});
  final String initialName;

  @override
  State<_ListNameDialog> createState() => _ListNameDialogState();
}

class _ListNameDialogState extends State<_ListNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova lista'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Nome da lista'),
        onSubmitted: (_) => Navigator.pop(context, _controller.text.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Criar'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs, AppSpacing.md, AppSpacing.xs, AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
