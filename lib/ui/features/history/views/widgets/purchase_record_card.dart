import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/purchase_record.dart';

class PurchaseRecordCard extends StatelessWidget {
  const PurchaseRecordCard({super.key, required this.record});

  final PurchaseRecord record;

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            Icons.receipt_long_outlined,
            color: scheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          record.listName,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${_formatDate(record.completedAt)} · ${record.entries.length} ${record.entries.length == 1 ? 'item' : 'items'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        children: record.entries.map((entry) => _EntryRow(entry: entry)).toList(),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final PurchaseRecordEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final qty = entry.quantity == entry.quantity.truncateToDouble()
        ? entry.quantity.toInt().toString()
        : entry.quantity.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: scheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              entry.itemName,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '$qty ${entry.unit}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
