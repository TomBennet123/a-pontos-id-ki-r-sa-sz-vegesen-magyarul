import SwiftUI
import Domain

struct DashboardView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    insightSection
                    upcomingRoutineSection
                }
                .padding()
            }
            .navigationTitle("Gym")
            .toolbar {
                Button(action: { Task { await viewModel.refresh() } }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
            .task { viewModel.onAppear() }
        }
    }

    private var insightSection: some View {
        GroupBox("AI Edző") {
            if let insight = viewModel.latestInsight {
                VStack(alignment: .leading, spacing: 12) {
                    Text(insight.motivationText)
                        .font(.headline)
                    Text(insight.recommendationText)
                        .font(.subheadline)
                    TagCloud(tags: insight.tags)
                }
            } else {
                Text("Még nincs értékelés. Rögzíts egy edzést!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var upcomingRoutineSection: some View {
        GroupBox("Következő edzés") {
            if let routine = viewModel.upcomingRoutine {
                VStack(alignment: .leading, spacing: 8) {
                    Text(routine.name)
                        .font(.headline)
                    Text(routine.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Divider()
                    ForEach(routine.dayPlans) { day in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(day.name)
                                .font(.title3.bold())
                            Text(day.muscleFocus.map(\.localizedName).joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            } else {
                Text("Az AI Edző a legutóbbi teljesítmény alapján készíti el a következő edzésedet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct TagCloud: View {
    let tags: [AIInsight.InsightKind]

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tagLabel(tag))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.accentColor.opacity(0.1)))
            }
        }
    }

    private func tagLabel(_ tag: AIInsight.InsightKind) -> String {
        switch tag {
        case .motivation: return "Motiváció"
        case .recommendation: return "Ajánlás"
        case .warning: return "Figyelmeztetés"
        case .deloadSuggestion: return "Deload"
        }
    }
}
