# StoreKit 2 Gotchas

The non-obvious things that bite people. Read this before declaring a StoreKit setup "done."

## 1. Interrupted purchases (most-missed)

A purchase can complete *outside* your app — e.g., parent approves "Ask to Buy" hours later, or a pending bank transfer clears. If your app doesn't have a `Transaction.updates` listener running from launch, you'll miss this transaction and the user will be charged without getting the entitlement.

**Fix**: instantiate `SubscriptionManager` (which starts the listener) in your `App` struct's init or as a `@StateObject` — *not* lazily inside a view that only appears after onboarding.

## 2. Always verify transactions

Every `VerificationResult` has `.verified` and `.unverified` cases. The unverified case can come from jailbroken devices, MITM attacks, or local clock manipulation. Never grant entitlements based on an unverified transaction.

The skill's `SubscriptionManager.checkVerified` does this correctly. Don't remove it "to simplify."

## 3. `currentEntitlements` vs `Transaction.all`

- `Transaction.currentEntitlements` — only currently-valid entitlements. Use this for gating features.
- `Transaction.all` — every transaction ever, including expired and refunded. Use only for analytics or audit logs.

Using `Transaction.all` for entitlement checks is the most common reason expired subscriptions still grant access.

## 4. Always call `transaction.finish()`

After verifying a transaction, you MUST call `transaction.finish()`. If you don't, the App Store keeps re-delivering it on every launch indefinitely, and your `Transaction.updates` listener keeps firing.

This is easy to forget on the "pending" path — make sure your code calls finish after the resolution, not just after the initial purchase call.

## 5. Family sharing

If you mark a subscription as `familyShareable: true` in App Store Connect, family members get entitlements through `Transaction.currentEntitlements` automatically. But:
- The `ownershipType` on the transaction will be `.familyShared` vs `.purchased`
- You may want to track this for analytics (family-shared users have different retention characteristics)
- You cannot offer family-shared users promotional offers tied to their personal account

For v1 setups, leave `familyShareable: false` unless the user asks otherwise.

## 6. Why you still need server-side validation

Even though StoreKit 2 verifies transactions cryptographically on-device, you should *eventually* add server-side validation. Reasons:
- Cross-device entitlement sync (user buys on phone, opens iPad)
- Refund detection without waiting for the app to launch
- Fraud detection (e.g., revoke entitlements when Apple notifies you of a refund via App Store Server Notifications)
- Backend feature gating (if your app calls APIs, the server needs to know who's premium)

Apple's `App Store Server API` and `App Store Server Notifications V2` are the official path. The skill doesn't generate server code in v1 — flag this as a known gap when handing off.

## 7. Sandbox subscription durations are accelerated

In sandbox, a monthly subscription renews every 5 minutes and a yearly subscription renews every hour. This means:
- Don't be surprised when you see 6 renewals in an afternoon during testing
- Sandbox accounts are auto-cancelled after 6 renewals (then you can't test renewal anymore until you make a new sandbox account)
- This is the #1 reason "my renewal logic doesn't work" — it's actually working, the sandbox is just behaving as designed

## 8. Promotional offers and intro pricing

Out of scope for v1. If the user asks, explain:
- Introductory offers are configured in App Store Connect, surface automatically via `Product.subscription.introductoryOffer`
- Promotional offers (for win-back) require server-signed JWTs and are significantly more complex
- Recommend they ship without these first, then add intro offers in v1.1

## 9. Tax and banking config in App Store Connect

Apps with subscriptions cannot make ANY purchases — sandbox or production — until you complete:
- Paid Applications Agreement (in Agreements, Tax, and Banking)
- Tax forms for every region you sell in
- Banking info

This silently blocks everything with no clear error message in the app. If "Product.products(for:)" returns an empty array and there's no obvious bug, check this first.

## 10. Product ID mismatches

Product IDs are case-sensitive and must match exactly across three places:
1. App Store Connect product setup
2. `Products.storekit` configuration file
3. Your Swift code (`productIDs` set)

A typo in any one means `Product.products(for:)` silently returns fewer products than expected. There's no error — just missing products.

Recommended convention: `<bundle-id>.<tier>.<period>` — e.g., `com.example.myapp.pro.monthly`.
