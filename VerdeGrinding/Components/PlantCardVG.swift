import SwiftUI

struct PlantCardVG: View {
    let plant: PlantVG
    let isUnlocked: Bool
    
    var body: some View {
        ZStack {
            // Background Blur
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.darkForest.opacity(0.6))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isUnlocked ? Color.neonLeaf.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: isUnlocked ? Color.neonLeaf.opacity(0.2) : .clear, radius: 10)
            
            VStack {
                // Plant Image
                if isUnlocked {
                    Image(plant.stages.last ?? "plant_avatar_stage_1") // Placeholder fallback
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .shadow(color: .neonLeaf.opacity(0.6), radius: 8)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .frame(height: 80)
                }
                
                // Info
                Text(plant.name)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? .white : .gray)
                
                Text(plant.rarity.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(rarityColor(plant.rarity))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(rarityColor(plant.rarity).opacity(0.2))
                    .cornerRadius(5)
            }
            .padding()
        }
        .frame(width: 140, height: 180)
    }
    
    func rarityColor(_ rarity: PlantRarityVG) -> Color {
        switch rarity {
        case .common: return .white
        case .rare: return .neonLeaf
        case .legendary: return .glowingLime
        case .exotic: return .purple
        }
    }
}

#Preview {
    ZStack {
        Color.black
        PlantCardVG(
            plant: PlantVG(id: "1", name: "Test Plant", scientificName: "Testus", description: "Desc", rarity: .rare, type: .habit, maxLevel: 3, stages: ["plant_avatar_stage_3"], unlockCondition: nil),
            isUnlocked: true
        )
    }
}
