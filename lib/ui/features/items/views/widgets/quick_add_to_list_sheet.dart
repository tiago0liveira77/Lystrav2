import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/domain/models/shopping_list.dart';
import 'package:lystra/ui/core/widgets/empty_state_widget.dart';

class QuickAddToListSheet extends StatefulWidget {
  const QuickAddToListSheet({
    super.key,
    required this.item,
    required this.getLists,
    required this.isInList,
    required this.onAdd,
  });

  final Item item;
  final Future<List<ShoppingList>> Function() getLists;
  final Future<bool> Function(String listId) isInList;
  final Future<void> Function(String listId) onAdd;

  @override
  State<QuickAddToListSheet> createState() => _QuickAddToListSheetState();
}

class _QuickAddToListSheetState extends State<QuickAddToListSheet> {
  List<ShoppingList>? _lists;
  final Map<String, bool> _inListStatus = {};
  final Set<String> _adding = {};
  final Set<String> _justAdded = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lists = await widget.getLists();
    if (!mounted) return;
    setState(() => _lists = lists);

    // Check status for each list in parallel
    await Future.wait(lists.map((list) async {
      final inList = await widget.isInList(list.id);
      if (mounted) setState(() => _inListStatus[list.id] = inList);
    }));
  }

  Future<void> _add(ShoppingList list) async {
    if (_adding.contains(list.id) || _inListStatus[list.id] == true) return;
    setState(() => _adding.add(list.id));
    await widget.onAdd(list.id);
    if (mounted) {
      setState(() {
        _adding.remove(list.id);
        _inListStatus[list.id] = true;
        _justAdded.add(list.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lists = _lists;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.sm, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Adicionar a lista',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.emoji != null
                            ? '${widget.item.emoji} ${widget.item.name}'
                            : widget.item.name,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (lists == null)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (lists.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: EmptyStateWidget(
                icon: Icons.shopping_cart_outlined,
                headline: 'Sem listas ativas',
                subtext: 'Cria uma lista primeiro.',
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lists.length,
                itemBuilder: (_, i) {
                  final list = lists[i];
                  final alreadyIn = _inListStatus[list.id] ?? false;
                  final isAdding = _adding.contains(list.id);
                  final justAdded = _justAdded.contains(list.id);

                  return ListTile(
                    leading: Icon(
                      alreadyIn
                          ? Icons.check_circle
                          : Icons.shopping_cart_outlined,
                      color: alreadyIn ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                    title: Text(list.name, style: theme.textTheme.titleMedium),
                    subtitle: alreadyIn
                        ? Text(
                            justAdded ? 'Adicionado!' : 'Já está nesta lista',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: justAdded ? scheme.primary : scheme.onSurfaceVariant,
                            ),
                          )
                        : null,
                    trailing: isAdding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : alreadyIn
                            ? null
                            : FilledButton.tonal(
                                onPressed: () => _add(list),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Adicionar'),
                              ),
                    onTap: alreadyIn ? null : () => _add(list),
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
