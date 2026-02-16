import SwiftUI

struct TestRunnerViewVG: View {
    let test: TestVG
    @EnvironmentObject var viewModel: ViewModelVG
    @Environment(\.dismiss) var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var selectedOptionIndex: Int? = nil
    @State private var score = 0
    @State private var showResults = false
    @State private var isAnswered = false
    @State private var animateSuccess = false
    
    var currentQuestion: QuestionVG {
        test.questions[currentQuestionIndex]
    }
    
    var progress: Double {
        Double(currentQuestionIndex) / Double(test.questions.count)
    }
    
    var body: some View {
        ZStack {
            VGGradient.primary.ignoresSafeArea()
            
            if showResults {
                ResultsView(
                    score: score,
                    totalQuestions: test.questions.count,
                    rewardXP: test.rewardXP,
                    onClaim: {
                        viewModel.completeTest(testId: test.id, score: score)
                        dismiss()
                    },
                    onRetry: {
                        resetTest()
                    },
                    onClose: {
                        dismiss()
                    }
                )
            } else {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text("Question \(currentQuestionIndex + 1)/\(test.questions.count)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        // Placeholder for symmetry
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding()
                    
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.1))
                            Capsule().fill(Color.neonLeaf)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Question
                            Text(currentQuestion.text)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                            
                            // Options
                            VStack(spacing: 15) {
                                ForEach(0..<currentQuestion.options.count, id: \.self) { index in
                                    Button(action: {
                                        selectOption(index)
                                    }) {
                                        HStack {
                                            Text(currentQuestion.options[index])
                                                .font(.body)
                                                .fontWeight(.medium)
                                            Spacer()
                                            if isAnswered && index == selectedOptionIndex {
                                                Image(systemName: index == currentQuestion.correctOptionIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                    .foregroundColor(index == currentQuestion.correctOptionIndex ? .green : .red)
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            getBackgroundColor(for: index)
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(15)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(getBorderColor(for: index), lineWidth: 2)
                                        )
                                    }
                                    .disabled(isAnswered)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Continue Button
                    if isAnswered {
                        Button(action: nextQuestion) {
                            Text(currentQuestionIndex == test.questions.count - 1 ? "Finish Test" : "Next Question")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.neonLeaf)
                                .cornerRadius(15)
                        }
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
    }
    
    func resetTest() {
        currentQuestionIndex = 0
        selectedOptionIndex = nil
        score = 0
        showResults = false
        isAnswered = false
    }

    
    func selectOption(_ index: Int) {
        selectedOptionIndex = index
        isAnswered = true
        
        if index == currentQuestion.correctOptionIndex {
            score += 1
            // Haptic feedback could go here
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex < test.questions.count - 1 {
            currentQuestionIndex += 1
            selectedOptionIndex = nil
            isAnswered = false
        } else {
            showResults = true
        }
    }
    
    func getBackgroundColor(for index: Int) -> Color {
        if isAnswered {
            if index == currentQuestion.correctOptionIndex {
                return Color.green.opacity(0.3)
            }
            if index == selectedOptionIndex {
                return Color.red.opacity(0.3)
            }
        }
        return Color.white.opacity(0.1)
    }
    
    func getBorderColor(for index: Int) -> Color {
        if isAnswered {
            if index == currentQuestion.correctOptionIndex {
                return Color.green
            }
            if index == selectedOptionIndex {
                return Color.red
            }
        }
        return Color.clear
    }
}

struct ResultsView: View {
    let score: Int
    let totalQuestions: Int
    let rewardXP: Int
    let onClaim: () -> Void
    let onRetry: () -> Void
    let onClose: () -> Void
    
    var isSuccess: Bool {
        let percentage = Double(score) / Double(totalQuestions)
        return percentage >= 0.5
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: isSuccess ? "checkmark.seal.fill" : "xmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(isSuccess ? .neonLeaf : .red)
                .shadow(color: (isSuccess ? Color.neonLeaf : Color.red).opacity(0.5), radius: 20)
            
            Text(isSuccess ? "Test Completed!" : "Test Failed")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                Text("You scored")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                Text("\(score) / \(totalQuestions)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(isSuccess ? .white : .red)
            }
            
            if isSuccess {
                VStack(spacing: 5) {
                    Text("Reward Earned")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("+\(rewardXP) XP")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.glowingLime)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(15)
            } else {
                Text("You need at least 50% to pass.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                if isSuccess {
                    Button(action: onClaim) {
                        Text("Claim Reward")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.neonLeaf)
                            .cornerRadius(15)
                    }
                } else {
                    Button(action: onRetry) {
                        Text("Try Again")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                    }
                    
                    Button(action: onClose) {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
    }
}
