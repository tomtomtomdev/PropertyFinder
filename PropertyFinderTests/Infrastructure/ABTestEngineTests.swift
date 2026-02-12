import Testing
@testable import PropertyFinder

@Suite("ABTestEngine Tests")
struct ABTestEngineTests {
    @Test("Returns variant for valid experiment")
    func validExperiment() {
        let variant = ABTestEngine.variant(for: "card_layout", userID: "test_user")
        #expect(variant != nil)
        #expect(["compact", "expanded"].contains(variant!))
    }

    @Test("Returns nil for unknown experiment")
    func unknownExperiment() {
        let variant = ABTestEngine.variant(for: "nonexistent", userID: "test_user")
        #expect(variant == nil)
    }

    @Test("Same user gets consistent variant")
    func consistentVariant() {
        let variant1 = ABTestEngine.variant(for: "card_layout", userID: "consistent_user")
        let variant2 = ABTestEngine.variant(for: "card_layout", userID: "consistent_user")
        #expect(variant1 == variant2)
    }

    @Test("Different users can get different variants")
    func differentUsersVariants() {
        var variants: Set<String> = []
        for i in 0..<100 {
            if let v = ABTestEngine.variant(for: "card_layout", userID: "user_\(i)") {
                variants.insert(v)
            }
        }
        // With 100 users, both variants should appear
        #expect(variants.count == 2)
    }

    @Test("All experiments are accessible")
    func allExperiments() {
        let experiments = ABTestEngine.allExperiments
        #expect(experiments.count == 3)
        #expect(experiments.contains { $0.id == "card_layout" })
        #expect(experiments.contains { $0.id == "search_algorithm" })
        #expect(experiments.contains { $0.id == "cta_color" })
    }

    @Test("Hash function is deterministic")
    func hashDeterministic() {
        let h1 = ABTestEngine.stableHash("test_input")
        let h2 = ABTestEngine.stableHash("test_input")
        #expect(h1 == h2)
    }

    @Test("Hash function produces different values for different inputs")
    func hashDifferentInputs() {
        let h1 = ABTestEngine.stableHash("input_a")
        let h2 = ABTestEngine.stableHash("input_b")
        #expect(h1 != h2)
    }
}
