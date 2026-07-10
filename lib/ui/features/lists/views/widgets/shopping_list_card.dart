import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/shopping_list.dart';

class ShoppingListCard extends StatelessWidget {
  const ShoppingListCard({
    super.key,
    required this.shoppingList,
    required this.onTap,
    this.totalCount = 0,
    this.checkedCount = 0,
    this.onDelete,
    this.onRename,
  });

  final ShoppingList shoppingList;
  final VoidCallback onTap;
  final int totalCount;
  final int checkedCount;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  int get _remaining => totalCount - checkedCount;
  double get _progress => totalCount == 0 ? 0 : checkedCount / totalCount;

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays == 1) return 'ontem';
    if (diff.inDays < 7) return 'há ${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final updatedAt = shoppingList.updatedAt ?? shoppingList.createdAt;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      shoppingList.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onDelete != null || onRename != null)
                    PopupMenuButton<_Action>(
                      icon: Icon(Icons.more_vert,
                          color: scheme.onSurfaceVariant, size: 20),
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

              // Thin progress bar (only when items are checked)
              if (totalCount > 0 && checkedCount > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: _progress),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 3,
                      backgroundColor: scheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(scheme.primary),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.sm),

              // Meta row
              Row(
                children: [
                  Text(
                    totalCount == 0
                        ? 'Lista vazia'
                        : '$totalCount ${totalCount == 1 ? 'item' : 'itens'} · $_remaining por comprar',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _relativeTime(updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Action { rename, delete }
