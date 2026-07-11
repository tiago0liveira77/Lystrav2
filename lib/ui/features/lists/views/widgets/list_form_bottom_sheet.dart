import 'package:flutter/material.dart';
import 'package:lystra/ui/core/widgets/lystra_bottom_sheet.dart';

class ListFormBottomSheet extends StatefulWidget {
  const ListFormBottomSheet({
    super.key,
    this.initialName,
    this.title,
    required this.onSubmit,
  });

  final String? initialName;
  final String? title;
  final Future<void> Function(String name) onSubmit;

  @override
  State<ListFormBottomSheet> createState() => _ListFormBottomSheetState();
}

class _ListFormBottomSheetState extends State<ListFormBottomSheet> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await widget.onSubmit(_controller.text.trim());
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialName != null;
    return LystraBottomSheetContent(
      title: widget.title ?? (isEdit ? 'Renomear lista' : 'Nova lista'),
      action: FilledButton(
        onPressed: _isLoading ? null : _submit,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(isEdit ? 'Guardar' : 'Criar'),
      ),
      child: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            labelText: 'Nome da lista',
            hintText: 'Ex: Supermercado',
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Nome obrigatório' : null,
        ),
      ),
    );
  }
}
