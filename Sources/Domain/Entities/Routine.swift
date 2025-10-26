import Foundation

public struct Routine: Identifiable, Hashable, Codable {
    public struct DayPlan: Identifiable, Hashable, Codable {
        public let id: UUID
        public var name: String
        public var muscleFocus: [MuscleGroup]
        public var exercises: [Exercise]
        public var notes: String?

        public init(
            id: UUID = UUID(),
            name: String,
            muscleFocus: [MuscleGroup],
            exercises: [Exercise],
            notes: String? = nil
        ) {
            self.id = id
            self.name = name
            self.muscleFocus = muscleFocus
            self.exercises = exercises
            self.notes = notes
        }
    }

    public let id: UUID
    public var name: String
    public var description: String
    public var createdAt: Date
    public var updatedAt: Date
    public var dayPlans: [DayPlan]
    public var source: Workout.Source

    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        createdAt: Date = .init(),
        updatedAt: Date = .init(),
        dayPlans: [DayPlan],
        source: Workout.Source = .manual
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.dayPlans = dayPlans
        self.source = source
    }
}
