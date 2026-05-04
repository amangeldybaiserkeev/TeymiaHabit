import Foundation
import StoreKit

@Observable @MainActor
final class PaywallViewModel {
    private let storeKitService: StoreKitService

    var selectedProduct: Product?
    var isPurchasing = false
    var alertMessage: LocalizedStringResource = ""
    var showingAlert = false

    init(storeKitService: StoreKitService) {
        self.storeKitService = storeKitService
    }

    var products: [Product] { storeKitService.products }

    func selectDefaultProduct() {
        guard !products.isEmpty else { return }
        selectedProduct = products.first(where: { $0.id.contains("yearly") }) ?? products.first
    }

    func purchaseSelected(onSuccess: @escaping () -> Void) {
        guard let product = selectedProduct, !isPurchasing else { return }
        isPurchasing = true

        Task {
            do {
                let result = try await storeKitService.purchase(product)
                isPurchasing = false
                switch result {
                case .success:
                    onSuccess()
                case .cancelled:
                    break
                case .pending:
                    alertMessage = "paywall_purchase_pending_message"
                    showingAlert = true
                }
            } catch {
                isPurchasing = false
                alertMessage = "paywall_purchase_failed_message"
                showingAlert = true
            }
        }
    }

    func restorePurchases(onSuccess: @escaping () -> Void) {
        isPurchasing = true

        Task {
            do {
                try await storeKitService.restorePurchases()
                isPurchasing = false
                if storeKitService.isPremium {
                    onSuccess()
                } else {
                    alertMessage = "paywall_no_purchases_to_restore_message"
                    showingAlert = true
                }
            } catch {
                isPurchasing = false
                alertMessage = "paywall_no_purchases_to_restore_message"
                showingAlert = true
            }
        }
    }
}

