# What a real version needs

The prototype keeps everything in `AppState`. Four features need a server:

- **Accounts and profiles:** sign-in, a public profile per user, avatar upload.
- **Follow and discovery:** a followers table and a way to search users.
- **Direct messages:** realtime delivery. Firebase or Supabase both give you
  this without writing a server.
- **Store:** plans stored on a server, with payment.

Pick one backend (Supabase or Firebase are the usual choices for a small team)
and replace `AppState` with repositories that call it. Keep screens reading
from the same interface so they do not change.

## Payments

Selling workout plans is selling digital content.

- On iOS and Android, digital content bought inside the app normally has to use
  Apple's and Google's in-app purchase, which take a commission.
- Paying creators out is a separate problem. Stripe Connect handles payouts,
  but it is not available in every country, and Iraq may not be covered. Check
  where your users and sellers are before choosing.
- Until you decide, the "Buy" button is a demo and takes no money.

## Moderation

User-to-user messaging and user-generated plans need a way to report and block
people. App stores require this for apps with user-generated content.
