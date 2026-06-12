import StoreKit
import Observation

enum PurchaseResult {
    case success, cancelled, pending
}

@Observable @MainActor
final class StoreKitService {

    // MARK: - Product IDs (must match App Store Connect exactly)
    private enum ProductID {
        static let monthly  = "com.amanbayserkeev.teymiahabit.pro_monthly"
        static let yearly   = "com.amanbayserkeev.teymiahabit.pro_yearly"
        static let lifetime = "com.amanbayserkeev.teymiahabit.pro_lifetime"

        static let all     = [monthly, yearly, lifetime]
        static let ordered = [monthly, yearly, lifetime]
    }

    // MARK: - State
    private(set) var products: [Product] = []
    private(set) var isPremium: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var hasLifetimePurchase: Bool = false
    private(set) var hasActiveSubscription: Bool = false

    // MARK: - Transaction listener
    // No deinit needed — service lives for the entire app lifetime
    private var transactionListener: Task<Void, Never>?

    init() {
        #if DEBUG
        isPremium = true
        hasLifetimePurchase = true
        #endif

        transactionListener = listenForTransactions()
    }

    // MARK: - Public API

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await Product.products(for: ProductID.all)
            products = fetched.sorted { product1, product2 in
                (ProductID.ordered.firstIndex(of: product1.id) ?? .max) <
                (ProductID.ordered.firstIndex(of: product2.id) ?? .max)
            }
        } catch {
            print("[StoreKitService] Failed to load products: \(error)")
        }

        await updatePremiumStatus()
    }

    func purchase(_ product: Product) async throws -> PurchaseResult {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            // Update immediately so UI reacts without waiting for Transaction.updates
            await updatePremiumStatus()
            await transaction.finish()
            return .success

        case .userCancelled:
            return .cancelled

        case .pending:
            return .pending

        @unknown default:
            return .cancelled
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePremiumStatus()
    }

    // MARK: - Premium Status

    func updatePremiumStatus() async {
        #if DEBUG
        // In debug, status is set in init and controlled via setDebugPremium()
        return
        #else
        var foundLifetime = false
        var foundActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else {
                if case .unverified(_, let error) = result {
                    print("[StoreKitService] Unverified entitlement: \(error)")
                }
                continue
            }

            guard ProductID.all.contains(transaction.productID),
                  transaction.revocationDate == nil
            else { continue }

            if let expiration = transaction.expirationDate {
                if expiration > Date() && !transaction.isUpgraded {
                    foundActiveSubscription = true
                }
            } else {
                foundLifetime = true
            }
        }

        hasLifetimePurchase = foundLifetime
        hasActiveSubscription = foundActiveSubscription
        isPremium = foundLifetime || foundActiveSubscription
        #endif
    }

    // MARK: - Private

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { break }
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePremiumStatus()
                    await transaction.finish()
                } catch {
                    print("[StoreKitService] Transaction verification failed: \(error)")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let value): return value
        }
    }

    // MARK: - Debug

    #if DEBUG
    func toggleDebugPremium() {
        isPremium.toggle()
    }

    // for #Preview
    func setDebugPremium(_ value: Bool) {
        isPremium = value
    }
    #endif
}
