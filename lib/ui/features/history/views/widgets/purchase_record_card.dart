import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/purchase_record.dart';

class PurchaseRecordCard extends StatefulWidget {
  const PurchaseRecordCard({
    super.key,
    required this.record,
    required this.onDelete,
  });

  final PurchaseRecord record;
  final VoidCallback onDelete;

  @override
  State<PurchaseRecordCard> createState() => _PurchaseRecordCardState();
}

class _PurchaseRecordCardState extends State<PurchaseRecordCard> {
  bool _isExpanded = false;

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
        tilePadding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.xs,
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        onExpansionChanged: (v) => setState(() => _isExpanded = v),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            Icons.receipt_long_outlined,
            color: scheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          widget.record.listName,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${_formatDate(widget.record.completedAt)} · ${widget.record.entries.length} ${widget.record.entries.length == 1 ? 'item' : 'items'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete_outline, color: scheme.error, size: 20),
              onPressed: widget.onDelete,
              visualDensity: VisualDensity.compact,
              tooltip: 'Apagar registo',
            ),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        children:
            widget.record.entries.map((e) => _EntryRow(entry: e)).toList(),
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
          Icon(Icons.circle, size: 6, color: scheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(entry.itemName, style: theme.textTheme.bodyMedium),
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
