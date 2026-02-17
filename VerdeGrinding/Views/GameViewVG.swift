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
    
    @State private var bgScale: CGFloat = 1.0
    @State private var sparkleOpacity: Double = 0.0
    @State private var viewSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Foreground Content
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
                        // Invisible background to capture taps
                        Color.clear
                            .onAppear { 
                                viewSize = geometry.size 
                                print("GAME_DEBUG: viewSize updated to \(viewSize)")
                            }
                            .onChange(of: geometry.size) { newSize in 
                                viewSize = newSize 
                                print("GAME_DEBUG: viewSize changed to \(viewSize)")
                            }
                        
                        // Sparkles
                        ForEach(0..<10, id: \.self) { i in
                            Circle()
                                .fill(viewModel.currentTheme.accentColor.opacity(0.3))
                                .frame(width: CGFloat.random(in: 4...10), height: CGFloat.random(in: 4...10))
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                                .opacity(sparkleOpacity)
                        }
                            
                        ForEach(targets) { target in
                            if !target.isRemoved {
                                Button(action: { removeTarget(id: target.id) }) {
                                    Image("game_plant_target")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .shadow(color: .red.opacity(0.5), radius: 10)
                                }
                                .position(x: target.x, y: target.y)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.1).combined(with: .opacity),
                                    removal: .scale(scale: 1.5).combined(with: .opacity)
                                ))
                            }
                        }
                    }
                }
                .padding(.top, 120)
                .padding(.bottom, 100)
                .padding(.horizontal, 20)
                
                // Header (Above Game Area)
                VStack {
                    HStack(spacing: 0) {
                        HStack {
                            Text("Time: \(timeRemaining)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(width: 100)
                        
                        Text("Score: \(score)")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(viewModel.currentTheme.accentColor)
                            .frame(maxWidth: .infinity)
                        
                        HStack {
                            Spacer()
                            Button(action: { quitGame() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .frame(width: 100)
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    .padding(.bottom, 15)
                    .background(
                        viewModel.currentTheme.headerBackground
                            .ignoresSafeArea(edges: .top)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
                    )
                    
                    Spacer()
                }
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
                            isGameActive = false
                        }
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                viewModel.themeGradient
                
                Image("onboarding_slide_3")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(bgScale)
                    .opacity(0.3)
            }
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                bgScale = 1.1
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                sparkleOpacity = 0.6
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
        // Use the captured viewSize or fallback to screen bounds
        let viewW = viewSize.width > 0 ? viewSize.width : UIScreen.main.bounds.width - 40
        let viewH = viewSize.height > 0 ? viewSize.height : UIScreen.main.bounds.height - 300 // Safe fallback
        
        // Target is 80x80. Calculate safe margins to keep it fully on screen.
        let margin: CGFloat = 45 // 40 (half-size) + 5 slack
        
        let x = CGFloat.random(in: margin...(viewW - margin))
        let y = CGFloat.random(in: margin...(viewH - margin))
        
        let newTarget = GameTarget(x: x, y: y)
        print("GAME_DEBUG: Spawning target at (\(x), \(y)) within bounds (\(viewW), \(viewH))")
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
    
    func quitGame() {
        isGameActive = false
        showResult = false
        targets.removeAll()
    }
}
