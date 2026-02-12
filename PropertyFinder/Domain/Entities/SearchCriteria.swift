import Foundation

struct SearchCriteria: Equatable, Sendable {
    var query: String = ""
    var propertyType: Property.PropertyType?
    var purpose: Property.PropertyPurpose?
    var minPrice: Double?
    var maxPrice: Double?
    var minBedrooms: Int?
    var maxBedrooms: Int?
    var location: String?
    var minArea: Double?
    var maxArea: Double?

    var isEmpty: Bool {
        query.isEmpty
            && propertyType == nil
            && purpose == nil
            && minPrice == nil
            && maxPrice == nil
            && minBedrooms == nil
            && maxBedrooms == nil
            && location == nil
            && minArea == nil
            && maxArea == nil
    }
}
