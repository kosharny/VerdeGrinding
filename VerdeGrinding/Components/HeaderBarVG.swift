import SwiftUI

struct HeaderBarVG: View {
    let title: String
    let showBackButton: Bool
    var action: (() -> Void)? = nil
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: ViewModelVG
    
    var body: some View {
        VStack(spacing: 0) {
            // Top safe area filler
            viewModel.currentTheme.headerBackground
                .frame(height: 0)
                .ignoresSafeArea(edges: .top)
            
            HStack {
                if showBackButton {
                    Button(action: {
                        if let action = action {
                            action()
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: viewModel.currentTheme.headerAccent.opacity(0.5), radius: 5)
                
                Spacer()
            }
            .padding()
            .background(viewModel.currentTheme.headerBackground)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        HeaderBarVG(title: "My Garden", showBackButton: true)
    }
}
