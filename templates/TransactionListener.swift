import Foundation
import StoreKit

/// In this skill's v1, the transaction listener lives inside `SubscriptionManager`
/// to keep things simple. This file is here as a reference for users who want to
/// extract the listener into its own type — e.g., to plug in analytics or
/// server-side validation hooks.
///
/// To use this version:
/// 1. Delete the `listenForTransactions()` method and `transactionListener` property
///    from `SubscriptionManager`.
/// 2. Instantiate `TransactionListener` from your `App` struct and pass it a
///    closure that calls `subscriptionManager.updatePurchasedProducts()`.
///
/// Most apps don't need this split — keep the version in SubscriptionManager
/// unless you have a clear reason to separate concerns.
actor TransactionListener {

    private var task: Task<Void, Error>?
    private let onUpdate: () async -> Void

    init(onUpdate: @escaping () async -> Void) {
        self.onUpdate = onUpdate
    }

    func start() {
        task?.cancel()
        task = Task { [onUpdate] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await onUpdate()
                }
                // Unverified transactions are silently ignored here.
                // In production, log them to your analytics for fraud monitoring.
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}
