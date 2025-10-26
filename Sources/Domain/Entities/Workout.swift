import Foundation

public struct Workout: Identifiable, Hashable, Codable {
    public enum Source: String, Codable {
        case manual
        case routine
        case aiGenerated
    }

    public let id: UUID
    public var date: Date
    public var duration: TimeInterval
    public var volume: Double
    public var averageHeartRate: Double?
    public var maxHeartRate: Double?
    public var recoveryTimeMinutes: Int?
    public var notes: String?
    public var entries: [WorkoutEntry]
    public var source: Source

    public init(
        id: UUID = UUID(),
        date: Date = .init(),
        duration: TimeInterval = 0,
        volume: Double = 0,
        averageHeartRate: Double? = nil,
        maxHeartRate: Double? = nil,
        recoveryTimeMinutes: Int? = nil,
        notes: String? = nil,
        entries: [WorkoutEntry] = [],
        source: Source = .manual
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.volume = volume
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.recoveryTimeMinutes = recoveryTimeMinutes
        self.notes = notes
        self.entries = entries
        self.source = source
    }
}

public extension Workout {
    var musclesTargeted: Set<MuscleGroup> {
        Set(entries.flatMap { $0.exercise.primaryMuscles + $0.exercise.secondaryMuscles })
    }

    var totalSets: Int {
        entries.reduce(into: 0) { result, entry in
            result += entry.sets.count
        }
    }
}
