import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/item.dart';

class ListItemRow extends StatelessWidget {
  const ListItemRow({
    super.key,
    required this.item,
    this.categoryName,
    this.categoryColorHex,
    this.onTap,
    this.onQuickAdd,
  });

  final Item item;
  final String? categoryName;
  final String? categoryColorHex;
  final VoidCallback? onTap;
  final VoidCallback? onQuickAdd;

  Color _bgColor(BuildContext context) {
    if (categoryColorHex != null) {
      try {
        return Color(int.parse(categoryColorHex!.replaceFirst('#', '0xFF')))
            .withValues(alpha: 0.18);
      } catch (_) {}
    }
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  Color _fgColor(BuildContext context) {
    if (categoryColorHex != null) {
      try {
        return Color(int.parse(categoryColorHex!.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              // Emoji avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _bgColor(context),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: item.emoji != null && item.emoji!.isNotEmpty
                      ? Text(item.emoji!,
                          style: const TextStyle(fontSize: 22))
                      : Text(
                          item.name.isNotEmpty
                              ? item.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _fgColor(context),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Name + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${categoryName ?? 'Sem categoria'} · ${item.unit}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Quick-add button
              if (onQuickAdd != null)
                IconButton(
                  onPressed: onQuickAdd,
                  icon: Icon(Icons.playlist_add,
                      color: scheme.onSurfaceVariant, size: 22),
                  tooltip: 'Adicionar a lista',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
