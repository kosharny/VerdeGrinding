import Foundation

struct JournalEntryVG: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var date: Date
    var text: String
    var mood: String
    var photoPath: String?
    var tags: [String]
}
