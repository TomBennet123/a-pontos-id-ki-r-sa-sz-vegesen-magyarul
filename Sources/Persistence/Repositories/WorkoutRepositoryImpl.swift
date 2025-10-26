import Foundation
import GRDB
import Domain

public final class WorkoutRepositoryImpl: WorkoutRepository {
    private let dbQueue: DatabaseQueue
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    public func save(_ workout: Workout) async throws {
        try await dbQueue.write { db in
            let data = try encoder.encode(workout)
            try db.execute(sql: "REPLACE INTO workout (id, date, duration, volume, averageHeartRate, maxHeartRate, recoveryTimeMinutes, notes, source, payload) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                           arguments: [
                            workout.id.uuidString,
                            workout.date,
                            workout.duration,
                            workout.volume,
                            workout.averageHeartRate,
                            workout.maxHeartRate,
                            workout.recoveryTimeMinutes,
                            workout.notes,
                            workout.source.rawValue,
                            data
                           ])
        }
    }

    public func latestWorkout(for exerciseID: UUID) async throws -> Workout? {
        try await dbQueue.read { db in
            let row = try Row.fetchOne(db, sql: "SELECT payload FROM workout ORDER BY date DESC LIMIT 1")
            guard let data: Data = row?["payload"] else { return nil }
            return try decoder.decode(Workout.self, from: data)
        }
    }

    public func workouts(between startDate: Date, and endDate: Date) async throws -> [Workout] {
        try await dbQueue.read { db in
            let rows = try Row.fetchAll(db, sql: "SELECT payload FROM workout WHERE date BETWEEN ? AND ? ORDER BY date DESC", arguments: [startDate, endDate])
            return try rows.map { row in
                guard let data: Data = row["payload"] else { throw PersistenceError.invalidData }
                return try decoder.decode(Workout.self, from: data)
            }
        }
    }
}

public enum PersistenceError: Error {
    case invalidData
}
