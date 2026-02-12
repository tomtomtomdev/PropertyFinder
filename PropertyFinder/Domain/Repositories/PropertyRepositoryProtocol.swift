import Foundation

protocol PropertyRepositoryProtocol {
    func searchProperties(criteria: SearchCriteria) async throws -> [Property]
    func getProperty(id: String) async throws -> Property?
    func getFeaturedProperties() async throws -> [Property]
    func getFilterOptions() async -> FilterOptions
}
