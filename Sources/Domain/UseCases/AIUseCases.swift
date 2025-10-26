import Foundation

public protocol AIRecommender {
    func generateInsight(for workout: Workout, history: [Workout], metrics: [BodyMetric]) async throws -> AIInsight
}

public struct GenerateAIInsightUseCase {
    private let workoutRepository: WorkoutRepository
    private let bodyMetricRepository: BodyMetricRepository
    private let recommender: AIRecommender
    private let aiInsightRepository: AIInsightRepository

    public init(
        workoutRepository: WorkoutRepository,
        bodyMetricRepository: BodyMetricRepository,
        recommender: AIRecommender,
        aiInsightRepository: AIInsightRepository
    ) {
        self.workoutRepository = workoutRepository
        self.bodyMetricRepository = bodyMetricRepository
        self.recommender = recommender
        self.aiInsightRepository = aiInsightRepository
    }

    public func execute(for workout: Workout) async throws -> AIInsight {
        let historyInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -42, to: workout.date) ?? workout.date, end: workout.date)
        let history = try await workoutRepository.workouts(between: historyInterval.start, and: historyInterval.end)
        let metrics = try await bodyMetricRepository.metrics(of: .weight, limit: 12)
        let insight = try await recommender.generateInsight(for: workout, history: history, metrics: metrics)
        try await aiInsightRepository.save(insight)
        return insight
    }
}
