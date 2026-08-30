# Stripe Setup for RePlate

## Keys (test mode)
Never commit secret keys. Publishable key is in `RePlate/StripeConfig.swift`.

### Set secrets in Supabase (one time):
```
supabase secrets set STRIPE_SECRET_KEY=sk_test_YOUR_SECRET_KEY
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_YOUR_WEBHOOK_SECRET
```

## iOS SDK — add in Xcode (one time):
1. File → Add Package Dependencies…
2. URL: https://github.com/stripe/stripe-ios
3. Add product: **StripePaymentSheet** to the RePlate target.
4. Uncomment the `import StripePaymentSheet` lines in `StripePaymentService.swift`.
5. Uncomment `STPAPIClient.shared.publishableKey = StripeConfig.publishableKey` in `RePlateApp.swift`.
6. Build (⌘B).

## Supabase Edge Functions — deploy (one time per change):
```
cd path/to/RePlate
supabase functions deploy create-payment-intent
supabase functions deploy stripe-webhook
```

## Stripe Webhook — register in dashboard:
1. Go to https://dashboard.stripe.com/test/webhooks → Add endpoint
2. URL: https://qubatmvrhcvllqwakcgk.supabase.co/functions/v1/stripe-webhook
3. Events: payment_intent.succeeded, payment_intent.payment_failed
4. Copy the signing secret → `supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...`

## Test cards:
- Success: 4242 4242 4242 4242, any future expiry, any 3-digit CVC
- Decline: 4000 0000 0000 0002

## Stripe Connect (Part F — future phase):
See Part F comments in StripePaymentService.swift. Requires onboarding restaurants
as Stripe Express accounts before marketplace payouts work.
