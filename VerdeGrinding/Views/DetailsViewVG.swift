import SwiftUI

struct DetailsViewVG: View {
    let title: String
    let subtitle: String?
    let content: String
    let imageName: String
    let type: DetailTypeVG
    
    enum DetailTypeVG {
        case article
        case plant
        case test
        case quest
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background that extends fully
            Color.deepEmerald.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Image
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                        .overlay(
                            LinearGradient(colors: [.clear, .deepEmerald], startPoint: .center, endPoint: .bottom)
                        )
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(title)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.top)
                            
                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.neonLeaf)
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // Content Body based on Type
                        switch type {
                        case .article:
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(content.components(separatedBy: "\n\n"), id: \.self) { paragraph in
                                    if !paragraph.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text(paragraph)
                                            .font(.body)
                                            .foregroundColor(.white.opacity(0.9))
                                            .lineSpacing(6)
                                            .padding()
                                            .background(Color.white.opacity(0.05))
                                            .cornerRadius(15)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                    }
                                }
                                
                                Button(action: { dismiss() }) {
                                    Text("Mark as Read")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.neonLeaf)
                                        .cornerRadius(15)
                                }
                                .padding(.top, 20)
                            }
                            
                        case .plant:
                            VStack(spacing: 20) {
                                Text(content)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("Water Level")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        ProgressView(value: 0.7) // Mock value
                                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                    }
                                    VStack {
                                        Text("Growth Stage")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("Seedling")
                                            .font(.headline)
                                            .foregroundColor(.neonLeaf)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(10)
                                
                                Button(action: {
                                    // Action to water plant
                                }) {
                                    Text("Water Plant")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.cyan)
                                        .cornerRadius(15)
                                }
                            }
                            
                        case .test:
                            Text("Test details coming soon...")
                                .foregroundColor(.gray)
                                
                        case .quest:
                             VStack(alignment: .leading, spacing: 15) {
                                 Text("Objectives")
                                     .font(.headline)
                                     .foregroundColor(.neonLeaf)
                                 
                                 Text(content) // Description of quest
                                     .font(.body)
                                     .foregroundColor(.white.opacity(0.9))
                                 
                                 Divider().background(Color.white.opacity(0.1))
                                 
                                 HStack {
                                     Image(systemName: "gift.fill")
                                         .foregroundColor(.glowingLime)
                                     Text("Reward")
                                         .font(.subheadline)
                                         .foregroundColor(.gray)
                                     Spacer()
                                     Text("500 XP") // Could be passed in subtitle
                                         .font(.headline)
                                         .fontWeight(.bold)
                                         .foregroundColor(.glowingLime)
                                 }
                                 .padding()
                                 .background(Color.white.opacity(0.05))
                                 .cornerRadius(10)
                             }
                        }
                        
                        // Extra space at bottom
                        Color.clear.frame(height: 50)
                    }
                    .padding(20)
                    .background(Color.deepEmerald)
                    // Visual trick: pull the content up over the image slightly
                    .offset(y: -40)
                    // But we don't corner radius the bottom, so it flows down endlessly
                    .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 30))
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            // Floating Back Button
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, 50) // Safe Area adjustment
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    DetailsViewVG(
        title: "The Psychology of the Sprout",
        subtitle: "Why starting small is key.",
        content: "Long text content goes here...",
        imageName: "plant_avatar_stage_1",
        type: .article
    )
}
