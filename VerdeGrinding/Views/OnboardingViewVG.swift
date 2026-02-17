import SwiftUI
import StoreKit

struct OnboardingViewVG: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentTab = 0
    
    let slides: [OnboardingSlideVG] = [
        OnboardingSlideVG(image: "glass_lab_flask", title: "Discovery", description: "Discover rare biological specimens and expand your laboratory collection."),
        OnboardingSlideVG(image: "neon_leaf_veins", title: "Nurture", description: "Water your habits daily. Consistency is the nutrient that fuels growth."),
        OnboardingSlideVG(image: "onboarding_slide_3", title: "Feedback", description: "Help us improve the ecosystem. Your input shapes the future of Verde."),
        OnboardingSlideVG(image: "rare_fern_blue", title: "Growth", description: "Track your progress. Watch your digital garden flourish over time.")
    ]
    
    var body: some View {
        ZStack {
            // Fallback black background to prevent white gaps
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentTab) {
                ForEach(0..<slides.count, id: \.self) { index in
                    SlideView(slide: slides[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Bottom UI Overlay
            VStack {
                Spacer()
                
                VStack(spacing: 25) {
                    // Indicators
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Capsule()
                                .fill(currentTab == index ? Color.neonLeaf : Color.white.opacity(0.3))
                                .frame(width: currentTab == index ? 24 : 8, height: 8)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    VStack(spacing: 12) {
                        Text(slides[currentTab].title)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(slides[currentTab].description)
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .lineSpacing(4)
                    }
                    
                    VStack(spacing: 15) {
                        // Main Button
                        Button(action: {
                            if currentTab < slides.count - 1 {
                                withAnimation { currentTab += 1 }
                            } else {
                                withAnimation { isOnboardingComplete = true }
                            }
                        }) {
                            HStack {
                                Text(currentTab == slides.count - 1 ? "Start Grinding" : "Continue")
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(colors: [.neonLeaf, .neonLeaf.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(16)
                            .shadow(color: .neonLeaf.opacity(0.3), radius: 10, y: 5)
                        }
                        
                        // Skip Button
                        Button(action: {
                            withAnimation { isOnboardingComplete = true }
                        }) {
                            Text("Skip")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
                .padding(.top, 60)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.8), .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .onChange(of: currentTab) { newTab in
            if newTab == 2 {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
}

struct OnboardingSlideVG {
    let image: String
    let title: String
    let description: String
}

struct SlideView: View {
    let slide: OnboardingSlideVG
    
    var body: some View {
        ZStack {
            Image(slide.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .clipped()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingViewVG(isOnboardingComplete: .constant(false))
}
