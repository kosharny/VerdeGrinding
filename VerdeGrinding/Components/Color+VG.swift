import SwiftUI

extension Color {
    static let vgDeepEmerald = Color("DeepEmerald")
    static let vgNeonLeaf = Color("NeonLeaf")
    static let vgDarkForest = Color("DarkForest")
    static let vgSoftMoss = Color("SoftMoss")
    static let vgGlowingLime = Color("GlowingLime")
    static let vgVoidBlack = Color("VoidBlack")
    
    // Fallbacks if assets are not yet created
    static func vgHex(_ hex: String) -> Color {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (str.hasPrefix("#")) {
            str.remove(at: str.startIndex)
        }
        if str.count != 6 {
            return Color.gray
        }
        var rgbValue: UInt64 = 0
        Scanner(string: str).scanHexInt64(&rgbValue)
        return Color(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
    
    // Default definitions using Hex if Asset Catalog is missing
    static let deepEmerald = vgHex("023020")
    static let neonLeaf = vgHex("39FF14")
    static let darkForest = vgHex("011F14")
    static let softMoss = vgHex("8A9A5B")
    static let glowingLime = vgHex("CCFF00")
    static let voidBlack = vgHex("050505")
}

struct VGGradient {
    static let primary = LinearGradient(colors: [.deepEmerald, .darkForest], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let neonGlow = LinearGradient(colors: [.neonLeaf, .glowingLime], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let glass = LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
}
