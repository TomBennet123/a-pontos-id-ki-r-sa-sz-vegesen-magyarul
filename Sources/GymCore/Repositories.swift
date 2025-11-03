import Foundation

public protocol WorkoutStore {
    func allWorkouts() -> [Workout]
    func save(workout: Workout)
}

public final class InMemoryWorkoutStore: WorkoutStore {
    private var storage: [UUID: Workout]
    private let queue = DispatchQueue(label: "InMemoryWorkoutStore", attributes: .concurrent)

    public init(initial: [Workout] = []) {
        self.storage = Dictionary(uniqueKeysWithValues: initial.map { ($0.id, $0) })
    }

    public func allWorkouts() -> [Workout] {
        queue.sync {
            storage.values.sorted(by: { $0.date < $1.date })
        }
    }

    public func save(workout: Workout) {
        queue.async(flags: .barrier) {
            self.storage[workout.id] = workout
        }
    }
}

public protocol BodyMetricStore {
    func allMetrics() -> [BodyMetric]
    func save(metric: BodyMetric)
}

public final class InMemoryBodyMetricStore: BodyMetricStore {
    private var storage: [UUID: BodyMetric]
    private let queue = DispatchQueue(label: "InMemoryBodyMetricStore", attributes: .concurrent)

    public init(initial: [BodyMetric] = []) {
        self.storage = Dictionary(uniqueKeysWithValues: initial.map { ($0.id, $0) })
    }

    public func allMetrics() -> [BodyMetric] {
        queue.sync {
            storage.values.sorted(by: { $0.date < $1.date })
        }
    }

    public func save(metric: BodyMetric) {
        queue.async(flags: .barrier) {
            self.storage[metric.id] = metric
        }
    }
}

public protocol AIInsightStore {
    func insights(for workoutID: UUID) -> [AIInsight]
    func save(insight: AIInsight)
}

public final class InMemoryAIInsightStore: AIInsightStore {
    private var storage: [UUID: [AIInsight]]
    private let queue = DispatchQueue(label: "InMemoryAIInsightStore", attributes: .concurrent)

    public init(initial: [AIInsight] = []) {
        self.storage = Dictionary(grouping: initial, by: { $0.workoutID })
    }

    public func insights(for workoutID: UUID) -> [AIInsight] {
        queue.sync {
            storage[workoutID]?.sorted(by: { $0.createdAt < $1.createdAt }) ?? []
        }
    }

    public func save(insight: AIInsight) {
        queue.async(flags: .barrier) {
            var values = self.storage[insight.workoutID] ?? []
            values.append(insight)
            self.storage[insight.workoutID] = values
        }
    }
}
