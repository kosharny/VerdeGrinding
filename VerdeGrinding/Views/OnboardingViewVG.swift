import SwiftUI
import StoreKit

struct OnboardingViewVG: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentTab = 0
    
    let slides: [OnboardingSlideVG] = [
        OnboardingSlideVG(image: "leaf.circle.fill", title: "Discovery", description: "Discover rare biological specimens and expand your laboratory collection."),
        OnboardingSlideVG(image: "drop.fill", title: "Nurture", description: "Water your habits daily. Consistency is the nutrient that fuels growth."),
        OnboardingSlideVG(image: "star.fill", title: "Feedback", description: "Help us improve the ecosystem. Your input shapes the future of Verde."),
        OnboardingSlideVG(image: "chart.bar.fill", title: "Growth", description: "Track your progress. Watch your digital garden flourish over time.")
    ]
    
    var body: some View {
        ZStack {
            VGGradient.primary
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentTab) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        SlideView(slide: slides[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Indicators
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(currentTab == index ? Color.neonLeaf : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding()
                
                GlassButtonVG(title: currentTab == slides.count - 1 ? "Start Grinding" : "Continue", icon: "arrow.right") {
                    if currentTab < slides.count - 1 {
                        withAnimation {
                            currentTab += 1
                        }
                    } else {
                        // Finish
                        withAnimation {
                            isOnboardingComplete = true
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .onChange(of: currentTab) { newTab in
            if newTab == 2 {
                // Slide 3: Request Review
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
        VStack(spacing: 30) {
            Image(systemName: slide.image)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.neonLeaf)
                .shadow(color: .neonLeaf.opacity(0.5), radius: 20)
                .padding(.top, 50)
            
            VStack(spacing: 16) {
                Text(slide.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(slide.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .lineSpacing(6)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingViewVG(isOnboardingComplete: .constant(false))
}
