import Foundation

public struct AIInsight: Identifiable, Codable, Hashable {
    public enum InsightKind: String, Codable {
        case motivation
        case recommendation
        case warning
        case deloadSuggestion
    }

    public let id: UUID
    public var workoutID: UUID
    public var createdAt: Date
    public var motivationText: String
    public var recommendationText: String
    public var tags: [InsightKind]
    public var appliedChanges: [RoutineChange]

    public init(
        id: UUID = UUID(),
        workoutID: UUID,
        createdAt: Date = .init(),
        motivationText: String,
        recommendationText: String,
        tags: [InsightKind] = [],
        appliedChanges: [RoutineChange] = []
    ) {
        self.id = id
        self.workoutID = workoutID
        self.createdAt = createdAt
        self.motivationText = motivationText
        self.recommendationText = recommendationText
        self.tags = tags
        self.appliedChanges = appliedChanges
    }
}

public struct RoutineChange: Identifiable, Codable, Hashable {
    public enum ChangeKind: String, Codable {
        case increaseWeight
        case increaseReps
        case adjustSets
        case introduceSuperset
        case scheduleDeload
        case adjustRest
    }

    public let id: UUID
    public var exerciseID: UUID?
    public var description: String
    public var changeKind: ChangeKind
    public var metadata: [String: String]

    public init(
        id: UUID = UUID(),
        exerciseID: UUID? = nil,
        description: String,
        changeKind: ChangeKind,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.description = description
        self.changeKind = changeKind
        self.metadata = metadata
    }
}
