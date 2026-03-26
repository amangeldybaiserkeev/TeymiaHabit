import SwiftUI

extension Image {
    func iconStyle() -> some View {
        
        return self
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(.white.gradient)
            .frame(width: 24, height: 24)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.orange.gradient)
            )
            .frame(width: 32, height: 32)
    }
}
