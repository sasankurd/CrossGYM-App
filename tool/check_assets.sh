#!/usr/bin/env bash
# Fails if an exercise in the catalog has no drawing in assets/art.
set -euo pipefail
cd "$(dirname "$0")/.."
missing=0
for slug in $(grep -oE "Exercise\('[a-z0-9-]+'" lib/data/exercise_catalog.dart | sed -E "s/Exercise\('//; s/'//"); do
  if [ ! -f "assets/art/$slug.txt" ]; then
    echo "missing: assets/art/$slug.txt"
    missing=1
  fi
done
if [ "$missing" -eq 0 ]; then echo "all exercise drawings present"; fi
exit "$missing"
