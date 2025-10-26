import Foundation

public protocol WorkoutRepository {
    func save(_ workout: Workout) async throws
    func latestWorkout(for exerciseID: UUID) async throws -> Workout?
    func workouts(between startDate: Date, and endDate: Date) async throws -> [Workout]
}

public protocol RoutineRepository {
    func routines() async throws -> [Routine]
    func save(_ routine: Routine) async throws
    func update(_ routine: Routine) async throws
}

public protocol BodyMetricRepository {
    func save(_ metric: BodyMetric) async throws
    func metrics(of kind: BodyMetric.Kind, limit: Int) async throws -> [BodyMetric]
}

public protocol AIInsightRepository {
    func save(_ insight: AIInsight) async throws
    func latestInsight() async throws -> AIInsight?
}

public struct LogWorkoutUseCase {
    private let workoutRepository: WorkoutRepository

    public init(workoutRepository: WorkoutRepository) {
        self.workoutRepository = workoutRepository
    }

    public func execute(_ workout: Workout) async throws {
        try await workoutRepository.save(workout)
    }
}

public struct FetchProgressSummaryUseCase {
    private let workoutRepository: WorkoutRepository
    private let bodyMetricRepository: BodyMetricRepository

    public init(
        workoutRepository: WorkoutRepository,
        bodyMetricRepository: BodyMetricRepository
    ) {
        self.workoutRepository = workoutRepository
        self.bodyMetricRepository = bodyMetricRepository
    }

    public func execute(for interval: DateInterval) async throws -> ProgressSummary {
        let workouts = try await workoutRepository.workouts(between: interval.start, and: interval.end)
        let weightMetrics = try await bodyMetricRepository.metrics(of: .weight, limit: 30)
        return ProgressSummary(workouts: workouts, weightMetrics: weightMetrics)
    }
}

public struct SaveAIInsightUseCase {
    private let repository: AIInsightRepository

    public init(repository: AIInsightRepository) {
        self.repository = repository
    }

    public func execute(_ insight: AIInsight) async throws {
        try await repository.save(insight)
    }
}

public struct ProgressSummary: Hashable {
    public let totalVolume: Double
    public let averageIntensity: Double
    public let workoutCount: Int
    public let latestWeight: Double?
    public let volumeByMuscleGroup: [MuscleGroup: Double]

    public init(workouts: [Workout], weightMetrics: [BodyMetric]) {
        workoutCount = workouts.count
        totalVolume = workouts.reduce(0) { $0 + $1.volume }
        if workoutCount > 0 {
            let intensity = workouts.compactMap { workout -> Double? in
                guard workout.totalSets > 0 else { return nil }
                return workout.volume / Double(workout.totalSets)
            }
            averageIntensity = intensity.reduce(0, +) / Double(intensity.count)
        } else {
            averageIntensity = 0
        }
        latestWeight = weightMetrics.sorted(by: { $0.date > $1.date }).first?.value
        volumeByMuscleGroup = workouts.reduce(into: [:]) { partialResult, workout in
            let entries = workout.entries
            entries.forEach { entry in
                let volume = entry.totalVolume
                entry.exercise.primaryMuscles.forEach { partialResult[$0, default: 0] += volume }
                entry.exercise.secondaryMuscles.forEach { partialResult[$0, default: 0] += volume * 0.5 }
            }
        }
    }
}
