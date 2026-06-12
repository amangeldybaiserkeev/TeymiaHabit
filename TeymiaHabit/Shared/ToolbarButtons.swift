import SwiftUI

struct DismissToolbarButton: ToolbarContent {
    @Environment(\.dismiss) private var dismiss

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .close) {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.appPrimary)
            }
        }
    }
}

struct ConfirmationToolbarButton: ToolbarContent {
    let isDisabled: Bool
    let action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm) {
                action()
            } label: {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.glassProminent)
            .tint(.main)
            .disabled(isDisabled)
        }
    }
}
