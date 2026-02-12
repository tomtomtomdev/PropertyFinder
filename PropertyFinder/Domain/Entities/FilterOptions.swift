import Foundation

struct FilterOptions: Sendable {
    let propertyTypes: [Property.PropertyType]
    let purposes: [Property.PropertyPurpose]
    let priceRange: ClosedRange<Double>
    let bedroomRange: ClosedRange<Int>
    let availableLocations: [String]

    static let `default` = FilterOptions(
        propertyTypes: Property.PropertyType.allCases,
        purposes: Property.PropertyPurpose.allCases,
        priceRange: 100_000...50_000_000,
        bedroomRange: 0...10,
        availableLocations: [
            "Downtown Dubai",
            "Dubai Marina",
            "Palm Jumeirah",
            "Business Bay",
            "JBR",
            "Abu Dhabi Corniche",
            "Saadiyat Island",
            "Yas Island",
        ]
    )
}
