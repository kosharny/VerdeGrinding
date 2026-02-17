import SwiftUI
import AppTrackingTransparency
import Combine

enum TabVG {
    case home
    case journal
    case game
    case stat
    case settings
}

class ViewModelVG: ObservableObject {
    @Published var selectedTab: TabVG = .home
    
    @Published var plants: [PlantVG] = []
    @Published var articles: [ArticleVG] = []
    @Published var tests: [TestVG] = []
    @Published var quests: [QuestVG] = []
    @Published var journalEntries: [JournalEntryVG] = []
    
    @Published var userLevel: Int = 1
    @Published var userXP: Int = 0
    @Published var unlockedThemeId: String = "default"
    
    // Premium & Themes
    @Published var premiumEnabled: Bool = false
    @Published var currentTheme: ThemeModelVG = .defaultTheme
    
    // Stats
    @Published var totalPlantsGrown: Int = 0
    @Published var totalTestsPassed: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        loadUserProgress()
        setupStoreSubscription()
    }
    
    func setupStoreSubscription() {
        StoreManagerVG.shared.$purchasedProductIDs
            .receive(on: RunLoop.main)
            .sink { [weak self] purchasedIDs in
                let isPremium = !purchasedIDs.isEmpty
                self?.premiumEnabled = isPremium
                self?.revalidateThemeAccess(isPremium: isPremium)
            }
            .store(in: &cancellables)
    }
    
    func revalidateThemeAccess(isPremium: Bool) {
        // If current theme is premium but user lost access (e.g. refund/error), revert to default
        if currentTheme.isPremium && !isPremium {
            // Further check: does the user own this specific premium theme?
            // Since isPremium is a broad check here, let's be more specific
            if !StoreManagerVG.shared.hasAccess(to: currentTheme) {
                print("Lost access to premium theme, reverting.")
                selectTheme(.defaultTheme)
            }
        }
    }
    
    func loadData() {
        self.plants = DataManagerVG.shared.plants
        self.articles = DataManagerVG.shared.articles
        // We are overriding local data with "Cloud" mock data for now to ensure content exists
        self.journalEntries = DataManagerVG.shared.loadJournalEntries()
        
        // Load Quests and Tests from JSON via DataManager
        self.quests = DataManagerVG.shared.quests
        self.tests = DataManagerVG.shared.tests
        
        // If JSON load failed (empty), fallback or handle gracefully
        if self.quests.isEmpty {
            print("Warning: No quests loaded from JSON.")
        }
        if self.tests.isEmpty {
            print("Warning: No tests loaded from JSON.")
        }
    }
    
    func loadUserProgress() {
        let stats = DataManagerVG.shared.loadStats()
        self.userLevel = stats["level"] as? Int ?? 1
        self.userXP = stats["xp"] as? Int ?? 0
        self.totalPlantsGrown = stats["plantsGrown"] as? Int ?? 0
        self.totalTestsPassed = stats["testsPassed"] as? Int ?? 0
        
        // Load Theme ID but don't apply yet - wait for store to load
        let savedThemeID = UserDefaults.standard.string(forKey: "VG_SelectedTheme") ?? "default"
        self.unlockedThemeId = savedThemeID
        
        // Apply theme after a short delay to allow StoreManager to restore purchases
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.applyStoredTheme()
        }
        
        // Restore completed state for tests and quests
        let completedTestIds = UserDefaults.standard.stringArray(forKey: "VG_CompletedTestIds") ?? []
        for id in completedTestIds {
            if let index = tests.firstIndex(where: { $0.id == id }) {
                tests[index].isCompleted = true
            }
        }
        
        let completedQuestIds = UserDefaults.standard.stringArray(forKey: "VG_CompletedQuestIds") ?? []
        for id in completedQuestIds {
            if let index = quests.firstIndex(where: { $0.id == id }) {
                quests[index].isCompleted = true
            }
        }
    }
    
    func applyStoredTheme() {
        let savedThemeID = UserDefaults.standard.string(forKey: "VG_SelectedTheme") ?? "default"
        
        if let theme = ThemeModelVG.allThemes.first(where: { $0.id == savedThemeID }) {
            // Check access before applying
            if StoreManagerVG.shared.hasAccess(to: theme) {
                self.currentTheme = theme
                print("Applied saved theme: \(theme.name)")
            } else {
                print("No access to saved theme \(theme.name), using default")
                self.currentTheme = .defaultTheme
                self.unlockedThemeId = "default"
                UserDefaults.standard.set("default", forKey: "VG_SelectedTheme")
            }
        } else {
            self.currentTheme = .defaultTheme
        }
    }
    
    func saveProgress() {
        let stats: [String: Any] = [
            "level": userLevel,
            "xp": userXP,
            "plantsGrown": totalPlantsGrown,
            "testsPassed": totalTestsPassed
        ]
        DataManagerVG.shared.saveStats(stats)
        UserDefaults.standard.set(currentTheme.id, forKey: "VG_SelectedTheme")
        
        // Save completed IDs
        let completedTestIds = tests.filter { $0.isCompleted }.map { $0.id }
        UserDefaults.standard.set(completedTestIds, forKey: "VG_CompletedTestIds")
        
        let completedQuestIds = quests.filter { $0.isCompleted }.map { $0.id }
        UserDefaults.standard.set(completedQuestIds, forKey: "VG_CompletedQuestIds")
    }
    
    var themeGradient: LinearGradient {
        LinearGradient(
            colors: [currentTheme.primaryColor, currentTheme.accentColor.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    func selectTheme(_ theme: ThemeModelVG) {
        if theme.isPremium {
            if !StoreManagerVG.shared.hasAccess(to: theme) {
                return
            }
        }

        self.currentTheme = theme
        self.unlockedThemeId = theme.id
        saveProgress()
    }
    
    var sortedJournalEntries: [JournalEntryVG] {
        journalEntries.sorted { $0.date > $1.date }
    }
    
    func addJournalEntry(_ entry: JournalEntryVG, imageData: Data?) {
        var entryWithImage = entry
        
        if let data = imageData {
            if let path = saveImageToDocuments(data: data) {
                entryWithImage.photoPath = path
            }
        }
        
        journalEntries.append(entryWithImage)
        DataManagerVG.shared.saveJournalEntry(entryWithImage)
        // Reward XP
        addXP(amount: 20)
    }
    
    private func saveImageToDocuments(data: Data) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImageFromDocuments(fileName: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func addXP(amount: Int) {
        userXP += amount
        // Simple level up logic
        if userXP >= (userLevel * 100) {
            userLevel += 1
            userXP = 0 // Reset or carry over logic
        }
        saveProgress()
    }
    
    func requestTrackingPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // Handle status
                print("Tracking status: \(status.rawValue)")
            }
        }
    }
    
    // Plant Logic
    func unlockPlant(id: String) {
        // Implementation for persistence of unlocked plants needed
        // For now just tracking stats
        totalPlantsGrown += 1
        saveProgress()
    }
    
    // Test Logic
    func completeTest(testId: String, score: Int) {
        guard let index = tests.firstIndex(where: { $0.id == testId }) else { return }
        
        // Pass Logic: Must answer at least 50% correctly
        // Note: score passed here is raw count. We need total questions to calc percentage.
        // We can get total from the test object.
        let test = tests[index]
        let totalQuestions = test.questions.count
        let percentage = Double(score) / Double(totalQuestions)
        
        if percentage >= 0.5 {
            if !tests[index].isCompleted {
                tests[index].isCompleted = true
                totalTestsPassed += 1
                
                // Award XP
                let reward = tests[index].rewardXP
                addXP(amount: reward)
                
                saveProgress()
            }
        } else {
             // Logic for failure is handled in View (Retry), but here we ensure no completion is marked.
             print("Test failed. Score: \(score)/\(totalQuestions)")
        }
    }
    
    // Quest Logic
    func completeQuest(questId: String) {
        guard let index = quests.firstIndex(where: { $0.id == questId }) else { return }
        
        if !quests[index].isCompleted {
            quests[index].isCompleted = true
            addXP(amount: quests[index].rewardXP)
            
            saveProgress()
        }
    }
}
