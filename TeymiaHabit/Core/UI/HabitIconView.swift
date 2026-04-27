import SwiftUI

struct HabitIconView: View {
    let iconName: String?
    let color: Color
    var size: CGFloat = DS.Icon.s20
    var showBackground: Bool = true
    
    private let fallbackIcon = "book"

    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .fill(color.opacity(DS.Colors.iconOpacity))
            }
            
            resolvedImage
        }
        .frame(size: size * DS.Icon.backgroundMultiplier)
    }

    @ViewBuilder
    private var resolvedImage: some View {
        let name = iconName ?? fallbackIcon
        
        if UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(size: size)
                .foregroundStyle(color.gradient)
        } else {
            Image(systemName: UIImage(systemName: name) != nil ? name : fallbackIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(size: size)
                .foregroundStyle(color.gradient)
        }
    }
}
