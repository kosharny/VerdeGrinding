import SwiftUI

struct TestsListViewVG: View {
    @EnvironmentObject var viewModel: ViewModelVG
    @State private var selectedTest: TestVG?
    
    var body: some View {
        ZStack {
            VGGradient.primary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Inline Header since it's inside a NavigationStack
                // But we can also use standard nav bar title
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.tests) { test in
                            Button(action: {
                                selectedTest = test
                            }) {
                                TestRowCard(test: test)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("All Tests")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $selectedTest) { test in
            TestRunnerViewVG(test: test)
        }
    }
}

struct TestRowCard: View {
    let test: TestVG
    
    var body: some View {
        BlurCardVG {
            HStack(spacing: 15) {
                Image(systemName: test.imageName)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.neonLeaf.opacity(0.8))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(test.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(test.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if test.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.glowingLime)
                } else {
                    Text("Start")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.neonLeaf)
                        .cornerRadius(10)
                }
            }
        }
    }
}
