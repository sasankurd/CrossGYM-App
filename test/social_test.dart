import 'dart:typed_data';

import 'package:crossgym/data/app_state.dart';
import 'package:crossgym/data/models.dart';
import 'package:crossgym/data/rank.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rank thresholds and progress', () {
    expect(RankTier.forPoints(0), RankTier.rookie);
    expect(RankTier.forPoints(29), RankTier.rookie);
    expect(RankTier.forPoints(30), RankTier.bronze);
    expect(RankTier.forPoints(600), RankTier.master);
    expect(RankTier.master.next, isNull);
    expect(RankTier.bronze.progress(60), closeTo(0.5, 0.001));
    expect(RankTier.master.progress(900), 1);
  });

  test('medals give points and points give rank', () {
    final s = AppState()..continueAsGuest();
    expect(s.achievementPoints, 0);
    expect(s.rank, RankTier.rookie);
    s.logWorkout(WorkoutType.gym); // First step: bronze, 10 points
    expect(s.achievementPoints, 10);
    final fresh = s.takeNewMedals();
    expect(fresh.map((a) => a.title), isEmpty); // first account: nothing announced
    s.addPost('hello', null); // First post: bronze
    expect(s.achievementPoints, 20);
    expect(s.takeNewMedals().map((a) => a.title), ['First post']);
    expect(s.takeNewMedals(), isEmpty);
  });

  test('comments can be added and deleted by their author', () {
    final s = AppState()..continueAsGuest();
    final post = s.feed.first;
    final before = s.commentsOf(post).length;
    s.addComment(post, '  nice  ');
    expect(s.commentsOf(post).length, before + 1);
    expect(s.commentsOf(post).last.text, 'nice');
    expect(s.myCommentCount, 1);
    s.deleteComment(s.commentsOf(post).last);
    expect(s.commentsOf(post).length, before);
    s.addComment(post, '   ');
    expect(s.commentsOf(post).length, before);
  });

  test('posts keep a photo and survive a JSON round trip', () {
    final p = Post(
      id: 'p',
      authorId: 'me',
      text: 'hi',
      createdAt: DateTime(2026, 11, 26),
      image: Uint8List.fromList([1, 2, 3]),
      attachment: const PostAttachment(
          kind: AttachmentKind.pr, title: 'Squat', detail: '100 kg'),
    );
    final back = Post.fromJson(p.toJson());
    expect(back.image, [1, 2, 3]);
    expect(back.attachment!.title, 'Squat');
    final c = Comment(
        id: 'c', postId: 'p', authorId: 'u1', text: 'x', at: DateTime(2026));
    expect(Comment.fromJson(c.toJson()).text, 'x');
  });

  test('leaderboard orders by points and includes you', () {
    final s = AppState()..continueAsGuest();
    final board = s.leaderboard;
    expect(board.first.id, 'u2'); // highest demo points
    expect(board.any((u) => u.id == AppState.meId), isTrue);
    expect(s.rankOf('u2'), RankTier.diamond);
  });

  test('profile photo can be set and removed', () {
    final s = AppState()..continueAsGuest();
    s.setMyPhoto(Uint8List.fromList([1]));
    expect(s.me.photo, isNotNull);
    expect(s.achievements.firstWhere((a) => a.title == 'Face of the app').unlocked, isTrue);
    s.setMyPhoto(null);
    expect(s.me.photo, isNull);
  });

  test('following feed shows only followed people and you', () {
    final s = AppState()..continueAsGuest();
    expect(s.followingFeed.where((p) => p.authorId != AppState.meId), isEmpty);
    s.toggleFollow('u1');
    expect(s.followingFeed.every((p) => p.authorId == 'u1' || p.authorId == AppState.meId), isTrue);
    expect(s.followingFeed, isNotEmpty);
  });
}
