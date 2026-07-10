import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/core/utils/motion.dart';
import 'package:lystra/domain/models/item.dart';
import 'package:lystra/domain/models/list_entry.dart';

class ShoppingItemRow extends StatefulWidget {
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

  @override
  State<ShoppingItemRow> createState() => _ShoppingItemRowState();
}

class _ShoppingItemRowState extends State<ShoppingItemRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _strikethroughAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _tintAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.7, curve: Curves.elasticOut),
    ));

    _tintAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45),
    ));

    _strikethroughAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
    ));

    _opacityAnim = Tween(begin: 1.0, end: 0.6).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5),
    ));

    if (widget.entry.isChecked) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(ShoppingItemRow old) {
    super.didUpdateWidget(old);
    if (old.entry.isChecked != widget.entry.isChecked) {
      final reduce = shouldReduceMotion(context);
      if (widget.entry.isChecked) {
        reduce ? _controller.value = 1.0 : _controller.forward();
      } else {
        reduce ? _controller.value = 0.0 : _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onToggle();
  }

  void _handleIncrease() {
    HapticFeedback.lightImpact();
    widget.onIncrease();
  }

  Color? get _categoryColor {
    if (widget.categoryColorHex == null) return null;
    try {
      return Color(
          int.parse(widget.categoryColorHex!.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  String _formatQty(double qty) {
    if (qty == qty.truncateToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dotColor = _categoryColor ?? scheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Dismissible(
          key: ValueKey(widget.entry.id),
          direction: DismissDirection.horizontal,
          // Swipe right → increase quantity
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
                    style: textTheme.labelLarge
                        ?.copyWith(color: scheme.primary)),
              ],
            ),
          ),
          // Swipe left → delete
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
              widget.onRemove();
            }
            return false;
          },
          child: Container(
            height: 64,
            color: Color.lerp(
              Colors.transparent,
              scheme.primaryContainer.withValues(alpha: 0.4),
              _tintAnim.value,
            ),
            child: InkWell(
              onTap: _handleTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    // Category dot or emoji
                    widget.item.emoji != null
                        ? SizedBox(
                            width: 28,
                            child: Text(widget.item.emoji!,
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center),
                          )
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: widget.entry.isChecked
                                  ? scheme.primary
                                  : dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                    const SizedBox(width: AppSpacing.md),

                    // Item name with strikethrough
                    Expanded(
                      child: Opacity(
                        opacity: _opacityAnim.value,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Text(
                              widget.item.name,
                              style: textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_strikethroughAnim.value > 0)
                              LayoutBuilder(builder: (ctx, constraints) {
                                return Positioned(
                                  left: 0,
                                  right: constraints.maxWidth *
                                      (1 - _strikethroughAnim.value),
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Container(
                                      height: 1.5,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.xs),

                    // Quantity + unit badge (always visible)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${_formatQty(widget.entry.quantity)} ${widget.item.unit}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.xs),

                    // "+" quick increase button
                    GestureDetector(
                      onTap: _handleIncrease,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add,
                            size: 16, color: scheme.primary),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    // Check/uncheck icon with bounce animation
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Icon(
                        widget.entry.isChecked
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: widget.entry.isChecked
                            ? scheme.primary
                            : scheme.outline,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
