import SwiftUI
import StoreKit

@Observable @MainActor
final class PaywallViewModel {
    private let storeKitService: StoreKitService

    var selectedProduct: Product?
    var isPurchasing = false
    var alertMessage: LocalizedStringKey = ""
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
                    alertMessage = "Your purchase is pending approval."
                    showingAlert = true
                }
            } catch {
                isPurchasing = false
                alertMessage = "Purchase failed. Please try again."
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
                    alertMessage = "No previous purchases found."
                    showingAlert = true
                }
            } catch {
                isPurchasing = false
                alertMessage = "Restore failed. No purchases available."
                showingAlert = true
            }
        }
    }
}

