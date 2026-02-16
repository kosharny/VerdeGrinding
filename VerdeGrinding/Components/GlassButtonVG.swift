import SwiftUI

struct GlassButtonVG: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var color: Color = .neonLeaf
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [color.opacity(0.6), color.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .cornerRadius(15)
            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        GlassButtonVG(title: "Plant Seed", icon: "leaf.fill", action: {})
            .padding()
    }
}
