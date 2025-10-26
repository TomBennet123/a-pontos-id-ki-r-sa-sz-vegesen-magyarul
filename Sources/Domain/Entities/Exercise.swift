import Foundation

public struct Exercise: Identifiable, Hashable, Codable {
    public struct Guidance: Hashable, Codable {
        public var goal: String
        public var recommendedWeight: Double?
        public var setCount: Int
        public var repsPerSet: Int
        public var perSide: Bool
        public var detailedDescription: String
        public var videoURL: URL?
        public var mediaURL: URL?

        public init(
            goal: String,
            recommendedWeight: Double? = nil,
            setCount: Int,
            repsPerSet: Int,
            perSide: Bool = false,
            detailedDescription: String,
            videoURL: URL? = nil,
            mediaURL: URL? = nil
        ) {
            self.goal = goal
            self.recommendedWeight = recommendedWeight
            self.setCount = setCount
            self.repsPerSet = repsPerSet
            self.perSide = perSide
            self.detailedDescription = detailedDescription
            self.videoURL = videoURL
            self.mediaURL = mediaURL
        }
    }

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
    public var guidance: Guidance?

    public init(
        id: UUID = UUID(),
        name: String,
        kind: Kind,
        primaryMuscles: [MuscleGroup],
        secondaryMuscles: [MuscleGroup] = [],
        instructions: String? = nil,
        guidance: Guidance? = nil
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.guidance = guidance
    }
}

public extension Exercise.Guidance {
    var recommendedWeightText: String {
        guard let recommendedWeight else { return "-" }
        if recommendedWeight.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(recommendedWeight)) kg"
        }
        return String(format: "%.1f kg", recommendedWeight)
    }

    var setSummaryText: String {
        let base = "\(setCount) × \(repsPerSet) ismétlés"
        return perSide ? base + " karonként" : base
    }
}
