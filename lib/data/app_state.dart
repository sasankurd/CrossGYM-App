import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/tokens.dart';
import 'models.dart';

/// In-memory app state with seed data.
///
/// Follow, messages, posts and the store are local only for now. Replace this
/// class with repositories backed by a real service (see docs/BACKEND.md).
class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  static const String meId = 'me';

  late final AppUser me;
  final Map<String, AppUser> _users = {};
  final List<Plan> _plans = [];
  final Set<String> _following = {};
  final Set<String> _purchasedPlanIds = {};
  final Map<String, List<ChatMessage>> _chats = {};
  final List<WorkoutLog> _logs = [];
  final List<Post> _posts = [];
  final Set<String> _likedPostIds = {};
  final Map<int, List<PlannedExercise>> _plan = {
    for (var i = 0; i < 7; i++) i: <PlannedExercise>[],
  };
  int _themeIndex = 0;
  int _nextPlanNumber = 100;
  int _nextPostNumber = 100;
  int _nextPlannedId = 1;

  // ---- theme ---------------------------------------------------------------

  int get themeIndex => _themeIndex;
  AnimeTheme get theme => kAnimeThemes[_themeIndex];

  void setTheme(int index) {
    if (index < 0 || index >= kAnimeThemes.length) return;
    _themeIndex = index;
    notifyListeners();
  }

  // ---- users, store, follow ------------------------------------------------

  List<AppUser> get otherUsers => _users.values.toList();
  AppUser? userById(String id) => id == meId ? me : _users[id];
  List<Plan> get allPlans => List.unmodifiable(_plans);
  List<Plan> get myPlans =>
      _plans.where((p) => p.sellerId == meId).toList(growable: false);
  List<Plan> get purchasedPlans => _plans
      .where((p) => _purchasedPlanIds.contains(p.id))
      .toList(growable: false);

  bool isFollowing(String userId) => _following.contains(userId);
  int get followingCount => _following.length;
  bool owns(Plan p) => p.sellerId == meId || _purchasedPlanIds.contains(p.id);

  // ---- training stats (all computed from the workout log) ------------------

  int get totalWorkouts => _logs.length;
  int workoutsOf(WorkoutType t) => _logs.where((l) => l.type == t).length;

  /// Consecutive days with at least one session, ending today or yesterday.
  int get streakDays {
    final days = _logs.map((l) => DateUtils.dateOnly(l.at)).toSet();
    var day = DateUtils.dateOnly(DateTime.now());
    if (!days.contains(day)) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (days.contains(day)) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// Rough readiness estimate from how much you trained in the last 48 hours.
  /// This is not a physiological measurement.
  double get readiness {
    final now = DateTime.now();
    var load = 0.0;
    for (final l in _logs) {
      final hours = now.difference(l.at).inHours;
      if (hours < 24) {
        load += 18;
      } else if (hours < 48) {
        load += 8;
      }
    }
    return math.max(35.0, 100.0 - load) / 100.0;
  }

  /// Time left in the 6 hour recovery window after the last session.
  Duration? get shieldRemaining {
    if (_logs.isEmpty) return null;
    const window = Duration(hours: 6);
    final since = DateTime.now().difference(_logs.last.at);
    return since < window ? window - since : null;
  }

  /// Sessions per day for the last 7 days, oldest first, today last.
  List<int> get weekCounts {
    final today = DateUtils.dateOnly(DateTime.now());
    return [
      for (var i = 6; i >= 0; i--)
        _logs
            .where((l) =>
                DateUtils.dateOnly(l.at) ==
                today.subtract(Duration(days: i)))
            .length,
    ];
  }

  int get xp => totalWorkouts * 50 + _following.length * 5;
  int get level => 1 + xp ~/ 250;
  double get levelProgress => (xp % 250) / 250;

  /// The workout type trained least over the last 7 days.
  WorkoutType get leastTrainedType {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    var best = WorkoutType.values.first;
    var fewest = 1 << 30;
    for (final t in WorkoutType.values) {
      final count =
          _logs.where((l) => l.type == t && l.at.isAfter(cutoff)).length;
      if (count < fewest) {
        fewest = count;
        best = t;
      }
    }
    return best;
  }

  List<Achievement> get achievements => [
        Achievement(
          title: 'First step',
          description: 'Log your first workout',
          icon: Icons.flag,
          goal: 1,
          progress: totalWorkouts,
          tier: MedalTier.bronze,
        ),
        Achievement(
          title: 'Getting serious',
          description: 'Log 10 workouts',
          icon: Icons.local_fire_department,
          goal: 10,
          progress: totalWorkouts,
          tier: MedalTier.silver,
        ),
        Achievement(
          title: 'Machine',
          description: 'Log 50 workouts',
          icon: Icons.military_tech,
          goal: 50,
          progress: totalWorkouts,
          tier: MedalTier.gold,
        ),
        Achievement(
          title: 'Legend',
          description: 'Log 200 workouts',
          icon: Icons.diamond,
          goal: 200,
          progress: totalWorkouts,
          tier: MedalTier.diamond,
        ),
        Achievement(
          title: 'On a roll',
          description: 'Train 7 days in a row',
          icon: Icons.calendar_month,
          goal: 7,
          progress: streakDays,
          tier: MedalTier.silver,
        ),
        Achievement(
          title: 'Road runner',
          description: 'Log 5 running workouts',
          icon: Icons.directions_run,
          goal: 5,
          progress: workoutsOf(WorkoutType.running),
          tier: MedalTier.bronze,
        ),
        Achievement(
          title: 'Box regular',
          description: 'Log 5 CrossFit workouts',
          icon: Icons.bolt,
          goal: 5,
          progress: workoutsOf(WorkoutType.crossfit),
          tier: MedalTier.silver,
        ),
        Achievement(
          title: 'Well rounded',
          description: 'Try all five workout types',
          icon: Icons.donut_large,
          goal: WorkoutType.values.length,
          progress: WorkoutType.values.where((t) => workoutsOf(t) > 0).length,
          tier: MedalTier.gold,
        ),
        Achievement(
          title: 'Social',
          description: 'Follow 3 people',
          icon: Icons.group,
          goal: 3,
          progress: _following.length,
          tier: MedalTier.bronze,
        ),
        Achievement(
          title: 'Coach',
          description: 'Publish a plan in the store',
          icon: Icons.storefront,
          goal: 1,
          progress: myPlans.length,
          tier: MedalTier.silver,
        ),
      ];

  // ---- messages ------------------------------------------------------------

  List<ChatMessage> chatWith(String userId) =>
      List.unmodifiable(_chats[userId] ?? const []);

  /// User ids that have a conversation, most recent first.
  List<String> get conversationIds {
    final ids = _chats.keys.where((k) => _chats[k]!.isNotEmpty).toList();
    ids.sort(
        (a, b) => _chats[b]!.last.sentAt.compareTo(_chats[a]!.last.sentAt));
    return ids;
  }

  // ---- posts ---------------------------------------------------------------

  List<Post> get feed {
    final list = [..._posts];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Post> postsBy(String userId) =>
      feed.where((p) => p.authorId == userId).toList();

  bool isLiked(Post p) => _likedPostIds.contains(p.id);
  int likesOf(Post p) => p.baseLikes + (_likedPostIds.contains(p.id) ? 1 : 0);

  void toggleLike(Post p) {
    if (!_likedPostIds.remove(p.id)) _likedPostIds.add(p.id);
    notifyListeners();
  }

  void addPost(String text, PostAttachment? attachment) {
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachment == null) return;
    _posts.add(Post(
      id: 'post${_nextPostNumber++}',
      authorId: meId,
      text: trimmed,
      createdAt: DateTime.now(),
      attachment: attachment,
    ));
    notifyListeners();
  }

  void deletePost(Post p) {
    if (p.authorId != meId) return;
    _posts.removeWhere((x) => x.id == p.id);
    notifyListeners();
  }

  // ---- weekly plan ---------------------------------------------------------

  List<PlannedExercise> planFor(int day) =>
      List.unmodifiable(_plan[day] ?? const <PlannedExercise>[]);

  void addToPlan(int day, Exercise e) {
    _plan[day]!.add(PlannedExercise(id: _nextPlannedId++, exercise: e));
    notifyListeners();
  }

  void removeFromPlan(int day, PlannedExercise p) {
    _plan[day]!.removeWhere((x) => x.id == p.id);
    notifyListeners();
  }

  void toggleOpen(PlannedExercise p) {
    p.open = !p.open;
    notifyListeners();
  }

  void addSet(PlannedExercise p) {
    final last = p.sets.isEmpty ? SetEntry() : p.sets.last;
    p.sets.add(SetEntry(reps: last.reps, kg: last.kg));
    notifyListeners();
  }

  void removeSet(PlannedExercise p, int index) {
    if (p.sets.length <= 1) return;
    p.sets.removeAt(index);
    notifyListeners();
  }

  void adjustReps(SetEntry s, int delta) {
    s.reps = math.max(1, math.min(99, s.reps + delta));
    notifyListeners();
  }

  void adjustKg(SetEntry s, double delta) {
    s.kg = math.max(0.0, s.kg + delta);
    notifyListeners();
  }

  /// Logs one session for the most common type in that day's plan.
  /// Returns that type, or null when the day is empty.
  WorkoutType? completeDay(int day) {
    final items = _plan[day] ?? const <PlannedExercise>[];
    if (items.isEmpty) return null;
    final counts = <WorkoutType, int>{};
    for (final p in items) {
      counts[p.exercise.type] = (counts[p.exercise.type] ?? 0) + 1;
    }
    var best = items.first.exercise.type;
    counts.forEach((t, c) {
      if (c > counts[best]!) best = t;
    });
    logWorkout(best);
    return best;
  }

  // ---- actions -------------------------------------------------------------

  void logWorkout(WorkoutType type) {
    _logs.add(WorkoutLog(type, DateTime.now()));
    me.workouts = totalWorkouts;
    notifyListeners();
  }

  void toggleFollow(String userId) {
    final user = _users[userId];
    if (user == null) return;
    if (_following.remove(userId)) {
      user.followers -= 1;
    } else {
      _following.add(userId);
      user.followers += 1;
    }
    notifyListeners();
  }

  /// Prototype purchase: no money moves. See docs/BACKEND.md for payments.
  void buyPlan(Plan plan) {
    if (owns(plan)) return;
    _purchasedPlanIds.add(plan.id);
    notifyListeners();
  }

  void publishPlan({
    required String title,
    required String description,
    required WorkoutType type,
    required int weeks,
    required double priceUsd,
  }) {
    _plans.insert(
      0,
      Plan(
        id: 'p${_nextPlanNumber++}',
        title: title,
        description: description,
        type: type,
        weeks: weeks,
        priceUsd: priceUsd,
        sellerId: meId,
      ),
    );
    notifyListeners();
  }

  void sendMessage(String toUserId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final list = _chats.putIfAbsent(toUserId, () => []);
    list.add(ChatMessage(fromId: meId, text: trimmed, sentAt: DateTime.now()));
    notifyListeners();
  }

  // ---- seed data -----------------------------------------------------------

  void _seed() {
    me = AppUser(
      id: meId,
      name: 'You',
      handle: 'you',
      bio: 'Add a bio',
      city: '',
    );

    void addUser(AppUser u) => _users[u.id] = u;
    addUser(AppUser(
      id: 'u1',
      name: 'Lana Ahmed',
      handle: 'lana.lifts',
      bio: 'Powerlifting coach. Strength plans that stick.',
      city: 'Erbil',
      followers: 1240,
      workouts: 312,
    ));
    addUser(AppUser(
      id: 'u2',
      name: 'Karwan Omar',
      handle: 'karwan.runs',
      bio: 'Marathon runner. 5K to half marathon plans.',
      city: 'Sulaimaniyah',
      followers: 860,
      workouts: 540,
    ));
    addUser(AppUser(
      id: 'u3',
      name: 'Dilan Salih',
      handle: 'dilan.flow',
      bio: 'Pilates instructor and mobility nerd.',
      city: 'Duhok',
      followers: 2100,
      workouts: 275,
    ));
    addUser(AppUser(
      id: 'u4',
      name: 'Hawre Jaza',
      handle: 'hawre.wod',
      bio: 'CrossFit coach. Daily WODs.',
      city: 'Kirkuk',
      followers: 530,
      workouts: 410,
    ));

    _plans.addAll(const [
      Plan(
        id: 'p1',
        title: '12-Week Strength Base',
        description:
            'Three full-body days a week built on squat, bench and deadlift.',
        type: WorkoutType.gym,
        weeks: 12,
        priceUsd: 14.99,
        sellerId: 'u1',
      ),
      Plan(
        id: 'p2',
        title: 'Couch to 10K',
        description: 'Walk-run intervals that build to a continuous 10K.',
        type: WorkoutType.running,
        weeks: 10,
        priceUsd: 9.99,
        sellerId: 'u2',
      ),
      Plan(
        id: 'p3',
        title: 'Core and Posture',
        description: 'Twenty-minute Pilates sessions for a stronger core.',
        type: WorkoutType.pilates,
        weeks: 6,
        priceUsd: 0,
        sellerId: 'u3',
      ),
      Plan(
        id: 'p4',
        title: 'Engine Builder WODs',
        description: 'Short, hard CrossFit workouts for conditioning.',
        type: WorkoutType.crossfit,
        weeks: 8,
        priceUsd: 12.50,
        sellerId: 'u4',
      ),
      Plan(
        id: 'p5',
        title: 'Weekly Recovery Reset',
        description: 'Mobility and stretching routine for rest days.',
        type: WorkoutType.recovery,
        weeks: 4,
        priceUsd: 0,
        sellerId: 'u3',
      ),
    ]);

    final now = DateTime.now();
    _posts.addAll([
      Post(
        id: 'post1',
        authorId: 'u1',
        text: 'New deadlift PR after 12 weeks on the base plan.',
        createdAt: now.subtract(const Duration(hours: 2)),
        attachment: const PostAttachment(
          kind: AttachmentKind.pr,
          title: 'Deadlift',
          detail: '180 kg x 1',
        ),
        baseLikes: 48,
      ),
      Post(
        id: 'post2',
        authorId: 'u3',
        text: 'My free core plan is live. Twenty minutes, no equipment.',
        createdAt: now.subtract(const Duration(hours: 5)),
        attachment: const PostAttachment(
          kind: AttachmentKind.plan,
          title: 'Core and Posture',
          detail: '6 weeks - Free',
        ),
        baseLikes: 91,
      ),
      Post(
        id: 'post3',
        authorId: 'u2',
        text: 'Sunday long run done. Easy pace, tired legs.',
        createdAt: now.subtract(const Duration(days: 1)),
        baseLikes: 27,
      ),
      Post(
        id: 'post4',
        authorId: 'u4',
        text: 'Fran today. Thrusters and pull-ups, nothing else.',
        createdAt: now.subtract(const Duration(days: 2)),
        attachment: const PostAttachment(
          kind: AttachmentKind.pr,
          title: 'Fran',
          detail: '4:52',
        ),
        baseLikes: 63,
      ),
    ]);

    _chats['u1'] = [
      ChatMessage(
        fromId: 'u1',
        text: 'Hey! Thanks for following. Questions about the plan?',
        sentAt: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }
}

/// Makes [AppState] available to the widget tree.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing above this widget');
    return scope!.notifier!;
  }
}
