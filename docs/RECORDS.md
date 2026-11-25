# Records

The Hub has a Records section listing every logged workout. Open it to filter
by type (running, gym, CrossFit, Pilates, recovery) and by date (all time,
7 days, 30 days, this year, or a date range you pick).

## Running tab
- **Record a run**: uses the browser's location (GPS). The page must stay open
  and the screen on, because a web page cannot track you while the phone is
  locked. Readings less accurate than 50 m and moves under 3 m are ignored.
- **Import from watch**: reads a GPX route file. Export one from Garmin Connect
  (activity, then Export to GPX), Strava or Apple Fitness exports. Time, distance
  and average heart rate (when present) are read from the file.
  Direct automatic sync with Garmin or Apple is NOT built: it needs their
  developer approval and a server.
- **Map**: drawn with flutter_map using OpenStreetMap pictures, which need an
  internet connection. OpenStreetMap's tile policy is meant for light use; for
  heavy traffic switch to a paid tile provider.

## Storage
Workouts are saved per account in this browser (`logs:<account id>`). Routes
are thinned to at most 300 points to keep storage small. Clearing site data
removes them until there is a server (see BACKEND.md).
