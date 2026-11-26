import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../rank/rank_widgets.dart';

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
      color: AppColors.glassFill,
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

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _open = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    AppScope.of(context).addComment(widget.post, _controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final comments = state.commentsOf(post);
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
              UserAvatar(
                  name: author?.name ?? '?', photo: author?.photo, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(author?.name ?? 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleMedium),
                        ),
                        const SizedBox(width: 6),
                        RankPill(state.rankOf(post.authorId)),
                      ],
                    ),
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
          if (post.image != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(post.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
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
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => setState(() => _open = !_open),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 20, color: AppColors.gray400),
                      const SizedBox(width: 6),
                      Text('${comments.length}',
                          style: mono(size: 12, color: AppColors.gray300)),
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
          if (_open) ...[
            const Divider(height: 20),
            for (final c in comments)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(
                      name: state.userById(c.authorId)?.name ?? '?',
                      photo: state.userById(c.authorId)?.photo,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${state.userById(c.authorId)?.name ?? 'Unknown'}  -  ${ago(c.at)}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.gray400),
                          ),
                          Text(c.text, style: text.bodyMedium),
                        ],
                      ),
                    ),
                    if (c.authorId == AppState.meId)
                      IconButton(
                        tooltip: 'Delete comment',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => state.deleteComment(c),
                        icon: const Icon(Icons.close,
                            size: 16, color: AppColors.gray400),
                      ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Write a comment',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Send comment',
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded, size: 20),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
