import AVFoundation
import SwiftUI

struct TemplatesView: View {
    @Binding var isPresented: Bool

    @State private var selectedTemplate: HabitTemplate?
    @State private var showingCustomHabit = false
    @State private var pendingClose = false

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
            .safeAreaBar(edge: .bottom) {
                Button {
                    showingCustomHabit = true
                } label: {
                    Text("Custom Habit")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, minHeight: TouchTarget.minimum)
                }
                .buttonStyle(.glassProminent)
                .tint(.clear)
                .padding(.horizontal, Spacing.reg)
                .padding(.bottom, Spacing.xxs)
            }
            .fullScreenSheet(item: $selectedTemplate) { template, safeArea in
                NewHabitView(template: template, onSave: {
                    pendingClose = true
                    selectedTemplate = nil
                })
                .safeAreaPadding(.top, safeArea.top + 35)
            } background: {
                ConcentricRectangle(corners: .concentric, isUniform: true)
                    .fill(.black.gradient)
            }
            .sheet(isPresented: $showingCustomHabit) {
                NewHabitView(onSave: {
                    showingCustomHabit = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        isPresented = false
                    }
                })
            }
            .onChange(of: selectedTemplate) { _, newValue in
                guard newValue == nil, pendingClose else { return }
                pendingClose = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isPresented = false
                }
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
