import Foundation
import GRDB
import Domain

public final class BodyMetricRepositoryImpl: BodyMetricRepository {
    private let dbQueue: DatabaseQueue
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    public func save(_ metric: BodyMetric) async throws {
        try await dbQueue.write { db in
            let data = try encoder.encode(metric)
            try db.execute(sql: "REPLACE INTO bodyMetric (id, kind, value, unit, date, note, payload) VALUES (?, ?, ?, ?, ?, ?, ?)",
                           arguments: [metric.id.uuidString, metric.kind.rawValue, metric.value, metric.unit, metric.date, metric.note, data])
        }
    }

    public func metrics(of kind: BodyMetric.Kind, limit: Int) async throws -> [BodyMetric] {
        try await dbQueue.read { db in
            let rows = try Row.fetchAll(db, sql: "SELECT payload FROM bodyMetric WHERE kind = ? ORDER BY date DESC LIMIT ?", arguments: [kind.rawValue, limit])
            return try rows.compactMap { row in
                guard let data: Data = row["payload"] else { throw PersistenceError.invalidData }
                return try decoder.decode(BodyMetric.self, from: data)
            }
        }
    }
}
