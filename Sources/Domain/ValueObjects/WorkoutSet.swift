import Foundation

public struct WorkoutSet: Identifiable, Hashable, Codable {
    public enum SetKind: String, Codable {
        case regular
        case drop
        case amrap
        case failure
        case warmup
        case cooldown
        case cluster
    }

    public let id: UUID
    public var weight: Double
    public var reps: Int
    public var rpe: Double?
    public var notes: String?
    public var kind: SetKind

    public init(
        id: UUID = UUID(),
        weight: Double,
        reps: Int,
        rpe: Double? = nil,
        notes: String? = nil,
        kind: SetKind = .regular
    ) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
        self.notes = notes
        self.kind = kind
    }
}

public extension WorkoutSet {
    var volume: Double {
        weight * Double(reps)
    }
}
