import SwiftUI

struct PropertyListView: View {
    @Bindable var viewModel: PropertyListViewModel
    @State private var selectedProperty: Property?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if !viewModel.featuredProperties.isEmpty {
                        featuredSection
                    }

                    allPropertiesHeader

                    if viewModel.isGridLayout {
                        gridLayout
                    } else {
                        listLayout
                    }

                    if viewModel.hasMore {
                        ProgressView()
                            .padding()
                            .onAppear { viewModel.loadMore() }
                    }
                }
            }
            .navigationTitle("PropertyFinder")
            .overlay {
                if viewModel.isLoading && viewModel.properties.isEmpty {
                    shimmerOverlay
                }
            }
            .overlay {
                if let error = viewModel.error {
                    ContentUnavailableView(
                        "Error Loading Properties",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                }
            }
            .refreshable {
                await viewModel.loadProperties()
            }
            .sheet(item: $selectedProperty) { property in
                NavigationStack {
                    PropertyDetailView(property: property)
                }
            }
            .task {
                if viewModel.properties.isEmpty {
                    await viewModel.loadProperties()
                }
            }
        }
    }

    // MARK: - Sections

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Featured")
                .font(.title2.bold())
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewModel.featuredProperties) { property in
                        PropertyCardView(property: property, style: .featured)
                            .onTapGesture { selectedProperty = property }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var allPropertiesHeader: some View {
        HStack {
            Text("All Properties")
                .font(.title2.bold())
            Spacer()
            Button(action: viewModel.toggleLayout) {
                Image(systemName: viewModel.isGridLayout ? "list.bullet" : "square.grid.2x2")
                    .imageScale(.large)
            }
        }
        .padding(.horizontal)
    }

    private var gridLayout: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.properties) { property in
                PropertyCardView(property: property, style: .grid)
                    .onTapGesture { selectedProperty = property }
            }
        }
        .padding(.horizontal)
    }

    private var listLayout: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.properties) { property in
                PropertyCardView(property: property, style: .list)
                    .onTapGesture { selectedProperty = property }
            }
        }
        .padding(.horizontal)
    }

    private var shimmerOverlay: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                ShimmerView()
                    .frame(height: 200)
            }
        }
        .padding()
    }
}
