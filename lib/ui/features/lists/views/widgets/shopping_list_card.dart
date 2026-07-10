import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/shopping_list.dart';

class ShoppingListCard extends StatelessWidget {
  const ShoppingListCard({
    super.key,
    required this.shoppingList,
    required this.onTap,
    this.checkedCount = 0,
    this.totalCount = 0,
    this.onDelete,
    this.onRename,
  });

  final ShoppingList shoppingList;
  final VoidCallback onTap;
  final int checkedCount;
  final int totalCount;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  double get _progress =>
      totalCount == 0 ? 0 : checkedCount / totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shoppingList.name,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onDelete != null || onRename != null)
                    PopupMenuButton<_Action>(
                      onSelected: (action) {
                        if (action == _Action.rename) onRename?.call();
                        if (action == _Action.delete) onDelete?.call();
                      },
                      itemBuilder: (_) => [
                        if (onRename != null)
                          const PopupMenuItem(
                            value: _Action.rename,
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Renomear'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: _Action.delete,
                            child: ListTile(
                              leading: Icon(Icons.delete_outline,
                                  color: scheme.error),
                              title: Text('Apagar',
                                  style: TextStyle(color: scheme.error)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              if (totalCount > 0) ...[
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _progress),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => LinearProgressIndicator(
                      value: value,
                      backgroundColor: scheme.surfaceContainerHighest,
                      valueColor:
                          AlwaysStoppedAnimation(scheme.primary),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$checkedCount de $totalCount items',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ] else
                Text(
                  'Lista vazia — adiciona items',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Action { rename, delete }
