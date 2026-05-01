import SwiftUI

extension View {
    func primaryBackground() -> some View {
        self.background(DS.Colors.primaryBackground)
    }
    
    func secondaryBackground() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(DS.Colors.secondaryBackground)
    }
    
    func rowBackground() -> some View {
        self.listRowBackground(DS.Colors.rowBackground)
    }
}
