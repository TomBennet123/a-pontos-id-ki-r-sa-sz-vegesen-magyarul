import Foundation
import GRDB
import Domain

public final class DatabaseManager {
    public static let shared = DatabaseManager()

    public let dbQueue: DatabaseQueue

    private init() {
        let fileManager = FileManager.default
        let baseURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let dbURL = baseURL.appendingPathComponent("gym.sqlite")
        dbQueue = try! DatabaseQueue(path: dbURL.path)
        migrate()
    }

    private func migrate() {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createWorkouts") { db in
            try db.create(table: "workout") { table in
                table.column("id", .text).primaryKey()
                table.column("date", .datetime).notNull()
                table.column("duration", .double).notNull()
                table.column("volume", .double).notNull()
                table.column("averageHeartRate", .double)
                table.column("maxHeartRate", .double)
                table.column("recoveryTimeMinutes", .integer)
                table.column("notes", .text)
                table.column("source", .text).notNull()
                table.column("payload", .blob).notNull()
            }
        }
        migrator.registerMigration("createBodyMetrics") { db in
            try db.create(table: "bodyMetric") { table in
                table.column("id", .text).primaryKey()
                table.column("kind", .text).notNull()
                table.column("value", .double).notNull()
                table.column("unit", .text).notNull()
                table.column("date", .datetime).notNull()
                table.column("note", .text)
                table.column("payload", .blob).notNull()
            }
        }
        migrator.registerMigration("createAIInsights") { db in
            try db.create(table: "aiInsight") { table in
                table.column("id", .text).primaryKey()
                table.column("workoutID", .text).notNull()
                table.column("createdAt", .datetime).notNull()
                table.column("payload", .blob).notNull()
            }
        }
        migrator.registerMigration("createRoutines") { db in
            try db.create(table: "routine") { table in
                table.column("id", .text).primaryKey()
                table.column("name", .text).notNull()
                table.column("description", .text).notNull()
                table.column("createdAt", .datetime).notNull()
                table.column("updatedAt", .datetime).notNull()
                table.column("source", .text).notNull()
                table.column("payload", .blob).notNull()
            }
        }
        try? migrator.migrate(dbQueue)
    }
}
