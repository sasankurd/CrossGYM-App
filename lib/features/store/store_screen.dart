import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import 'sell_plan_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final selling = state.myPlans;
    final bought = state.purchasedPlans;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, contentTop(context), 16, 120),
      children: [
        Row(
          children: [
            Expanded(child: Text('Store', style: text.headlineSmall)),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SellPlanScreen(),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Sell a plan'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SubTabs(
          labels: const ['Browse', 'My plans'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 16),
        if (_tab == 0)
          for (final p in state.allPlans) ...[
            _PlanCard(plan: p),
            const SizedBox(height: 12),
          ]
        else ...[
          if (selling.isEmpty && bought.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Plans you buy or sell will show up here.',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: AppColors.gray400),
              ),
            ),
          if (selling.isNotEmpty) ...[
            const SectionLabel('Selling'),
            const SizedBox(height: 8),
            for (final p in selling) ...[
              _PlanCard(plan: p),
              const SizedBox(height: 12),
            ],
          ],
          if (bought.isNotEmpty) ...[
            const SectionLabel('Purchased'),
            const SizedBox(height: 8),
            for (final p in bought) ...[
              _PlanCard(plan: p),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final seller = state.userById(plan.sellerId);
    final owned = state.owns(plan);
    final isMine = plan.sellerId == AppState.meId;
    final color = typeColor(context, plan.type);

    return NeoCard(
      accent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Icon(plan.type.icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(plan.title, style: text.titleMedium)),
              Text(
                plan.priceLabel,
                style: mono(
                  size: 15,
                  weight: FontWeight.w700,
                  color: plan.priceUsd == 0 ? AppColors.emerald : AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            plan.description,
            style: text.bodyMedium?.copyWith(color: AppColors.gray300),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Pill(plan.type.label, color: color),
              const SizedBox(width: 6),
              Pill('${plan.weeks} wk'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isMine ? 'by you' : 'by ${seller?.name ?? 'unknown'}',
                  overflow: TextOverflow.ellipsis,
                  style: mono(
                    size: 11,
                    weight: FontWeight.w500,
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: isMine
                ? const Pill('YOUR PLAN', color: AppColors.amber)
                : owned
                    ? const Pill('OWNED', color: AppColors.emerald, icon: Icons.check)
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
                        child: Text(plan.priceUsd == 0 ? 'Get free' : 'Buy'),
                      ),
          ),
        ],
      ),
    );
  }
}
