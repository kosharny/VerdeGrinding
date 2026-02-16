import SwiftUI

struct HomeViewVG: View {
    @EnvironmentObject var viewModel: ViewModelVG
    @State private var selectedArticle: ArticleVG?
    @State private var selectedTest: TestVG?
    @State private var selectedQuest: QuestVG?
    @State private var showArticleDetails = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                viewModel.themeGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HeaderBarVG(title: "Laboratory", showBackButton: false)
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            
                            // 1. Central Plant Node (Progress)
                            ZStack {
                                // Orbiting Particles (Decorative)
                                ForEach(0..<3) { i in
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        .frame(width: 280 + CGFloat(i * 40), height: 280 + CGFloat(i * 40))
                                }
                                
                                // Progress Ring
                                ProgressRingVG(
                                    progress: Double(viewModel.userXP) / Double(viewModel.userLevel * 100), // Mock max XP logic
                                    size: 240
                                )
                                
                                // Central Icon depends on growth
                                Image(viewModel.totalPlantsGrown > 5 ? "plant_avatar_stage_33" : (viewModel.totalPlantsGrown > 2 ? "plant_avatar_stage_22" : "plant_avatar_stage_11"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 260)
                                    .shadow(color: .neonLeaf.opacity(0.6), radius: 25)
                                
                                VStack {
                                    Spacer()
                                    VStack(spacing: 4) {
                                        Text("Level \(viewModel.userLevel)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("\(viewModel.userXP) / \(viewModel.userLevel * 100) XP")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(Capsule().fill(Color.black.opacity(0.7)))
                                    .offset(y: 30)
                                }
                            }
                            .frame(height: 320)
                            
                                    // 2. Available Tests (Horizontal Scroll)
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Available Tests")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    
                                    NavigationLink(destination: TestsListViewVG()) {
                                        Text("See All")
                                            .font(.caption)
                                            .foregroundColor(.neonLeaf)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(viewModel.tests) { test in
                                            Button(action: {
                                                selectedTest = test
                                            }) {
                                                TestCardVG(test: test)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // 3. Plant Matcher Card
                            Button(action: {
                                 if let matchTest = viewModel.tests.first(where: { $0.type == .personalityMatch }) {
                                     selectedTest = matchTest
                                 }
                            }) {
                                ZStack {
                                    LinearGradient(colors: [.deepEmerald, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    HStack {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Find Your Perfect Plant")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            Text("Take the compatibility quiz to see which rare species suits your lifestyle.")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .multilineTextAlignment(.leading)
                                            
                                            HStack {
                                                Text("Start Quiz")
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.black)
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 16)
                                                    .background(Color.neonLeaf)
                                                    .cornerRadius(20)
                                            }
                                            .padding(.top, 5)
                                        }
                                        Spacer()
                                        Image(systemName: "person.crop.circle.badge.questionmark")
                                            .font(.system(size: 50))
                                            .foregroundColor(viewModel.currentTheme.accentColor)
                                    }
                                    .padding(20)
                                }
                                .background(viewModel.currentTheme.cardBackground)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(viewModel.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.horizontal)
                            }
                            
                            // 4. Featured Article (Restored)
                            if let randomArticle = viewModel.articles.randomElement() {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Daily Insight")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    Button(action: {
                                        selectedArticle = randomArticle
                                        showArticleDetails = true
                                    }) {
                                        BlurCardVG {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text(randomArticle.title)
                                                        .font(.headline)
                                                        .foregroundColor(viewModel.currentTheme.cardText)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Text(randomArticle.subtitle)
                                                        .font(.subheadline)
                                                        .foregroundColor(viewModel.currentTheme.cardText.opacity(0.7))
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    HStack {
                                                        Image(systemName: "clock")
                                                        Text("\(randomArticle.readingTime) min read")
                                                    }
                                                    .font(.caption)
                                                    .foregroundColor(viewModel.currentTheme.accentColor)
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(viewModel.currentTheme.cardText.opacity(0.5))
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // 5. Daily Eco-Challenge (Bottom Card) - Interactive
                            Button(action: {
                                if let dailyQuest = viewModel.quests.first {
                                    selectedQuest = dailyQuest
                                }
                            }) {
                                HStack(spacing: 15) {
                                    // Challenge
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "leaf.arrow.triangle.circlepath")
                                                .foregroundColor(viewModel.currentTheme.accentColor)
                                            Text("Daily Task")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(viewModel.currentTheme.accentColor)
                                        }
                                        Text(viewModel.quests.first?.title ?? "Daily Quest")
                                            .font(.headline)
                                            .foregroundColor(viewModel.currentTheme.cardText)
                                            .multilineTextAlignment(.leading)
                                        Text("+\(viewModel.quests.first?.rewardXP ?? 0) XP")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(viewModel.currentTheme.cardText.opacity(0.7))
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(viewModel.currentTheme.cardBackground)
                                    .cornerRadius(15)
                                    
                                    // Moon Phase (Decorative)
                                    VStack {
                                        Image(systemName: "moon.stars.fill")
                                            .font(.title)
                                            .foregroundColor(viewModel.currentTheme.accentColor)
                                        Text("Waning Gibbous")
                                            .font(.caption2)
                                            .foregroundColor(viewModel.currentTheme.cardText.opacity(0.7))
                                            .padding(.top, 2)
                                    }
                                    .padding()
                                    .frame(width: 100, height: 100)
                                    .background(viewModel.currentTheme.cardBackground)
                                    .cornerRadius(15)
                                }
                                .padding(.horizontal)
                            }
                            
                            Spacer(minLength: 120)
                        }
                        .padding(.top)
                    }
                }
            }
            .fullScreenCover(item: $selectedArticle) { article in
                DetailsViewVG(
                    title: article.title,
                    subtitle: article.subtitle,
                    content: article.content,
                    imageName: article.imageName,
                    type: article.category == "Test" ? .test : (article.category == "Quest" ? .quest : (article.category == "Plant" ? .plant : .article))
                )
            }
            .fullScreenCover(item: $selectedTest) { test in
                TestRunnerViewVG(test: test)
            }
            .fullScreenCover(item: $selectedQuest) { quest in
                QuestDetailsViewVG(quest: quest)
            }
        }
    }
}

// Keeping QuestCard for compatibility or future use
struct QuestCard: View {
    let quest: QuestVG
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "scroll.fill")
                    .foregroundColor(.glowingLime)
                Spacer()
                Text("\(quest.rewardXP) XP")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(5)
                    .background(Color.glowingLime)
                    .cornerRadius(5)
            }
            
            Text(quest.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(quest.difficulty)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 160, height: 120)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
