import XCTest
@testable import Domain

final class ProgressSummaryTests: XCTestCase {
    func testProgressSummaryCalculatesVolumeAndSets() {
        let exercise = Exercise(name: "Guggolás", kind: .barbell, primaryMuscles: [.quadriceps])
        let entry = WorkoutEntry(exercise: exercise, sets: [WorkoutSet(weight: 100, reps: 5), WorkoutSet(weight: 120, reps: 3)])
        let workout = Workout(date: Date(), duration: 3600, volume: entry.totalVolume, entries: [entry])
        let summary = ProgressSummary(workouts: [workout], weightMetrics: [])
        XCTAssertEqual(summary.totalVolume, entry.totalVolume)
        XCTAssertEqual(summary.workoutCount, 1)
        XCTAssertEqual(summary.volumeByMuscleGroup[.quadriceps], entry.totalVolume)
    }
}
