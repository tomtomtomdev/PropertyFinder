import Testing
@testable import PropertyFinder

@Suite("FeatureFlag Tests")
struct FeatureFlagTests {
    @Test("Returns default value when no override")
    func defaultValue() {
        let provider = FeatureFlagProvider.shared
        provider.removeAllOverrides()
        #expect(provider.isEnabled("enhanced_search") == true)
        #expect(provider.isEnabled("price_prediction") == false)
    }

    @Test("Override takes precedence over default")
    func overrideTakesPrecedence() {
        let provider = FeatureFlagProvider.shared
        provider.removeAllOverrides()

        provider.setOverride("price_prediction", value: true)
        #expect(provider.isEnabled("price_prediction") == true)

        provider.removeOverride("price_prediction")
        #expect(provider.isEnabled("price_prediction") == false)
    }

    @Test("Unknown flag returns false")
    func unknownFlag() {
        let provider = FeatureFlagProvider.shared
        provider.removeAllOverrides()
        #expect(provider.isEnabled("nonexistent_flag") == false)
    }

    @Test("Remove all overrides restores defaults")
    func removeAllOverrides() {
        let provider = FeatureFlagProvider.shared
        provider.setOverride("enhanced_search", value: false)
        provider.setOverride("price_prediction", value: true)

        provider.removeAllOverrides()

        #expect(provider.isEnabled("enhanced_search") == true)
        #expect(provider.isEnabled("price_prediction") == false)
    }

    @Test("All flags returns sorted list")
    func allFlags() {
        let provider = FeatureFlagProvider.shared
        provider.removeAllOverrides()
        let flags = provider.allFlags
        #expect(!flags.isEmpty)
        let keys = flags.map(\.key)
        #expect(keys == keys.sorted())
    }

    @Test("Property wrapper reads from provider")
    func propertyWrapper() {
        let provider = FeatureFlagProvider.shared
        provider.removeAllOverrides()

        @FeatureFlag("enhanced_search", default: false) var enhancedSearch
        #expect(enhancedSearch == true) // Default is true in provider

        provider.setOverride("enhanced_search", value: false)
        @FeatureFlag("enhanced_search", default: false) var enhancedSearch2
        #expect(enhancedSearch2 == false)

        provider.removeAllOverrides()
    }
}
