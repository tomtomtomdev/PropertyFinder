import Foundation

actor FavoritesStore {
    private var ids: Set<String>
    private let defaults: UserDefaults
    private let key = "favorite_property_ids"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.ids = Set(defaults.stringArray(forKey: "favorite_property_ids") ?? [])
    }

    func getIDs() -> Set<String> { ids }

    func add(_ id: String) {
        ids.insert(id)
        persist()
    }

    func remove(_ id: String) {
        ids.remove(id)
        persist()
    }

    func contains(_ id: String) -> Bool {
        ids.contains(id)
    }

    @discardableResult
    func toggle(_ id: String) -> Bool {
        if ids.contains(id) {
            ids.remove(id)
            persist()
            return false
        } else {
            ids.insert(id)
            persist()
            return true
        }
    }

    private func persist() {
        defaults.set(Array(ids), forKey: key)
    }
}

final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let store: FavoritesStore

    init(store: FavoritesStore = FavoritesStore()) {
        self.store = store
    }

    func getFavoriteIDs() async -> Set<String> {
        await store.getIDs()
    }

    func addFavorite(propertyID: String) async {
        await store.add(propertyID)
    }

    func removeFavorite(propertyID: String) async {
        await store.remove(propertyID)
    }

    func isFavorite(propertyID: String) async -> Bool {
        await store.contains(propertyID)
    }

    @discardableResult
    func toggleFavorite(propertyID: String) async -> Bool {
        await store.toggle(propertyID)
    }
}
