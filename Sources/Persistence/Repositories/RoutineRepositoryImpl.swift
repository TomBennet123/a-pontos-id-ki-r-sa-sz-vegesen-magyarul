import Foundation
import GRDB
import Domain

public final class RoutineRepositoryImpl: RoutineRepository {
    private let dbQueue: DatabaseQueue
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        seedDefaultRoutineIfNeeded()
    }

    public func routines() async throws -> [Routine] {
        try await dbQueue.read { db in
            let rows = try Row.fetchAll(db, sql: "SELECT payload FROM routine ORDER BY updatedAt DESC")
            return try rows.map { row in
                guard let data: Data = row["payload"] else { throw PersistenceError.invalidData }
                return try decoder.decode(Routine.self, from: data)
            }
        }
    }

    public func save(_ routine: Routine) async throws {
        try await persist(routine)
    }

    public func update(_ routine: Routine) async throws {
        try await persist(routine)
    }

    private func persist(_ routine: Routine) async throws {
        try await dbQueue.write { db in
            let data = try encoder.encode(routine)
            try db.execute(sql: "REPLACE INTO routine (id, name, description, createdAt, updatedAt, source, payload) VALUES (?, ?, ?, ?, ?, ?, ?)",
                           arguments: [routine.id.uuidString, routine.name, routine.description, routine.createdAt, routine.updatedAt, routine.source.rawValue, data])
        }
    }

    private func seedDefaultRoutineIfNeeded() {
        do {
            try dbQueue.write { db in
                let existingCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM routine") ?? 0
                guard existingCount == 0 else { return }
                let routine = GymSampleData.sampleRoutine
                let data = try encoder.encode(routine)
                try db.execute(sql: "INSERT INTO routine (id, name, description, createdAt, updatedAt, source, payload) VALUES (?, ?, ?, ?, ?, ?, ?)",
                               arguments: [routine.id.uuidString, routine.name, routine.description, routine.createdAt, routine.updatedAt, routine.source.rawValue, data])
            }
        } catch {
            print("Routine seed failed: \(error)")
        }
    }
}
