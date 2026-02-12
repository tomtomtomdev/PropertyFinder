import Foundation
import Testing
@testable import PropertyFinder

final class StubAPIClient: APIClientProtocol {
    var stubbedProperties: [Property] = TestFixtures.sampleProperties
    var fetchCallCount = 0

    func fetchProperties() async throws -> [Property] {
        fetchCallCount += 1
        return stubbedProperties
    }
}

@Suite("PropertyRepository Tests")
struct PropertyRepositoryTests {
    let stubClient = StubAPIClient()
    var sut: PropertyRepository { PropertyRepository(apiClient: stubClient) }

    @Test("Search returns all when empty criteria")
    func searchEmptyCriteria() async throws {
        let results = try await sut.searchProperties(criteria: SearchCriteria())
        #expect(results.count == TestFixtures.sampleProperties.count)
    }

    @Test("Search filters by query")
    func searchByQuery() async throws {
        let criteria = SearchCriteria(query: "Marina")
        let results = try await sut.searchProperties(criteria: criteria)
        #expect(!results.isEmpty)
        #expect(results.allSatisfy {
            $0.title.localizedCaseInsensitiveContains("Marina")
            || $0.location.area.localizedCaseInsensitiveContains("Marina")
        })
    }

    @Test("Get property by ID returns correct property")
    func getPropertyByID() async throws {
        let property = try await sut.getProperty(id: "p1")
        #expect(property != nil)
        #expect(property?.title == "Villa in Palm Jumeirah")
    }

    @Test("Get property by invalid ID returns nil")
    func getPropertyByInvalidID() async throws {
        let property = try await sut.getProperty(id: "nonexistent")
        #expect(property == nil)
    }

    @Test("Featured properties only includes featured")
    func getFeaturedProperties() async throws {
        let featured = try await sut.getFeaturedProperties()
        #expect(featured.allSatisfy { $0.isFeatured })
        #expect(!featured.isEmpty)
    }

    @Test("Filter options returns valid ranges")
    func getFilterOptions() async {
        let options = await sut.getFilterOptions()
        #expect(!options.availableLocations.isEmpty)
        #expect(options.priceRange.lowerBound > 0)
    }

    @Test("Caches properties after first load")
    func cachesProperties() async throws {
        let client = StubAPIClient()
        let repo = PropertyRepository(apiClient: client)
        _ = try await repo.searchProperties(criteria: SearchCriteria())
        _ = try await repo.searchProperties(criteria: SearchCriteria())
        #expect(client.fetchCallCount == 1)
    }
}
