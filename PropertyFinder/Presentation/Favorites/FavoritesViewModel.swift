import Foundation
import Observation

@Observable
final class FavoritesViewModel {
    var favorites: [Property] = []
    var isLoading = false
    var error: String?

    private let favoritesUseCase: ManageFavoritesUseCase

    init(favoritesUseCase: ManageFavoritesUseCase) {
        self.favoritesUseCase = favoritesUseCase
    }

    func loadFavorites() async {
        isLoading = true
        error = nil
        do {
            favorites = try await favoritesUseCase.getFavoriteProperties()
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func removeFavorite(_ propertyID: String) async {
        await favoritesUseCase.toggleFavorite(propertyID: propertyID)
        favorites.removeAll { $0.id == propertyID }
    }
}
