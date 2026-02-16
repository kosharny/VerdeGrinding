import Foundation

enum PlantRarityVG: String, Codable {
    case common
    case rare
    case legendary
    case exotic
}

enum PlantTypeVG: String, Codable {
    case habit // Grows with good habits
    case weed // Shrinks/Dies with bad habits (concept: you want to eliminate these or transform them)
}

struct PlantVG: Identifiable, Codable {
    let id: String
    let name: String
    let scientificName: String
    let description: String
    let rarity: PlantRarityVG
    let type: PlantTypeVG
    let maxLevel: Int
    let stages: [String] // Image names for each stage
    let unlockCondition: String?
}
