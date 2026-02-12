import Testing
@testable import PropertyFinder

@Suite("FavoritesViewModel Tests")
struct FavoritesViewModelTests {
    let mockFavRepo = MockFavoritesRepository()
    let mockPropRepo = MockPropertyRepository()

    func makeSUT() -> FavoritesViewModel {
        let useCase = ManageFavoritesUseCase(
            favoritesRepository: mockFavRepo,
            propertyRepository: mockPropRepo
        )
        return FavoritesViewModel(favoritesUseCase: useCase)
    }

    @Test("Loads favorites from repository")
    func loadFavorites() async {
        await mockFavRepo.addFavorite(propertyID: "p1")
        await mockFavRepo.addFavorite(propertyID: "p2")

        let sut = makeSUT()
        await sut.loadFavorites()

        #expect(sut.favorites.count == 2)
        #expect(sut.isLoading == false)
    }

    @Test("Empty favorites list")
    func emptyFavorites() async {
        let sut = makeSUT()
        await sut.loadFavorites()

        #expect(sut.favorites.isEmpty)
        #expect(sut.error == nil)
    }

    @Test("Remove favorite updates list")
    func removeFavorite() async {
        await mockFavRepo.addFavorite(propertyID: "p1")
        await mockFavRepo.addFavorite(propertyID: "p2")

        let sut = makeSUT()
        await sut.loadFavorites()
        #expect(sut.favorites.count == 2)

        await sut.removeFavorite("p1")
        #expect(sut.favorites.count == 1)
        #expect(!sut.favorites.contains { $0.id == "p1" })
    }
}
