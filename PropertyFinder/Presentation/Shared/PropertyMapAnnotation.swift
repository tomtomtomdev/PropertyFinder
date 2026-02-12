import MapKit
import SwiftUI

struct PropertyMapAnnotation: View {
    let property: Property

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
            }
            Triangle()
                .fill(.blue)
                .frame(width: 12, height: 8)
        }
    }

    private var iconName: String {
        switch property.type {
        case .villa: "house.fill"
        case .apartment: "building.fill"
        case .penthouse: "building.2.fill"
        case .townhouse: "house.and.flag.fill"
        case .studio: "square.split.bottomrightquarter.fill"
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
