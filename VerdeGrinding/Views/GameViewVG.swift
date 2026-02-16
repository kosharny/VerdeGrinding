import SwiftUI
import Combine

struct GameViewVG: View {
    @EnvironmentObject var viewModel: ViewModelVG
    
    @State private var timeRemaining = 60
    @State private var score = 0
    @State private var isGameActive = false
    @State private var showResult = false
    @State private var targets: [GameTarget] = []
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    struct GameTarget: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var isRemoved = false
    }
    
    @State private var viewSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            viewModel.themeGradient.ignoresSafeArea()
            
            if !isGameActive && !showResult {
                // Start Screen
                VStack(spacing: 20) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 80))
                        .foregroundColor(viewModel.currentTheme.accentColor)
                        .shadow(color: viewModel.currentTheme.accentColor, radius: 20)
                    
                    Text("Weed Patrol")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Tap the bad habits (weeds) to clear your mind.\nYou have 60 seconds.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                    
                    GlassButtonVG(title: "Start Patrol", icon: "play.fill") {
                        startGame()
                    }
                    .padding(.horizontal, 50)
                }
            } else if isGameActive {
                // Game Area
                GeometryReader { geometry in
                    ZStack {
                        Color.clear
                            .onAppear { viewSize = geometry.size }
                            .onChange(of: geometry.size) { newSize in viewSize = newSize }
                        Image("onboarding_slide_3")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.5)
                            .ignoresSafeArea()
                            .frame(maxHeight: .infinity)
                            
                        ForEach(targets) { target in
                            if !target.isRemoved {
                                Button(action: { removeTarget(id: target.id) }) {
                                    Image("game_plant_target")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .shadow(color: .red.opacity(0.5), radius: 10)
                                }
                                .position(x: target.x, y: target.y)
                                .transition(.scale)
                            }
                        }
                    }
                }
                
                VStack {
                    HStack {
                        Text("Time: \(timeRemaining)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        Text("Score: \(score)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.currentTheme.accentColor)
                    }
                    .padding()
                    .padding(.top, 40) // Extra padding for safe area since we handle custom header
                    .background(viewModel.currentTheme.headerBackground)
                    
                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
            }
            
            if showResult {
                Color.black.opacity(0.8).ignoresSafeArea()
                BlurCardVG {
                    VStack(spacing: 20) {
                        Text("Patrol Complete")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text("You reduced stress by \(score)%")
                            .font(.headline)
                            .foregroundColor(viewModel.currentTheme.accentColor)
                        
                        GlassButtonVG(title: "Collect Rewards", icon: "star.fill") {
                            viewModel.addXP(amount: score * 2)
                            showResult = false
                        }
                    }
                }
                .padding()
            }
        }
        .onReceive(timer) { _ in
            if isGameActive {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    // Randomly add targets
                    if Double.random(in: 0...1) > 0.3 {
                        addTarget()
                    }
                } else {
                    endGame()
                }
            }
        }
    }
    
    func startGame() {
        score = 0
        timeRemaining = 60
        targets.removeAll()
        isGameActive = true
        showResult = false
    }
    
    func addTarget() {
        // Use viewSize which is captured from GeometryReader
        // Padding: 40px from sides, 120px from top (header), 40px from bottom (tab bar is already outside the view usually)
        let width = viewSize.width > 0 ? viewSize.width : UIScreen.main.bounds.width
        let height = viewSize.height > 0 ? viewSize.height : UIScreen.main.bounds.height
        
        let x = CGFloat.random(in: 40...width - 40)
        let y = CGFloat.random(in: 120...height - 40)
        
        let newTarget = GameTarget(x: x, y: y)
        withAnimation {
            targets.append(newTarget)
        }
    }
    
    func removeTarget(id: UUID) {
        if let index = targets.firstIndex(where: { $0.id == id }) {
            withAnimation(.spring()) {
                targets.remove(at: index)
                score += 1
                // Feedback? Haptic?
            }
        }
    }
    
    func endGame() {
        isGameActive = false
        showResult = true
    }
}
