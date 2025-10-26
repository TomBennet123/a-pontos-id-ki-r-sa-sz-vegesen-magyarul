import Foundation
import Domain

public final class OfflineAIRecommender: AIRecommender {
    private let trendAnalyzer: TrendAnalyzer
    private let languageGenerator: LanguageGenerator

    public init(
        trendAnalyzer: TrendAnalyzer = TrendAnalyzer(),
        languageGenerator: LanguageGenerator = LanguageGenerator()
    ) {
        self.trendAnalyzer = trendAnalyzer
        self.languageGenerator = languageGenerator
    }

    public func generateInsight(for workout: Workout, history: [Workout], metrics: [BodyMetric]) async throws -> AIInsight {
        let trend = trendAnalyzer.makeTrend(for: workout, history: history, metrics: metrics)
        let texts = try await languageGenerator.generateMessages(for: trend)
        return AIInsight(
            workoutID: workout.id,
            motivationText: texts.motivation,
            recommendationText: texts.recommendation,
            tags: texts.tags,
            appliedChanges: texts.changes
        )
    }
}

public struct WorkoutTrend {
    public let workout: Workout
    public let progressiveOverloadScore: Double
    public let fatigueScore: Double
    public let muscleBalance: [MuscleGroup: Double]
    public let averageHeartRate: Double
    public let maxHeartRate: Double
    public let weightTrend: Double?
}

public final class TrendAnalyzer {
    public init() {}

    public func makeTrend(for workout: Workout, history: [Workout], metrics: [BodyMetric]) -> WorkoutTrend {
        let progressiveScore = Self.progressionScore(for: workout, history: history)
        let fatigueScore = Self.fatigueScore(for: history + [workout])
        let muscleBalance = Self.balance(for: history + [workout])
        let weightTrend = Self.weightTrend(metrics: metrics)
        return WorkoutTrend(
            workout: workout,
            progressiveOverloadScore: progressiveScore,
            fatigueScore: fatigueScore,
            muscleBalance: muscleBalance,
            averageHeartRate: workout.averageHeartRate ?? 0,
            maxHeartRate: workout.maxHeartRate ?? 0,
            weightTrend: weightTrend
        )
    }

    private static func progressionScore(for workout: Workout, history: [Workout]) -> Double {
        let similar = history.filter { $0.date < workout.date && !$0.entries.isEmpty }
        guard let last = similar.sorted(by: { $0.date > $1.date }).first else { return 1 }
        return workout.volume / max(last.volume, 1)
    }

    private static func fatigueScore(for workouts: [Workout]) -> Double {
        let lastWeek = workouts.filter { workout in
            guard let diff = Calendar.current.dateComponents([.day], from: workout.date, to: Date()).day else { return false }
            return diff <= 7
        }
        let totalSets = lastWeek.reduce(0) { $0 + $1.totalSets }
        return Double(totalSets) / 100.0
    }

    private static func balance(for workouts: [Workout]) -> [MuscleGroup: Double] {
        workouts.reduce(into: [:]) { partialResult, workout in
            workout.entries.forEach { entry in
                let volume = entry.totalVolume
                entry.exercise.primaryMuscles.forEach { partialResult[$0, default: 0] += volume }
            }
        }
    }

    private static func weightTrend(metrics: [BodyMetric]) -> Double? {
        guard metrics.count >= 2 else { return nil }
        let sorted = metrics.sorted { $0.date < $1.date }
        guard let first = sorted.first, let last = sorted.last else { return nil }
        return (last.value - first.value) / Double(sorted.count)
    }
}

public final class LanguageGenerator {
    public struct Result {
        public let motivation: String
        public let recommendation: String
        public let tags: [AIInsight.InsightKind]
        public let changes: [RoutineChange]
    }

    public init() {}

    public func generateMessages(for trend: WorkoutTrend) async throws -> Result {
        var tags: [AIInsight.InsightKind] = [.motivation, .recommendation]
        var changes: [RoutineChange] = []
        var recommendation = ""

        if trend.progressiveOverloadScore < 0.95 {
            tags.append(.warning)
            recommendation += "Koncentrálj a fokozatos terhelésre: növeld a kulcs gyakorlatok súlyát 2-2,5 kg-mal. "
            changes.append(RoutineChange(description: "Növeld a fő emelés súlyát 2,5 kg-mal", changeKind: .increaseWeight))
        } else {
            recommendation += "Fenntartsd az előző edzés intenzitását, próbálj meg +1 ismétlést beépíteni. "
            changes.append(RoutineChange(description: "Adj hozzá egy ismétlést az utolsó szettekhez", changeKind: .increaseReps))
        }

        if trend.fatigueScore > 0.9 {
            tags.append(.deloadSuggestion)
            recommendation += "A magas szettszám miatt javasolt egy deload hét beiktatása. "
            changes.append(RoutineChange(description: "Tervezett deload hét 50%-os volumen csökkentéssel", changeKind: .scheduleDeload))
        }

        let motivation = "Remek munka! Az átlagpulzusod \(Int(trend.averageHeartRate)) bpm, a csúcs \(Int(trend.maxHeartRate)) bpm volt."

        return Result(
            motivation: motivation,
            recommendation: recommendation.trimmingCharacters(in: .whitespaces),
            tags: tags,
            changes: changes
        )
    }
}
