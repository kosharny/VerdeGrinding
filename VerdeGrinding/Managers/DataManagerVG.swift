import Foundation

class DataManagerVG {
    static let shared = DataManagerVG()
    
    // Cache
    var plants: [PlantVG] = []
    var articles: [ArticleVG] = []
    var tests: [TestVG] = []
    var quests: [QuestVG] = []
    
    // Persistence Keys
    private let kJournal = "VG_Journal"
    private let kUserStats = "VG_UserStats"
    private let kUnlockedThemes = "VG_UnlockedThemes"
    private let kCompletedQuests = "VG_CompletedQuests"
    private let kUnlockedPlants = "VG_UnlockedPlants"
    
    private init() {
        loadJSONData()
    }
    
    func loadJSONData() {
        plants = load("plantsVG.json")
        articles = load("articlesVG.json")
        tests = load("testsVG.json")
        quests = load("questsVG.json")
    }
    
    func load<T: Decodable>(_ filename: String) -> [T] {
        let data: Data
        
        // First try to load from Bundle
        guard let file = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json")
        else {
            print("Couldn't find \(filename) in main bundle.")
            // Fallback: Check Documents directory (if we ever support dynamic updates)
            // For now, return empty
            return []
        }
        
        do {
            data = try Data(contentsOf: file)
            let decoder = JSONDecoder()
            // Support formatted dates if needed
            return try decoder.decode([T].self, from: data)
        } catch {
            print("Couldn't parse \(filename) as \(T.self):\n\(error)")
            return []
        }
    }
    
    // --- Persistence Methods ---
    
    func saveJournalEntry(_ entry: JournalEntryVG) {
        var entries = loadJournalEntries()
        entries.append(entry)
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: kJournal)
        }
    }
    
    func loadJournalEntries() -> [JournalEntryVG] {
        guard let data = UserDefaults.standard.data(forKey: kJournal),
              let entries = try? JSONDecoder().decode([JournalEntryVG].self, from: data) else {
            return []
        }
        return entries
    }
    
    // Helper for simple stats dictionary
    func saveStats(_ stats: [String: Any]) {
        UserDefaults.standard.set(stats, forKey: kUserStats)
    }
    
    func loadStats() -> [String: Any] {
        return UserDefaults.standard.dictionary(forKey: kUserStats) ?? [:]
    }
}
