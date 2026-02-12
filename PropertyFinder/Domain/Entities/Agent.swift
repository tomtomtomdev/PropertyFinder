import Foundation

struct Agent: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let name: String
    let company: String
    let phone: String
    let email: String
    let imageURL: String
    let rating: Double
}
