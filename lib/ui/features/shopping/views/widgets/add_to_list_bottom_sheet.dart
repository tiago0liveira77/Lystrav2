import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/category.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/ui/core/widgets/empty_state_widget.dart';

class AddToListBottomSheet extends StatefulWidget {
  const AddToListBottomSheet({
    super.key,
    required this.availableItems,
    required this.categories,
    required this.onAdd,
  });

  final List<Item> availableItems;
  final List<Category> categories;
  final Future<void> Function(String itemId) onAdd;

  @override
  State<AddToListBottomSheet> createState() => _AddToListBottomSheetState();
}

class _AddToListBottomSheetState extends State<AddToListBottomSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  final Set<String> _adding = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Item> get _filtered {
    if (_query.isEmpty) return widget.availableItems;
    final q = _query.toLowerCase();
    return widget.availableItems
        .where((i) => i.name.toLowerCase().contains(q))
        .toList();
  }

  Category? _categoryFor(String categoryId) =>
      widget.categories.where((c) => c.id == categoryId).firstOrNull;

  Color? _colorFrom(String? hex) {
    if (hex == null) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  Future<void> _add(Item item) async {
    if (_adding.contains(item.id)) return;
    setState(() => _adding.add(item.id));
    await widget.onAdd(item.id);
    if (mounted) setState(() => _adding.remove(item.id));
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
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text('Adicionar à lista',
                      style: theme.textTheme.titleLarge),
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
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: items.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    headline: _query.isEmpty
                        ? 'Todos os items já estão na lista'
                        : 'Sem resultados',
                    subtext: _query.isEmpty
                        ? 'Cria novos items no separador Items.'
                        : 'Tenta outra pesquisa.',
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final category = _categoryFor(item.categoryId);
                      final dotColor =
                          _colorFrom(category?.colorHex) ?? scheme.primary;
                      final isAdding = _adding.contains(item.id);

                      return ListTile(
                        leading: item.emoji != null
                            ? Text(item.emoji!,
                                style: const TextStyle(fontSize: 22))
                            : CircleAvatar(
                                radius: 6,
                                backgroundColor: dotColor,
                              ),
                        title: Text(item.name,
                            style: theme.textTheme.titleMedium),
                        subtitle: Text(
                          category?.name ?? 'Sem categoria',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        trailing: isAdding
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                            : IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    color: scheme.primary),
                                onPressed: () => _add(item),
                              ),
                        onTap: () => _add(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
