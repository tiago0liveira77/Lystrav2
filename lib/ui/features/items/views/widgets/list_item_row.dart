import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/item.dart';

class ListItemRow extends StatelessWidget {
  const ListItemRow({
    super.key,
    required this.item,
    this.categoryName,
    this.categoryColorHex,
    this.onDelete,
    this.trailing,
  });

  final Item item;
  final String? categoryName;
  final String? categoryColorHex;
  final VoidCallback? onDelete;
  final Widget? trailing;

  Color? get _categoryColor {
    if (categoryColorHex == null) return null;
    try {
      return Color(int.parse(categoryColorHex!.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _categoryColor ?? scheme.primary;

    Widget tile = SizedBox(
      height: categoryName != null ? 64 : 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            item.emoji != null
                ? SizedBox(
                    width: 28,
                    child: Text(item.emoji!,
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center),
                  )
                : Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (categoryName != null)
                    Text(
                      categoryName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );

    if (onDelete != null) {
      tile = Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          color: scheme.errorContainer,
          child: Icon(Icons.delete_outline, color: scheme.error),
        ),
        confirmDismiss: (_) async {
          onDelete!();
          return false;
        },
        child: tile,
      );
    }

    return tile;
  }
}
