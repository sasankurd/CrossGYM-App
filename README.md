# CrossGYM

A Flutter app for gym, running, CrossFit, Pilates and recovery workouts, with
profiles you can follow, achievements, a store where users sell workout plans,
and direct messages.

## What works now

- Five workout types with an exercise library and animated drawings
- Log workouts, earn XP, levels and 9 achievements
- Profiles, follow and unfollow, other users' plans
- Store: browse, get free plans, publish your own plan with a price
- Direct messages with a chat screen

Everything is stored in memory with seed data, so it resets on restart. Follow,
messages and the store do not talk to a server yet. See
[docs/BACKEND.md](docs/BACKEND.md).

## Run it

This repo holds the Dart code and assets. Generate the platform folders once:

```
flutter create . --project-name crossgym --org com.crossgym
flutter pub get
flutter run
```

## Layout

```
lib/
  main.dart            app shell and bottom navigation
  core/                theme and the exercise drawing widget
  data/                models, exercise list, in-memory AppState
  features/            home, workouts, store, social, messages, profile
assets/art/            exercise drawings (see CREDITS.md)
tool/check_assets.sh   checks every exercise has its drawing
```

## Credits and license

Exercise art is from GymMane / Workout Guide / Everkinetic, CC BY-SA 4.0. See
[CREDITS.md](CREDITS.md). Add a license for your own code before you publish
the repository.
