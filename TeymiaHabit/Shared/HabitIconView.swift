import SwiftUI

struct HabitIconView: View {
    let iconName: String?
    let color: Color
    var size: CGFloat = DS.IconSize.sm
    var showBackground: Bool = true

    private static let backgroundScale: CGFloat  = 2.0
    private static let backgroundOpacity: Double = 0.15
    private let fallbackIcon = "book"

    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .fill(color.opacity(Self.backgroundOpacity))
            }
            resolvedImage
        }
        .frame(size: size * Self.backgroundScale)
    }

    private var resolvedImage: some View {
        let name = iconName ?? fallbackIcon
        
        // Пробуем найти кастомное изображение в Asset Catalog
        if isCustomImageAvailable(name: name) {
            return Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundStyle(color.gradient)
                .eraseToAnyView()
        } else {
            // Используем system image
            return Image(systemName: name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundStyle(color.gradient)
                .eraseToAnyView()
        }
    }
    
    private func isCustomImageAvailable(name: String) -> Bool {
        #if os(iOS)
        return UIImage(named: name) != nil
        #elseif os(macOS)
        return NSImage(named: name) != nil
        #else
        return false
        #endif
    }
}

// Helper для стирания типа
extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
