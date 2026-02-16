import StoreKit
import SwiftUI
import Combine

@MainActor
final class StoreManagerVG: ObservableObject {
    static let shared = StoreManagerVG()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    
    // Using correct product IDs from ThemeModelVG
    private let productIDs: Set<String> = [
        "premium_theme_forest_pro",
        "premium_theme_neon_pro"
    ]
    
    init() {
        Task {
            await fetchProducts()
            await updatePurchasedProducts()
            await observeTransactions()
        }
    }
    
    func fetchProducts() async {
        isLoading = true
        
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            self.products = fetchedProducts
            
            if fetchedProducts.isEmpty {
                print("Warning: StoreKit returned no products. Check identifiers in .storekit file or Connect.")
            }
            
        } catch {
            print("Error loading products: \(error)")
        }
        
        isLoading = false
    }
    
    func purchase(_ product: Product) async -> PurchaseStatus {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                purchasedProductIDs.insert(transaction.productID)
                
                await transaction.finish()
                
                return .success
                
            case .userCancelled:
                return .cancelled
                
            case .pending:
                return .pending
                
            @unknown default:
                return .failed
            }
        } catch {
            print("Purchase failed:", error)
            return .failed
        }
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }
    
    private func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }
    
    private func observeTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreError.failedVerification
        }
    }
    
    nonisolated func paymentQueue(_ queue: SKPaymentQueue,
                                  shouldAddStorePayment payment: SKPayment,
                                  for product: SKProduct) -> Bool {
        return true
    }
}

extension StoreManagerVG {
    func hasAccess(to theme: ThemeModelVG) -> Bool {
        guard theme.isPremium else { return true }
        guard let productID = theme.productID else { return false }
        return purchasedProductIDs.contains(productID)
    }
    
    func isPurchased(_ productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
}

enum StoreError: Error {
    case failedVerification
}

extension StoreManagerVG {
    func getPrice(for productID: String) -> String? {
        return products.first(where: { $0.id == productID })?.displayPrice
    }
}

enum PurchaseStatus {
    case success
    case pending
    case cancelled
    case failed
}
