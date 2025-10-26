import Foundation
import Domain

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var latestInsight: AIInsight?
    @Published private(set) var upcomingRoutine: Routine?
    @Published private(set) var isLoading = false

    private let workoutRepository: WorkoutRepository
    private let aiInsightRepository: AIInsightRepository

    init(workoutRepository: WorkoutRepository, aiInsightRepository: AIInsightRepository) {
        self.workoutRepository = workoutRepository
        self.aiInsightRepository = aiInsightRepository
    }

    func onAppear() {
        Task { await refresh() }
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            latestInsight = try await aiInsightRepository.latestInsight()
            let now = Date()
            let interval = DateInterval(start: Calendar.current.startOfDay(for: now), end: Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now)
            let workouts = try await workoutRepository.workouts(between: interval.start, and: interval.end)
            upcomingRoutine = workouts.first?.entries.first?.exercise.kind == .cardio ? nil : workouts.first?.entries.first.map { entry in
                Routine(name: "Következő edzés", description: "Automatikus előrejelzés", dayPlans: [Routine.DayPlan(name: "Dinamikus nap", muscleFocus: entry.exercise.primaryMuscles, exercises: [entry.exercise])])
            }
        } catch {
            print("Dashboard refresh failed: \(error)")
        }
    }
}
