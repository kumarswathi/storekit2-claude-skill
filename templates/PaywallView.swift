import SwiftUI
import StoreKit

/// A minimal but production-shape paywall.
///
/// Customization points (search for `// CUSTOMIZE:`):
/// - Header text and benefits list
/// - Product card visual style
/// - Footer (terms & privacy links — required by App Store Review)
///
/// Apple's review guidelines require:
/// - A clear "Restore Purchases" button
/// - Links to Terms of Use and Privacy Policy
/// - The actual price displayed (do NOT hardcode — use product.displayPrice)
struct PaywallView: View {

    @EnvironmentObject private var subscriptions: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                benefits
                productList

                if let errorMessage {
                    errorBanner(errorMessage)
                }

                purchaseButton
                footer
            }
            .padding()
        }
        .overlay {
            if subscriptions.isProcessing {
                ProgressView()
                    .controlSize(.large)
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .task {
            // Default to the first (cheapest) product
            selectedProduct = subscriptions.products.first
        }
    }

    // MARK: - Sections

    private var header: some View {
        // CUSTOMIZE: replace with your branding
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Unlock Pro")
                .font(.largeTitle.bold())
            Text("Get the full experience")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 32)
    }

    private var benefits: some View {
        // CUSTOMIZE: list your actual premium features
        VStack(alignment: .leading, spacing: 12) {
            BenefitRow(icon: "checkmark.circle.fill", text: "Unlimited access")
            BenefitRow(icon: "checkmark.circle.fill", text: "No ads")
            BenefitRow(icon: "checkmark.circle.fill", text: "Priority support")
        }
    }

    private var productList: some View {
        VStack(spacing: 12) {
            ForEach(subscriptions.products) { product in
                ProductCard(
                    product: product,
                    isSelected: product.id == selectedProduct?.id
                )
                .onTapGesture {
                    selectedProduct = product
                }
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }

    private var purchaseButton: some View {
        VStack(spacing: 12) {
            Button {
                Task { await handlePurchase() }
            } label: {
                Text("Subscribe")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.tint, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
            .disabled(selectedProduct == nil || subscriptions.isProcessing)

            Button("Restore Purchases") {
                Task { await subscriptions.restorePurchases() }
            }
            .font(.subheadline)
        }
    }

    private var footer: some View {
        // CUSTOMIZE: link to your actual Terms and Privacy URLs
        // Apple WILL reject the app if these links are missing or broken.
        VStack(spacing: 4) {
            Text("Auto-renews until cancelled. Cancel anytime in Settings.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 16) {
                Link("Terms of Use", destination: URL(string: "https://example.com/terms")!)
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            }
            .font(.caption)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Actions

    private func handlePurchase() async {
        guard let product = selectedProduct else { return }
        errorMessage = nil

        let result = await subscriptions.purchase(product)
        switch result {
        case .success:
            dismiss()
        case .userCancelled:
            // Stay on paywall, no error needed
            break
        case .pending:
            errorMessage = "Purchase is pending approval. You'll be notified when it completes."
        case .failed(let error):
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }
}

private struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
            Text(text)
            Spacer()
        }
    }
}

private struct ProductCard: View {
    let product: Product
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName)
                    .font(.headline)
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(product.displayPrice)
                .font(.title3.bold())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1)
        )
    }
}
