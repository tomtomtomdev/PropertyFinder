import Foundation

enum Endpoint {
    case searchProperties(SearchCriteria)
    case propertyDetail(String)
    case featuredProperties

    var path: String {
        switch self {
        case .searchProperties: "/api/properties/search"
        case .propertyDetail(let id): "/api/properties/\(id)"
        case .featuredProperties: "/api/properties/featured"
        }
    }
}
