import Testing
@testable import PropertyFinder

@Suite("PerformanceMonitor Tests")
struct PerformanceMonitorTests {
    @Test("Records and retrieves metric average")
    func recordAndAverage() async {
        let monitor = PerformanceMonitor()
        await monitor.record("test.metric", value: 100)
        await monitor.record("test.metric", value: 200)
        await monitor.record("test.metric", value: 300)

        let avg = await monitor.average("test.metric")
        #expect(avg == 200.0)
    }

    @Test("Returns nil for unknown metric")
    func unknownMetric() async {
        let monitor = PerformanceMonitor()
        let avg = await monitor.average("nonexistent")
        #expect(avg == nil)
    }

    @Test("Calculates percentiles correctly")
    func percentiles() async {
        let monitor = PerformanceMonitor()
        for i in 1...100 {
            await monitor.record("perc.metric", value: Double(i))
        }

        let p50 = await monitor.percentile("perc.metric", p: 50)
        #expect(p50 != nil)
        #expect(p50! >= 49 && p50! <= 51)

        let p95 = await monitor.percentile("perc.metric", p: 95)
        #expect(p95 != nil)
        #expect(p95! >= 94 && p95! <= 96)
    }

    @Test("All metrics returns summaries")
    func allMetrics() async {
        let monitor = PerformanceMonitor()
        await monitor.record("m1", value: 10)
        await monitor.record("m2", value: 20)

        let all = await monitor.allMetrics()
        #expect(all.count == 2)
        #expect(all["m1"]?.count == 1)
        #expect(all["m2"]?.average == 20.0)
    }

    @Test("Reset clears all metrics")
    func resetMetrics() async {
        let monitor = PerformanceMonitor()
        await monitor.record("metric", value: 42)

        await monitor.reset()

        let all = await monitor.allMetrics()
        #expect(all.isEmpty)
    }

    @Test("Single value percentile returns that value")
    func singleValuePercentile() async {
        let monitor = PerformanceMonitor()
        await monitor.record("single", value: 42.0)

        let p50 = await monitor.percentile("single", p: 50)
        #expect(p50 == 42.0)

        let p99 = await monitor.percentile("single", p: 99)
        #expect(p99 == 42.0)
    }
}
