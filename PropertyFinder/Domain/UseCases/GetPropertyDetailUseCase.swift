import Foundation

struct GetPropertyDetailUseCase {
    private let repository: any PropertyRepositoryProtocol

    init(repository: any PropertyRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) async throws -> Property? {
        try await repository.getProperty(id: id)
    }
}
