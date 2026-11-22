import 'package:flutter/material.dart';

import 'models.dart';

/// In-memory app state with seed data.
///
/// Follow, messages and the store are local only for now. Replace this class
/// with repositories backed by a real service (see docs/BACKEND.md).
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
  final Map<WorkoutType, int> _workoutsByType = {
    for (final t in WorkoutType.values) t: 0,
  };
  int _streakDays = 0;
  int _nextPlanNumber = 100;

  // ---- reads ---------------------------------------------------------------

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

  int get totalWorkouts =>
      _workoutsByType.values.fold(0, (sum, v) => sum + v);
  int workoutsOf(WorkoutType t) => _workoutsByType[t] ?? 0;
  int get streakDays => _streakDays;
  int get xp => totalWorkouts * 50 + _following.length * 5;
  int get level => 1 + xp ~/ 250;
  double get levelProgress => (xp % 250) / 250;

  List<ChatMessage> chatWith(String userId) =>
      List.unmodifiable(_chats[userId] ?? const []);

  /// User ids that have a conversation, most recent first.
  List<String> get conversationIds {
    final ids = _chats.keys.where((k) => _chats[k]!.isNotEmpty).toList();
    ids.sort((a, b) =>
        _chats[b]!.last.sentAt.compareTo(_chats[a]!.last.sentAt));
    return ids;
  }

  List<Achievement> get achievements => [
        Achievement(
          title: 'First step',
          description: 'Log your first workout',
          icon: Icons.flag,
          goal: 1,
          progress: totalWorkouts,
        ),
        Achievement(
          title: 'Getting serious',
          description: 'Log 10 workouts',
          icon: Icons.local_fire_department,
          goal: 10,
          progress: totalWorkouts,
        ),
        Achievement(
          title: 'Machine',
          description: 'Log 50 workouts',
          icon: Icons.military_tech,
          goal: 50,
          progress: totalWorkouts,
        ),
        Achievement(
          title: 'On a roll',
          description: 'Train 7 days in a row',
          icon: Icons.calendar_month,
          goal: 7,
          progress: _streakDays,
        ),
        Achievement(
          title: 'Road runner',
          description: 'Log 5 running workouts',
          icon: Icons.directions_run,
          goal: 5,
          progress: workoutsOf(WorkoutType.running),
        ),
        Achievement(
          title: 'Box regular',
          description: 'Log 5 CrossFit workouts',
          icon: Icons.bolt,
          goal: 5,
          progress: workoutsOf(WorkoutType.crossfit),
        ),
        Achievement(
          title: 'Well rounded',
          description: 'Try all five workout types',
          icon: Icons.donut_large,
          goal: WorkoutType.values.length,
          progress: _workoutsByType.values.where((v) => v > 0).length,
        ),
        Achievement(
          title: 'Social',
          description: 'Follow 3 people',
          icon: Icons.group,
          goal: 3,
          progress: _following.length,
        ),
        Achievement(
          title: 'Coach',
          description: 'Publish a plan in the store',
          icon: Icons.storefront,
          goal: 1,
          progress: myPlans.length,
        ),
      ];

  // ---- actions -------------------------------------------------------------

  void logWorkout(WorkoutType type) {
    _workoutsByType[type] = (_workoutsByType[type] ?? 0) + 1;
    me.workouts = totalWorkouts;
    // Prototype streak: one more day per logged workout.
    // A real version compares calendar days.
    _streakDays += 1;
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

    _chats['u1'] = [
      ChatMessage(
        fromId: 'u1',
        text: 'Hey! Thanks for following. Questions about the plan?',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
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
