# StoreKit 2 Subscriptions Skill

A Claude skill that scaffolds a complete StoreKit 2 auto-renewable subscription implementation in a SwiftUI iOS app — including a subscription manager, transaction listener, customizable paywall view, and a local `.storekit` config for sandbox-free testing.

Go from zero to a working purchase flow in about an hour, without reading Apple's StoreKit docs.

## What you get

```
YourApp/
├── Subscriptions/
│   ├── SubscriptionManager.swift   # products, purchase, entitlements
│   ├── TransactionListener.swift   # handles updates from outside the app
│   └── PaywallView.swift           # SwiftUI paywall, ready to customize
└── Products.storekit               # local config for testing without sandbox
```

Plus a checklist of App Store Connect steps and a gotchas doc covering the things that bite people in production (interrupted purchases, family sharing, sandbox renewal quirks, why `currentEntitlements` ≠ `Transaction.all`).

## Requirements

- iOS 17+ / Xcode 15+
- SwiftUI project (UIKit not supported in v1)
- Active Apple Developer Program membership for sandbox/production testing

## How to use

### With Claude Code

Clone into your skills directory:

```bash
cd ~/.claude/skills
git clone https://github.com/kumarswathi/storekit2-claude-skill.git
```

Then in Claude Code, just ask:

> "Add StoreKit 2 subscriptions to this app — one monthly and one yearly tier."

Claude will pick up the skill, ask you a few questions (bundle ID, product IDs, prices), and generate everything.

### Manually

Even without Claude, this repo is a working reference implementation. Copy the files in `templates/` into your project, substitute the placeholders, and follow the checklist in `references/app-store-connect-checklist.md`.

## What's in v1

- Auto-renewable subscriptions
- Purchase flow with verification
- Restore purchases
- Entitlement checking
- Transaction listener for out-of-app purchases (Ask to Buy, pending approvals)
- Customizable SwiftUI paywall
- Local `.storekit` config

## What's NOT in v1

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

MIT — see [LICENSE](LICENSE).
