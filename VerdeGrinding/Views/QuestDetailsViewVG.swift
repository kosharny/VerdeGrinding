import SwiftUI

struct QuestDetailsViewVG: View {
    let quest: QuestVG
    @EnvironmentObject var viewModel: ViewModelVG
    @Environment(\.dismiss) var dismiss
    
    var isCompleted: Bool {
        // Check current state from VM to ensure UI updates
        viewModel.quests.first(where: { $0.id == quest.id })?.isCompleted ?? quest.isCompleted
    }
    
    var body: some View {
        ZStack {
            VGGradient.primary.ignoresSafeArea()
            
            VStack {
                // Header Image Area
                ZStack(alignment: .bottomLeading) {
                    Image("quest_bg") // Placeholder or generic quest image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                        .overlay(
                            LinearGradient(colors: [.clear, .deepEmerald], startPoint: .center, endPoint: .bottom)
                        )
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(quest.difficulty.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.neonLeaf)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        
                        Text(quest.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // Description
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Mission Brief")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(quest.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                        }
                        
                        Divider().background(Color.white.opacity(0.2))
                        
                        // Rewards
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Rewards")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("\(quest.rewardXP) XP")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.glowingLime)
                            }
                            Spacer()
                            Image(systemName: "gift.fill")
                                .font(.largeTitle)
                                .foregroundColor(.glowingLime)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                      
                        
                        Spacer()
                    }
                    .padding()
                }
                
                // Action Button
                VStack {
                    if isCompleted {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Quest Completed")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.glowingLime)
                        .cornerRadius(15)
                    } else {
                        VStack(spacing: 8) {
                            Text("Quest is Active")
                                .font(.caption)
                                .foregroundColor(.neonLeaf)
                                .padding(.bottom, 2)
                            
                            Button(action: {
                                withAnimation {
                                    viewModel.completeQuest(questId: quest.id)
                                }
                            }) {
                                Text("Complete Quest")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.neonLeaf)
                                    .cornerRadius(15)
                            }
                        }
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
