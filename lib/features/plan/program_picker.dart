import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../data/program_templates.dart';

/// Bottom sheet to switch programs, create one, or start from a template or
/// from a plan you own in the Store.
Future<void> showProgramPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.85,
      child: _ProgramPicker(screenContext: context),
    ),
  );
}

class _ProgramPicker extends StatelessWidget {
  const _ProgramPicker({required this.screenContext});

  /// Context of the Plan screen, used for the confirmation snackbar.
  final BuildContext screenContext;

  void _done(BuildContext context, String message) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(screenContext)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final programs = state.programs;
    final activeId = state.activeProgram.id;
    final owned = [...state.myPlans, ...state.purchasedPlans];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.hairlineStrong,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Programs', style: text.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Pick the program you want to follow. Each one has its own week.',
            style: text.bodySmall?.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 16),
          const SectionLabel('My programs'),
          const SizedBox(height: 8),
          for (final p in programs) ...[
            _ProgramTile(
              program: p,
              active: p.id == activeId,
              canDelete: programs.length > 1,
              onSelect: () => _done(context, '${p.name} is now your program'),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () async {
              final name = await _askName(
                context,
                title: 'New program',
                action: 'Create',
              );
              if (name != null && context.mounted) {
                state.createProgram(name);
                _done(context, '$name created');
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('New blank program'),
          ),
          const SizedBox(height: 24),
          const SectionLabel('Start from a template'),
          const SizedBox(height: 8),
          for (final t in kProgramTemplates) ...[
            _TemplateTile(
              icon: t.type.icon,
              color: typeColor(context, t.type),
              title: t.name,
              subtitle: t.description,
              badge: '${t.days.length} days',
              onTap: () {
                state.addProgramFromTemplate(t);
                _done(context, '${t.name} added and selected');
              },
            ),
            const SizedBox(height: 8),
          ],
          if (owned.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionLabel('From your plans'),
            const SizedBox(height: 4),
            Text(
              'Starts a program named after the plan, using a starter week for '
              'its workout type. You can edit it afterwards.',
              style: text.bodySmall?.copyWith(color: AppColors.gray400),
            ),
            const SizedBox(height: 8),
            for (final plan in owned) ...[
              _TemplateTile(
                icon: plan.type.icon,
                color: typeColor(context, plan.type),
                title: plan.title,
                subtitle: '${plan.type.label} - ${plan.weeks} weeks',
                badge: 'USE',
                onTap: () {
                  state.addProgramFromPlan(plan);
                  _done(context, '${plan.title} added and selected');
                },
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _ProgramTile extends StatelessWidget {
  const _ProgramTile({
    required this.program,
    required this.active,
    required this.canDelete,
    required this.onSelect,
  });

  final Program program;
  final bool active;
  final bool canDelete;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return NeoCard(
      radius: 20,
      selected: active,
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
      onTap: () {
        state.selectProgram(program.id);
        onSelect();
      },
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle : Icons.radio_button_unchecked,
            color: active ? scheme.primary : AppColors.gray400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${program.exerciseCount} exercises - '
                  '${program.trainingDays} days',
                  style: mono(
                    size: 11,
                    weight: FontWeight.w500,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: const Icon(Icons.more_vert, color: AppColors.gray300),
            onSelected: (value) async {
              if (value == 'rename') {
                final name = await _askName(
                  context,
                  title: 'Rename program',
                  initial: program.name,
                  action: 'Save',
                );
                if (name != null) state.renameProgram(program.id, name);
              } else if (value == 'delete') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete program?'),
                    content: Text(
                      '"${program.name}" and its exercises will be removed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.rose,
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok == true) state.deleteProgram(program.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              if (canDelete)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(color: AppColors.rose),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      radius: 20,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.gray400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Pill(badge, color: color),
        ],
      ),
    );
  }
}

Future<String?> _askName(
  BuildContext context, {
  required String title,
  required String action,
  String initial = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(title: title, action: action, initial: initial),
  );
}

/// Owns its text controller so it is disposed together with the dialog.
class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.action,
    required this.initial,
  });

  final String title;
  final String action;
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Program name'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.action)),
      ],
    );
  }
}
