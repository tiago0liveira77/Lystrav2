import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';

class PremiumBanner extends StatelessWidget {
  const PremiumBanner({super.key, required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.secondary, scheme.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.workspace_premium,
                        color: scheme.onSecondary, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Lystra Premium',
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Sincroniza listas com a família em tempo real.',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSecondary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton(
            onPressed: onUpgrade,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.onSecondary,
              foregroundColor: scheme.secondary,
            ),
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
  }
}
