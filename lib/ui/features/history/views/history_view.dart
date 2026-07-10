import 'package:flutter/material.dart';
import 'package:lystra/ui/core/widgets/empty_state_widget.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Histórico')),
          SliverFillRemaining(
            child: EmptyStateWidget(
              icon: Icons.history_outlined,
              headline: 'Ainda sem histórico',
              subtext: 'As tuas compras concluídas vão aparecer aqui.',
            ),
          ),
        ],
      ),
    );
  }
}
