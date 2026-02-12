import Foundation
import Observation

@Observable
final class SearchViewModel {
    var searchText = ""
    var results: [Property] = []
    var isSearching = false
    var suggestions: [String] = SearchViewModel.defaultSuggestions

    // Filter state
    var selectedType: Property.PropertyType?
    var selectedPurpose: Property.PropertyPurpose?
    var minPrice: Double?
    var maxPrice: Double?
    var minBedrooms: Int?
    var selectedLocation: String?
    var showingFilters = false

    private let searchUseCase: SearchPropertiesUseCase
    private var searchTask: Task<Void, Never>?

    static let defaultSuggestions = [
        "Dubai Marina", "Palm Jumeirah", "Downtown Dubai",
        "Business Bay", "JBR", "Villa", "Penthouse",
        "Abu Dhabi", "Saadiyat Island",
    ]

    init(searchUseCase: SearchPropertiesUseCase) {
        self.searchUseCase = searchUseCase
    }

    func search() {
        searchTask?.cancel()

        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty || hasActiveFilters else {
            results = []
            isSearching = false
            return
        }

        isSearching = true

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            let criteria = buildCriteria()

            do {
                let start = CFAbsoluteTimeGetCurrent()
                let searchResults = try await searchUseCase.execute(criteria: criteria)
                let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
                await PerformanceMonitor.shared.record("search.execute", value: elapsed)

                guard !Task.isCancelled else { return }
                results = searchResults
                isSearching = false
            } catch {
                guard !Task.isCancelled else { return }
                isSearching = false
            }
        }
    }

    func selectSuggestion(_ suggestion: String) {
        searchText = suggestion
        search()
    }

    func clearSearch() {
        searchText = ""
        results = []
        clearFilters()
    }

    func applyFilters() {
        showingFilters = false
        search()
    }

    func clearFilters() {
        selectedType = nil
        selectedPurpose = nil
        minPrice = nil
        maxPrice = nil
        minBedrooms = nil
        selectedLocation = nil
    }

    var hasActiveFilters: Bool {
        selectedType != nil || selectedPurpose != nil
            || minPrice != nil || maxPrice != nil
            || minBedrooms != nil || selectedLocation != nil
    }

    var activeFilterCount: Int {
        [
            selectedType != nil,
            selectedPurpose != nil,
            minPrice != nil || maxPrice != nil,
            minBedrooms != nil,
            selectedLocation != nil,
        ].filter { $0 }.count
    }

    private func buildCriteria() -> SearchCriteria {
        SearchCriteria(
            query: searchText,
            propertyType: selectedType,
            purpose: selectedPurpose,
            minPrice: minPrice,
            maxPrice: maxPrice,
            minBedrooms: minBedrooms,
            location: selectedLocation
        )
    }
}
