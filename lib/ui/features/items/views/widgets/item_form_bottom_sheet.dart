import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/category.dart';
import 'package:lystra/ui/core/widgets/lystra_bottom_sheet.dart';

class ItemFormBottomSheet extends StatefulWidget {
  const ItemFormBottomSheet({
    super.key,
    required this.categories,
    required this.onSubmit,
    this.initialName,
    this.initialCategoryId,
    this.initialUnit,
  });

  final List<Category> categories;
  final Future<void> Function(String name, String categoryId, String unit)
      onSubmit;
  final String? initialName;
  final String? initialCategoryId;
  final String? initialUnit;

  @override
  State<ItemFormBottomSheet> createState() => _ItemFormBottomSheetState();
}

class _ItemFormBottomSheetState extends State<ItemFormBottomSheet> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _selectedCategoryId;
  String _selectedUnit = 'un';

  static const _units = ['un', 'kg', 'g', 'L', 'mL', 'cx', 'dz'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedCategoryId = widget.initialCategoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
    _selectedUnit = widget.initialUnit ?? 'un';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;
    setState(() => _isLoading = true);
    await widget.onSubmit(
        _nameController.text.trim(), _selectedCategoryId!, _selectedUnit);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return LystraBottomSheetContent(
      title: widget.initialName != null ? 'Editar item' : 'Novo item',
      action: FilledButton(
        onPressed: _isLoading ? null : _submit,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(widget.initialName != null ? 'Guardar' : 'Adicionar'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Nome do item'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nome obrigatório' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            if (widget.categories.isNotEmpty) ...[
              Text('Categoria',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId, // ignore: deprecated_member_use
                decoration: const InputDecoration(),
                items: widget.categories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
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
