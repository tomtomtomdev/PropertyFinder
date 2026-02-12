import Foundation

protocol APIClientProtocol {
    func fetchProperties() async throws -> [Property]
}

final class MockAPIClient: APIClientProtocol {
    func fetchProperties() async throws -> [Property] {
        let start = CFAbsoluteTimeGetCurrent()
        // Simulate network latency
        try await Task.sleep(for: .milliseconds(Int.random(in: 200...600)))

        guard let url = Bundle.main.url(forResource: "properties", withExtension: "json") else {
            throw APIError.resourceNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let properties = try decoder.decode([Property].self, from: data)

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        await PerformanceMonitor.shared.record("api.fetch_properties", value: elapsed)

        return properties
    }
}

enum APIError: Error, LocalizedError {
    case resourceNotFound
    case decodingFailed
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .resourceNotFound: "Mock data file not found"
        case .decodingFailed: "Failed to decode response"
        case .networkError(let message): "Network error: \(message)"
        }
    }
}
