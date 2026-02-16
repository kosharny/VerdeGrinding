import SwiftUI

struct ThemePreviewCardVG: View {
    let title: String
    let accentColor: Color
    let primaryColor: Color
    let isSelected: Bool
    let isLocked: Bool
    let price: String // "Free" or "$4.99" etc.
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Gradient Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [primaryColor, accentColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 100, height: 100)
                    }
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                }
                
                // Title & Price
                VStack(spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(price)
                        .font(.caption2)
                        .foregroundColor(isLocked ? .glowingLime : .gray)
                }
            }
        }
    }
}


