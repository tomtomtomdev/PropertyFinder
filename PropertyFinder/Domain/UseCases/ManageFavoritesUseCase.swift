import Foundation

struct ManageFavoritesUseCase {
    private let favoritesRepository: any FavoritesRepositoryProtocol
    private let propertyRepository: any PropertyRepositoryProtocol

    init(
        favoritesRepository: any FavoritesRepositoryProtocol,
        propertyRepository: any PropertyRepositoryProtocol
    ) {
        self.favoritesRepository = favoritesRepository
        self.propertyRepository = propertyRepository
    }

    @discardableResult
    func toggleFavorite(propertyID: String) async -> Bool {
        await favoritesRepository.toggleFavorite(propertyID: propertyID)
    }

    func isFavorite(propertyID: String) async -> Bool {
        await favoritesRepository.isFavorite(propertyID: propertyID)
    }

    func getFavoriteProperties() async throws -> [Property] {
        let ids = await favoritesRepository.getFavoriteIDs()
        let allProperties = try await propertyRepository.searchProperties(criteria: SearchCriteria())
        return allProperties.filter { ids.contains($0.id) }
    }
}
