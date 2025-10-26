import Foundation
import Domain

@MainActor
final class WorkoutLoggingViewModel: ObservableObject {
    @Published var activeWorkout: Workout
    @Published var isSaving = false
    @Published var saveError: String?
    @Published var featuredExercises: [Exercise]

    private let logWorkoutUseCase: LogWorkoutUseCase
    private let routineRepository: RoutineRepository

    init(logWorkoutUseCase: LogWorkoutUseCase, routineRepository: RoutineRepository) {
        self.logWorkoutUseCase = logWorkoutUseCase
        self.routineRepository = routineRepository
        activeWorkout = Workout(date: Date(), duration: 0, volume: 0, entries: [])
        featuredExercises = GymSampleData.featuredExercises
    }

    func applyRoutine(_ routine: Routine) {
        activeWorkout.entries = routine.dayPlans.flatMap { day in
            day.exercises.map { exercise in
                WorkoutEntry(exercise: exercise, sets: [WorkoutSet(weight: 0, reps: 8, kind: .regular)])
            }
        }
        recalculateVolume()
    }

    func addExercise(_ exercise: Exercise) {
        activeWorkout.entries.append(WorkoutEntry(exercise: exercise, sets: []))
        recalculateVolume()
    }

    func addExerciseFromCatalog(_ exercise: Exercise) {
        var sets: [WorkoutSet] = []
        if let guidance = exercise.guidance {
            let templateSet = WorkoutSet(weight: guidance.recommendedWeight ?? 0, reps: guidance.repsPerSet)
            for _ in 0..<max(guidance.setCount, 1) {
                sets.append(templateSet)
            }
        }
        activeWorkout.entries.append(WorkoutEntry(exercise: exercise, sets: sets))
        recalculateVolume()
    }

    func addSet(to entryID: UUID, set: WorkoutSet) {
        guard let index = activeWorkout.entries.firstIndex(where: { $0.id == entryID }) else { return }
        activeWorkout.entries[index].sets.append(set)
        recalculateVolume()
    }

    func addRecommendedSet(to entryID: UUID) {
        guard let entry = activeWorkout.entries.first(where: { $0.id == entryID }) else { return }
        let set = defaultSet(for: entry.exercise)
        addSet(to: entryID, set: set)
    }

    func removeEntry(_ entryID: UUID) {
        activeWorkout.entries.removeAll { $0.id == entryID }
        recalculateVolume()
    }

    func save() {
        Task {
            do {
                isSaving = true
                try await logWorkoutUseCase.execute(activeWorkout)
                saveError = nil
            } catch {
                saveError = error.localizedDescription
            }
            isSaving = false
        }
    }

    func availableRoutines() async throws -> [Routine] {
        try await routineRepository.routines()
    }

    private func recalculateVolume() {
        activeWorkout.volume = activeWorkout.entries.reduce(0) { $0 + $1.totalVolume }
    }

    private func defaultSet(for exercise: Exercise) -> WorkoutSet {
        if let guidance = exercise.guidance {
            return WorkoutSet(weight: guidance.recommendedWeight ?? 0, reps: guidance.repsPerSet)
        }
        return WorkoutSet(weight: 20, reps: 8)
    }
}
