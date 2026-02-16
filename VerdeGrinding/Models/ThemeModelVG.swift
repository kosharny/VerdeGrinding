import SwiftUI

struct ThemeModelVG: Identifiable, Equatable {
    let id: String
    let name: String
    let accentColor: Color
    let primaryColor: Color
    let headerBackground: Color
    let headerAccent: Color
    let cardBackground: Color
    let cardText: Color
    let isPremium: Bool
    let productID: String?
    
    // Predefined Themes
    static let defaultTheme = ThemeModelVG(
        id: "default",
        name: "Laboratory",
        accentColor: .neonLeaf,
        primaryColor: .darkForest, // Darker than deepEmerald
        headerBackground: Color.darkForest.opacity(0.95),
        headerAccent: .neonLeaf,
        cardBackground: Color.black.opacity(0.6),
        cardText: .white,
        isPremium: false,
        productID: nil
    )
    
    static let forestPro = ThemeModelVG(
        id: "forest_pro",
        name: "Forest Pro",
        accentColor: Color(red: 0.8, green: 1.0, blue: 0.0), // Bright lime
        primaryColor: Color(red: 0.0, green: 0.15, blue: 0.08), // Dark forest
        headerBackground: Color(red: 0.0, green: 0.1, blue: 0.05).opacity(0.95),
        headerAccent: Color(red: 0.8, green: 1.0, blue: 0.0),
        cardBackground: Color.black.opacity(0.7),
        cardText: .white,
        isPremium: true,
        productID: "premium_theme_forest_pro"
    )
    
    static let neonPro = ThemeModelVG(
        id: "neon_pro",
        name: "Neon Pro",
        accentColor: Color(red: 0.0, green: 1.0, blue: 1.0), // Bright cyan
        primaryColor: Color(red: 0.03, green: 0.0, blue: 0.08), // Very dark purple
        headerBackground: Color(red: 0.02, green: 0.0, blue: 0.06).opacity(0.95),
        headerAccent: Color(red: 0.8, green: 0.4, blue: 1.0), // Bright purple
        cardBackground: Color.black.opacity(0.7),
        cardText: .white,
        isPremium: true,
        productID: "premium_theme_neon_pro"
    )
    
    static let allThemes: [ThemeModelVG] = [defaultTheme, forestPro, neonPro]
}
