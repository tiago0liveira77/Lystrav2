import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/ui/features/profile/view_models/profile_view_model.dart';
import 'package:lystra/ui/features/profile/views/widgets/household_section.dart';
import 'package:lystra/ui/features/profile/views/widgets/premium_banner.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _householdNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onStateChange);
    widget.viewModel.loadUserData();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onStateChange);
    _householdNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (!mounted) return;
    final vm = widget.viewModel;

    // Seed feedback
    if ((vm.seedState == SeedState.success || vm.seedState == SeedState.error) &&
        vm.seedMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(vm.seedMessage!),
        backgroundColor: vm.seedState == SeedState.success
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ));
      vm.clearSeedMessage();
    }

    // Household error
    if (vm.householdState == HouseholdState.error &&
        vm.householdError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(vm.householdError!),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ));
      vm.clearHouseholdError();
    }
  }

  Future<void> _confirmLoadBaseItems() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Carregar items base'),
        content: const Text(
            'Adiciona ao teu catálogo os items pré-definidos que ainda não existam. Os teus items actuais não são afectados.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Carregar')),
        ],
      ),
    );
    if (confirmed == true) widget.viewModel.loadBaseItems();
  }

  void _showCreateHouseholdSheet() {
    _householdNameController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Criar household',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _householdNameController,
              autofocus: true,
              decoration:
                  const InputDecoration(labelText: 'Nome do household'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () {
                final name = _householdNameController.text.trim();
                if (name.isNotEmpty) {
                  widget.viewModel.createHousehold(name);
                  Navigator.pop(context);
                }
              },
              child: const Text('Criar'),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showJoinHouseholdSheet() {
    _inviteCodeController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Entrar num household',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text('Pede o código de 6 dígitos ao dono do household.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _inviteCodeController,
              autofocus: true,
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                  labelText: 'Código de convite',
                  hintText: 'Ex: AB1C2D'),
            ),
            FilledButton(
              onPressed: () {
                final code = _inviteCodeController.text.trim();
                if (code.isNotEmpty) {
                  widget.viewModel.joinHousehold(code);
                  Navigator.pop(context);
                }
              },
              child: const Text('Entrar'),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
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
        final displayStr = user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : user?.email.isNotEmpty == true
                ? user!.email
                : '?';
        final initials = displayStr[0].toUpperCase();

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
                              vertical: AppSpacing.sm),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: scheme.primaryContainer,
                            child: Text(initials,
                                style: TextStyle(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ),
                          title: Text(user?.displayName ?? 'Utilizador',
                              style: theme.textTheme.titleMedium),
                          subtitle: Text(user?.email ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant)),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Premium banner or premium active chip
                      if (!vm.isPremium)
                        PremiumBanner(
                          onUpgrade: kDebugMode
                              ? () => vm.togglePremium(true)
                              : null,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.workspace_premium,
                                  color: scheme.secondary, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text('Premium activo',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                        color: scheme.onSecondaryContainer)),
                              ),
                              if (kDebugMode)
                                Switch(
                                  value: true,
                                  onChanged: (_) => vm.togglePremium(false),
                                  activeThumbColor: scheme.secondary,
                                ),
                            ],
                          ),
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      // Household section (premium only)
                      if (vm.isPremium) ...[
                        _SectionLabel('Household'),
                        const SizedBox(height: AppSpacing.xs),
                        if (vm.householdState == HouseholdState.loading)
                          const Center(
                              child: Padding(
                                  padding:
                                      EdgeInsets.all(AppSpacing.lg),
                                  child: CircularProgressIndicator()))
                        else if (vm.household != null)
                          HouseholdSection(
                            household: vm.household!,
                            viewModel: vm,
                            currentUid: user?.uid ?? '',
                          )
                        else ...[
                          Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.add_home_outlined,
                                      color: scheme.primary),
                                  title: const Text('Criar household'),
                                  subtitle: const Text(
                                      'Cria um grupo e convida a família'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: _showCreateHouseholdSheet,
                                ),
                                const Divider(height: 1, indent: 16),
                                ListTile(
                                  leading: Icon(Icons.group_add_outlined,
                                      color: scheme.primary),
                                  title: const Text('Entrar num household'),
                                  subtitle: const Text(
                                      'Usa um código de convite'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: _showJoinHouseholdSheet,
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Catalogue
                      _SectionLabel('Catálogo'),
                      const SizedBox(height: AppSpacing.xs),
                      Card(
                        child: ListTile(
                          leading: vm.seedState == SeedState.loading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: scheme.primary))
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

                      // Account
                      _SectionLabel('Conta'),
                      const SizedBox(height: AppSpacing.xs),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.logout_outlined,
                              color: scheme.error),
                          title: Text('Terminar sessão',
                              style: TextStyle(color: scheme.error)),
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Terminar sessão'),
                                content: const Text(
                                    'Tens a certeza que queres sair da conta?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          scheme.error,
                                      foregroundColor:
                                          scheme.onError,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Sair'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) vm.signOut();
                          },
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
