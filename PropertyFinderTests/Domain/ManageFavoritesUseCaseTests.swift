import Testing
@testable import PropertyFinder

@Suite("ManageFavoritesUseCase Tests")
struct ManageFavoritesUseCaseTests {
    let mockFavRepo = MockFavoritesRepository()
    let mockPropRepo = MockPropertyRepository()
    var sut: ManageFavoritesUseCase {
        ManageFavoritesUseCase(
            favoritesRepository: mockFavRepo,
            propertyRepository: mockPropRepo
        )
    }

    @Test("Toggle adds then removes favorite")
    func toggleFavorite() async {
        let result1 = await sut.toggleFavorite(propertyID: "p1")
        #expect(result1 == true) // Added

        let result2 = await sut.toggleFavorite(propertyID: "p1")
        #expect(result2 == false) // Removed
    }

    @Test("Checks favorite status")
    func isFavorite() async {
        await mockFavRepo.addFavorite(propertyID: "p2")
        let isFav = await sut.isFavorite(propertyID: "p2")
        #expect(isFav == true)

        let isNotFav = await sut.isFavorite(propertyID: "p999")
        #expect(isNotFav == false)
    }

    @Test("Gets favorite properties")
    func getFavoriteProperties() async throws {
        await mockFavRepo.addFavorite(propertyID: "p1")
        await mockFavRepo.addFavorite(propertyID: "p3")

        let favorites = try await sut.getFavoriteProperties()
        #expect(favorites.count == 2)
        #expect(favorites.contains { $0.id == "p1" })
        #expect(favorites.contains { $0.id == "p3" })
    }

    @Test("Returns empty when no favorites")
    func emptyFavorites() async throws {
        let favorites = try await sut.getFavoriteProperties()
        #expect(favorites.isEmpty)
    }
}
