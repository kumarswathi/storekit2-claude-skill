# Testing StoreKit 2 Subscriptions

There are three testing environments. Use them in this order — local is fastest, TestFlight is closest to production.

## 1. Local StoreKit Configuration (start here)

The `.storekit` file the skill generated. Tests purchase flow without needing any App Store Connect setup or Apple sandbox account.

**Setup:**
1. In Xcode: **Product → Scheme → Edit Scheme**
2. Run → Options → StoreKit Configuration → select `Products.storekit`
3. Run the app

**What it tests well:**
- Product loading
- Purchase flow UI
- Entitlement updates
- Restore purchases logic
- `hasActiveSubscription` gating

**What it does NOT test:**
- Real App Store Connect product configuration (catches typos in product IDs)
- Actual receipt format / server validation
- Apple's purchase UI (sheet styling, family approval flow)
- Renewal behavior over time (you can simulate with the Transactions Manager, but it's not the same)

**Useful Xcode menus while testing:**
- **Debug → StoreKit → Manage Transactions** — view, refund, expire, or revoke transactions
- **Debug → StoreKit → Set Renewal Rate** — speed up renewals for testing

## 2. Sandbox (use before TestFlight)

Real Apple Sandbox environment. Requires App Store Connect product setup and a sandbox tester account.

**Setup:**
1. Complete App Store Connect product setup (see `app-store-connect-checklist.md`)
2. Create a sandbox tester (Users and Access → Sandbox → Test Accounts)
3. On device: **Settings → App Store → Sandbox Account** → sign in
4. In Xcode scheme, **disable** the StoreKit Configuration file (set to None)
5. Run the app on a real device (sandbox doesn't work on simulator for all flows)

**What it tests:**
- Everything local does, PLUS:
- Real Apple Purchase UI
- Actual product fetch from App Store Connect (catches Product ID mismatches!)
- Renewal behavior (accelerated — see below)
- Real receipt format

**Accelerated renewal in sandbox:**
| Real duration | Sandbox duration |
|---|---|
| 1 week | 3 minutes |
| 1 month | 5 minutes |
| 3 months | 10 minutes |
| 6 months | 15 minutes |
| 1 year | 1 hour |

Sandbox auto-cancels after 6 renewals on the same account. Make new sandbox accounts when you exhaust them.

## 3. TestFlight (final check before launch)

Closest thing to production. Apps go through a light review, then internal/external testers can install.

**What it tests that sandbox doesn't:**
- Real review screenshots (catches paywall layout issues at review)
- The actual install + first-launch flow
- Crash reporting / production telemetry

**Note:** TestFlight purchases use sandbox payment, not real charges, so no actual money moves. But the rest of the flow is production-grade.

## Recommended workflow

1. Develop with local `.storekit` file — fast iteration
2. Once flow works locally, configure App Store Connect and test in sandbox — catches config mismatches
3. Submit to TestFlight before App Store — catches anything sandbox missed
4. Launch

Most StoreKit bugs are caught at step 2 (sandbox), not step 1 (local). Don't skip sandbox testing.
