import Foundation
import Domain

#if canImport(WatchKit)
import HealthKit
import WatchKit

final class WorkoutSessionManager: NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    @Published private(set) var state: HKWorkoutSessionState = .notStarted
    @Published private(set) var heartRate: Double = 0

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func startWorkout(activity: HKWorkoutActivityType) throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activity
        configuration.locationType = .indoor

        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        session?.delegate = self
        builder?.delegate = self
        session?.startActivity(with: .now)
        builder?.beginCollection(withStart: .now) { _, _ in }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        Task { @MainActor in
            state = toState
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session error: \(error)")
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        guard collectedTypes.contains(where: { $0 == HKQuantityType.quantityType(forIdentifier: .heartRate) }) else { return }
        let statistics = workoutBuilder.statistics(for: .quantityType(forIdentifier: .heartRate)!)
        let unit = HKUnit.count().unitDivided(by: .minute())
        let value = statistics?.mostRecentQuantity()?.doubleValue(for: unit) ?? 0
        Task { @MainActor in
            heartRate = value
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
#else
final class WorkoutSessionManager: ObservableObject {}
#endif
