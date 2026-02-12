import Testing
import Foundation
@testable import PropertyFinder

@Suite("ImageCache Tests")
struct ImageCacheTests {
    @Test("Stores and retrieves data from memory")
    func storeAndRetrieve() async {
        let cache = ImageCache()
        let testData = Data("test image data".utf8)

        await cache.store(testData, for: "key1")
        let retrieved = await cache.data(for: "key1")

        #expect(retrieved == testData)
    }

    @Test("Returns nil for missing key")
    func missingKey() async {
        let cache = ImageCache()
        let result = await cache.data(for: "nonexistent")
        #expect(result == nil)
    }

    @Test("Tracks hit count")
    func trackHits() async {
        let cache = ImageCache()
        let testData = Data("test".utf8)

        await cache.store(testData, for: "key")
        _ = await cache.data(for: "key")
        _ = await cache.data(for: "key")

        let stats = await cache.stats
        #expect(stats.hitCount == 2)
    }

    @Test("Tracks miss count")
    func trackMisses() async {
        let cache = ImageCache()
        _ = await cache.data(for: "miss1")
        _ = await cache.data(for: "miss2")

        let stats = await cache.stats
        #expect(stats.missCount == 2)
    }

    @Test("Clears memory cache")
    func clearMemory() async {
        let cache = ImageCache()
        await cache.store(Data("data".utf8), for: "key")
        await cache.clearMemory()

        let stats = await cache.stats
        #expect(stats.memoryEntries == 0)
    }

    @Test("Computes hit rate correctly")
    func hitRate() async {
        let cache = ImageCache()
        await cache.store(Data("data".utf8), for: "key")
        _ = await cache.data(for: "key")   // hit
        _ = await cache.data(for: "miss")  // miss

        let stats = await cache.stats
        #expect(stats.hitRate == 0.5)
    }
}
