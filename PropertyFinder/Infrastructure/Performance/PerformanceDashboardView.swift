import SwiftUI

struct PerformanceDashboardView: View {
    @State private var metrics: [String: MetricSummary] = [:]
    @State private var cacheStats: CacheStats?
    @State private var isRefreshing = false

    var body: some View {
        List {
            Section("Performance Metrics") {
                if metrics.isEmpty {
                    Text("No metrics recorded yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(metrics.sorted(by: { $0.key < $1.key }), id: \.key) { key, summary in
                        metricRow(key: key, summary: summary)
                    }
                }
            }

            Section("Image Cache") {
                if let stats = cacheStats {
                    LabeledContent("Memory Entries", value: "\(stats.memoryEntries)")
                    LabeledContent("Hits", value: "\(stats.hitCount)")
                    LabeledContent("Misses", value: "\(stats.missCount)")
                    LabeledContent("Hit Rate", value: String(format: "%.1f%%", stats.hitRate * 100))
                } else {
                    Text("No cache data")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Refresh Metrics") {
                    Task { await refreshMetrics() }
                }

                Button("Reset All Metrics", role: .destructive) {
                    Task {
                        await PerformanceMonitor.shared.reset()
                        await refreshMetrics()
                    }
                }
            }
        }
        .navigationTitle("Performance")
        .task { await refreshMetrics() }
    }

    private func metricRow(key: String, summary: MetricSummary) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key)
                .font(.headline)
            HStack {
                Text("n=\(summary.count)")
                Spacer()
                Text("avg: \(String(format: "%.1fms", summary.average))")
                Spacer()
                Text("p95: \(String(format: "%.1fms", summary.p95))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private func refreshMetrics() async {
        metrics = await PerformanceMonitor.shared.allMetrics()
        cacheStats = await ImageCache.shared.stats
    }
}
