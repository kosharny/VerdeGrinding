import SwiftUI
import Charts

struct StatViewVG: View {
    @EnvironmentObject var viewModel: ViewModelVG
    @State private var animateChart = false
    
    // Helper to organize chart data
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
    }
    
    var chartData: [ChartDataPoint] {
        let sortedEntries = viewModel.journalEntries.sorted(by: { $0.date < $1.date })
        var points: [ChartDataPoint] = []
        
        // If we have entries, add points
        for (index, entry) in sortedEntries.enumerated() {
            points.append(ChartDataPoint(date: entry.date, count: index + 1))
        }
        
        // "If it's the first day, then just segment upwards from the previous day (0) to this day"
        // We add a synthetic "zero" point before the first actual point
        if let firstPoint = points.first {
            let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: firstPoint.date) ?? firstPoint.date
            points.insert(ChartDataPoint(date: previousDay, count: 0), at: 0)
        }
        
        return points
    }
    
    var body: some View {
        ZStack {
            viewModel.themeGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderBarVG(title: "Growth Analytics", showBackButton: false)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Main Chart (Growth Pulse)
                        BlurCardVG {
                            VStack(alignment: .leading) {
                                Text("Journal Growth")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                if viewModel.journalEntries.isEmpty {
                                    Text("Start journaling to see your data!")
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 20)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Chart {
                                        ForEach(chartData) { point in
                                            // Segment (Line)
                                            LineMark(
                                                x: .value("Date", point.date),
                                                y: .value("Entries", point.count)
                                            )
                                            .foregroundStyle(Color.neonLeaf)
                                            .lineStyle(StrokeStyle(lineWidth: 2))
                                            
                                            // Dots
                                            PointMark(
                                                x: .value("Date", point.date),
                                                y: .value("Entries", point.count)
                                            )
                                            .foregroundStyle(Color.white)
                                            .symbolSize(30)
                                        }
                                    }
                                    .frame(height: 200)
                                    .chartYAxis {
                                        AxisMarks(position: .leading, values: .automatic) { _ in
                                            AxisGridLine().foregroundStyle(.white.opacity(0.1))
                                            AxisTick().foregroundStyle(.white)
                                            AxisValueLabel().foregroundStyle(.white)
                                        }
                                    }
                                    .chartXAxis {
                                        AxisMarks(values: .automatic) { _ in
                                            AxisValueLabel(format: .dateTime.day().month()).foregroundStyle(.white)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Detailed Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            StatBox(title: "Tests Passed", value: "\(viewModel.totalTestsPassed)", icon: "checkmark.seal.fill")
                            StatBox(title: "Plants Grown", value: "\(viewModel.totalPlantsGrown)", icon: "leaf.fill")
                            StatBox(title: "Journal Entries", value: "\(viewModel.journalEntries.count)", icon: "book.closed.fill")
                            StatBox(title: "Current Level", value: "\(viewModel.userLevel)", icon: "arrow.up.circle.fill")
                        }
                        .padding(.horizontal)
                        
                        // Global Stats (Enhanced)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Global Laboratory")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            BlurCardVG {
                                VStack(spacing: 15) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Global Community")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("1,245,892 Growers")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                        }
                                        Spacer()
                                        Image(systemName: "globe.europe.africa.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.glowingLime)
                                    }
                                    
                                    Divider().background(Color.white.opacity(0.2))
                                    
                                    // Community Goal
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Goal: 1 Billion Plants")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                            Spacer()
                                            Text("4.5%")
                                                .font(.caption)
                                                .foregroundColor(.neonLeaf)
                                        }
                                        
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule().fill(Color.white.opacity(0.1))
                                                Capsule().fill(
                                                    LinearGradient(colors: [.neonLeaf, .glowingLime], startPoint: .leading, endPoint: .trailing)
                                                )
                                                .frame(width: geo.size.width * 0.045)
                                            }
                                        }
                                        .frame(height: 8)
                                    }
                                    
                                    Divider().background(Color.white.opacity(0.2))
                                    
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Total Plants Planted")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("45,230,121")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                        }
                                        Spacer()
                                        Image(systemName: "leaf.circle.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.green)
                                    }
                                    
                                    Divider().background(Color.white.opacity(0.2))
                                    
                                    Text("You are in the top 12% of growers this week!")
                                        .font(.subheadline)
                                        .italic()
                                        .foregroundColor(.neonLeaf)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top)
                }
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        BlurCardVG {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.neonLeaf)
                    .padding(.bottom, 5)
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
