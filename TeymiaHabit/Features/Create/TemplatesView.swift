import SwiftUI
import SwiftData

struct TemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TemplatesViewModel()
    @State private var selectedTemplate: HabitTemplate?

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.reg),
        GridItem(.flexible(), spacing: Spacing.reg)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {

                    if !viewModel.manualTemplates.isEmpty {
                        TemplateSection(
                            title: "Popular",
                            columns: columns,
                            templates: viewModel.manualTemplates,
                            selectedTemplate: $selectedTemplate
                        )
                    }

                    if !viewModel.healthKitTemplates.isEmpty {
                        TemplateSection(
                            title: "Apple Health",
                            columns: columns,
                            templates: viewModel.healthKitTemplates,
                            selectedTemplate: $selectedTemplate
                        )
                    }
                }
                .padding(Spacing.reg)
            }
            .navigationTitle("Templates")
            .toolbarTitleDisplayMode(.inline)
            .toolbar { DismissToolbarButton() }
            .sheet(item: $selectedTemplate) { template in
                NavigationStack {
                    NewHabitView(template: template)
                }
                .environment(\.modelContext, modelContext)
            }
        }
    }
}

// MARK: - Вспомогательный Сабвью для Секции
private struct TemplateSection: View {
    let title: String
    let columns: [GridItem]
    let templates: [HabitTemplate]
    @Binding var selectedTemplate: HabitTemplate?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(.appSecondary)
                .padding(.leading, Spacing.xs)

            LazyVGrid(columns: columns, spacing: Spacing.reg) {
                ForEach(templates) { template in
                    Button {
                        selectedTemplate = template
                    } label: {
                        TemplateGridCard(template: template)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

@Observable
final class TemplatesViewModel {
    let manualTemplates: [HabitTemplate]
    let healthKitTemplates: [HabitTemplate]

    init() {
        self.manualTemplates = HabitTemplate.allTemplates.filter { $0.source == .manual }
        self.healthKitTemplates = HabitTemplate.allTemplates.filter { $0.source == .healthKit }
    }
}

struct TemplateGridCard: View {
    let template: HabitTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HabitIconView(icon: template.icon, color: template.color)

            Spacer()

            Text(template.name)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.appPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(Spacing.reg)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .glassEffect(.clear, in: .rect(cornerRadius: Radius.xl))
    }
}
