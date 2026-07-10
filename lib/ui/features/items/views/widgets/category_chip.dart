import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';

class CategoryChipWidget extends StatelessWidget {
  const CategoryChipWidget({
    super.key,
    required this.label,
    this.colorHex,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String? colorHex;
  final bool isSelected;
  final VoidCallback onTap;

  Color? get _color {
    if (colorHex == null) return null;
    try {
      return Color(
          int.parse(colorHex!.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _color ?? scheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        avatar: colorHex != null
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        selectedColor: scheme.primaryContainer,
        checkmarkColor: scheme.onPrimaryContainer,
        labelStyle: TextStyle(
          color: isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        showCheckmark: false,
      ),
    );
  }
}
