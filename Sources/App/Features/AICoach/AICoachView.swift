import SwiftUI
import Domain

struct AICoachView: View {
    @EnvironmentObject private var viewModel: AICoachViewModel
    @EnvironmentObject private var workoutViewModel: WorkoutLoggingViewModel

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if let insight = viewModel.insight {
                        GymCard(title: "Legutóbbi elemzés", icon: "sparkles") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(insight.motivationText)
                                    .font(.headline)
                                Text(insight.recommendationText)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                Divider()
                                TagCloud(tags: insight.tags)
                            }
                        }
                    } else {
                        GymCard(title: "Még nincs elemzés", icon: "sparkles") {
                            Text("Válassz ki egy edzést a naplóból, majd generálj AI visszajelzést.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    GymCard(title: "AI műveletek", icon: "wand.and.rays") {
                        VStack(spacing: 16) {
                            Button {
                                let workout = workoutViewModel.activeWorkout
                                guard !workout.entries.isEmpty else { return }
                                viewModel.generate(for: workout)
                            } label: {
                                Label("AI értékelés készítése", systemImage: viewModel.isLoading ? "hourglass" : "wand.and.stars")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.isLoading || workoutViewModel.activeWorkout.entries.isEmpty)

                            Text("Az AI az aktuális edzésedet elemzi, és javaslatot készít a következő alkalomra.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(
                LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationTitle("AI Edző")
        }
    }
}
