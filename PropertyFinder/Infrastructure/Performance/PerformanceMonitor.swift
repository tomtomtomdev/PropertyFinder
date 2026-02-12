import Foundation

actor PerformanceMonitor {
    static let shared = PerformanceMonitor()

    private var metrics: [String: [Double]] = [:]

    func record(_ metric: String, value: Double) {
        metrics[metric, default: []].append(value)
    }

    func percentile(_ metric: String, p: Double) -> Double? {
        guard let values = metrics[metric], !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let index = min(Int(Double(sorted.count - 1) * p / 100.0), sorted.count - 1)
        return sorted[index]
    }

    func average(_ metric: String) -> Double? {
        guard let values = metrics[metric], !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    func allMetrics() -> [String: MetricSummary] {
        metrics.compactMapValues { values in
            guard !values.isEmpty else { return nil }
            let sorted = values.sorted()
            let count = sorted.count
            return MetricSummary(
                count: count,
                average: sorted.reduce(0, +) / Double(count),
                p50: sorted[count / 2],
                p95: sorted[min(Int(Double(count - 1) * 0.95), count - 1)],
                p99: sorted[min(Int(Double(count - 1) * 0.99), count - 1)]
            )
        }
    }

    func reset() {
        metrics.removeAll()
    }
}

struct MetricSummary: Sendable {
    let count: Int
    let average: Double
    let p50: Double
    let p95: Double
    let p99: Double
}
