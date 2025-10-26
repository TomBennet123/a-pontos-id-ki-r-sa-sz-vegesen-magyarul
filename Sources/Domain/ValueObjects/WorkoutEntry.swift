import Foundation

public struct WorkoutEntry: Identifiable, Hashable, Codable {
    public let id: UUID
    public var exercise: Exercise
    public var sets: [WorkoutSet]
    public var restTime: TimeInterval?
    public var isWarmup: Bool

    public init(
        id: UUID = UUID(),
        exercise: Exercise,
        sets: [WorkoutSet],
        restTime: TimeInterval? = nil,
        isWarmup: Bool = false
    ) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.restTime = restTime
        self.isWarmup = isWarmup
    }
}

public extension WorkoutEntry {
    var totalVolume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }
}
