import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/category.dart';
import 'package:lystra/ui/core/widgets/lystra_bottom_sheet.dart';
import 'package:lystra/ui/features/items/views/widgets/category_form_bottom_sheet.dart';

class ItemFormBottomSheet extends StatefulWidget {
  const ItemFormBottomSheet({
    super.key,
    required this.categories,
    required this.onSubmit,
    this.onCreateCategory,
    this.initialName,
    this.initialCategoryId,
    this.initialUnit,
    this.initialEmoji,
    this.extraActions,
  });

  final List<Category> categories;
  final Future<void> Function(
      String name, String categoryId, String unit, String? emoji) onSubmit;
  final Future<Category?> Function(String name, String colorHex)?
      onCreateCategory;
  final String? initialName;
  final String? initialCategoryId;
  final String? initialUnit;
  final String? initialEmoji;
  final List<Widget>? extraActions;

  @override
  State<ItemFormBottomSheet> createState() => _ItemFormBottomSheetState();
}

class _ItemFormBottomSheetState extends State<ItemFormBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late List<Category> _categories;
  String? _selectedCategoryId;
  String _selectedUnit = 'un';

  static const _units = ['un', 'kg', 'g', 'L', 'mL', 'cx', 'dz'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emojiController = TextEditingController(text: widget.initialEmoji);
    _categories = List.of(widget.categories);
    _selectedCategoryId = widget.initialCategoryId ??
        (_categories.isNotEmpty ? _categories.first.id : null);
    _selectedUnit = widget.initialUnit ?? 'un';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final emoji = _emojiController.text.trim().isEmpty
        ? null
        : _emojiController.text.trim();
    try {
      await widget.onSubmit(
        _nameController.text.trim(),
        _selectedCategoryId ?? 'uncategorized',
        _selectedUnit,
        emoji,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCreateCategory() {
    if (widget.onCreateCategory == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (_) => CategoryFormBottomSheet(
        onSubmit: (name, colorHex) async {
          final created = await widget.onCreateCategory!(name, colorHex);
          if (created != null && mounted) {
            setState(() {
              _categories = [..._categories, created]
                ..sort((a, b) => a.name.compareTo(b.name));
              _selectedCategoryId = created.id;
            });
            Navigator.pop(context); // ignore: use_build_context_synchronously
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainButton = FilledButton(
      onPressed: _isLoading ? null : _submit,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : Text(widget.initialName != null ? 'Guardar' : 'Adicionar'),
    );

    return LystraBottomSheetContent(
      title: widget.initialName != null ? 'Editar item' : 'Novo item',
      action: widget.extraActions != null && widget.extraActions!.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                mainButton,
                const SizedBox(height: 4),
                ...widget.extraActions!,
              ],
            )
          : mainButton,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64,
                  child: TextFormField(
                    controller: _emojiController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24),
                    maxLength: 2,
                    decoration: const InputDecoration(
                      labelText: 'Emoji',
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration:
                        const InputDecoration(labelText: 'Nome do item'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Nome obrigatório' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categoria',
                    style: Theme.of(context).textTheme.titleSmall),
                if (widget.onCreateCategory != null)
                  TextButton.icon(
                    onPressed: _showCreateCategory,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Nova'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            if (_categories.isEmpty)
              Text(
                'Sem categorias — toca em "Nova" para criar.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedCategoryId, // ignore: deprecated_member_use
                decoration: const InputDecoration(),
                items: _categories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
            const SizedBox(height: AppSpacing.md),
            Text('Unidade', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: _units
                  .map(
                    (u) => ChoiceChip(
                      label: Text(u),
                      selected: _selectedUnit == u,
                      onSelected: (_) => setState(() => _selectedUnit = u),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
