# App Store Connect Checklist

These steps cannot be automated — they must be done in the App Store Connect web UI. Walk the user through them in order. Missing any of these silently breaks the subscription flow.

## Before you start

You need:
- An active Apple Developer Program membership ($99/year)
- The app already created in App Store Connect (even if not yet submitted)
- Admin or Account Holder role on the Apple Developer account

## Step 1: Agreements, Tax, and Banking (the silent killer)

Go to **App Store Connect → Business → Agreements, Tax, and Banking**.

- [ ] Paid Applications Agreement: status is "Active" (not "Action Needed")
- [ ] Tax forms completed for the US (W-9 or W-8BEN) at minimum
- [ ] Tax forms completed for any other region you plan to sell in
- [ ] Banking info added and verified
- [ ] Contact info filled in for all four contact types

**Until all of these say "Active," your app cannot make any purchases — sandbox or production. This is the #1 silent blocker.**

## Step 2: Create the subscription group

In your app: **Monetization → Subscriptions → Manage**.

- [ ] Create a new subscription group (e.g., "Pro")
- [ ] The group name should match what you used in `Products.storekit`

## Step 3: Create each subscription product

For each tier (e.g., monthly, yearly):

- [ ] Click "+" to add a subscription
- [ ] Reference Name: internal label (e.g., "Pro Monthly")
- [ ] Product ID: must exactly match what's in your Swift code and .storekit file
- [ ] Subscription Duration: 1 Month, 1 Year, etc.
- [ ] Subscription Group: select the group from Step 2
- [ ] Family Sharing: leave OFF for v1 unless explicitly wanted
- [ ] Pricing: set the base price tier
- [ ] Localizations: add at least one language (English) with:
  - [ ] Display Name (shown to user — e.g., "Pro Monthly")
  - [ ] Description (shown to user — e.g., "Unlimited features, billed monthly")
- [ ] Review Information:
  - [ ] Screenshot of the paywall (required for review)
  - [ ] Review notes (optional)

## Step 4: Submit subscriptions for review (with first app submission only)

The first time you submit subscriptions, they must be reviewed alongside an app version. After that, you can edit and add subscriptions without a new app review.

- [ ] In the App Store tab, attach the new subscriptions to your app version submission

## Step 5: Set up sandbox testers

For sandbox testing (real Apple ID flow, not just the local .storekit file):

- [ ] Go to **Users and Access → Sandbox → Test Accounts**
- [ ] Create at least one sandbox tester (use an email you don't already use for an Apple ID)
- [ ] On your test device: **Settings → App Store → Sandbox Account** → sign in
- [ ] **Important**: never sign into iCloud with a sandbox account, only use it in the App Store sandbox section

## Step 6: Verify with the local .storekit file first

Before testing in sandbox:

- [ ] Open `Products.storekit` in Xcode
- [ ] In your scheme: **Edit Scheme → Run → Options → StoreKit Configuration** → select `Products.storekit`
- [ ] Run the app and confirm `subscriptions.products` is populated
- [ ] Make a test purchase — should succeed instantly and flip `hasActiveSubscription` to `true`

If this works locally but not in sandbox, the issue is almost certainly Step 1 (Agreements, Tax, Banking) or Step 3 (Product ID mismatch).

## Common review rejections

Apple will reject the app if:
- Paywall doesn't show the price clearly (use `product.displayPrice`, not hardcoded strings)
- "Restore Purchases" button is missing
- Terms of Use and Privacy Policy links are missing or broken
- Subscription length and auto-renewal aren't disclosed near the purchase button
- Screenshots in App Store Connect don't match what the user sees

The provided `PaywallView.swift` covers all of these except the Terms/Privacy URLs, which you must replace with real ones.
