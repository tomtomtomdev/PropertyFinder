import Foundation

struct PriceFormatter {
    static func format(_ price: Double, currency: String = "AED", purpose: Property.PropertyPurpose = .buy) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","

        let formatted = formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
        let suffix = purpose == .rent ? "/year" : ""
        return "\(currency) \(formatted)\(suffix)"
    }

    static func compactFormat(_ price: Double, currency: String = "AED") -> String {
        switch price {
        case 1_000_000...:
            return "\(currency) \(String(format: "%.1fM", price / 1_000_000))"
        case 1_000...:
            return "\(currency) \(String(format: "%.0fK", price / 1_000))"
        default:
            return "\(currency) \(Int(price))"
        }
    }
}
