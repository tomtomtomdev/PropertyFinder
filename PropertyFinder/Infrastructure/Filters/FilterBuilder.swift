import Foundation

struct PropertyFilter {
    let name: String
    let predicate: (Property) -> Bool
}

@resultBuilder
struct FilterBuilder {
    static func buildBlock(_ filters: PropertyFilter...) -> [PropertyFilter] {
        filters
    }

    static func buildOptional(_ filters: [PropertyFilter]?) -> [PropertyFilter] {
        filters ?? []
    }

    static func buildEither(first filters: [PropertyFilter]) -> [PropertyFilter] {
        filters
    }

    static func buildEither(second filters: [PropertyFilter]) -> [PropertyFilter] {
        filters
    }

    static func buildArray(_ components: [[PropertyFilter]]) -> [PropertyFilter] {
        components.flatMap { $0 }
    }
}

extension PropertyFilter {
    static func type(_ type: Property.PropertyType) -> PropertyFilter {
        PropertyFilter(name: "type:\(type.rawValue)") { $0.type == type }
    }

    static func purpose(_ purpose: Property.PropertyPurpose) -> PropertyFilter {
        PropertyFilter(name: "purpose:\(purpose.rawValue)") { $0.purpose == purpose }
    }

    static func priceRange(_ range: ClosedRange<Double>) -> PropertyFilter {
        PropertyFilter(name: "price:\(range.lowerBound)-\(range.upperBound)") {
            range.contains($0.price)
        }
    }

    static func minBedrooms(_ count: Int) -> PropertyFilter {
        PropertyFilter(name: "minBed:\(count)") { $0.bedrooms >= count }
    }

    static func maxBedrooms(_ count: Int) -> PropertyFilter {
        PropertyFilter(name: "maxBed:\(count)") { $0.bedrooms <= count }
    }

    static func location(_ location: String) -> PropertyFilter {
        PropertyFilter(name: "location:\(location)") {
            $0.location.area.localizedCaseInsensitiveContains(location)
                || $0.location.city.localizedCaseInsensitiveContains(location)
                || $0.location.emirate.localizedCaseInsensitiveContains(location)
        }
    }

    static func query(_ text: String) -> PropertyFilter {
        let searchText = text.lowercased()
        return PropertyFilter(name: "query:\(text)") { property in
            property.title.lowercased().contains(searchText)
                || property.description.lowercased().contains(searchText)
                || property.location.area.lowercased().contains(searchText)
                || property.location.city.lowercased().contains(searchText)
        }
    }

    static func minArea(_ sqft: Double) -> PropertyFilter {
        PropertyFilter(name: "minArea:\(sqft)") { $0.areaSqFt >= sqft }
    }
}
