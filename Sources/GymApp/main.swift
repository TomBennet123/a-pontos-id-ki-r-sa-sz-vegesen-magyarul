import Foundation
import GymCore

struct GymCLI {
    let workoutStore: WorkoutStore
    let metricStore: BodyMetricStore
    let insightStore: AIInsightStore
    let coach: AIRecommending
    let analyzer: ProgressAnalyzing

    init(
        workoutStore: WorkoutStore = InMemoryWorkoutStore(),
        metricStore: BodyMetricStore = InMemoryBodyMetricStore(),
        insightStore: AIInsightStore = InMemoryAIInsightStore(),
        coach: AIRecommending = RuleBasedCoach(),
        analyzer: ProgressAnalyzing = ProgressAnalyzer()
    ) {
        self.workoutStore = workoutStore
        self.metricStore = metricStore
        self.insightStore = insightStore
        self.coach = coach
        self.analyzer = analyzer
    }

    func run() {
        let arguments = CommandLine.arguments.dropFirst()
        guard let command = arguments.first else {
            printUsage()
            return
        }

        switch command {
        case "log":
            logWorkout(arguments: Array(arguments.dropFirst()))
        case "progress":
            showProgress()
        case "metrics":
            logMetric(arguments: Array(arguments.dropFirst()))
        default:
            printUsage()
        }
    }

    private func printUsage() {
        print("Gym CLI — használat:")
        print("  gym log <cím> <volume> — rögzít egy edzést fiktív adatokkal")
        print("  gym progress — kiírja az edzés haladás statisztikát")
        print("  gym metrics <tömeg kg> — testsúly mentése és átlag számítása")
    }

    private func logWorkout(arguments: [String]) {
        guard let title = arguments.first, let volumeString = arguments.dropFirst().first, let volume = Double(volumeString) else {
            print("Hibás paraméterek. Adj meg címet és volument (pl. 12000).")
            return
        }

        let bench = Exercise(name: "Fekvenyomás", kind: .compound, primaryMuscle: .chest)
        let sets = stride(from: 0, to: 3, by: 1).map { index in
            WorkoutSet(repetitions: 8 + index, weight: volume / 100.0)
        }
        let entry = WorkoutEntry(exercise: bench, sets: sets)
        let workout = Workout(title: title, entries: [entry])
        workoutStore.save(workout: workout)

        let context = WorkoutContext(workout: workout, previous: workoutStore.allWorkouts().filter { $0.id != workout.id })
        let motivation = coach.motivation(for: context)
        let recommendation = coach.recommendation(for: context)
        let insight = AIInsight(workoutID: workout.id, motivation: motivation, recommendation: recommendation)
        insightStore.save(insight: insight)

        print("Edzés elmentve: \(title) — össz volumen: \(Int(workout.totalVolume))")
        print("Motiváció: \(motivation)")
        print("Ajánlás: \(recommendation)")
    }

    private func showProgress() {
        let workouts = workoutStore.allWorkouts()
        if workouts.isEmpty {
            print("Még nincs edzésed. Használd a 'gym log' parancsot.")
            return
        }

        print("Összes edzés: \(workouts.count)")
        let exerciseStats = analyzer.progress(for: workouts)
        for stat in exerciseStats {
            let maxWeight = String(format: "%.1f", stat.maxWeight)
            let avgVolume = String(format: "%.1f", stat.averageVolume)
            print("- \(stat.exerciseName): max súly \(maxWeight) kg, átlag volumen/szett \(avgVolume)")
        }

        let balance = analyzer.muscleBalance(for: workouts)
        if !balance.isEmpty {
            print("Izomcsoport megoszlás:")
            balance.forEach { summary in
                let formatted = String(format: "%.0f", summary.volume)
                print("  • \(summary.muscleGroup.rawValue.capitalized): \(formatted) volumen egység")
            }
        }
    }

    private func logMetric(arguments: [String]) {
        guard let weightString = arguments.first, let weight = Double(weightString) else {
            print("Adj meg testsúlyt kilogrammban (pl. 82.5)")
            return
        }

        let metric = BodyMetric(kind: .weight, value: weight)
        metricStore.save(metric: metric)
        let metrics = metricStore.allMetrics().filter { $0.kind == .weight }
        let average = metrics.map { $0.value }.reduce(0, +) / Double(max(metrics.count, 1))
        print("Testsúly elmentve: \(weight) kg — átlag: \(String(format: "%.1f", average)) kg")
    }
}

GymCLI().run()
