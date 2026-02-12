import SwiftUI

struct SearchView: View {
    @Bindable var viewModel: SearchViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    @State private var selectedProperty: Property?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                content
            }
            .navigationTitle("Search")
            .sheet(item: $selectedProperty) { property in
                NavigationStack {
                    PropertyDetailView(property: property)
                }
            }
            .sheet(isPresented: $viewModel.showingFilters) {
                FilterSheetView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search properties...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .onSubmit { viewModel.search() }

                if !viewModel.searchText.isEmpty {
                    Button(action: viewModel.clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Button(action: { viewModel.showingFilters = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .frame(width: 40, height: 40)
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    if viewModel.activeFilterCount > 0 {
                        Text("\(viewModel.activeFilterCount)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 18, height: 18)
                            .background(.red)
                            .clipShape(Circle())
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isSearching {
            Spacer()
            ProgressView("Searching...")
            Spacer()
        } else if !viewModel.results.isEmpty {
            resultsList
        } else if !viewModel.searchText.isEmpty || viewModel.hasActiveFilters {
            ContentUnavailableView.search(text: viewModel.searchText)
        } else {
            suggestionsView
        }
    }

    private var resultsList: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.results) { property in
                    PropertyCardView(property: property, style: .grid)
                        .onTapGesture { selectedProperty = property }
                }
            }
            .padding()
        }
    }

    private var suggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Popular Searches")
                    .font(.headline)
                    .padding(.horizontal)

                FlowLayout(spacing: 8) {
                    ForEach(viewModel.suggestions, id: \.self) { suggestion in
                        Button(action: { viewModel.selectSuggestion(suggestion) }) {
                            Text(suggestion)
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }
}
