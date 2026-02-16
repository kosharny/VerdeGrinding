import SwiftUI

struct AboutViewVG: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VGGradient.primary.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.neonLeaf)
                    .shadow(color: .neonLeaf.opacity(0.8), radius: 20)
                    .padding(.top, 20)
                
                Text("Verde Grinding")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Created for the digital botanist in search of growth. Nurture your mind, prune your bad habits, and watch your garden flourish.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                
                Spacer()
            }
        }
    }
}
