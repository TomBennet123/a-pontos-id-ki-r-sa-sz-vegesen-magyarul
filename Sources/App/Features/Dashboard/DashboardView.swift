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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    insightSection
                    upcomingRoutineSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(
                LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationTitle("Gym")
            .toolbar {
                Button(action: { Task { await viewModel.refresh() } }) {
                    Image(systemName: viewModel.isLoading ? "hourglass" : "arrow.clockwise")
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
        GymCard(title: "AI Edző", icon: "brain.head.profile") {
            if let insight = viewModel.latestInsight {
                VStack(alignment: .leading, spacing: 12) {
                    Text(insight.motivationText)
                        .font(.title3.bold())
                    Text(insight.recommendationText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Divider()
                    TagCloud(tags: insight.tags)
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Még nincs értékelés")
                        .font(.headline)
                    Text("Rögzíts egy edzést, hogy az AI visszajelzést adhasson.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
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
        GymCard(title: "Következő edzés", icon: "calendar") {
            if let routine = viewModel.upcomingRoutine {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(routine.name)
                            .font(.title3.bold())
                        Text(routine.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(routine.dayPlans) { day in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(day.name)
                                    .font(.headline)
                                Spacer()
                                Text(day.muscleFocus.map(\.localizedName).joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            ForEach(day.exercises) { exercise in
                                HStack(alignment: .center, spacing: 12) {
                                    Image(systemName: "dumbbell")
                                        .foregroundStyle(.accent)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exercise.name)
                                            .font(.subheadline)
                                        if let guidance = exercise.guidance {
                                            Text(guidance.setSummaryText)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.tertiarySystemBackground))
                        )
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Még nincs tervezett edzés")
                        .font(.headline)
                    Text("Az AI Edző az aktivitásod alapján ajánl majd rutint.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
