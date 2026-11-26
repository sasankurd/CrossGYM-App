import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../profile/photo_picker.dart';
import 'post_card.dart';

/// Write a post and optionally attach one of your plans or a personal record.
class PostComposer extends StatefulWidget {
  const PostComposer({super.key});

  @override
  State<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final _controller = TextEditingController();
  PostAttachment? _attachment;
  Uint8List? _image;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _attachPr() async {
    final lift = TextEditingController();
    final result = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Attach a PR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lift,
              decoration: const InputDecoration(labelText: 'Lift or workout'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: result,
              decoration:
                  const InputDecoration(labelText: 'Result (for example 100 kg)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Attach'),
          ),
        ],
      ),
    );
    final liftText = lift.text.trim();
    final resultText = result.text.trim();
    lift.dispose();
    result.dispose();
    if (ok == true && liftText.isNotEmpty && resultText.isNotEmpty && mounted) {
      setState(() => _attachment = PostAttachment(
            kind: AttachmentKind.pr,
            title: liftText,
            detail: resultText,
          ));
    }
  }

  Future<void> _addPhoto() async {
    final png = await pickPhoto(context, square: false);
    if (png != null && mounted) setState(() => _image = png);
  }

  void _post() {
    AppScope.of(context).addPost(_controller.text, _attachment, image: _image);
    _controller.clear();
    setState(() {
      _attachment = null;
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final plans = state.myPlans;
    return NeoCard(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            minLines: 2,
            decoration: const InputDecoration(
              hintText: 'Share a workout, a PR or a plan',
            ),
          ),
          if (_attachment != null) ...[
            const SizedBox(height: 10),
            AttachmentCard(
              attachment: _attachment!,
              onRemove: () => setState(() => _attachment = null),
            ),
          ],
          if (_image != null) ...[
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(_image!,
                      width: double.infinity, height: 180, fit: BoxFit.cover),
                ),
                IconButton.filled(
                  tooltip: 'Remove photo',
                  onPressed: () => setState(() => _image = null),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
              PopupMenuButton<Plan>(
                tooltip: 'Attach a plan',
                enabled: plans.isNotEmpty,
                onSelected: (p) => setState(() => _attachment = PostAttachment(
                      kind: AttachmentKind.plan,
                      title: p.title,
                      detail: '${p.weeks} weeks - ${p.priceLabel}',
                    )),
                itemBuilder: (context) => [
                  for (final p in plans)
                    PopupMenuItem<Plan>(value: p, child: Text(p.title)),
                ],
                child: Pill(
                  plans.isEmpty ? 'PLAN (SELL ONE FIRST)' : 'PLAN',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icons.storefront,
                ),
              ),
              GestureDetector(
                onTap: _addPhoto,
                child: const Pill('PHOTO', color: AppColors.cyan, icon: Icons.photo_outlined),
              ),
              GestureDetector(
                onTap: _attachPr,
                child: const Pill('PR', color: AppColors.amber, icon: Icons.emoji_events),
              ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _post, child: const Text('Post')),
            ],
          ),
        ],
      ),
    );
  }
}
