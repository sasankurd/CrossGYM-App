import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/tokens.dart';
import 'accounts.dart';
import 'exercise_catalog.dart';
import 'models.dart';
import 'nutrition.dart';
import 'program_templates.dart';

/// In-memory app state with seed data.
///
/// Follow, messages, posts and the store are local only for now. Replace this
/// class with repositories backed by a real service (see docs/BACKEND.md).
class AppState extends ChangeNotifier {
  AppState({SharedPreferences? prefs}) : _prefs = prefs {
    _loadAccounts();
    _seed();
    _restoreSession();
  }

  static const String meId = 'me';

  final SharedPreferences? _prefs;
  late AppUser me;
  final Map<String, AppUser> _users = {};
  final List<Plan> _plans = [];
  final Set<String> _following = {};
  final Set<String> _purchasedPlanIds = {};
  final Map<String, List<ChatMessage>> _chats = {};
  final List<WorkoutLog> _logs = [];
  final List<Post> _posts = [];
  final Set<String> _likedPostIds = {};
  final List<Program> _programs = [];
  String _activeProgramId = '';
  int _themeIndex = 0;
  int _nextPlanNumber = 100;
  int _nextPostNumber = 100;
  int _nextPlannedId = 1;
  int _nextProgramNumber = 2;

  // ---- accounts (demo: stored in this browser only) -------------------------

  final List<AuthAccount> _accounts = [];
  AuthAccount? _account;
  HealthProfile? _profile;
  final List<FoodEntry> _foods = [];

  AuthAccount? get account => _account;
  bool get isSignedIn => _account != null;
  bool get isGuest => _account?.isGuest ?? false;
  bool get needsOnboarding => isSignedIn && _profile == null;
  HealthProfile? get profile => _profile;

  void _loadAccounts() {
    final raw = _prefs?.getString('accounts');
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _accounts.addAll([
        for (final j in list) AuthAccount.fromJson(j as Map<String, dynamic>),
      ]);
    } on Object {
      _accounts.clear();
    }
  }

  void _saveAccounts() => _prefs?.setString(
        'accounts',
        jsonEncode([for (final a in _accounts) a.toJson()]),
      );

  void _restoreSession() {
    final id = _prefs?.getString('session');
    if (id == null) return;
    for (final a in _accounts) {
      if (a.id == id) {
        _activate(a);
        return;
      }
    }
  }

  static String _handleFor(AuthAccount a) {
    final base = a.email.isNotEmpty ? a.email.split('@').first : a.name;
    final clean = base.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._]'), '');
    return clean.isEmpty ? a.provider : clean;
  }

  void _activate(AuthAccount a) {
    _account = a;
    _prefs?.setString('session', a.id);
    me.name = a.name;
    me.handle = _handleFor(a);
    _profile = null;
    _foods.clear();
    final rawProfile = _prefs?.getString('profile:${a.id}');
    if (rawProfile != null) {
      try {
        _profile = HealthProfile.fromJson(
            jsonDecode(rawProfile) as Map<String, dynamic>);
      } on Object {
        _profile = null;
      }
    }
    final rawFoods = _prefs?.getString('foods:${a.id}');
    if (rawFoods != null) {
      try {
        _foods.addAll([
          for (final j in jsonDecode(rawFoods) as List<dynamic>)
            FoodEntry.fromJson(j as Map<String, dynamic>),
        ]);
      } on Object {
        _foods.clear();
      }
    }
    notifyListeners();
  }

  /// Returns an error message, or null when the account was created.
  String? signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    if (cleanName.isEmpty) return 'Enter your name.';
    if (!looksLikeEmail(cleanEmail)) return 'Enter a valid email address.';
    if (password.length < 8) return 'Use at least 8 characters for the password.';
    if (_accounts.any((a) => a.provider == 'email' && a.email == cleanEmail)) {
      return 'An account with this email already exists. Sign in instead.';
    }
    final salt = newSalt();
    final account = AuthAccount(
      id: 'email:$cleanEmail',
      name: cleanName,
      provider: 'email',
      email: cleanEmail,
      salt: salt,
      hash: hashPassword(password, salt),
    );
    _accounts.add(account);
    _saveAccounts();
    _activate(account);
    return null;
  }

  /// Returns an error message, or null when signed in.
  String? signInWithEmail(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    for (final a in _accounts) {
      if (a.provider == 'email' &&
          a.email == cleanEmail &&
          a.hash == hashPassword(password, a.salt)) {
        _activate(a);
        return null;
      }
    }
    return 'Email or password is incorrect.';
  }

  /// Simulated Apple, Google or Facebook sign-in. No real provider is called.
  void signInDemo(String provider) {
    final existing = _accounts.where((a) => a.id == provider);
    if (existing.isNotEmpty) {
      _activate(existing.first);
      return;
    }
    final label = switch (provider) {
      'apple' => 'Apple',
      'google' => 'Google',
      _ => 'Facebook',
    };
    final account =
        AuthAccount(id: provider, name: '$label user', provider: provider);
    _accounts.add(account);
    _saveAccounts();
    _activate(account);
  }

  void continueAsGuest() {
    final existing = _accounts.where((a) => a.id == 'guest');
    if (existing.isNotEmpty) {
      _activate(existing.first);
      return;
    }
    const guest = AuthAccount(id: 'guest', name: 'Guest', provider: 'guest');
    _accounts.add(guest);
    _saveAccounts();
    _activate(guest);
  }

  void signOut() {
    _account = null;
    _profile = null;
    _foods.clear();
    _prefs?.remove('session');
    _resetWorld();
    notifyListeners();
  }

  /// Clears everything that belongs to the signed-in person.
  void _resetWorld() {
    _users.clear();
    _plans.clear();
    _following.clear();
    _purchasedPlanIds.clear();
    _chats.clear();
    _logs.clear();
    _posts.clear();
    _likedPostIds.clear();
    _programs.clear();
    _activeProgramId = '';
    _nextPlannedId = 1;
    _nextProgramNumber = 2;
    _seed();
  }

  void saveProfile(HealthProfile p) {
    _profile = p;
    final id = _account?.id;
    if (id != null) _prefs?.setString('profile:$id', jsonEncode(p.toJson()));
    notifyListeners();
  }

  // ---- calorie tracker -------------------------------------------------------

  List<FoodEntry> foodsOn(DateTime day) {
    final d = DateUtils.dateOnly(day);
    final list = _foods.where((f) => DateUtils.dateOnly(f.at) == d).toList();
    list.sort((a, b) => a.at.compareTo(b.at));
    return list;
  }

  int caloriesOn(DateTime day) =>
      foodsOn(day).fold(0, (sum, f) => sum + f.kcal);
  double proteinOn(DateTime day) =>
      foodsOn(day).fold(0.0, (sum, f) => sum + f.protein);
  double carbsOn(DateTime day) =>
      foodsOn(day).fold(0.0, (sum, f) => sum + f.carbs);
  double fatOn(DateTime day) =>
      foodsOn(day).fold(0.0, (sum, f) => sum + f.fat);

  void _saveFoods() {
    final id = _account?.id;
    if (id == null) return;
    _prefs?.setString(
        'foods:$id', jsonEncode([for (final f in _foods) f.toJson()]));
  }

  void addFood({
    required String name,
    required int kcal,
    required Meal meal,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    DateTime? at,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || kcal <= 0) return;
    final when = at ?? DateTime.now();
    _foods.add(FoodEntry(
      id: 'f${when.microsecondsSinceEpoch}-${_foods.length}',
      name: trimmed,
      kcal: kcal,
      protein: protein,
      carbs: carbs,
      fat: fat,
      meal: meal,
      at: when,
    ));
    _saveFoods();
    notifyListeners();
  }

  void removeFood(String id) {
    _foods.removeWhere((f) => f.id == id);
    _saveFoods();
    notifyListeners();
  }

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
    final pool = (_profile?.types.isNotEmpty ?? false)
        ? WorkoutType.values.where(_profile!.types.contains).toList()
        : WorkoutType.values;
    var best = pool.first;
    var fewest = 1 << 30;
    for (final t in pool) {
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

  // ---- programs and weekly plan --------------------------------------------

  List<Program> get programs => List.unmodifiable(_programs);

  Program get activeProgram =>
      _programs.firstWhere((p) => p.id == _activeProgramId);

  void selectProgram(String id) {
    if (_programs.any((p) => p.id == id)) {
      _activeProgramId = id;
      notifyListeners();
    }
  }

  /// Creates an empty program and makes it the active one.
  void createProgram(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final p = Program(id: 'prog${_nextProgramNumber++}', name: trimmed);
    _programs.add(p);
    _activeProgramId = p.id;
    notifyListeners();
  }

  void renameProgram(String id, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    for (final p in _programs) {
      if (p.id == id) p.name = trimmed;
    }
    notifyListeners();
  }

  /// Deletes a program. The last remaining program cannot be deleted.
  void deleteProgram(String id) {
    if (_programs.length <= 1) return;
    _programs.removeWhere((p) => p.id == id);
    if (_activeProgramId == id) _activeProgramId = _programs.first.id;
    notifyListeners();
  }

  /// Copies a template into a new program and makes it the active one.
  void addProgramFromTemplate(ProgramTemplate t, {String? name}) {
    final p = Program(
      id: 'prog${_nextProgramNumber++}',
      name: name ?? t.name,
      description: t.description,
    );
    t.days.forEach((day, slugs) {
      for (final slug in slugs) {
        final e = exerciseBySlug(slug);
        if (e != null) {
          p.days[day]!.add(PlannedExercise(id: _nextPlannedId++, exercise: e));
        }
      }
    });
    _programs.add(p);
    _activeProgramId = p.id;
    notifyListeners();
  }

  /// Turns a store plan you own into a program, based on its workout type.
  void addProgramFromPlan(Plan plan) =>
      addProgramFromTemplate(templateForType(plan.type), name: plan.title);

  List<PlannedExercise> planFor(int day) =>
      List.unmodifiable(activeProgram.days[day] ?? const <PlannedExercise>[]);

  void addToPlan(int day, Exercise e) {
    activeProgram.days[day]!
        .add(PlannedExercise(id: _nextPlannedId++, exercise: e));
    notifyListeners();
  }

  void removeFromPlan(int day, PlannedExercise p) {
    activeProgram.days[day]!.removeWhere((x) => x.id == p.id);
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
    final items = activeProgram.days[day] ?? const <PlannedExercise>[];
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

    final starter = Program(id: 'prog1', name: 'My Program');
    _programs.add(starter);
    _activeProgramId = starter.id;

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
