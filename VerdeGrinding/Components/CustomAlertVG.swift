import SwiftUI

struct CustomAlertVG: View {
    let title: String
    let message: String
    let primaryButton: AlertButton?
    let secondaryButton: AlertButton?
    
    struct AlertButton {
        let title: String
        var isPrimary: Bool = false
        let action: () -> Void
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    if let secondaryButton = secondaryButton {
                        Button(action: secondaryButton.action) {
                            Text(secondaryButton.title)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    
                    if let primaryButton = primaryButton {
                        Button(action: primaryButton.action) {
                            Text(primaryButton.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(primaryButton.isPrimary ? Color.neonLeaf : Color.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(25)
            .background(Color.deepEmerald)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(30)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    .padding(30)
            )
        }
    }
}

extension View {
    func customAlert(isPresented: Binding<Bool>, alert: CustomAlertVG) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue {
                alert
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(1)
            }
        }
    }
}
