import SwiftUI

struct FavoritesView: View {
    @Bindable var viewModel: FavoritesViewModel
    @State private var selectedProperty: Property?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading favorites...")
                } else if viewModel.favorites.isEmpty {
                    ContentUnavailableView(
                        "No Favorites Yet",
                        systemImage: "heart.slash",
                        description: Text("Properties you favorite will appear here.")
                    )
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Favorites")
            .sheet(item: $selectedProperty) { property in
                NavigationStack {
                    PropertyDetailView(property: property)
                }
            }
            .task {
                await viewModel.loadFavorites()
            }
            .refreshable {
                await viewModel.loadFavorites()
            }
        }
    }

    private var favoritesList: some View {
        List {
            ForEach(viewModel.favorites) { property in
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue.opacity(0.15))
                            .frame(width: 60, height: 60)
                        Image(systemName: "house.fill")
                            .foregroundStyle(.blue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(property.title)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                        Text(property.location.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(PriceFormatter.format(property.price, currency: property.currency, purpose: property.purpose))
                            .font(.caption.bold())
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { selectedProperty = property }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { await viewModel.removeFavorite(property.id) }
                    } label: {
                        Label("Remove", systemImage: "heart.slash")
                    }
                }
            }
        }
    }
}
