import Foundation

public struct Exercise: Identifiable, Hashable, Codable {
    public enum Kind: String, Codable, CaseIterable {
        case barbell
        case dumbbell
        case machine
        case bodyweight
        case cable
        case kettlebell
        case resistanceBand
        case cardio
        case mobility
    }

    public let id: UUID
    public var name: String
    public var kind: Kind
    public var primaryMuscles: [MuscleGroup]
    public var secondaryMuscles: [MuscleGroup]
    public var instructions: String?

    public init(
        id: UUID = UUID(),
        name: String,
        kind: Kind,
        primaryMuscles: [MuscleGroup],
        secondaryMuscles: [MuscleGroup] = [],
        instructions: String? = nil
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
    }
}
