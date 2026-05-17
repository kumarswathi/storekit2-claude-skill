import Foundation
import StoreKit
import os

/// Manages auto-renewable subscriptions for the app.
@MainActor
final class SubscriptionManager: ObservableObject {

    enum PurchaseResult {
        case success
        case userCancelled
        case pending
        case failed(Error)
    }

    private static let productIDs: Set<String> = {{PRODUCT_IDS}}

    private let logger = Logger(subsystem: "com.yourapp.subscriptions", category: "StoreKit")

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isProcessing: Bool = false
    @Published private(set) var lastError: Error?

    var hasActiveSubscription: Bool {
        !purchasedProductIDs.isEmpty
    }

    private var transactionListener: Task<Void, Error>?

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: Self.productIDs)
            self.products = storeProducts.sorted { $0.price < $1.price }
            self.lastError = nil
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription)")
            self.lastError = error
        }
    }

    @discardableResult
    func purchase(_ product: Product) async -> PurchaseResult {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                do {
                    let transaction = try checkVerified(verification)
                    await transaction.finish()
                    await updatePurchasedProducts()
                    self.lastError = nil
                    return .success
                } catch {
                    logger.error("Transaction verification failed: \(error.localizedDescription)")
                    self.lastError = error
                    return .failed(error)
                }
            case .userCancelled:
                return .userCancelled
            case .pending:
                return .pending
            @unknown default:
                let error = NSError(domain: "SubscriptionManager", code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Unknown purchase result"])
                logger.error("Unknown purchase result encountered")
                return .failed(error)
            }
        } catch {
            logger.error("Purchase failed: \(error.localizedDescription)")
            self.lastError = error
            return .failed(error)
        }
    }

    func restorePurchases() async {
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            self.lastError = nil
        } catch {
            logger.error("Restore failed: \(error.localizedDescription)")
            self.lastError = error
        }
    }

    func updatePurchasedProducts() async {
        var activeIDs: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil {
                activeIDs.insert(transaction.productID)
            }
        }
        self.purchasedProductIDs = activeIDs
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                } catch {
                    await self.logger.error(
                        "Transaction update verification failed: \(error.localizedDescription)"
                    )
                }
            }
        }
    }
}
