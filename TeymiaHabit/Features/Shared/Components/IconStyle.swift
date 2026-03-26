import SwiftUI

extension Image {
    func iconStyle() -> some View {
        
        return self
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundStyle(Color.primary.gradient)
    }
}
