import SwiftUI

@main
struct VerdeGrindingApp: App {
    var body: some Scene {
        WindowGroup {
            MainViewVG()
                .environmentObject(ViewModelVG())
        }
    }
}
