import Observation
import SwiftUI

@Observable
final class AppCoordinator {
    var selectedTab: Tab = .browse
    var navigationPath = NavigationPath()
    var showingFilterSheet = false

    enum Tab: Int, CaseIterable {
        case browse, search, favorites, debug

        var title: String {
            switch self {
            case .browse: "Browse"
            case .search: "Search"
            case .favorites: "Favorites"
            case .debug: "Debug"
            }
        }

        var icon: String {
            switch self {
            case .browse: "building.2"
            case .search: "magnifyingglass"
            case .favorites: "heart"
            case .debug: "gear"
            }
        }
    }
}

@Observable
final class DependencyContainer {
    static let shared = DependencyContainer()

    let apiClient: any APIClientProtocol
    let propertyRepository: any PropertyRepositoryProtocol
    let favoritesRepository: any FavoritesRepositoryProtocol
    let searchPropertiesUseCase: SearchPropertiesUseCase
    let getPropertyDetailUseCase: GetPropertyDetailUseCase
    let manageFavoritesUseCase: ManageFavoritesUseCase

    init(
        apiClient: (any APIClientProtocol)? = nil,
        favoritesRepository: (any FavoritesRepositoryProtocol)? = nil
    ) {
        let client = apiClient ?? MockAPIClient()
        let propRepo = PropertyRepository(apiClient: client)
        let favRepo = favoritesRepository ?? FavoritesRepository()

        self.apiClient = client
        self.propertyRepository = propRepo
        self.favoritesRepository = favRepo
        self.searchPropertiesUseCase = SearchPropertiesUseCase(repository: propRepo)
        self.getPropertyDetailUseCase = GetPropertyDetailUseCase(repository: propRepo)
        self.manageFavoritesUseCase = ManageFavoritesUseCase(
            favoritesRepository: favRepo,
            propertyRepository: propRepo
        )
    }

    func makePropertyListViewModel() -> PropertyListViewModel {
        PropertyListViewModel(
            searchUseCase: searchPropertiesUseCase,
            favoritesUseCase: manageFavoritesUseCase
        )
    }

    func makePropertyDetailViewModel() -> PropertyDetailViewModel {
        PropertyDetailViewModel(
            getDetailUseCase: getPropertyDetailUseCase,
            favoritesUseCase: manageFavoritesUseCase
        )
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(searchUseCase: searchPropertiesUseCase)
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(favoritesUseCase: manageFavoritesUseCase)
    }
}
