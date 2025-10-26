import Foundation

public enum GymSampleData {
    public static let singleArmChestPress = Exercise(
        name: "Egykezes mellnyomás fekve",
        kind: .dumbbell,
        primaryMuscles: [.chest],
        secondaryMuscles: [.triceps, .shoulders],
        instructions: """
Cél: mellizom, tricepsz, váll
Súly: 16 kg
Sorozat: 3 × 10 ismétlés karonként
Leírás: Hanyatt fekve nyomd fel a súlyt, könyököt enyhén oldalra engedve. Kézfej lehet kissé befelé fordítva.
""",
        guidance: .init(
            goal: "Mellizom, tricepsz, váll",
            recommendedWeight: 16,
            setCount: 3,
            repsPerSet: 10,
            perSide: true,
            detailedDescription: "Hanyatt fekve nyomd fel a súlyt, könyököt enyhén oldalra engedve. Kézfej lehet kissé befelé fordítva.",
            videoURL: URL(string: "https://www.youtube.com/watch?v=Ad9mRbPt1D8"),
            mediaURL: URL(string: "https://musclewiki.com/media/uploads/dumbbell-one-arm-bench-press-male.gif")
        )
    )

    public static let sampleRoutine: Routine = {
        Routine(
            name: "Mell fókuszú minta",
            description: "Egykezes mellnyomás fekve variáció a mell, tricepsz és vállak aktiválására.",
            dayPlans: [
                Routine.DayPlan(
                    name: "Felsőtest erő",
                    muscleFocus: [.chest, .triceps, .shoulders],
                    exercises: [singleArmChestPress],
                    notes: "Használd a javasolt terhelést és ismétlésszámot oldalanként."
                )
            ],
            source: .routine
        )
    }()

    public static let featuredExercises: [Exercise] = [singleArmChestPress]
}
