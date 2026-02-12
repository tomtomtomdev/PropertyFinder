import Foundation

struct Property: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let title: String
    let description: String
    let type: PropertyType
    let purpose: PropertyPurpose
    let price: Double
    let currency: String
    let location: PropertyLocation
    let bedrooms: Int
    let bathrooms: Int
    let areaSqFt: Double
    let amenities: [String]
    let imageURLs: [String]
    let agent: Agent
    let isFeatured: Bool
    let createdAt: Date
    let latitude: Double
    let longitude: Double

    enum PropertyType: String, Codable, CaseIterable, Sendable {
        case villa
        case apartment
        case penthouse
        case townhouse
        case studio
    }

    enum PropertyPurpose: String, Codable, CaseIterable, Sendable {
        case buy
        case rent
    }
}

struct PropertyLocation: Hashable, Codable, Sendable {
    let area: String
    let city: String
    let emirate: String

    var displayName: String {
        "\(area), \(city)"
    }
}
