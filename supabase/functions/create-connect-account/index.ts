// FUTURE PHASE — Stripe Connect for restaurant payouts
// This function creates a Stripe Express account for a restaurant and
// returns an AccountLink URL for onboarding. Requires:
// 1. stripe.accounts.create({ type: "express" })
// 2. stripe.accountLinks.create({ account: id, type: "account_onboarding", ... })
// 3. Store the connected account id in restaurants.stripe_account_id
// 4. On PaymentIntent, set transfer_data.destination = restaurant.stripe_account_id
//    and application_fee_amount = platform fee
// Currently not active — payments go to the platform Stripe account.

export {}
