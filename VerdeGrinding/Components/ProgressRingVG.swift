import SwiftUI

struct ProgressRingVG: View {
    var progress: Double // 0.0 to 1.0
    var color: Color = .neonLeaf
    var lineWidth: CGFloat = 10
    var size: CGFloat = 100
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
                .shadow(color: color.opacity(0.5), radius: 5)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color.black
        ProgressRingVG(progress: 0.7)
    }
}
