import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/domain/models/household.dart';
import 'package:lystra/ui/features/profile/view_models/profile_view_model.dart';

class HouseholdSection extends StatelessWidget {
  const HouseholdSection({
    super.key,
    required this.household,
    required this.viewModel,
    required this.currentUid,
  });

  final Household household;
  final ProfileViewModel viewModel;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isOwner = household.ownerId == currentUid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group_outlined, color: scheme.primary, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    household.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Invite code (only owner sees it)
            if (isOwner) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Código de convite',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant)),
                          Text(
                            household.inviteCode,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: household.inviteCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Código copiado!'),
                              behavior: SnackBarBehavior.floating),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Member count
            Text(
              '${household.memberIds.length} ${household.memberIds.length == 1 ? 'membro' : 'membros'}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),

            const SizedBox(height: AppSpacing.sm),
            const Divider(),

            // Leave button
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.exit_to_app_outlined, color: scheme.error),
              title: Text(
                isOwner ? 'Dissolver household' : 'Sair do household',
                style: TextStyle(color: scheme.error),
              ),
              onTap: () => _confirmLeave(context, isOwner),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLeave(BuildContext context, bool isOwner) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isOwner ? 'Dissolver household' : 'Sair do household'),
        content: Text(
          isOwner
              ? 'Ao dissolver, todos os membros perdem acesso. Tens a certeza?'
              : 'Vais sair de "${household.name}". Tens a certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(isOwner ? 'Dissolver' : 'Sair'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) viewModel.leaveHousehold();
    });
  }
}
