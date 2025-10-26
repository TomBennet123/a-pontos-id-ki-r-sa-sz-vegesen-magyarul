import SwiftUI
import Domain

struct AICoachView: View {
    @EnvironmentObject private var viewModel: AICoachViewModel
    @EnvironmentObject private var workoutViewModel: WorkoutLoggingViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if let insight = viewModel.insight {
                    GroupBox("Legutóbbi elemzés") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(insight.motivationText)
                                .font(.headline)
                            Text(insight.recommendationText)
                                .font(.body)
                            TagCloud(tags: insight.tags)
                        }
                    }
                } else {
                    ContentUnavailableView("Még nincs elemzés", systemImage: "sparkles", description: Text("Válassz ki egy edzést a naplóból, majd generálj AI visszajelzést."))
                }

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

                Spacer()
            }
            .padding()
            .navigationTitle("AI Edző")
        }
    }
}
