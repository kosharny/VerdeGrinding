import SwiftUI
import AppTrackingTransparency
import AdSupport

struct SplashViewVG: View {
    @State private var isAnimating = false
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            VGGradient.primary
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Plant Animation
                ZStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.neonLeaf)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .rotationEffect(Angle(degrees: isAnimating ? 0 : -45))
                        .shadow(color: .neonLeaf.opacity(0.8), radius: 20)
                    
                    // Particles
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(Color.glowingLime)
                            .frame(width: 5, height: 5)
                            .offset(x: isAnimating ? CGFloat.random(in: -50...50) : 0,
                                    y: isAnimating ? CGFloat.random(in: -50...50) : 0)
                            .opacity(isAnimating ? 0 : 1)
                            .animation(.easeOut(duration: 1.5).delay(Double(i) * 0.1), value: isAnimating)
                    }
                }
                
                Text("VERDE")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(5)
                
                Text("GRINDING")
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.softMoss)
                    .tracking(2)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                opacity = 1.0
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5)) {
                isAnimating = true
            }
            
            // Request Tracking
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if #available(iOS 14, *) {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        print("Tracking status: \(status)")
                    }
                }
            }
        }
    }
}

#Preview {
    SplashViewVG()
}
