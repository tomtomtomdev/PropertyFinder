import Foundation
import Testing
@testable import PropertyFinder

// MARK: - Shared Test Helpers

final class MockPropertyRepository: PropertyRepositoryProtocol {
    var stubbedProperties: [Property] = TestFixtures.sampleProperties
    var searchCallCount = 0
    var lastSearchCriteria: SearchCriteria?

    func searchProperties(criteria: SearchCriteria) async throws -> [Property] {
        searchCallCount += 1
        lastSearchCriteria = criteria

        guard !criteria.isEmpty else { return stubbedProperties }

        return stubbedProperties.filter { property in
            var matches = true
            if !criteria.query.isEmpty {
                let q = criteria.query.lowercased()
                matches = matches && (
                    property.title.lowercased().contains(q)
                    || property.location.area.lowercased().contains(q)
                )
            }
            if let type = criteria.propertyType {
                matches = matches && property.type == type
            }
            if let purpose = criteria.purpose {
                matches = matches && property.purpose == purpose
            }
            if let minPrice = criteria.minPrice {
                matches = matches && property.price >= minPrice
            }
            if let maxPrice = criteria.maxPrice {
                matches = matches && property.price <= maxPrice
            }
            if let minBedrooms = criteria.minBedrooms {
                matches = matches && property.bedrooms >= minBedrooms
            }
            return matches
        }
    }

    func getProperty(id: String) async throws -> Property? {
        stubbedProperties.first { $0.id == id }
    }

    func getFeaturedProperties() async throws -> [Property] {
        stubbedProperties.filter(\.isFeatured)
    }

    func getFilterOptions() async -> FilterOptions {
        .default
    }
}

final class MockFavoritesRepository: FavoritesRepositoryProtocol {
    var favorites: Set<String> = []

    func getFavoriteIDs() async -> Set<String> { favorites }

    func addFavorite(propertyID: String) async {
        favorites.insert(propertyID)
    }

    func removeFavorite(propertyID: String) async {
        favorites.remove(propertyID)
    }

    func isFavorite(propertyID: String) async -> Bool {
        favorites.contains(propertyID)
    }

    @discardableResult
    func toggleFavorite(propertyID: String) async -> Bool {
        if favorites.contains(propertyID) {
            favorites.remove(propertyID)
            return false
        } else {
            favorites.insert(propertyID)
            return true
        }
    }
}

// MARK: - Test Fixtures

enum TestFixtures {
    static let sampleAgent = Agent(
        id: "agent_test",
        name: "Test Agent",
        company: "Test Realty",
        phone: "+971-50-000-0000",
        email: "test@test.ae",
        imageURL: "agent_test",
        rating: 4.5
    )

    static let sampleProperties: [Property] = [
        Property(
            id: "p1", title: "Villa in Palm Jumeirah",
            description: "Luxury waterfront villa",
            type: .villa, purpose: .buy, price: 12_500_000, currency: "AED",
            location: PropertyLocation(area: "Palm Jumeirah", city: "Dubai", emirate: "Dubai"),
            bedrooms: 5, bathrooms: 7, areaSqFt: 8500,
            amenities: ["Pool", "Beach", "Gym"],
            imageURLs: ["img1", "img2"],
            agent: sampleAgent, isFeatured: true,
            createdAt: Date(), latitude: 25.1124, longitude: 55.1390
        ),
        Property(
            id: "p2", title: "Apartment in Dubai Marina",
            description: "Modern marina apartment",
            type: .apartment, purpose: .buy, price: 1_850_000, currency: "AED",
            location: PropertyLocation(area: "Dubai Marina", city: "Dubai", emirate: "Dubai"),
            bedrooms: 2, bathrooms: 2, areaSqFt: 1250,
            amenities: ["Pool", "Gym"],
            imageURLs: ["img3"],
            agent: sampleAgent, isFeatured: false,
            createdAt: Date(), latitude: 25.0805, longitude: 55.1403
        ),
        Property(
            id: "p3", title: "Penthouse in Downtown",
            description: "Premium downtown penthouse with views",
            type: .penthouse, purpose: .buy, price: 8_500_000, currency: "AED",
            location: PropertyLocation(area: "Downtown Dubai", city: "Dubai", emirate: "Dubai"),
            bedrooms: 4, bathrooms: 5, areaSqFt: 6200,
            amenities: ["Terrace", "Concierge", "Spa"],
            imageURLs: ["img4", "img5"],
            agent: sampleAgent, isFeatured: true,
            createdAt: Date(), latitude: 25.1972, longitude: 55.2744
        ),
        Property(
            id: "p4", title: "Studio in Business Bay",
            description: "Modern studio for professionals",
            type: .studio, purpose: .rent, price: 55_000, currency: "AED",
            location: PropertyLocation(area: "Business Bay", city: "Dubai", emirate: "Dubai"),
            bedrooms: 0, bathrooms: 1, areaSqFt: 550,
            amenities: ["Gym", "Pool"],
            imageURLs: ["img6"],
            agent: sampleAgent, isFeatured: false,
            createdAt: Date(), latitude: 25.1852, longitude: 55.2620
        ),
        Property(
            id: "p5", title: "Villa in Abu Dhabi",
            description: "Saadiyat Island beach villa",
            type: .villa, purpose: .buy, price: 15_000_000, currency: "AED",
            location: PropertyLocation(area: "Saadiyat Island", city: "Abu Dhabi", emirate: "Abu Dhabi"),
            bedrooms: 6, bathrooms: 8, areaSqFt: 10200,
            amenities: ["Beach", "Pool", "Garden"],
            imageURLs: ["img7", "img8"],
            agent: sampleAgent, isFeatured: true,
            createdAt: Date(), latitude: 24.5401, longitude: 54.4348
        ),
    ]
}
