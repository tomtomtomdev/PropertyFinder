import Foundation

protocol FavoritesRepositoryProtocol {
    func getFavoriteIDs() async -> Set<String>
    func addFavorite(propertyID: String) async
    func removeFavorite(propertyID: String) async
    func isFavorite(propertyID: String) async -> Bool
    @discardableResult
    func toggleFavorite(propertyID: String) async -> Bool
}
