import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import 'sell_plan_screen.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Store'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Browse'), Tab(text: 'My plans')],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Sell a plan'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SellPlanScreen()),
          ),
        ),
        body: TabBarView(
          children: [
            _PlanList(
              plans: state.allPlans,
              empty: 'No plans yet.',
            ),
            _MyPlans(state: state),
          ],
        ),
      ),
    );
  }
}

class _MyPlans extends StatelessWidget {
  const _MyPlans({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final selling = state.myPlans;
    final bought = state.purchasedPlans;
    if (selling.isEmpty && bought.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Plans you buy or sell will show up here.'),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (selling.isNotEmpty) ...[
          Text('Selling', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final p in selling) ...[
            _PlanCard(plan: p),
            const SizedBox(height: 10),
          ],
        ],
        if (bought.isNotEmpty) ...[
          Text('Purchased', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final p in bought) ...[
            _PlanCard(plan: p),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({required this.plans, required this.empty});

  final List<Plan> plans;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) return Center(child: Text(empty));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _PlanCard(plan: plans[i]),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final seller = state.userById(plan.sellerId);
    final owned = state.owns(plan);
    final isMine = plan.sellerId == AppState.meId;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(plan.type.icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(plan.title, style: theme.textTheme.titleMedium),
                ),
                Text(plan.priceLabel, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 6),
            Text(plan.description),
            const SizedBox(height: 6),
            Text(
              '${plan.type.label} - ${plan.weeks} weeks - by '
              '${isMine ? 'you' : seller?.name ?? 'unknown'}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: isMine
                  ? const Chip(label: Text('Your plan'))
                  : owned
                      ? const Chip(label: Text('Owned'))
                      : FilledButton(
                          onPressed: () {
                            state.buyPlan(plan);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  plan.priceUsd == 0
                                      ? 'Added to your plans'
                                      : 'Demo purchase: no payment taken',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            plan.priceUsd == 0 ? 'Get free' : 'Buy',
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
