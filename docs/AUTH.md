# Sign in and calories

## What is real and what is a demo

- **Email sign up / sign in** works, but only inside one browser. Accounts are
  saved in the browser's local storage with a salted SHA-256 hash of the
  password. That is not real security: anyone with access to the browser can
  read or copy it, and the account does not exist on any other device.
- **Apple, Gmail and Facebook** buttons are simulated. They create a local
  account named "Apple user", "Google user" or "Facebook user" and call no
  provider.
- **Guest** creates a local account named "Guest".
- Workouts, posts, plans and messages are still in memory and reset on reload.
  Only the account, health answers and food log are saved.

The sign-in screen says this on screen.

## What a real version needs

1. A sign-in service such as Firebase Authentication or Supabase Auth. It stores
   accounts on a server and handles passwords, email verification and reset.
2. **Apple:** an Apple Developer account (paid). Apple's App Store rules require
   offering Sign in with Apple when an app offers other social sign-ins.
3. **Google:** an OAuth client ID from Google Cloud Console.
4. **Facebook:** an app in Meta for Developers.
5. Add `crossgym.pages.dev` (and your own domain) as an authorized domain in
   each provider.
6. A privacy policy and clear consent, because age, height, weight and food are
   health-related data. Store them on the server, protected per user.

Replace the methods in `lib/data/app_state.dart` marked under "accounts" with
calls to the service; the screens do not need to change.

## Calorie maths

1. Resting burn (BMR), Mifflin-St Jeor: `10 x kg + 6.25 x cm - 5 x age`, then
   `+5` for male or `-161` for female.
2. Daily burn = BMR x activity factor from weekly training hours:
   under 1 h 1.2, under 3 h 1.375, under 5 h 1.55, under 8 h 1.725, else 1.9.
3. Target = daily burn, minus 20% to lose weight, unchanged to maintain, plus
   10% to gain. Rounded to the nearest 10.
4. Weight loss never goes below 1,500 (male) or 1,200 (female), and is not
   offered under 18.
5. Protein per kg: 2.0 (lose), 1.6 (maintain), 1.8 (gain). Fat is 25% of
   calories. Carbs are the rest.

These are estimates, not medical advice. `test/nutrition_test.dart` checks them.
