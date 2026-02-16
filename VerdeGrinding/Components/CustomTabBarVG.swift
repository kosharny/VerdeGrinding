import SwiftUI

struct CustomTabBarVG: View {
    @EnvironmentObject var viewModel: ViewModelVG
    
    var body: some View {
        HStack {
            TabBarButton(icon: "house.fill", tab: .home)
            Spacer()
            TabBarButton(icon: "book.fill", tab: .journal)
            Spacer()
            
            // Center Game Button - Fully opaque
            Button(action: {
                withAnimation {
                    viewModel.selectedTab = .game
                }
            }) {
                ZStack {
                    Circle()
                        .fill(viewModel.currentTheme.accentColor) // Solid color, no gradient
                        .frame(width: 60, height: 60)
                        .shadow(color: viewModel.currentTheme.accentColor.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "leaf.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .offset(y: -20)
            
            Spacer()
            TabBarButton(icon: "chart.bar.fill", tab: .stat)
            Spacer()
            TabBarButton(icon: "gearshape.fill", tab: .settings)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            viewModel.currentTheme.primaryColor
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    @ViewBuilder
    func TabBarButton(icon: String, tab: TabVG) -> some View {
        Button(action: {
            withAnimation {
                viewModel.selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(viewModel.selectedTab == tab ? viewModel.currentTheme.accentColor : .gray)
                
                if viewModel.selectedTab == tab {
                    Circle()
                        .fill(viewModel.currentTheme.accentColor)
                        .frame(width: 4, height: 4)
                }
            }
        }
    }
}

// Helper for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    CustomTabBarVG()
        .environmentObject(ViewModelVG())
}
