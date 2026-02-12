import SwiftUI

struct ContentView: View {
    @Bindable var coordinator: AppCoordinator
    let container: DependencyContainer

    @State private var listViewModel: PropertyListViewModel?
    @State private var searchViewModel: SearchViewModel?
    @State private var favoritesViewModel: FavoritesViewModel?

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            Tab("Browse", systemImage: "building.2", value: .browse) {
                PropertyListView(viewModel: resolveListViewModel())
            }

            Tab("Search", systemImage: "magnifyingglass", value: .search) {
                SearchView(viewModel: resolveSearchViewModel())
            }

            Tab("Favorites", systemImage: "heart", value: .favorites) {
                FavoritesView(viewModel: resolveFavoritesViewModel())
            }

            Tab("Debug", systemImage: "gear", value: .debug) {
                DebugMenuView()
            }
        }
    }

    private func resolveListViewModel() -> PropertyListViewModel {
        if let vm = listViewModel { return vm }
        let vm = container.makePropertyListViewModel()
        listViewModel = vm
        return vm
    }

    private func resolveSearchViewModel() -> SearchViewModel {
        if let vm = searchViewModel { return vm }
        let vm = container.makeSearchViewModel()
        searchViewModel = vm
        return vm
    }

    private func resolveFavoritesViewModel() -> FavoritesViewModel {
        if let vm = favoritesViewModel { return vm }
        let vm = container.makeFavoritesViewModel()
        favoritesViewModel = vm
        return vm
    }
}
