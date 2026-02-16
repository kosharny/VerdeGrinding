import SwiftUI

struct TestCardVG: View {
    let test: TestVG
    @EnvironmentObject var viewModel: ViewModelVG
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(viewModel.currentTheme.accentColor)
                Spacer()
                if test.isCompleted {
                    Text("DONE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(5)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(5)
                } else {
                    Text("EXP +\(test.rewardXP)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.currentTheme.accentColor)
                        .padding(5)
                        .background(viewModel.currentTheme.accentColor.opacity(0.2))
                        .cornerRadius(5)
                }
            }
            
            Text(test.title)
                .font(.headline)
                .foregroundColor(viewModel.currentTheme.cardText)
                .lineLimit(2)
            
            Text(test.description)
                .font(.caption)
                .foregroundColor(viewModel.currentTheme.cardText.opacity(0.7))
                .lineLimit(2)
        }
        .padding()
        .frame(width: 160, height: 140)
        .background(viewModel.currentTheme.cardBackground)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(viewModel.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
        )
    }
}
