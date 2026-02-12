import SwiftUI

struct ImageCarouselView: View {
    let property: Property
    @Binding var selectedIndex: Int

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(property.imageURLs.enumerated()), id: \.offset) { index, _ in
                ZStack {
                    LinearGradient(
                        colors: gradientColors(for: index),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    VStack(spacing: 8) {
                        Image(systemName: iconForType(property.type))
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                        Text("Photo \(index + 1) of \(property.imageURLs.count)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }

    private func gradientColors(for index: Int) -> [Color] {
        let palettes: [[Color]] = [
            [.blue, .blue.opacity(0.7)],
            [.purple, .purple.opacity(0.7)],
            [.teal, .teal.opacity(0.7)],
            [.indigo, .indigo.opacity(0.7)],
        ]
        return palettes[index % palettes.count]
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
}
