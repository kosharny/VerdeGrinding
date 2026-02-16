import Foundation


enum TestTypeVG: String, Codable {
    case problemSolving
    case personalityMatch
    case knowledge
}

struct TestVG: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let imageName: String
    var type: TestTypeVG = .knowledge
    var rewardXP: Int = 50
    var isCompleted: Bool = false
    let questions: [QuestionVG]
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, imageName, type, rewardXP, isCompleted, questions
    }
    
    init(id: String, title: String, description: String, imageName: String, type: TestTypeVG = .knowledge, rewardXP: Int = 50, isCompleted: Bool = false, questions: [QuestionVG]) {
        self.id = id
        self.title = title
        self.description = description
        self.imageName = imageName
        self.type = type
        self.rewardXP = rewardXP
        self.isCompleted = isCompleted
        self.questions = questions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        imageName = try container.decode(String.self, forKey: .imageName)
        questions = try container.decode([QuestionVG].self, forKey: .questions)
        
        // Optional fields with defaults
        type = try container.decodeIfPresent(TestTypeVG.self, forKey: .type) ?? .knowledge
        rewardXP = try container.decodeIfPresent(Int.self, forKey: .rewardXP) ?? 50
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }
}

struct QuestionVG: Identifiable, Codable {
    var id: String { text }
    let text: String
    let options: [String]
    let correctOptionIndex: Int // Optional, if it's a knowledge test
    let personalityImpact: [String: Int]? // Optional, for personality tests
}
