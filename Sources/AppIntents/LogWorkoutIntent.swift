#if canImport(AppIntents)
import AppIntents
import Domain
import Persistence

struct QuickLogWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Gyors edzés rögzítése"

    @Parameter(title: "Gyakorlat neve")
    var exerciseName: String

    @Parameter(title: "Ismétlések")
    var reps: Int

    @Parameter(title: "Súly (kg)")
    var weight: Double

    func perform() async throws -> some IntentResult {
        let exercise = Exercise(name: exerciseName, kind: .dumbbell, primaryMuscles: [.fullBody])
        let set = WorkoutSet(weight: weight, reps: reps)
        let entry = WorkoutEntry(exercise: exercise, sets: [set])
        let workout = Workout(date: .init(), duration: 1200, volume: entry.totalVolume, entries: [entry])
        let useCase = LogWorkoutUseCase(workoutRepository: WorkoutRepositoryImpl())
        try await useCase.execute(workout)
        return .result(value: "Rögzítve")
    }
}
#endif
