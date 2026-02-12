import Foundation
import Observation

@Observable
final class PropertyDetailViewModel {
    var property: Property?
    var isFavorite = false
    var isLoading = false
    var selectedImageIndex = 0
    var showAllAmenities = false

    private let getDetailUseCase: GetPropertyDetailUseCase
    private let favoritesUseCase: ManageFavoritesUseCase

    init(getDetailUseCase: GetPropertyDetailUseCase, favoritesUseCase: ManageFavoritesUseCase) {
        self.getDetailUseCase = getDetailUseCase
        self.favoritesUseCase = favoritesUseCase
    }

    func loadProperty(id: String) async {
        isLoading = true
        do {
            property = try await getDetailUseCase.execute(id: id)
            if let property {
                isFavorite = await favoritesUseCase.isFavorite(propertyID: property.id)
            }
            isLoading = false
        } catch {
            isLoading = false
        }
    }

    func loadProperty(_ property: Property) async {
        self.property = property
        isFavorite = await favoritesUseCase.isFavorite(propertyID: property.id)
    }

    func toggleFavorite() async {
        guard let property else { return }
        isFavorite = await favoritesUseCase.toggleFavorite(propertyID: property.id)
    }
}
