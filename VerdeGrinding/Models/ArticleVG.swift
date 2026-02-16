import Foundation

struct ArticleVG: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let content: String // Very long text
    let imageName: String
    let readingTime: Int
    let category: String
    let date: String
}
