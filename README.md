# CrossGYM

A Flutter app for gym, running, CrossFit, Pilates and recovery workouts, with
profiles you can follow, achievements, a store where users sell workout plans,
and direct messages.

## Design

Dark "Hybrid Neo-Tokyo" look: obsidian-violet canvas, glass header and floating
tab dock, six switchable colour themes (palette icon in the header), Space
Grotesk headings, Inter body text and JetBrains Mono for numbers. Fonts load
from Google Fonts at run time, so the first load needs internet.

## What works now

- Dashboard with an estimated readiness score, streak, 6 hour recovery window and a 7 day chart
- Five workout types with an exercise library and animated drawings
- Plan: several named programs you can switch between (blank, template or from a store plan), a 3 step exercise picker, and a star on each exercise to edit its sets
- Log workouts, earn XP and levels, 10 metal-tier medals
- Social: feed with likes, posts with plan or PR attachments, follow, profiles
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

## Publish the web version (Cloudflare Pages)

A GitHub Action in `.github/workflows/deploy-web.yml` builds the web app and
deploys it to Cloudflare Pages on every push to `main`. Set it up once:

1. In Cloudflare, create an API token (My Profile → API Tokens → Create Token)
   with the permission **Account → Cloudflare Pages → Edit**.
2. Copy your Account ID from the Cloudflare dashboard (Workers & Pages page).
3. In the GitHub repo go to Settings → Secrets and variables → Actions and add
   two secrets: `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.
4. Push to `main`, or run the workflow from the Actions tab.

Your link will be `https://crossgym.pages.dev` (Cloudflare adds a suffix if the
name is taken; the deploy log shows the exact address).

## Layout

```
lib/
  main.dart            app shell and bottom navigation
  core/                colours, themes, shared widgets, exercise drawing widget
  data/                models, exercise list, in-memory AppState
  features/            home, plan, workouts, store, social, messages, profile
assets/art/            exercise drawings (see CREDITS.md)
tool/check_assets.sh   checks every exercise has its drawing
```

## Credits and license

Exercise art is from GymMane / Workout Guide / Everkinetic, CC BY-SA 4.0. See
[CREDITS.md](CREDITS.md). Add a license for your own code before you publish
the repository.
