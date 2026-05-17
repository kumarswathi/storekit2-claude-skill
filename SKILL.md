---
name: storekit2-subscriptions
description: Scaffolds a complete StoreKit 2 auto-renewable subscription implementation in a SwiftUI iOS app — including a subscription manager actor, transaction listener, customizable paywall view, and a local .storekit config for sandbox-free testing. Use this skill whenever the user wants to add subscriptions, in-app purchases, paid tiers, or premium features to an iOS app, even if they don't explicitly say "StoreKit." Also use when they mention paywalls, RevenueCat alternatives, App Store subscriptions, or "monetize my iOS app." Targets iOS 17+ and SwiftUI.
---

# StoreKit 2 Subscriptions

Set up auto-renewable subscriptions in a SwiftUI iOS app end-to-end. This skill ships working Swift templates, a local testing config, and a checklist for App Store Connect — so the user can go from zero to a working purchase flow in about an hour.

## When to use this skill

Trigger when the user wants to add:
- Auto-renewable subscriptions (monthly, yearly, weekly)
- A paywall or "go premium" screen
- Restore purchases functionality
- Entitlement checks gating premium features

Do **not** use this skill (yet) for:
- One-time purchases (consumables, non-consumables) — v2
- Server-side receipt validation code — v2 (the skill explains *why* it matters but doesn't generate server code)
- UIKit projects — SwiftUI only for v1
- Promotional offers or introductory pricing logic — v2

If the user needs any of the above, tell them so and offer the v1 scope as a starting point.

## What this skill produces

By the end, the user's project will contain:

```
YourApp/
├── Subscriptions/
│   ├── SubscriptionManager.swift   (actor: products, purchase, entitlements)
│   ├── TransactionListener.swift   (handles updates from outside the app)
│   └── PaywallView.swift           (SwiftUI paywall, customization marked)
└── Products.storekit               (local config for testing without sandbox)
```

Plus a checklist of App Store Connect steps they need to do themselves (you can't automate those).

## Workflow

Follow these steps in order. Don't skip the interview — getting product IDs wrong is the #1 reason StoreKit setups fail silently.

### Step 1: Interview the user

Ask these questions in one batch (not one at a time):

1. **App's bundle identifier** (e.g., `com.example.myapp`) — needed for the .storekit config.
2. **Subscription tiers**: how many, and what are the names? (e.g., "Pro Monthly" and "Pro Yearly")
3. **Product IDs** they want to use. Recommend the format `com.example.myapp.pro.monthly` and `com.example.myapp.pro.yearly`. If they don't have a preference, propose IDs and confirm.
4. **Prices** for local testing (these are just for the .storekit file; real prices get set in App Store Connect).
5. **Subscription group name** — all auto-renewable subs must belong to a group. Default: `Pro`.
6. **Where to put the files** — confirm `Subscriptions/` folder at project root unless they specify.

### Step 2: Verify project compatibility

Before generating files, confirm:
- Xcode 15+ and iOS 17+ deployment target (StoreKit 2 features used require this)
- Project is SwiftUI-based (look for `@main` struct conforming to `App`, not `AppDelegate`)
- StoreKit capability will need to be added — flag this for the user

If any of these are missing, tell the user what they need to do before proceeding. Don't generate files into an incompatible project.

### Step 3: Generate the templates

Copy these files from `templates/` into the user's project, substituting their values:

- `templates/SubscriptionManager.swift` → `Subscriptions/SubscriptionManager.swift`
- `templates/TransactionListener.swift` → `Subscriptions/TransactionListener.swift`
- `templates/PaywallView.swift` → `Subscriptions/PaywallView.swift`
- `templates/Products.storekit` → project root, with product IDs and prices substituted in

Substitution targets in the templates:
- `{{BUNDLE_ID}}` → user's bundle identifier
- `{{PRODUCT_IDS}}` → user's product IDs as a Swift array literal
- `{{SUBSCRIPTION_GROUP}}` → user's group name

After generating, show the user the diff/files and explain what each one does in one sentence.

### Step 4: Wire it into the app

Show the user how to:
1. Instantiate `SubscriptionManager` as a `@StateObject` in their `App` struct
2. Pass it down via `.environmentObject(subscriptionManager)`
3. Present `PaywallView` from wherever they gate premium features
4. Check `subscriptionManager.hasActiveSubscription` to gate content

Give a complete code snippet for the `App` struct showing all of this.

### Step 5: App Store Connect checklist

Read `references/app-store-connect-checklist.md` and walk the user through it. This is manual work they have to do in the App Store Connect web UI — you can't automate it, but you can list every step in order so they don't miss any. Common miss: forgetting to fill in tax/banking info, which silently blocks all purchases.

### Step 6: Testing

Tell the user about the three testing modes (read `references/testing-guide.md` for details):
1. **Local .storekit file** — fastest, no Apple account needed, but doesn't test everything
2. **Sandbox** — real Apple account in TestFlight-like environment, tests most things
3. **TestFlight** — closest to production, tests everything

Recommend they start with the local .storekit file (which the skill already generated) and graduate to sandbox before launch.

### Step 7: Gotchas briefing

Before declaring done, read `references/storekit2-gotchas.md` and surface the 3 most likely gotchas for this user's setup. Don't dump the whole gotchas doc — pick what's relevant. Examples:
- If they're targeting family-shareable subs, flag the family sharing entitlement check
- If they didn't ask about server validation, briefly explain why they'll eventually want it
- Always mention the "interrupted purchase" case because almost everyone misses it

## Reference files

Read these as needed — don't load them all up front.

- `references/storekit2-gotchas.md` — Edge cases that bite people: interrupted purchases, ask-to-buy, family sharing, currentEntitlements vs all, why server validation matters
- `references/app-store-connect-checklist.md` — Step-by-step App Store Connect config
- `references/testing-guide.md` — Local .storekit vs sandbox vs TestFlight

## Quality bar

Before declaring done:
- The generated code compiles in a fresh SwiftUI project on Xcode 15+
- The .storekit file loads in Xcode's StoreKit configuration
- A purchase made against the local .storekit config succeeds and `hasActiveSubscription` flips to `true`
- The user knows which manual App Store Connect steps remain
