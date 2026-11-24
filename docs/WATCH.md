# Watch connection

## What works

The Hub has a watch button. It opens a screen that connects to any device that
shares live heart rate over Bluetooth (the standard "Heart Rate" service), using
the browser's Web Bluetooth feature. While connected you see:

- live beats per minute, a zone label, and a short graph
- low, average and high for the current connection
- a heart-rate badge on the Train tab and a live card on the Hub

Readings are kept in memory only. Nothing is saved or sent anywhere.

Zones use an estimated maximum heart rate of 220 minus age. That is a rough
rule, not a measured maximum.

## Which devices

- Garmin watches with Broadcast Heart Rate turned on.
- Chest and arm straps from Polar, Wahoo, Coospo and most other makers.
- Not Apple Watch, Fitbit or Samsung watches by default; they do not share live
  heart rate with other devices.

## Which browsers

Chrome and Edge on Android, Windows, Mac and Linux, over HTTPS (Cloudflare Pages
is). Not Safari, Firefox, or any browser on iPhone. The screen says so when the
browser cannot connect.

## What is not built

- Syncing saved workouts, sleep or steps from Garmin, Apple Health, Fitbit,
  Samsung or Google. Each needs the maker's developer program and a server that
  holds sign-in tokens (see docs/BACKEND.md and docs/AUTH.md).
- A native iPhone or Android app, which could use the phone's own health
  services. This is the route for Apple Watch.
- GPS runs. A watch GPS track would need the same maker services.
