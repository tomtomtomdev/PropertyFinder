# PropertyFinder

A polished property discovery app for the MENA region built with **SwiftUI**, **Clean Architecture**, and **MVVM**. Designed as a technical showcase for iOS engineering best practices.

## Screenshots

The app features four main tabs:

| Browse | Search | Favorites | Debug |
|--------|--------|-----------|-------|
| Grid/list property feed with featured carousel | Full-text search with multi-criteria filters | Shortlisted properties with swipe-to-remove | Feature flags, A/B tests, performance metrics |

## Architecture

```
PropertyFinder/
├── Domain/              # Entities, Use Cases, Repository Protocols
├── Data/                # API Client, Concrete Repositories, Cache
├── Infrastructure/      # Feature Flags, A/B Testing, Performance, Filters
└── Presentation/        # SwiftUI Views, ViewModels, Navigation
```

### Clean Architecture Layers

| Layer | Responsibility | Key Types |
|-------|---------------|-----------|
| **Domain** | Business logic, entities, use case definitions | `Property`, `SearchCriteria`, `SearchPropertiesUseCase`, `ManageFavoritesUseCase` |
| **Data** | Data access, network, persistence | `MockAPIClient`, `PropertyRepository`, `FavoritesStore` (actor), `ImageCache` (actor) |
| **Infrastructure** | Cross-cutting concerns | `FeatureFlagProvider`, `ABTestEngine`, `PerformanceMonitor`, `FilterBuilder` |
| **Presentation** | UI and view state | `PropertyListView`, `SearchView`, `FavoritesView`, ViewModels (`@Observable`) |

### Dependency Flow

```
Presentation → Domain ← Data
                 ↑
           Infrastructure
```

Views depend on ViewModels, which depend on Use Cases, which depend on Repository Protocols. Concrete repositories in the Data layer implement those protocols. No layer references a layer above it.

## Key Technical Patterns

### Combine Search Pipeline
The search flow uses a debounced, cancellable pipeline:
```
searchText → debounce(300ms) → cancel previous → build criteria → execute use case → update results
```

### Actor-Based Concurrency
Thread-safe state management using Swift actors:
- **`FavoritesStore`** — Actor managing favorite IDs with UserDefaults persistence
- **`ImageCache`** — Two-tier cache (memory + disk) with hit/miss tracking
- **`PerformanceMonitor`** — Collects timing metrics with percentile calculations (p50/p95/p99)

### @resultBuilder Filter Composition
Declarative filter construction:
```swift
pipeline.applyFilters {
    PropertyFilter.type(.villa)
    PropertyFilter.priceRange(1_000_000...5_000_000)
    PropertyFilter.minBedrooms(3)
}
```

### @propertyWrapper Feature Flags
```swift
@FeatureFlag("show_map_view", default: true) var showMap
```
Backed by `FeatureFlagProvider` with runtime override support for debugging.

### A/B Test Engine
Hash-based consistent bucketing (`DJB2 hash`) ensures users see the same variant across sessions:
```swift
ABTestEngine.variant(for: "card_layout", userID: userId) // → "compact" or "expanded"
```

### Performance Monitoring
- `PerformanceMonitor` actor tracks metrics with percentile aggregation
- `MetricCollector` integrates with `os_signpost` for Instruments profiling
- Built-in dashboard accessible from the Debug tab

## Tech Stack

| Technology | Usage |
|-----------|-------|
| **SwiftUI** | Declarative UI with `@Observable` ViewModels |
| **Swift Concurrency** | `async/await`, actors, structured concurrency |
| **Combine** | Filter pipeline, reactive data flow |
| **MapKit** | Property location maps in detail view |
| **Swift Testing** | 57 unit tests using `@Test`, `@Suite`, `#expect` |
| **os_signpost** | Performance instrumentation |

### Build Settings
- **Swift Language Mode**: 5 with strict concurrency
- **Default Actor Isolation**: `MainActor`
- **Approachable Concurrency**: Enabled
- **Target**: iOS 26.2

## Getting Started

### Requirements
- Xcode 26.2+
- iOS 26.2 Simulator

### Build & Run
```bash
# Build
xcodebuild build \
  -scheme PropertyFinder \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run Tests (57 unit tests)
xcodebuild test \
  -scheme PropertyFinder \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Or open `PropertyFinder.xcodeproj` in Xcode and press **Cmd+R**.

### Mock Data
The app uses bundled JSON with **22 MENA-region properties** spanning Dubai, Abu Dhabi, Sharjah, Ajman, Fujairah, and Ras Al Khaimah — all priced in AED. No backend required.

## Test Coverage

57 unit tests across 10 test suites:

| Suite | Tests | Covers |
|-------|-------|--------|
| `SearchPropertiesUseCaseTests` | 7 | Query, type, purpose, price, bedroom filters |
| `ManageFavoritesUseCaseTests` | 4 | Toggle, check, get favorites |
| `PropertyRepositoryTests` | 7 | Search, detail, featured, caching |
| `ImageCacheTests` | 6 | Store/retrieve, hit/miss tracking, clear |
| `PropertyListViewModelTests` | 5 | Load, featured, pagination, layout toggle |
| `SearchViewModelTests` | 6 | State, filters, suggestions, clear |
| `FavoritesViewModelTests` | 3 | Load, empty, remove |
| `FeatureFlagTests` | 6 | Defaults, overrides, property wrapper |
| `ABTestEngineTests` | 7 | Bucketing, consistency, distribution |
| `PerformanceMonitorTests` | 6 | Record, percentiles, reset |

## CI/CD

GitHub Actions workflow (`.github/workflows/ci.yml`) runs on every push and PR:
1. Build the project
2. Run all unit tests
3. Upload test results as artifacts

## Project Structure

```
PropertyFinder/
├── Domain/
│   ├── Entities/           # Property, Agent, SearchCriteria, FilterOptions
│   ├── UseCases/           # SearchProperties, GetPropertyDetail, ManageFavorites
│   └── Repositories/       # Protocol definitions
├── Data/
│   ├── Network/            # APIClient, Endpoint, MockData (properties.json)
│   ├── Repositories/       # PropertyRepository, FavoritesRepository + FavoritesStore actor
│   └── Cache/              # ImageCache actor (memory + disk)
├── Infrastructure/
│   ├── FeatureFlags/       # FeatureFlagProvider, @FeatureFlag wrapper, ABTestEngine
│   ├── Performance/        # PerformanceMonitor actor, MetricCollector, Dashboard
│   └── Filters/            # @FilterBuilder, FilterPipeline (Combine)
├── Presentation/
│   ├── App/                # AppCoordinator, DependencyContainer
│   ├── PropertyList/       # List/grid view, card component, ViewModel
│   ├── PropertyDetail/     # Parallax detail, image carousel, ViewModel
│   ├── Search/             # Search bar, filter sheet, ViewModel
│   ├── Favorites/          # Favorites list, ViewModel
│   ├── Shared/             # ShimmerView, PriceFormatter, MapAnnotation, FlowLayout
│   └── Debug/              # Feature flag overrides, A/B test viewer
├── ContentView.swift       # Tab-based root navigation
└── PropertyFinderApp.swift # App entry point with DI
```
