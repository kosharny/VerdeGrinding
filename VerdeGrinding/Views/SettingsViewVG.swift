import SwiftUI
import WebKit

struct SettingsViewVG: View {
    @EnvironmentObject var viewModel: ViewModelVG
    @State private var selectedThemeForPaywall: ThemeModelVG?
    @State private var showVideo = false
    @State private var showAbout = false
    
    // Helper to get binding for sheet
    var paywallThemeBinding: Binding<ThemeModelVG?> {
        Binding {
            selectedThemeForPaywall
        } set: { newValue in
            selectedThemeForPaywall = newValue
        }
    }
    
    var body: some View {
        ZStack {
            viewModel.themeGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderBarVG(title: "Settings", showBackButton: false)
                
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // Themes Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Laboratory Theme")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(ThemeModelVG.allThemes) { theme in
                                        let priceString: String = {
                                            if !theme.isPremium { return "Free" }
                                            if let productID = theme.productID,
                                               let price = StoreManagerVG.shared.getPrice(for: productID) {
                                                return price
                                            }
                                            return "Premium" // Fallback if price not loaded
                                        }()
                                        
                                        ThemePreviewCardVG(
                                            title: theme.name,
                                            accentColor: theme.accentColor,
                                            primaryColor: theme.primaryColor,
                                            isSelected: viewModel.currentTheme.id == theme.id,
                                            isLocked: !StoreManagerVG.shared.hasAccess(to: theme),
                                            price: priceString
                                        ) {
                                            if StoreManagerVG.shared.hasAccess(to: theme) {
                                                viewModel.selectTheme(theme)
                                            } else {
                                                selectedThemeForPaywall = theme
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // General Settings
                        VStack(spacing: 1) {
                            // General Premium Upsell
                            let allPremiumOwned = ThemeModelVG.allThemes.filter { $0.isPremium }.allSatisfy { StoreManagerVG.shared.hasAccess(to: $0) }
                            
                            if !allPremiumOwned {
                                SettingsRow(icon: "crown.fill", title: "Go Premium", color: .glowingLime) {
                                    selectedThemeForPaywall = .forestPro // Default upsell
                                }
                            }
                            
                            SettingsRow(icon: "arrow.clockwise", title: "Restore Purchases", color: .blue) {
                                Task {
                                    await StoreManagerVG.shared.restorePurchases()
                                }
                            }
                            
                            SettingsRow(icon: "play.tv.fill", title: "Botanical Inspiration", color: .red) {
                                showVideo = true
                            }
                            
                            SettingsRow(icon: "info.circle.fill", title: "About Verde", color: .white) {
                                showAbout = true
                            }
                        }
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.top)
                }
            }
        }
        .sheet(item: paywallThemeBinding) { theme in
            PaywallViewVG(theme: theme)
        }
        .sheet(isPresented: $showVideo) {
            VideoView(url: URL(string: "https://www.youtube.com/watch?v=pZVdQLn_E5w")!) 
        }
        .sheet(isPresented: $showAbout) {
            AboutViewVG()
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            BlurCardVG {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .frame(width: 30)
                    Text(title)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct VideoView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
