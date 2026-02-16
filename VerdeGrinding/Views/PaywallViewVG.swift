import SwiftUI
import StoreKit

struct PaywallViewVG: View {
    // Optional: Pass a specific theme to unlock, or nil to show general premium
    var theme: ThemeModelVG? = .forestPro
    
    @StateObject private var store = StoreManagerVG.shared
    @EnvironmentObject var viewModel: ViewModelVG
    @Environment(\.dismiss) var dismiss
    
    @State private var showConfirmAlert = false
    @State private var showResultAlert = false
    @State private var resultMessage = ""
    @State private var resultTitle = ""
    @State private var isSuccess = false
    @State private var selectedProduct: Product?
    
    // Fallback theme if none passed
    var targetTheme: ThemeModelVG {
        theme ?? .forestPro
    }
    
    var body: some View {
        ZStack {
            // Background
            VGGradient.primary.ignoresSafeArea()
            
            // Main Content
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 20) {
                    // Theme Preview Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [targetTheme.accentColor, targetTheme.primaryColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: targetTheme.accentColor.opacity(0.5), radius: 20)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    Text(targetTheme.name)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Unlock this exclusive premium theme")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRowVG(
                        icon: "paintpalette.fill",
                        title: "Unique Color Palette",
                        description: "Experience the app in stunning new colors"
                    )
                    
                    FeatureRowVG(
                        icon: "sparkles",
                        title: "Exclusive Visuals",
                        description: "Enhanced UI elements and accents"
                    )
                    
                    FeatureRowVG(
                        icon: "heart.fill",
                        title: "Support Development",
                        description: "Help us create more amazing content"
                    )
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Purchase Section
                if let productID = targetTheme.productID,
                   let product = store.products.first(where: { $0.id == productID }) {
                    
                    VStack(spacing: 16) {
                        // Purchase Button
                        Button {
                            selectedProduct = product
                            showConfirmAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                Text("Unlock for \(product.displayPrice)")
                                    .fontWeight(.bold)
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.neonLeaf, .glowingLime],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .neonLeaf.opacity(0.3), radius: 10)
                        }
                        
                        // Restore Button
                        Button {
                            Task {
                                await store.restorePurchases()
                                if store.hasAccess(to: targetTheme) {
                                    resultTitle = "Success"
                                    resultMessage = "Your purchases have been restored!"
                                    isSuccess = true
                                    viewModel.selectTheme(targetTheme)
                                    showResultAlert = true
                                } else {
                                    resultTitle = "No Purchases Found"
                                    resultMessage = "We couldn't find any previous purchases for this theme."
                                    isSuccess = false
                                    showResultAlert = true
                                }
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 24)
                } else {
                    VStack(spacing: 10) {
                        if store.isLoading {
                            ProgressView()
                                .tint(.neonLeaf)
                            Text("Loading products...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.yellow)
                            Text("Product not found")
                                .foregroundColor(.white.opacity(0.6))
                            
                            Button("Retry") {
                                Task { await store.fetchProducts() }
                            }
                            .padding(.top, 5)
                        }
                    }
                    .padding()
                }
                
                // Close Button
                Button {
                    dismiss()
                } label: {
                    Text("Not Now")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .customAlert(isPresented: $showConfirmAlert, alert: confirmAlert)
        .customAlert(isPresented: $showResultAlert, alert: resultAlert)
        .task {
            if store.products.isEmpty {
                await store.fetchProducts()
            }
        }
    }
    
    // Confirmation Alert
    var confirmAlert: CustomAlertVG {
        CustomAlertVG(
            title: "Confirm Purchase",
            message: "Unlock \(targetTheme.name) for \(selectedProduct?.displayPrice ?? "")?\n\nThis is a one-time purchase.",
            primaryButton: .init(title: "Purchase", isPrimary: true) {
                showConfirmAlert = false
                Task {
                    await performPurchase()
                }
            },
            secondaryButton: .init(title: "Cancel") {
                showConfirmAlert = false
            }
        )
    }
    
    // Result Alert
    var resultAlert: CustomAlertVG {
        CustomAlertVG(
            title: resultTitle,
            message: resultMessage,
            primaryButton: .init(title: "OK", isPrimary: true) {
                showResultAlert = false
                if isSuccess && store.hasAccess(to: targetTheme) {
                    dismiss()
                }
            },
            secondaryButton: nil
        )
    }

    func performPurchase() async {
        guard let product = selectedProduct else { return }
        
        let status = await store.purchase(product)
        
        switch status {
        case .success:
            if store.hasAccess(to: targetTheme) {
                resultTitle = "Success!"
                resultMessage = "\(targetTheme.name) has been unlocked. Enjoy!"
                isSuccess = true
                viewModel.selectTheme(targetTheme)
                showResultAlert = true
            }
            
        case .cancelled:
            print("User cancelled purchase")
            showResultAlert = false
            
        case .pending:
            resultTitle = "Pending"
            resultMessage = "Your purchase is pending approval."
            isSuccess = false
            showResultAlert = true
            
        case .failed:
            resultTitle = "Purchase Failed"
            resultMessage = "We couldn't complete your purchase. Please try again."
            isSuccess = false
            showResultAlert = true
        }
    }
}

struct FeatureRowVG: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.neonLeaf)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neonLeaf.opacity(0.3), lineWidth: 1)
        )
    }
}
