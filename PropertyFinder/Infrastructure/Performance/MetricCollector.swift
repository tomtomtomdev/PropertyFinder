import Foundation
import os

struct MetricCollector {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "PropertyFinder",
        category: "Performance"
    )
    private static let signposter = OSSignposter(logger: logger)

    static func beginInterval(_ name: StaticString) -> OSSignpostIntervalState {
        let id = signposter.makeSignpostID()
        return signposter.beginInterval(name, id: id)
    }

    static func endInterval(_ name: StaticString, _ state: OSSignpostIntervalState) {
        signposter.endInterval(name, state)
    }

    static func event(_ name: StaticString) {
        signposter.emitEvent(name)
    }

    static func withInterval<T>(_ name: StaticString, _ body: () async throws -> T) async rethrows -> T {
        let state = beginInterval(name)
        defer { endInterval(name, state) }
        return try await body()
    }
}
