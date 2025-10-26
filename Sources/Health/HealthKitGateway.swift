import Foundation
import Domain

#if canImport(HealthKit)
import HealthKit

public final class HealthKitGateway {
    private let healthStore = HKHealthStore()

    public init() {}

    public func requestAuthorization() async throws {
        let workoutType = HKObjectType.workoutType()
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        try await healthStore.requestAuthorization(toShare: [workoutType], read: [workoutType, heartRateType])
    }

    public func fetchHeartRateSummary(for workout: Workout) async throws -> HeartRateSummary {
        let predicate = HKQuery.predicateForSamples(withStart: workout.date, end: workout.date.addingTimeInterval(workout.duration))
        let descriptor = HKStatisticsQueryDescriptor(predicate: predicate, options: [.discreteAverage, .discreteMax])
        let result = try await descriptor.result(for: .quantityType(forIdentifier: .heartRate)!)
        let average = result.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
        let max = result.maximumQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
        return HeartRateSummary(average: average ?? 0, maximum: max ?? 0)
    }
}
#else
public final class HealthKitGateway {
    public init() {}
    public func requestAuthorization() async throws {}
    public func fetchHeartRateSummary(for workout: Workout) async throws -> HeartRateSummary {
        HeartRateSummary(average: 0, maximum: 0)
    }
}
#endif

public struct HeartRateSummary: Sendable {
    public let average: Double
    public let maximum: Double
}
