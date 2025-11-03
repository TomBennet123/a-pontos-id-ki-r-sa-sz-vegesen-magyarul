import Foundation

public struct Workout: Identifiable, Codable, Sendable {
    public var id: UUID
    public var date: Date
    public var title: String
    public var notes: String
    public var entries: [WorkoutEntry]

    public init(id: UUID = UUID(), date: Date = .now, title: String, notes: String = "", entries: [WorkoutEntry] = []) {
        self.id = id
        self.date = date
        self.title = title
        self.notes = notes
        self.entries = entries
    }

    public var totalVolume: Double {
        entries.reduce(0) { $0 + $1.totalVolume }
    }

    public var duration: TimeInterval {
        guard let first = entries.flatMap({ $0.sets }).min(by: { $0.startTime ?? .now < $1.startTime ?? .now })?.startTime,
              let last = entries.flatMap({ $0.sets }).max(by: { $0.endTime ?? .now < $1.endTime ?? .now })?.endTime else {
            return 0
        }
        return last.timeIntervalSince(first)
    }
}

public struct WorkoutEntry: Identifiable, Codable, Sendable {
    public var id: UUID
    public var exercise: Exercise
    public var sets: [WorkoutSet]

    public init(id: UUID = UUID(), exercise: Exercise, sets: [WorkoutSet]) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
    }

    public var totalVolume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }
}

public struct WorkoutSet: Identifiable, Codable, Sendable {
    public var id: UUID
    public var repetitions: Int
    public var weight: Double
    public var isWarmUp: Bool
    public var perceivedIntensity: Int
    public var startTime: Date?
    public var endTime: Date?

    public init(id: UUID = UUID(), repetitions: Int, weight: Double, isWarmUp: Bool = false, perceivedIntensity: Int = 5, startTime: Date? = nil, endTime: Date? = nil) {
        self.id = id
        self.repetitions = repetitions
        self.weight = weight
        self.isWarmUp = isWarmUp
        self.perceivedIntensity = perceivedIntensity
        self.startTime = startTime
        self.endTime = endTime
    }

    public var volume: Double {
        Double(repetitions) * weight
    }
}

public struct Exercise: Identifiable, Codable, Sendable, Hashable {
    public enum Kind: String, Codable, Sendable, CaseIterable {
        case compound
        case accessory
        case isolation
    }

    public enum MuscleGroup: String, Codable, Sendable, CaseIterable {
        case chest
        case back
        case legs
        case shoulders
        case arms
        case core
        case fullBody
    }

    public var id: UUID
    public var name: String
    public var kind: Kind
    public var primaryMuscle: MuscleGroup
    public var secondaryMuscles: [MuscleGroup]

    public init(id: UUID = UUID(), name: String, kind: Kind, primaryMuscle: MuscleGroup, secondaryMuscles: [MuscleGroup] = []) {
        self.id = id
        self.name = name
        self.kind = kind
        self.primaryMuscle = primaryMuscle
        self.secondaryMuscles = secondaryMuscles
    }
}

public struct BodyMetric: Identifiable, Codable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case weight
        case bodyFat
        case waist
        case chest
        case arm
        case thigh
    }

    public var id: UUID
    public var kind: Kind
    public var value: Double
    public var date: Date

    public init(id: UUID = UUID(), kind: Kind, value: Double, date: Date = .now) {
        self.id = id
        self.kind = kind
        self.value = value
        self.date = date
    }
}

public struct AIInsight: Identifiable, Codable, Sendable {
    public var id: UUID
    public var workoutID: UUID
    public var motivation: String
    public var recommendation: String
    public var createdAt: Date

    public init(id: UUID = UUID(), workoutID: UUID, motivation: String, recommendation: String, createdAt: Date = .now) {
        self.id = id
        self.workoutID = workoutID
        self.motivation = motivation
        self.recommendation = recommendation
        self.createdAt = createdAt
    }
}

public struct Routine: Identifiable, Codable, Sendable {
    public var id: UUID
    public var name: String
    public var schedule: [Weekday: [Exercise]]

    public init(id: UUID = UUID(), name: String, schedule: [Weekday: [Exercise]]) {
        self.id = id
        self.name = name
        self.schedule = schedule
    }
}

public enum Weekday: String, Codable, Sendable, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}
