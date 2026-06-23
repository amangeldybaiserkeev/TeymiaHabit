import SwiftUI

struct IconRow: View {
    @Binding var selectedIcon: String
    @Binding var selectedColor: HabitIconColor

    var body: some View {
        NavigationLink {
            IconPickerView(
                selectedIcon: $selectedIcon,
                selectedColor: $selectedColor
            )
        } label: {
            NewHabitRow(item: .icon)
        }
    }
}

struct IconPickerView: View {

    @Binding var selectedIcon: String
    @Binding var selectedColor: HabitIconColor
    @State private var searchText: String = ""

    private enum Layout {
        static let circleSize: CGFloat = 44
        static let gridSpacing: CGFloat = 14
        static let selectedScale: CGFloat = 1.15
        static let backgroundOpacity: CGFloat = 0.15
        static let strokeWidth: CGFloat = 2
    }

    private let categories = IconCatalog.categories

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Layout.gridSpacing), count: 6
    )

    private var filteredSections: [CategorySection] {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        if query.isEmpty { return categories }

        return categories.compactMap { section in
            let matchingIcons = section.icons.filter { $0.lowercased().contains(query) }
            return matchingIcons.isEmpty ? nil : CategorySection(name: section.name, icons: matchingIcons)
        }
    }

    var body: some View {
        ScrollView {
            if filteredSections.isEmpty {
                ContentUnavailableView.search(text: searchText)
                    .padding(.top, Spacing.xxl)
            } else {
                LazyVStack(alignment: .leading, spacing: Spacing.md) {
                    ForEach(filteredSections) { section in
                        Section(header: sectionHeader(section.name)) {
                            LazyVGrid(columns: columns, spacing: Layout.gridSpacing) {
                                ForEach(section.icons, id: \.self) { icon in
                                    iconButton(icon: icon)
                                }
                            }
                            .padding(.horizontal, Spacing.reg)
                        }
                    }
                }
                .padding(.vertical, Spacing.reg)
            }
        }
        .navigationTitle("Icon")
        .animation(Animations.snappy, value: searchText)
        .sensoryFeedback(.selection, trigger: selectedIcon)
        .safeAreaBar(edge: .bottom) {
            ColorSelectionView(selectedColor: $selectedColor)
                .padding(.horizontal, Spacing.reg)
                .padding(.bottom, Spacing.xxs)
        }
        .searchable(text: $searchText)
    }

    // MARK: - Private Views

    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.title2)
            .foregroundStyle(.primary)
            .padding(.horizontal, Spacing.reg)
            .padding(.vertical, Spacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func iconButton(icon: String) -> some View {
        let isSelected = selectedIcon == icon

        return Button {
            withAnimation( Animations.spring) {
                selectedIcon = icon
            }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        isSelected
                        ? selectedColor.baseColor.opacity(Layout.backgroundOpacity)
                        : .appTertiary
                    )
                    .overlay(
                        Circle()
                            .stroke(isSelected ? selectedColor.baseColor : .clear, lineWidth: Layout.strokeWidth)
                    )

                Image(icon)
                    .resizable()
                    .frame(size: IconSize.reg)
                    .foregroundStyle(isSelected ? selectedColor.baseColor : .primary)
            }
            .frame(size: Layout.circleSize)
            .contentShape(.circle)
            .scaleEffect(isSelected ? Layout.selectedScale : 1.0)
        }
        .buttonStyle(.plain)
    }
}
