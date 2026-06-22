import AVFoundation
import SwiftUI
import SwiftData

struct TemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTemplate: HabitTemplate?
    @State private var shouldDismissAfterSave = false

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.xs),
        GridItem(.flexible(), spacing: Spacing.xs),
        GridItem(.flexible(), spacing: Spacing.xs)
    ]

    private var manualTemplates: [HabitTemplate] {
        HabitTemplate.allTemplates.filter { $0.source == .manual }
    }

    private var healthKitTemplates: [HabitTemplate] {
        HabitTemplate.allTemplates.filter { $0.source == .healthKit }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    if !manualTemplates.isEmpty {
                        TemplateSection(
                            title: "Popular",
                            columns: columns,
                            templates: manualTemplates,
                            selectedTemplate: $selectedTemplate
                        )
                    }

                    if !healthKitTemplates.isEmpty {
                        TemplateSection(
                            title: "Apple Health",
                            columns: columns,
                            templates: healthKitTemplates,
                            selectedTemplate: $selectedTemplate
                        )
                    }
                }
                .padding(Spacing.sm)
            }
            .preferredColorScheme(.dark)
            .navigationTitle("Templates")
            .toolbarTitleDisplayMode(.inline)
            .toolbar { DismissToolbarButton() }
            .sheet(item: $selectedTemplate, onDismiss: {
                guard shouldDismissAfterSave else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    dismiss()
                }
            }) { template in
                NewHabitView(template: template, onSave: {
                    shouldDismissAfterSave = true
                })
                .environment(\.modelContext, modelContext)
            }
        }
    }
}

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

struct TemplateGridCard: View {
    let template: HabitTemplate

    var body: some View {
        if let videoName = template.videoName {
            VideoTemplateCard(template: template, videoName: videoName)
        } else {
            DefaultTemplateCard(template: template)
        }
    }
}

private struct VideoTemplateCard: View {
    let template: HabitTemplate
    let videoName: String

    var body: some View {
        ZStack(alignment: .bottom) {
            LoopingVideoPlayer(videoName: videoName)

            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )

            Text(template.name)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(0.75, contentMode: .fit)
        .clipShape(.rect(cornerRadius: Radius.sm))
        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: Radius.sm))
    }
}

private struct DefaultTemplateCard: View {
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
        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: Radius.sm))
    }
}
