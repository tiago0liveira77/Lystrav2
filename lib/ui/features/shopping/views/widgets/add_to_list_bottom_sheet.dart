import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/category.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/domain/models/list_entry.dart';
import 'package:lystra/ui/core/widgets/empty_state_widget.dart';
import 'package:lystra/ui/features/items/views/widgets/item_form_bottom_sheet.dart';

class AddToListBottomSheet extends StatefulWidget {
  const AddToListBottomSheet({
    super.key,
    required this.allItems,
    required this.categories,
    required this.entryFor,
    required this.onAddOrIncrement,
    this.onCreateItem,
    this.onCreateCategory,
  });

  final List<Item> allItems;
  final List<Category> categories;
  final ListEntry? Function(String itemId) entryFor;
  final Future<void> Function(String itemId) onAddOrIncrement;
  // Optional item-creation callbacks; when provided, shows "create" affordances.
  final Future<Item?> Function(String name, String categoryId, String unit,
      String? emoji)? onCreateItem;
  final Future<Category?> Function(String name, String colorHex)?
      onCreateCategory;

  @override
  State<AddToListBottomSheet> createState() => _AddToListBottomSheetState();
}

class _AddToListBottomSheetState extends State<AddToListBottomSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  final Set<String> _pending = {};

  final Map<String, double> _localQty = {};
  final Set<String> _inList = {};
  // Items created inline during this session (not yet in widget.allItems)
  final List<Item> _extraItems = [];

  @override
  void initState() {
    super.initState();
    for (final item in widget.allItems) {
      final entry = widget.entryFor(item.id);
      if (entry != null) {
        _inList.add(item.id);
        _localQty[item.id] = entry.quantity;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Item> get _allItems => [...widget.allItems, ..._extraItems];

  List<Item> get _filtered {
    if (_query.isEmpty) return _allItems;
    final q = _query.toLowerCase();
    return _allItems.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  void _showCreateForm(BuildContext ctx) {
    FocusScope.of(ctx).unfocus();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => ItemFormBottomSheet(
        categories: widget.categories,
        onCreateCategory: widget.onCreateCategory,
        initialName: _query.isNotEmpty ? _query : null,
        onSubmit: (name, categoryId, unit, emoji) async {
          final item =
              await widget.onCreateItem!(name, categoryId, unit, emoji);
          if (item != null && mounted) {
            setState(() {
              _extraItems.add(item);
              _inList.add(item.id);
              _localQty[item.id] = 1;
            });
          }
          if (mounted) {
            Navigator.pop(ctx); // ignore: use_build_context_synchronously
          }
        },
      ),
    );
  }

  Category? _categoryFor(String catId) =>
      widget.categories.where((c) => c.id == catId).firstOrNull;

  Color? _colorFrom(String? hex) {
    if (hex == null) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  String _fmtQty(double qty) => qty == qty.truncateToDouble()
      ? qty.toInt().toString()
      : qty.toStringAsFixed(1);

  Future<void> _addOrIncrement(Item item) async {
    if (_pending.contains(item.id)) return;
    setState(() => _pending.add(item.id));
    try {
      await widget.onAddOrIncrement(item.id);
      if (mounted) {
        setState(() {
          if (_inList.contains(item.id)) {
            _localQty[item.id] = (_localQty[item.id] ?? 1) + 1;
          } else {
            _inList.add(item.id);
            _localQty[item.id] = 1;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _pending.remove(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final items = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
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
                  child: Text('Adicionar à lista',
                      style: theme.textTheme.titleLarge),
                ),
                if (widget.onCreateItem != null)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    tooltip: 'Criar novo item',
                    onPressed: () => _showCreateForm(context),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Pesquisar items...',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: items.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    headline: 'Sem resultados',
                    subtext: _query.isNotEmpty && widget.onCreateItem != null
                        ? 'Nenhum item com esse nome.'
                        : 'Tenta outra pesquisa.',
                    ctaLabel: _query.isNotEmpty && widget.onCreateItem != null
                        ? 'Criar "$_query"'
                        : null,
                    onCta: _query.isNotEmpty && widget.onCreateItem != null
                        ? () => _showCreateForm(context)
                        : null,
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final category = _categoryFor(item.categoryId);
                      final dotColor =
                          _colorFrom(category?.colorHex) ?? scheme.primary;
                      final isPending = _pending.contains(item.id);
                      final isInList = _inList.contains(item.id);
                      final qty = _localQty[item.id];

                      return ListTile(
                        leading: item.emoji != null
                            ? SizedBox(
                                width: 36,
                                child: Text(item.emoji!,
                                    style: const TextStyle(fontSize: 22),
                                    textAlign: TextAlign.center),
                              )
                            : CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    dotColor.withValues(alpha: 0.18),
                                child: Text(
                                  item.name.isNotEmpty
                                      ? item.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: dotColor),
                                ),
                              ),
                        title: Text(item.name,
                            style: theme.textTheme.titleMedium),
                        subtitle: Text(
                          '${category?.name ?? 'Sem categoria'} · ${item.unit}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Quantity badge (fixed width for alignment)
                            SizedBox(
                              width: 64,
                              child: isInList && qty != null
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: 3),
                                      decoration: BoxDecoration(
                                        color: scheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.full),
                                      ),
                                      child: Text(
                                        '${_fmtQty(qty)} ${item.unit}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: scheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : null,
                            ),
                            // Add/increment button
                            isPending
                                ? const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(
                                      isInList
                                          ? Icons.add_circle
                                          : Icons.add_circle_outline,
                                      color: scheme.primary,
                                    ),
                                    onPressed: () => _addOrIncrement(item),
                                  ),
                          ],
                        ),
                        onTap: isPending ? null : () => _addOrIncrement(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
