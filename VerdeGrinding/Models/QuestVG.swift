import Foundation

struct QuestVG: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let difficulty: String
    let rewardXP: Int
    let requiredPlantId: String?
    var isCompleted: Bool = false
}
