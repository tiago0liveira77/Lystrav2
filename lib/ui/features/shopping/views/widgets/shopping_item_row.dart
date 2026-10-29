import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/domain/models/list_entry.dart';

class ShoppingItemRow extends StatelessWidget {
  const ShoppingItemRow({
    super.key,
    required this.entry,
    required this.item,
    required this.onToggle,
    required this.onRemove,
    required this.onIncrease,
    this.categoryColorHex,
  });

  final ListEntry entry;
  final Item item;
  final VoidCallback onToggle;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final String? categoryColorHex;

  void _handleTap() {
    HapticFeedback.mediumImpact();
    onToggle();
  }

  void _handleIncrease() {
    HapticFeedback.lightImpact();
    onIncrease();
  }

  Color? get _categoryColor {
    if (categoryColorHex == null) return null;
    try {
      return Color(int.parse(categoryColorHex!.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  String _formatQty(double qty) {
    if (qty == qty.truncateToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(1);
  }

  Widget _buildContent(ColorScheme scheme, TextTheme textTheme, Color dotColor,
      bool isChecked) {
    return Padding(
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
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              item.name,
              style: textTheme.titleMedium?.copyWith(color: scheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '${_formatQty(entry.quantity)} ${item.unit}',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: _handleIncrease,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 16, color: scheme.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isChecked ? scheme.primary : scheme.outline,
            size: 26,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dotColor = _categoryColor ?? scheme.primary;
    final isChecked = entry.isChecked;

    // Checked: sem Dismissible nem InkWell, e com ColoredBox explícito
    // para sobrepor o fundo cinzento que o ExpansionTile do MIUI/Samsung
    // aplica aos seus filhos.
    if (isChecked) {
      return GestureDetector(
        onTap: _handleTap,
        child: ColoredBox(
          color: scheme.surface,
          child: SizedBox(
            height: 64,
            child: _buildContent(scheme, textTheme, dotColor, isChecked),
          ),
        ),
      );
    }

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        color: scheme.primaryContainer,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: scheme.primary, size: 22),
            const SizedBox(width: 4),
            Text('+1',
                style: textTheme.labelLarge?.copyWith(color: scheme.primary)),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: scheme.errorContainer,
        child: Icon(Icons.delete_outline, color: scheme.error),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _handleIncrease();
        } else {
          onRemove();
        }
        return false;
      },
      child: ColoredBox(
        color: scheme.surface,
        child: SizedBox(
          height: 64,
          child: InkWell(
            onTap: _handleTap,
            child: _buildContent(scheme, textTheme, dotColor, isChecked),
          ),
        ),
      ),
    );
  }
}
