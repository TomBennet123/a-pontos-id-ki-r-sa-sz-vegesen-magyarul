import Foundation
import GRDB
import Domain

public final class AIInsightRepositoryImpl: AIInsightRepository {
    private let dbQueue: DatabaseQueue
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    public func save(_ insight: AIInsight) async throws {
        try await dbQueue.write { db in
            let data = try encoder.encode(insight)
            try db.execute(sql: "REPLACE INTO aiInsight (id, workoutID, createdAt, payload) VALUES (?, ?, ?, ?)",
                           arguments: [insight.id.uuidString, insight.workoutID.uuidString, insight.createdAt, data])
        }
    }

    public func latestInsight() async throws -> AIInsight? {
        try await dbQueue.read { db in
            let row = try Row.fetchOne(db, sql: "SELECT payload FROM aiInsight ORDER BY createdAt DESC LIMIT 1")
            guard let data: Data = row?["payload"] else { return nil }
            return try decoder.decode(AIInsight.self, from: data)
        }
    }
}
