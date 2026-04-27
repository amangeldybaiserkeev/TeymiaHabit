import SwiftUI

extension View {
    func frame(size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }
}
