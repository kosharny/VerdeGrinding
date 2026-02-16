import SwiftUI

struct MainViewVG: View {
    @EnvironmentObject var viewModel: ViewModelVG
    @State private var showSplash = true
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashViewVG()
                    .transition(.opacity)
            } else if !hasSeenOnboarding {
                OnboardingViewVG(isOnboardingComplete: $hasSeenOnboarding)
                    .transition(.opacity)
            } else {
                MainContent()
                    .transition(.opacity)
                    .onAppear {
                        // Request tracking when main view appears
                        viewModel.requestTrackingPermission()
                    }
            }
        }
        .onAppear {
            // Splash delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
    
    @ViewBuilder
    func MainContent() -> some View {
        ZStack {
            // Background - extends to all edges
            viewModel.themeGradient
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                switch viewModel.selectedTab {
                case .home:
                    HomeViewVG()
                case .journal:
                    JournalViewVG()
                case .game:
                    GameViewVG()
                case .stat:
                    StatViewVG()
                case .settings:
                    SettingsViewVG()
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                CustomTabBarVG()
            }
        }
    }
}

