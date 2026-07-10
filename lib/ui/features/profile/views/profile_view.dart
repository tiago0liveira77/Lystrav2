import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/ui/features/profile/view_models/profile_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onSeedStateChange);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onSeedStateChange);
    super.dispose();
  }

  void _onSeedStateChange() {
    final vm = widget.viewModel;
    if (!mounted) return;
    if ((vm.seedState == SeedState.success || vm.seedState == SeedState.error) &&
        vm.seedMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.seedMessage!),
          backgroundColor: vm.seedState == SeedState.success
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      vm.clearSeedMessage();
    }
  }

  Future<void> _confirmLoadBaseItems() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Carregar items base'),
        content: const Text(
          'Isto vai adicionar ao teu catálogo todos os items e categorias pré-definidos que ainda não existam. Os teus items actuais não serão afectados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Carregar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.viewModel.loadBaseItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final user = vm.currentUser;
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final initials =
            (user?.displayName ?? user?.email ?? '?')[0].toUpperCase();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('Perfil')),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info card
                      Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: scheme.primaryContainer,
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          title: Text(
                            user?.displayName ?? 'Utilizador',
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            user?.email ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Catalogue section
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs),
                        child: Text(
                          'Catálogo',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Card(
                        child: ListTile(
                          leading: vm.seedState == SeedState.loading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.primary),
                                )
                              : Icon(Icons.download_outlined,
                                  color: scheme.primary),
                          title: const Text('Carregar items base'),
                          subtitle: const Text(
                              '52 itens pré-definidos em 10 categorias'),
                          trailing: const Icon(Icons.chevron_right),
                          enabled: vm.seedState != SeedState.loading,
                          onTap: vm.seedState == SeedState.loading
                              ? null
                              : _confirmLoadBaseItems,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Account section
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs),
                        child: Text(
                          'Conta',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Card(
                        child: ListTile(
                          leading:
                              Icon(Icons.logout_outlined, color: scheme.error),
                          title: Text(
                            'Terminar sessão',
                            style: TextStyle(color: scheme.error),
                          ),
                          onTap: () => widget.viewModel.signOut(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
