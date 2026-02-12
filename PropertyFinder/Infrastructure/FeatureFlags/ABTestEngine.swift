import Foundation

struct ABTestEngine {
    struct Experiment: Identifiable, Sendable {
        let id: String
        let name: String
        let variants: [String]
        let trafficPercentage: Double
    }

    private static let experiments: [Experiment] = [
        Experiment(
            id: "card_layout",
            name: "Property Card Layout",
            variants: ["compact", "expanded"],
            trafficPercentage: 1.0
        ),
        Experiment(
            id: "search_algorithm",
            name: "Search Algorithm",
            variants: ["relevance", "price_weighted"],
            trafficPercentage: 0.5
        ),
        Experiment(
            id: "cta_color",
            name: "CTA Button Color",
            variants: ["blue", "green", "orange"],
            trafficPercentage: 1.0
        ),
    ]

    static func variant(for experimentKey: String, userID: String = defaultUserID) -> String? {
        guard let experiment = experiments.first(where: { $0.id == experimentKey }) else {
            return nil
        }

        let hash = stableHash("\(userID)_\(experimentKey)")
        let bucket = hash % 100

        guard Double(bucket) < experiment.trafficPercentage * 100 else { return nil }

        let variantIndex = Int(hash / 100) % experiment.variants.count
        return experiment.variants[variantIndex]
    }

    static var allExperiments: [Experiment] { experiments }

    private static var defaultUserID: String {
        if let stored = UserDefaults.standard.string(forKey: "ab_test_user_id") {
            return stored
        }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: "ab_test_user_id")
        return id
    }

    static func stableHash(_ input: String) -> UInt {
        var hash: UInt = 5381
        for char in input.utf8 {
            hash = ((hash &<< 5) &+ hash) &+ UInt(char)
        }
        return hash
    }
}
