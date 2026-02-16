import SwiftUI

struct BlurCardVG<Content: View>: View {
    let content: Content
    @EnvironmentObject var viewModel: ViewModelVG
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(viewModel.currentTheme.cardBackground)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(viewModel.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
                )
            
            content
                .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ZStack {
        Color.black
        BlurCardVG {
            Text("Blur Card Content")
                .foregroundColor(.white)
        }
        .frame(width: 200, height: 100)
    }
}
