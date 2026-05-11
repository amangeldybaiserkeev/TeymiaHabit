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
            HStack {
                Label {
                    Text("icon")
                } icon: {
                    RowIcon(iconName: "app.specular")
                }

                Spacer()

                Image(selectedIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(selectedColor.baseColor)
                    .frame(size: DS.IconSize.sm)
            }
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
                    .padding(.top, DS.Spacing.xxl)
            } else {
                LazyVStack(alignment: .leading, spacing: DS.Spacing.md) {
                    ForEach(filteredSections) { section in
                        Section(header: sectionHeader(section.name)) {
                            LazyVGrid(columns: columns, spacing: Layout.gridSpacing) {
                                ForEach(section.icons, id: \.self) { icon in
                                    iconButton(icon: icon)
                                }
                            }
                            .padding(.horizontal, DS.Spacing.reg)
                        }
                    }
                }
                .padding(.vertical, DS.Spacing.reg)
            }
        }
        .navigationTitle("icon")
        .animation(DS.Animations.snappy, value: searchText)
        .sensoryFeedback(.selection, trigger: selectedIcon)
        .safeAreaBar(edge: .bottom) {
            ColorSelectionView(selectedColor: $selectedColor)
                .padding(.horizontal, DS.Spacing.reg)
                .padding(.bottom, DS.Spacing.xxs)
        }
        .searchable(text: $searchText)
    }

    // MARK: - Private Views

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(DS.AppFont.title2)
            .foregroundStyle(DS.Colors.primary)
            .padding(.horizontal, DS.Spacing.reg)
            .padding(.vertical, DS.Spacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func iconButton(icon: String) -> some View {
        let isSelected = selectedIcon == icon

        return Button {
            withAnimation(DS.Animations.spring) {
                selectedIcon = icon
            }
        } label: {
            ZStack {
                Circle()
                    .fill(isSelected ? selectedColor.baseColor : DS.Colors.tertiary)

                Image(icon)
                    .resizable()
                    .frame(size: DS.IconSize.reg)
                    .foregroundStyle(isSelected ? DS.Colors.onPrimary : DS.Colors.primary)
            }
            .frame(width: Layout.circleSize, height: Layout.circleSize)
            .contentShape(.circle)
            .scaleEffect(isSelected ? Layout.selectedScale : 1.0)
        }
        .buttonStyle(.plain)
    }
}

