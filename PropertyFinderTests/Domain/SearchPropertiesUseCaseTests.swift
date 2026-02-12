import Testing
@testable import PropertyFinder

@Suite("SearchPropertiesUseCase Tests")
struct SearchPropertiesUseCaseTests {
    let mockRepo = MockPropertyRepository()
    var sut: SearchPropertiesUseCase { SearchPropertiesUseCase(repository: mockRepo) }

    @Test("Returns all properties for empty criteria")
    func searchWithEmptyCriteria() async throws {
        let results = try await sut.execute(criteria: SearchCriteria())
        #expect(results.count == TestFixtures.sampleProperties.count)
    }

    @Test("Filters by query text")
    func searchByQuery() async throws {
        let criteria = SearchCriteria(query: "Palm")
        let results = try await sut.execute(criteria: criteria)
        #expect(results.allSatisfy { $0.title.contains("Palm") || $0.location.area.contains("Palm") })
        #expect(!results.isEmpty)
    }

    @Test("Filters by property type")
    func searchByPropertyType() async throws {
        let criteria = SearchCriteria(propertyType: .villa)
        let results = try await sut.execute(criteria: criteria)
        #expect(results.allSatisfy { $0.type == .villa })
        #expect(results.count == 2) // p1 and p5
    }

    @Test("Filters by purpose")
    func searchByPurpose() async throws {
        let criteria = SearchCriteria(purpose: .rent)
        let results = try await sut.execute(criteria: criteria)
        #expect(results.allSatisfy { $0.purpose == .rent })
        #expect(results.count == 1) // p4 studio
    }

    @Test("Filters by price range")
    func searchByPriceRange() async throws {
        let criteria = SearchCriteria(minPrice: 1_000_000, maxPrice: 10_000_000)
        let results = try await sut.execute(criteria: criteria)
        #expect(results.allSatisfy { $0.price >= 1_000_000 && $0.price <= 10_000_000 })
    }

    @Test("Filters by minimum bedrooms")
    func searchByMinBedrooms() async throws {
        let criteria = SearchCriteria(minBedrooms: 4)
        let results = try await sut.execute(criteria: criteria)
        #expect(results.allSatisfy { $0.bedrooms >= 4 })
    }

    @Test("Returns featured properties")
    func getFeaturedProperties() async throws {
        let results = try await sut.featured()
        #expect(results.count == 3) // p1, p3, p5
        #expect(results.allSatisfy { $0.isFeatured })
    }

    @Test("Tracks search call count")
    func tracksCallCount() async throws {
        _ = try await sut.execute(criteria: SearchCriteria())
        _ = try await sut.execute(criteria: SearchCriteria(query: "test"))
        #expect(mockRepo.searchCallCount == 2)
    }
}
