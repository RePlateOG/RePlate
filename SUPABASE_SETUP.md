# RePlate — Supabase Setup

This connects the iOS app to a real backend: **auth + Postgres database + file storage + realtime**.

- Database schema lives in [`supabase/schema.sql`](supabase/schema.sql).
- The app's Supabase client lives in [`RePlate/SupabaseConfig.swift`](RePlate/SupabaseConfig.swift).
- Auth method: **email + password**.

> The publishable key in `SupabaseConfig.swift` is meant to be embedded in the app and is
> protected by Row Level Security. **Never** add the Supabase *secret* / `service_role` key
> to the app or to git.

---

## Step 1 — Create the database (do this once, in the browser)

1. Open your project: https://qubatmvrhcvllqwakcgk.supabase.co
2. Left sidebar → **SQL Editor** → **New query**.
3. Open `supabase/schema.sql` from this repo, copy ALL of it, paste, and click **Run**.
4. Confirm it succeeds. You should now see tables under **Table Editor** (profiles,
   restaurants, listings, orders, conversations, messages, notifications, payment_methods,
   reports) and buckets under **Storage** (avatars, restaurant-images, listing-images).

## Step 2 — Turn on email auth

1. Left sidebar → **Authentication** → **Providers** → ensure **Email** is enabled.
2. For easy testing: **Authentication → Providers → Email → turn OFF "Confirm email"**
   (so test signups log in immediately). Turn it back on before a real launch.

## Step 3 — Add the Swift package (in Xcode, on the Mac)

1. Open `RePlate.xcodeproj`.
2. **File → Add Package Dependencies…**
3. Paste: `https://github.com/supabase/supabase-swift`
4. Add the **Supabase** library to the **RePlate** target.
5. Make sure `RePlate/SupabaseConfig.swift` is a member of the RePlate target
   (File Inspector → Target Membership). Build (⌘B) — it should compile.

## Step 4 — Wire the app to Supabase

The app currently uses in-memory mock data (`MockData.swift`, the various `ViewModels`,
`AuthService`, `AppState`). Replace that with real Supabase calls. Run the prompt in the
next section with Claude Code in this repo, on the Mac, so it can build and verify.

---

## Prompt: wire the app to Supabase (paste into Claude Code on the Mac)

```text
The RePlate iOS app now has a Supabase backend. The schema is already applied
(supabase/schema.sql) and the client is configured in RePlate/SupabaseConfig.swift,
which exposes a global `supabase` SupabaseClient. Auth is email + password.

Goal: replace the in-memory mock data with real Supabase auth, database, and storage,
end to end, and verify it builds and runs in the simulator.

Do this in order, building after each step and fixing errors before continuing:

1) AUTH (AuthService.swift / AppState.swift / OnboardingView.swift):
   - Sign up with email+password via `supabase.auth.signUp(email:password:data:)`,
     passing name and account_type ('customer' or 'restaurant') in the metadata `data`
     so the DB trigger creates the matching profiles row.
   - Sign in via `supabase.auth.signIn(email:password:)`. Sign out via signOut().
   - On launch, restore the session (`supabase.auth.session`) and set isAuthenticated.
   - Load the current user's profile row into AppState.currentUser.
   - Keep the existing legal/terms consent gate; on acceptance, set profiles.accepted_terms_at.

2) DATA LAYER (replace MockData usage in the ViewModels):
   - Listings: fetch from `listings` (join restaurant), filter by category/search.
   - Orders: customer places an order (insert into `orders`); customer sees their orders;
     restaurant sees orders for their restaurant. Status transitions update the row.
   - Restaurant: dashboard listings come from `listings` where restaurant_id = the owner's
     restaurant; PostSurplusView inserts a new listing row.
   - Messages: conversations + messages tables; load and send real messages.
   - Use Codable structs matching the SQL columns (snake_case → use CodingKeys or a
     keyDecodingStrategy). Decode dates as ISO8601/timestamptz.

3) STORAGE (photo uploads):
   - Upload profile avatar to bucket `avatars`, restaurant logo/cover to
     `restaurant-images`, listing photos to `listing-images`.
   - IMPORTANT: upload to a path that starts with the user's uid folder, e.g.
     "<uid>/<filename>.jpg" — the storage RLS policy requires the first path segment to be
     auth.uid(). Save the resulting public URL on the profile/restaurant/listing row.

4) REALTIME (optional but nice):
   - Subscribe to `messages` and `orders` changes so the Messages and Orders screens
     update live.

5) ANTI-FRAUD hooks already in the schema:
   - Pickup uses orders.pickup_code (single use). When the restaurant confirms pickup,
     set status='completed', completed_at=now(), pickup_code_used=true. Don't allow
     completing an order whose code is already used or whose window expired.
   - Wire the reports table to the in-app "Report" action.

Definition of done: app builds; you can sign up + sign in as a customer AND as a
restaurant with real accounts; listings/orders/messages persist in Supabase (verify in
the Supabase Table Editor); photo uploads appear in Storage; no mock data remains in the
main flows. Summarize files changed, then commit and push.
```

---

## Troubleshooting
- **"No such module 'Supabase'"** → the Swift package wasn't added to the RePlate target (Step 3).
- **Rows don't appear / permission denied** → check you ran the whole `schema.sql` (RLS policies are at the bottom) and that you're signed in.
- **Signup works but no profile row** → confirm the `on_auth_user_created` trigger exists (it's in the schema) and that you passed `account_type` in the signup metadata.
- **Image upload denied** → the upload path must start with the signed-in user's uid (see Storage step).
