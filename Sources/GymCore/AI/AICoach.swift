import Foundation

public struct WorkoutContext: Sendable {
    public var workout: Workout
    public var previous: [Workout]

    public init(workout: Workout, previous: [Workout]) {
        self.workout = workout
        self.previous = previous
    }
}

public protocol AIRecommending {
    func motivation(for context: WorkoutContext) -> String
    func recommendation(for context: WorkoutContext) -> String
}

public struct RuleBasedCoach: AIRecommending {
    public init() {}

    public func motivation(for context: WorkoutContext) -> String {
        let volume = context.workout.totalVolume
        if volume > (context.previous.last?.totalVolume ?? 0) {
            return "Szép munka! Sikerült növelned az összvolument az előző alkalomhoz képest."
        } else if volume == 0 {
            return "Kezdésként rögzíts néhány szettet, hogy a fejlődésedet követni tudjuk."
        } else {
            return "Stabil teljesítmény! Tartsd a fókuszt és figyelj a tiszta végrehajtásra."
        }
    }

    public func recommendation(for context: WorkoutContext) -> String {
        let analyzer = ProgressAnalyzer()
        let historic = analyzer.progress(for: context.previous + [context.workout])
        guard let top = historic.max(by: { $0.maxWeight < $1.maxWeight }) else {
            return "Adj hozzá súlyt vagy plusz egy szettet a következő edzésen."
        }

        let delta = context.workout.totalVolume - (context.previous.last?.totalVolume ?? 0)
        if delta < 0 {
            return "Próbálj meg +5% volument elérni a(z) \(top.exerciseName) gyakorlatnál néhány extra ismétléssel."
        }

        if let best = top.bestSet {
            return "Tartsd meg a \(top.exerciseName) gyakorlatnál a \(Int(best.repetitions)) ismétlést és emelj 2.5 kg-mal."
        }

        return "Kísérletezz supersettekkel a fő izomcsoportjaid számára a változatosságért."
    }
}
