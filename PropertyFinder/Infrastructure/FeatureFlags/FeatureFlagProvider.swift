import Foundation

protocol FeatureFlagProviding {
    func isEnabled(_ key: String) -> Bool
    func value<T>(for key: String) -> T?
    func setOverride(_ key: String, value: Any?)
    func removeOverride(_ key: String)
    func removeAllOverrides()
}

final class FeatureFlagProvider: FeatureFlagProviding {
    static let shared = FeatureFlagProvider()

    private var defaults: [String: Any] = [
        "enhanced_search": true,
        "show_map_view": true,
        "dark_mode_support": true,
        "price_prediction": false,
        "virtual_tour": false,
        "mortgage_calculator": true,
        "push_notifications": false,
        "grid_layout": true,
    ]

    private var overrides: [String: Any] = [:]

    func isEnabled(_ key: String) -> Bool {
        if let override = overrides[key] as? Bool { return override }
        return defaults[key] as? Bool ?? false
    }

    func value<T>(for key: String) -> T? {
        if let override = overrides[key] as? T { return override }
        return defaults[key] as? T
    }

    func setOverride(_ key: String, value: Any?) {
        overrides[key] = value
    }

    func removeOverride(_ key: String) {
        overrides.removeValue(forKey: key)
    }

    func removeAllOverrides() {
        overrides.removeAll()
    }

    var allFlags: [(key: String, defaultValue: Bool, currentValue: Bool)] {
        defaults.compactMap { key, value in
            guard let defaultBool = value as? Bool else { return nil }
            return (key: key, defaultValue: defaultBool, currentValue: isEnabled(key))
        }.sorted(by: { $0.key < $1.key })
    }
}
