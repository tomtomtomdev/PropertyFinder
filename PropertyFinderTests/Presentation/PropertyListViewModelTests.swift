import Foundation
import Testing
@testable import PropertyFinder

@Suite("PropertyListViewModel Tests")
struct PropertyListViewModelTests {
    let mockPropRepo = MockPropertyRepository()
    let mockFavRepo = MockFavoritesRepository()

    func makeSUT() -> PropertyListViewModel {
        let searchUseCase = SearchPropertiesUseCase(repository: mockPropRepo)
        let favUseCase = ManageFavoritesUseCase(
            favoritesRepository: mockFavRepo,
            propertyRepository: mockPropRepo
        )
        return PropertyListViewModel(searchUseCase: searchUseCase, favoritesUseCase: favUseCase)
    }

    @Test("Loads properties successfully")
    func loadProperties() async {
        let sut = makeSUT()
        await sut.loadProperties()

        #expect(!sut.properties.isEmpty)
        #expect(sut.isLoading == false)
        #expect(sut.error == nil)
    }

    @Test("Sets featured properties")
    func setsFeaturedProperties() async {
        let sut = makeSUT()
        await sut.loadProperties()

        #expect(!sut.featuredProperties.isEmpty)
        #expect(sut.featuredProperties.allSatisfy { $0.isFeatured })
    }

    @Test("Load more increases visible count")
    func loadMore() async {
        // Set up 15 properties
        mockPropRepo.stubbedProperties = (0..<15).map { i in
            Property(
                id: "load_\(i)", title: "Property \(i)",
                description: "Test", type: .apartment, purpose: .buy,
                price: Double(i) * 100_000, currency: "AED",
                location: PropertyLocation(area: "Test", city: "Dubai", emirate: "Dubai"),
                bedrooms: 2, bathrooms: 1, areaSqFt: 1000,
                amenities: [], imageURLs: [],
                agent: TestFixtures.sampleAgent, isFeatured: false,
                createdAt: Date(), latitude: 25.0, longitude: 55.0
            )
        }

        let sut = makeSUT()
        await sut.loadProperties()
        let initialCount = sut.properties.count
        #expect(initialCount == 10) // Initial page size

        sut.loadMore()
        #expect(sut.properties.count == 15) // All loaded
    }

    @Test("hasMore returns true when more available")
    func hasMore() async {
        mockPropRepo.stubbedProperties = (0..<15).map { i in
            Property(
                id: "hm_\(i)", title: "P \(i)", description: "Test",
                type: .apartment, purpose: .buy, price: 100_000, currency: "AED",
                location: PropertyLocation(area: "Test", city: "Dubai", emirate: "Dubai"),
                bedrooms: 1, bathrooms: 1, areaSqFt: 500,
                amenities: [], imageURLs: [],
                agent: TestFixtures.sampleAgent, isFeatured: false,
                createdAt: Date(), latitude: 25.0, longitude: 55.0
            )
        }

        let sut = makeSUT()
        await sut.loadProperties()
        #expect(sut.hasMore == true)
    }

    @Test("Toggle layout switches between grid and list")
    func toggleLayout() {
        let sut = makeSUT()
        #expect(sut.isGridLayout == true)
        sut.toggleLayout()
        #expect(sut.isGridLayout == false)
        sut.toggleLayout()
        #expect(sut.isGridLayout == true)
    }
}
