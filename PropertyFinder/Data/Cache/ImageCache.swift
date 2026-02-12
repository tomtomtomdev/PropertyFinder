import Foundation

actor ImageCache {
    static let shared = ImageCache()

    private var memoryCache: [String: Data] = [:]
    private let diskCachePath: URL
    private var hitCount = 0
    private var missCount = 0

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCachePath = caches.appendingPathComponent("PropertyImageCache")
        try? FileManager.default.createDirectory(at: diskCachePath, withIntermediateDirectories: true)
    }

    func data(for key: String) -> Data? {
        // Memory tier
        if let cached = memoryCache[key] {
            hitCount += 1
            return cached
        }

        // Disk tier
        let fileURL = diskCachePath.appendingPathComponent(String(key.hashValue))
        if let data = try? Data(contentsOf: fileURL) {
            memoryCache[key] = data
            hitCount += 1
            return data
        }

        missCount += 1
        return nil
    }

    func store(_ data: Data, for key: String) {
        memoryCache[key] = data
        let fileURL = diskCachePath.appendingPathComponent(String(key.hashValue))
        try? data.write(to: fileURL)
    }

    func clearMemory() {
        memoryCache.removeAll()
    }

    func clearAll() {
        memoryCache.removeAll()
        try? FileManager.default.removeItem(at: diskCachePath)
        try? FileManager.default.createDirectory(at: diskCachePath, withIntermediateDirectories: true)
    }

    var stats: CacheStats {
        CacheStats(
            memoryEntries: memoryCache.count,
            hitCount: hitCount,
            missCount: missCount,
            hitRate: hitCount + missCount > 0
                ? Double(hitCount) / Double(hitCount + missCount) : 0
        )
    }
}

struct CacheStats: Sendable {
    let memoryEntries: Int
    let hitCount: Int
    let missCount: Int
    let hitRate: Double
}
