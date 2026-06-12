import SwiftUI

struct ListSection<Content: View>: View {
    private let header: String?
    private let footer: String?
    private let content: Content

    init(
        header: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = content()
    }

    var body: some View {
        _VariadicView.Tree(Layout(header: header, footer: footer)) {
            content
        }
    }

    private struct Layout: _VariadicView_MultiViewRoot {
        let header: String?
        let footer: String?

        @ViewBuilder
        func body(children: _VariadicView.Children) -> some View {
            if children.isEmpty {
                EmptyView()
            } else {
                let lastChildID = children.last?.id

                VStack(spacing: Spacing.xs) {
                    if let header {
                        Text(header)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.appSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, Spacing.xxl)
                    }

                    VStack(spacing: 0) {
                        ForEach(children) { child in
                            child

                            if child.id != lastChildID {
                                let hasIcon = child[HasIconLayoutKey.self]
                                let leadingPadding: CGFloat = hasIcon
                                ? RowToken.dividerIconPadding
                                : RowToken.dividerStandardPadding

                                HorizontalDivider(leadingPadding: leadingPadding)
                                    .padding(.trailing, Spacing.reg)
                            }
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                    .glassEffect(.clear, in: .rect(cornerRadius: Radius.xl))
                    .padding(.horizontal, Spacing.reg)

                    if let footer {
                        Text(footer)
                            .font(.caption)
                            .foregroundStyle(.appSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Spacing.xxl)
                    }
                }
            }
        }
    }
}

// MARK: - Has Icon Key
struct HasIconLayoutKey: _ViewTraitKey {
    static let defaultValue: Bool = false
}

extension View {
    func hasIcon(_ hasIcon: Bool) -> some View {
        _trait(HasIconLayoutKey.self, hasIcon)
    }
}
