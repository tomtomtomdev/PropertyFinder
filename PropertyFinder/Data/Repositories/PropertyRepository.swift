import Foundation

final class PropertyRepository: PropertyRepositoryProtocol {
    private let apiClient: any APIClientProtocol
    private var cachedProperties: [Property]?

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func searchProperties(criteria: SearchCriteria) async throws -> [Property] {
        let properties = try await loadProperties()

        guard !criteria.isEmpty else { return properties }

        return properties.filter { property in
            var matches = true

            if !criteria.query.isEmpty {
                let q = criteria.query.lowercased()
                matches = matches && (
                    property.title.lowercased().contains(q)
                    || property.description.lowercased().contains(q)
                    || property.location.area.lowercased().contains(q)
                    || property.location.city.lowercased().contains(q)
                    || property.location.emirate.lowercased().contains(q)
                    || property.agent.name.lowercased().contains(q)
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

            if let maxBedrooms = criteria.maxBedrooms {
                matches = matches && property.bedrooms <= maxBedrooms
            }

            if let location = criteria.location {
                let loc = location.lowercased()
                matches = matches && (
                    property.location.area.lowercased().contains(loc)
                    || property.location.city.lowercased().contains(loc)
                    || property.location.emirate.lowercased().contains(loc)
                )
            }

            if let minArea = criteria.minArea {
                matches = matches && property.areaSqFt >= minArea
            }

            if let maxArea = criteria.maxArea {
                matches = matches && property.areaSqFt <= maxArea
            }

            return matches
        }
    }

    func getProperty(id: String) async throws -> Property? {
        let properties = try await loadProperties()
        return properties.first { $0.id == id }
    }

    func getFeaturedProperties() async throws -> [Property] {
        let properties = try await loadProperties()
        return properties.filter(\.isFeatured)
    }

    func getFilterOptions() async -> FilterOptions {
        guard let properties = try? await loadProperties() else {
            return .default
        }
        let locations = Set(properties.map(\.location.area)).sorted()
        let prices = properties.map(\.price)
        let bedrooms = properties.map(\.bedrooms)
        return FilterOptions(
            propertyTypes: Property.PropertyType.allCases,
            purposes: Property.PropertyPurpose.allCases,
            priceRange: (prices.min() ?? 100_000)...(prices.max() ?? 50_000_000),
            bedroomRange: (bedrooms.min() ?? 0)...(bedrooms.max() ?? 10),
            availableLocations: locations
        )
    }

    private func loadProperties() async throws -> [Property] {
        if let cached = cachedProperties { return cached }
        let properties = try await apiClient.fetchProperties()
        cachedProperties = properties
        return properties
    }
}
