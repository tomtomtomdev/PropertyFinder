import Testing
@testable import PropertyFinder

@Suite("SearchViewModel Tests")
struct SearchViewModelTests {
    let mockRepo = MockPropertyRepository()

    func makeSUT() -> SearchViewModel {
        let useCase = SearchPropertiesUseCase(repository: mockRepo)
        return SearchViewModel(searchUseCase: useCase)
    }

    @Test("Initial state is correct")
    func initialState() {
        let sut = makeSUT()
        #expect(sut.searchText == "")
        #expect(sut.results.isEmpty)
        #expect(sut.isSearching == false)
        #expect(!sut.suggestions.isEmpty)
    }

    @Test("Clear search resets state")
    func clearSearch() {
        let sut = makeSUT()
        sut.searchText = "test"
        sut.clearSearch()
        #expect(sut.searchText == "")
        #expect(sut.results.isEmpty)
    }

    @Test("Has active filters detects filter state")
    func hasActiveFilters() {
        let sut = makeSUT()
        #expect(sut.hasActiveFilters == false)

        sut.selectedType = .villa
        #expect(sut.hasActiveFilters == true)

        sut.clearFilters()
        #expect(sut.hasActiveFilters == false)
    }

    @Test("Active filter count is accurate")
    func activeFilterCount() {
        let sut = makeSUT()
        #expect(sut.activeFilterCount == 0)

        sut.selectedType = .villa
        #expect(sut.activeFilterCount == 1)

        sut.selectedPurpose = .buy
        #expect(sut.activeFilterCount == 2)

        sut.minPrice = 100_000
        #expect(sut.activeFilterCount == 3)
    }

    @Test("Select suggestion updates search text")
    func selectSuggestion() {
        let sut = makeSUT()
        sut.selectSuggestion("Dubai Marina")
        #expect(sut.searchText == "Dubai Marina")
    }

    @Test("Clear filters resets all filter state")
    func clearFilters() {
        let sut = makeSUT()
        sut.selectedType = .villa
        sut.selectedPurpose = .buy
        sut.minPrice = 100_000
        sut.maxPrice = 5_000_000
        sut.minBedrooms = 3
        sut.selectedLocation = "Dubai"

        sut.clearFilters()

        #expect(sut.selectedType == nil)
        #expect(sut.selectedPurpose == nil)
        #expect(sut.minPrice == nil)
        #expect(sut.maxPrice == nil)
        #expect(sut.minBedrooms == nil)
        #expect(sut.selectedLocation == nil)
    }
}
