import Foundation
import Observation

@Observable
final class PropertyListViewModel {
    var properties: [Property] = []
    var featuredProperties: [Property] = []
    var isLoading = false
    var error: String?
    var isGridLayout = true

    private let searchUseCase: SearchPropertiesUseCase
    private let favoritesUseCase: ManageFavoritesUseCase
    private var allProperties: [Property] = []
    private var visibleCount = 10

    init(searchUseCase: SearchPropertiesUseCase, favoritesUseCase: ManageFavoritesUseCase) {
        self.searchUseCase = searchUseCase
        self.favoritesUseCase = favoritesUseCase
    }

    func loadProperties() async {
        isLoading = true
        error = nil

        do {
            let start = CFAbsoluteTimeGetCurrent()
            allProperties = try await searchUseCase.execute(criteria: SearchCriteria())
            let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
            await PerformanceMonitor.shared.record("property_list.load", value: elapsed)

            featuredProperties = allProperties.filter(\.isFeatured)
            visibleCount = 10
            properties = Array(allProperties.prefix(visibleCount))
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func loadMore() {
        guard visibleCount < allProperties.count else { return }
        visibleCount += 10
        properties = Array(allProperties.prefix(visibleCount))
    }

    var hasMore: Bool {
        visibleCount < allProperties.count
    }

    func toggleFavorite(_ propertyID: String) async {
        await favoritesUseCase.toggleFavorite(propertyID: propertyID)
    }

    func isFavorite(_ propertyID: String) async -> Bool {
        await favoritesUseCase.isFavorite(propertyID: propertyID)
    }

    func toggleLayout() {
        isGridLayout.toggle()
    }
}
