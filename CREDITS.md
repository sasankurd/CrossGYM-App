# Credits

## Exercise illustrations (assets/art/)

The 394 files in `assets/art/` are copied unchanged from
[GymMane](https://github.com/InlitX/GymMane) by InlitX. GymMane's own
credits say they come from:

- [Workout Guide](https://github.com/bryllim/workout-guide) by Bryl Lim, which
  builds on pose artwork from [Everkinetic](https://github.com/everkinetic/data).
- Everkinetic `dist/svg/` drawings, rasterized, traced and converted by GymMane.
- [Open Exercise Art](https://github.com/AlexMollard/Open-Exercise-Art) by Alex
  Mollard, the starting point for `reverse-pec-deck` and `bayesian-cable-curl`.

All of it is licensed under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

**What that means for this repository**

- Keep this credit and a link to the license (the in-app About screen does).
- If you change the drawings, share your changed versions under CC BY-SA 4.0 too.
- The license covers the art, not the Dart code in `lib/`. That code is
  written from scratch for CrossGYM and no GymMane source code is copied, so
  GymMane's GPL-3.0 does not apply to it. If you later copy any GymMane code,
  the GPL-3.0 and its "Based on GymMane by InlitX" notice apply to that work.

## Changes made

None to the drawings. Each file keeps GymMane's format: one SVG path per line,
one line per pose.

## Body diagram (lib/data/body_paths.dart)

The male front and back muscle outlines are from
[MuscleMap](https://github.com/melihcolpan/MuscleMap) by Melih Colpan, MIT
License (Copyright (c) 2026 Melih Colpan), taken from the converted path data in
[openGym](https://github.com/DuarteSantos8/openGym) `frontend/src/lib/body-paths.js`.
Only the outlines were used; openGym's exercise photos and animations are
licensed by Gym visual and are NOT used in this app.

MIT License: permission is granted, free of charge, to use, copy, modify,
merge, publish, distribute, sublicense and sell copies of the software, provided
the copyright notice and this permission notice are included in all copies. The
software is provided "as is", without warranty of any kind.
