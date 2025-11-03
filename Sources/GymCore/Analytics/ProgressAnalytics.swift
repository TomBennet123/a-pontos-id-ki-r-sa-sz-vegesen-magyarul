import Foundation

public struct ExerciseProgress: Sendable, Codable {
    public var exerciseName: String
    public var maxWeight: Double
    public var averageVolume: Double
    public var bestSet: WorkoutSet?
}

public struct MuscleGroupSummary: Sendable, Codable {
    public var muscleGroup: Exercise.MuscleGroup
    public var volume: Double
}

public protocol ProgressAnalyzing {
    func progress(for workouts: [Workout]) -> [ExerciseProgress]
    func muscleBalance(for workouts: [Workout]) -> [MuscleGroupSummary]
}

public struct ProgressAnalyzer: ProgressAnalyzing {
    public init() {}

    public func progress(for workouts: [Workout]) -> [ExerciseProgress] {
        let grouped = Dictionary(grouping: workouts.flatMap { workout in
            workout.entries.map { ($0.exercise.name, $0) }
        }, by: { $0.0 })

        return grouped.map { name, entries -> ExerciseProgress in
            let sets = entries.flatMap { $0.1.sets }
            let maxWeight = sets.map { $0.weight }.max() ?? 0
            let averageVolume = sets.map { $0.volume }.reduce(0, +) / Double(max(sets.count, 1))
            let bestSet = sets.max(by: { lhs, rhs in lhs.volume < rhs.volume })
            return ExerciseProgress(
                exerciseName: name,
                maxWeight: maxWeight,
                averageVolume: averageVolume,
                bestSet: bestSet
            )
        }.sorted(by: { $0.exerciseName < $1.exerciseName })
    }

    public func muscleBalance(for workouts: [Workout]) -> [MuscleGroupSummary] {
        let contributions = workouts.flatMap { workout -> [(Exercise.MuscleGroup, Double)] in
            workout.entries.map { entry in
                (entry.exercise.primaryMuscle, entry.totalVolume)
            }
        }

        let totals = Dictionary(grouping: contributions, by: { $0.0 })
            .mapValues { pairs in pairs.reduce(0) { $0 + $1.1 } }

        return totals.map { key, value in
            MuscleGroupSummary(muscleGroup: key, volume: value)
        }.sorted(by: { $0.volume > $1.volume })
    }
}
