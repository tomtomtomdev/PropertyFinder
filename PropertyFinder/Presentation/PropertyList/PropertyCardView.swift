import SwiftUI

struct PropertyCardView: View {
    let property: Property
    var style: CardStyle = .grid
    var onFavoriteToggle: (() -> Void)?

    enum CardStyle {
        case grid, list, featured
    }

    var body: some View {
        switch style {
        case .grid:
            gridCard
        case .list:
            listCard
        case .featured:
            featuredCard
        }
    }

    // MARK: - Grid Style

    private var gridCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            propertyImage
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(property.title)
                    .font(.subheadline.bold())
                    .lineLimit(2)

                Text(property.location.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(PriceFormatter.format(property.price, currency: property.currency, purpose: property.purpose))
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)

                HStack(spacing: 12) {
                    if property.bedrooms > 0 {
                        Label("\(property.bedrooms)", systemImage: "bed.double.fill")
                    }
                    Label("\(property.bathrooms)", systemImage: "shower.fill")
                    Label("\(Int(property.areaSqFt))", systemImage: "ruler")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    // MARK: - List Style

    private var listCard: some View {
        HStack(spacing: 12) {
            propertyImage
                .frame(width: 120, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(property.title)
                    .font(.subheadline.bold())
                    .lineLimit(2)

                Text(property.location.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(PriceFormatter.format(property.price, currency: property.currency, purpose: property.purpose))
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)

                HStack(spacing: 12) {
                    if property.bedrooms > 0 {
                        Label("\(property.bedrooms)", systemImage: "bed.double.fill")
                    }
                    Label("\(property.bathrooms)", systemImage: "shower.fill")
                    Label("\(Int(property.areaSqFt)) sqft", systemImage: "ruler")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(10)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    // MARK: - Featured Style

    private var featuredCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                propertyImage
                    .frame(width: 260, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("FEATURED")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.yellow)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
                    .padding(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(property.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                Text(PriceFormatter.format(property.price, currency: property.currency, purpose: property.purpose))
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)

                Text(property.location.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 260)
    }

    // MARK: - Shared

    private var propertyImage: some View {
        ZStack {
            LinearGradient(
                colors: [colorForType(property.type), colorForType(property.type).opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 4) {
                Image(systemName: iconForType(property.type))
                    .font(.title)
                    .foregroundStyle(.white)
                Text(property.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    private func iconForType(_ type: Property.PropertyType) -> String {
        switch type {
        case .villa: "house.fill"
        case .apartment: "building.fill"
        case .penthouse: "building.2.fill"
        case .townhouse: "house.and.flag.fill"
        case .studio: "square.split.bottomrightquarter.fill"
        }
    }

    private func colorForType(_ type: Property.PropertyType) -> Color {
        switch type {
        case .villa: .green
        case .apartment: .blue
        case .penthouse: .purple
        case .townhouse: .orange
        case .studio: .teal
        }
    }
}
