# StoreKit 2 Subscriptions Skill

A Claude skill that scaffolds a complete StoreKit 2 auto-renewable subscription implementation in a SwiftUI iOS app — including a subscription manager, transaction listener, customizable paywall view, and a local `.storekit` config for sandbox-free testing.

Go from zero to a working purchase flow in about an hour, without reading Apple's StoreKit docs.

## Why this exists

There are excellent paid services for subscriptions — RevenueCat, Adapty, Glassfy — and they're the right call for most apps. But sometimes you want:

- No third-party SDK in your binary
- No backend service tracking your users
- Direct StoreKit 2 because you understand the tradeoffs
- A starting point you can read, modify, and own

This skill scaffolds a working StoreKit 2 implementation you control, in roughly the same time it takes to onboard with a paid service — but with code that lives in your repo, that you fully understand, and that has zero ongoing cost.

It's a starter, not a complete subscription stack. For production at scale you'll still want server-side receipt validation (via Apple's [App Store Server API](https://developer.apple.com/documentation/appstoreserverapi)) — but you can ship and earn revenue with what this generates today.

## What you get

After running the skill, your project gets:

- `Subscriptions/SubscriptionManager.swift` — products, purchase flow, entitlements
- `Subscriptions/TransactionListener.swift` — handles updates from outside the app
- `Subscriptions/PaywallView.swift` — SwiftUI paywall, ready to customize
- `Products.storekit` — local config for testing without sandbox

Plus a checklist of App Store Connect steps and a gotchas doc covering things that bite people in production (interrupted purchases, family sharing, sandbox renewal quirks, why `currentEntitlements` is different from `Transaction.all`).

## Requirements

- iOS 17+ / Xcode 15+
- SwiftUI project (UIKit not supported in v1)
- Active Apple Developer Program membership for sandbox/production testing

## How to use

### With Claude Code

Clone into your skills directory, then in Claude Code, ask:

> Add StoreKit 2 subscriptions to this app — one monthly and one yearly tier.

Claude will pick up the skill, ask you a few questions (bundle ID, product IDs, prices), and generate everything.

### Manually

Even without Claude, this repo is a working reference implementation. Copy the files in the `templates/` folder into your project, substitute the placeholders, and follow the checklist in `references/app-store-connect-checklist.md`.

## What is in v1

- Auto-renewable subscriptions
- Purchase flow with verification
- `PurchaseResult` enum distinguishing success, user cancel, pending, and failure
- Restore purchases
- Entitlement checking
- Transaction listener for out-of-app purchases (Ask to Buy, pending approvals)
- Customizable SwiftUI paywall with error states
- Unified `os.Logger` for production-grade logging
- Local `.storekit` config

See `CHANGELOG.md` for the full version history.

## What is NOT in v1

- One-time purchases (consumables / non-consumables) — planned for v2
- Server-side receipt validation code — planned for v2
- UIKit support — SwiftUI only
- Promotional offers / introductory pricing logic — planned for v1.1
- Paywall A/B testing — out of scope

## Contributing

Issues and PRs welcome. Areas where help is especially useful:

- UIKit version of the templates
- Server-side validation example
- Additional paywall designs

## License

MIT — see the `LICENSE` file.
