import Foundation

struct SearchPropertiesUseCase {
    private let repository: any PropertyRepositoryProtocol

    init(repository: any PropertyRepositoryProtocol) {
        self.repository = repository
    }

    func execute(criteria: SearchCriteria) async throws -> [Property] {
        try await repository.searchProperties(criteria: criteria)
    }

    func featured() async throws -> [Property] {
        try await repository.getFeaturedProperties()
    }
}
