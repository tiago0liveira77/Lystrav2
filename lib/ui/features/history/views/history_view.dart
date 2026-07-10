import 'package:flutter/material.dart';
import 'package:lystra/core/di/service_locator.dart';
import 'package:lystra/core/theme/app_spacing.dart';
import 'package:lystra/ui/core/widgets/empty_state_widget.dart';
import 'package:lystra/ui/core/widgets/skeleton_list_tile.dart';
import 'package:lystra/ui/features/history/view_models/history_view_model.dart';
import 'package:lystra/ui/features/history/views/widgets/purchase_record_card.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late final HistoryViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = sl<HistoryViewModel>();
    _vm.loadRecords();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('Histórico')),
              ..._buildBody(context),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    switch (_vm.state) {
      case HistoryViewState.loading:
      case HistoryViewState.initial:
        return [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) => const SkeletonListTile(),
              childCount: 6,
            ),
          ),
        ];

      case HistoryViewState.error:
        return [
          SliverFillRemaining(
            child: EmptyStateWidget(
              icon: Icons.error_outline,
              headline: 'Erro ao carregar',
              subtext: _vm.errorMessage ?? 'Tenta novamente mais tarde.',
              ctaLabel: 'Tentar novamente',
              onCta: _vm.loadRecords,
            ),
          ),
        ];

      case HistoryViewState.loaded:
        if (_vm.records.isEmpty) {
          return [
            SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.history_outlined,
                headline: 'Ainda sem histórico',
                subtext:
                    'Conclui uma lista de compras para ver o histórico aqui.',
              ),
            ),
          ];
        }
        return _buildGroupedList(context);
    }
  }

  List<Widget> _buildGroupedList(BuildContext context) {
    final theme = Theme.of(context);
    final slivers = <Widget>[];

    for (final month in _vm.monthKeys) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xs),
            child: Text(
              month,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

      final records = _vm.recordsForMonth(month);
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => PurchaseRecordCard(record: records[i]),
            childCount: records.length,
          ),
        ),
      );
    }

    slivers.add(const SliverToBoxAdapter(
      child: SizedBox(height: AppSpacing.xxl),
    ));

    return slivers;
  }
}
