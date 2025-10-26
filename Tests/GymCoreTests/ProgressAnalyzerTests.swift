import XCTest
@testable import GymCore

final class ProgressAnalyzerTests: XCTestCase {
    func testProgressCalculations() {
        let bench = Exercise(name: "Fekvenyomás", kind: .compound, primaryMuscle: .chest)
        let squat = Exercise(name: "Guggolás", kind: .compound, primaryMuscle: .legs)

        let workout = Workout(
            title: "Hétfő",
            entries: [
                WorkoutEntry(
                    exercise: bench,
                    sets: [
                        WorkoutSet(repetitions: 5, weight: 100),
                        WorkoutSet(repetitions: 5, weight: 105)
                    ]
                ),
                WorkoutEntry(
                    exercise: squat,
                    sets: [
                        WorkoutSet(repetitions: 5, weight: 140)
                    ]
                )
            ]
        )

        let analyzer = ProgressAnalyzer()
        let progress = analyzer.progress(for: [workout])

        XCTAssertEqual(progress.count, 2)
        XCTAssertTrue(progress.contains(where: { $0.exerciseName == "Fekvenyomás" && $0.maxWeight == 105 }))
        XCTAssertTrue(progress.contains(where: { $0.exerciseName == "Guggolás" && $0.maxWeight == 140 }))

        let balance = analyzer.muscleBalance(for: [workout])
        XCTAssertEqual(balance.first?.muscleGroup, .chest)
        XCTAssertGreaterThan(balance.first?.volume ?? 0, balance.last?.volume ?? 0)
    }
}
