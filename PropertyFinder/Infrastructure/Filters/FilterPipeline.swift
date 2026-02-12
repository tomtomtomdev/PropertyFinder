import Combine
import Foundation

final class FilterPipeline {
    private let propertiesSubject = CurrentValueSubject<[Property], Never>([])
    private let filtersSubject = CurrentValueSubject<[PropertyFilter], Never>([])

    var filteredProperties: AnyPublisher<[Property], Never> {
        Publishers.CombineLatest(propertiesSubject, filtersSubject)
            .map { properties, filters in
                guard !filters.isEmpty else { return properties }
                return properties.filter { property in
                    filters.allSatisfy { $0.predicate(property) }
                }
            }
            .eraseToAnyPublisher()
    }

    func updateProperties(_ properties: [Property]) {
        propertiesSubject.send(properties)
    }

    func applyFilters(@FilterBuilder _ builder: () -> [PropertyFilter]) {
        filtersSubject.send(builder())
    }

    func clearFilters() {
        filtersSubject.send([])
    }

    var currentFilterCount: Int {
        filtersSubject.value.count
    }
}
