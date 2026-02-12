import MapKit
import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @State private var viewModel = DependencyContainer.shared.makePropertyDetailViewModel()
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Parallax image carousel
                GeometryReader { geo in
                    let offset = geo.frame(in: .global).minY
                    ImageCarouselView(property: property, selectedIndex: $viewModel.selectedImageIndex)
                        .frame(
                            height: max(300 + (offset > 0 ? offset : 0), 300)
                        )
                        .offset(y: offset > 0 ? -offset : 0)
                }
                .frame(height: 300)

                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    Divider()
                    detailsGrid
                    Divider()
                    descriptionSection
                    Divider()
                    amenitiesSection
                    if FeatureFlagProvider.shared.isEnabled("show_map_view") {
                        Divider()
                        mapSection
                    }
                    Divider()
                    agentSection
                }
                .padding()
            }
        }
        .navigationTitle(property.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    Task { await viewModel.toggleFavorite() }
                }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite ? .red : .primary)
                }
            }
        }
        .task {
            await viewModel.loadProperty(property)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(property.type.rawValue.capitalized)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.15))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())

                Text(property.purpose == .rent ? "For Rent" : "For Sale")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())

                if property.isFeatured {
                    Text("Featured")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.yellow.opacity(0.2))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }
            }

            Text(property.title)
                .font(.title2.bold())

            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.red)
                Text(property.location.displayName)
                    .foregroundStyle(.secondary)
            }

            Text(PriceFormatter.format(property.price, currency: property.currency, purpose: property.purpose))
                .font(.title.bold())
                .foregroundStyle(.blue)
        }
    }

    // MARK: - Details Grid

    private var detailsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: 16
        ) {
            detailItem(icon: "bed.double.fill", value: "\(property.bedrooms)", label: "Bedrooms")
            detailItem(icon: "shower.fill", value: "\(property.bathrooms)", label: "Bathrooms")
            detailItem(icon: "ruler", value: "\(Int(property.areaSqFt))", label: "Sq Ft")
        }
    }

    private func detailItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
            Text(property.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Amenities

    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amenities")
                .font(.headline)

            let visible = viewModel.showAllAmenities
                ? property.amenities
                : Array(property.amenities.prefix(6))

            FlowLayout(spacing: 8) {
                ForEach(visible, id: \.self) { amenity in
                    Text(amenity)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }

            if property.amenities.count > 6 {
                Button(viewModel.showAllAmenities ? "Show Less" : "Show All (\(property.amenities.count))") {
                    withAnimation { viewModel.showAllAmenities.toggle() }
                }
                .font(.caption)
            }
        }
    }

    // MARK: - Map

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.headline)

            let coordinate = CLLocationCoordinate2D(
                latitude: property.latitude,
                longitude: property.longitude
            )
            Map {
                Marker(property.title, coordinate: coordinate)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Agent

    private var agentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Listed By")
                .font(.headline)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.2))
                        .frame(width: 56, height: 56)
                    Text(String(property.agent.name.prefix(1)))
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(property.agent.name)
                        .font(.subheadline.bold())
                    Text(property.agent.company)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", property.agent.rating))
                    }
                    .font(.caption)
                }

                Spacer()

                VStack(spacing: 8) {
                    Button(action: {}) {
                        Image(systemName: "phone.fill")
                            .frame(width: 40, height: 40)
                            .background(.green.opacity(0.15))
                            .foregroundStyle(.green)
                            .clipShape(Circle())
                    }
                    Button(action: {}) {
                        Image(systemName: "envelope.fill")
                            .frame(width: 40, height: 40)
                            .background(.blue.opacity(0.15))
                            .foregroundStyle(.blue)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
