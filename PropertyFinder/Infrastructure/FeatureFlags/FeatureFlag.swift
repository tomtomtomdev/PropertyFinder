import Foundation

@propertyWrapper
struct FeatureFlag {
    let key: String
    let defaultValue: Bool

    var wrappedValue: Bool {
        FeatureFlagProvider.shared.isEnabled(key)
    }

    init(_ key: String, default defaultValue: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
