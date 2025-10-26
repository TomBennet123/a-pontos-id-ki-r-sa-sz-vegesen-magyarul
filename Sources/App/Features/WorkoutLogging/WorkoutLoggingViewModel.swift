import Foundation
import Domain

@MainActor
final class WorkoutLoggingViewModel: ObservableObject {
    @Published var activeWorkout: Workout
    @Published var isSaving = false
    @Published var saveError: String?

    private let logWorkoutUseCase: LogWorkoutUseCase
    private let routineRepository: RoutineRepository

    init(logWorkoutUseCase: LogWorkoutUseCase, routineRepository: RoutineRepository) {
        self.logWorkoutUseCase = logWorkoutUseCase
        self.routineRepository = routineRepository
        activeWorkout = Workout(date: Date(), duration: 0, volume: 0, entries: [])
    }

    func applyRoutine(_ routine: Routine) {
        activeWorkout.entries = routine.dayPlans.flatMap { day in
            day.exercises.map { exercise in
                WorkoutEntry(exercise: exercise, sets: [WorkoutSet(weight: 0, reps: 8, kind: .regular)])
            }
        }
    }

    func addExercise(_ exercise: Exercise) {
        activeWorkout.entries.append(WorkoutEntry(exercise: exercise, sets: []))
    }

    func addSet(to entryID: UUID, set: WorkoutSet) {
        guard let index = activeWorkout.entries.firstIndex(where: { $0.id == entryID }) else { return }
        activeWorkout.entries[index].sets.append(set)
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
}
