import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

/// Attached plan or PR shown inside a post or the composer.
class AttachmentCard extends StatelessWidget {
  const AttachmentCard({super.key, required this.attachment, this.onRemove});

  final PostAttachment attachment;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isPr = attachment.kind == AttachmentKind.pr;
    final color = isPr ? AppColors.amber : Theme.of(context).colorScheme.secondary;
    return NeoCard(
      radius: 16,
      color: AppColors.container,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(isPr ? Icons.emoji_events : Icons.storefront, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPr ? 'PERSONAL RECORD' : 'WORKOUT PLAN',
                  style: mono(size: 9, weight: FontWeight.w500, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  attachment.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  attachment.detail,
                  style: mono(
                    size: 12,
                    weight: FontWeight.w500,
                    color: AppColors.gray300,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              tooltip: 'Remove',
              icon: const Icon(Icons.close, size: 18, color: AppColors.gray400),
            ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final author = state.userById(post.authorId);
    final liked = state.isLiked(post);
    final mine = post.authorId == AppState.meId;

    return NeoCard(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientAvatar(initial: author?.name[0] ?? '?', size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author?.name ?? 'Unknown', style: text.titleMedium),
                    Text(
                      '@${author?.handle ?? '?'} - ${ago(post.createdAt)}',
                      style: mono(
                        size: 11,
                        weight: FontWeight.w500,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (post.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(post.text, style: text.bodyMedium),
          ],
          if (post.attachment != null) ...[
            const SizedBox(height: 10),
            AttachmentCard(attachment: post.attachment!),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => state.toggleLike(post),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: liked ? AppColors.rose : AppColors.gray400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.likesOf(post)}',
                        style: mono(
                          size: 12,
                          color: liked ? AppColors.rose : AppColors.gray300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (mine)
                IconButton(
                  tooltip: 'Delete post',
                  onPressed: () => state.deletePost(post),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.rose,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
