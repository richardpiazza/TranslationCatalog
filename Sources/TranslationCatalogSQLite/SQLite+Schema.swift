import PerfectSQLite
import StatementSQLite
import TranslationCatalog
import Foundation

// MARK: - Schema Version
extension SQLite {
    enum SchemaVersion: Int {
        case undefined = 0
        case v1 = 1
        /// Translation - Script Code
        case v2 = 2
        /// UUIDs / Project Entity
        case v3 = 3
        
        static var current: Self { .v3 }
    }
    
    var schemaVersion: SchemaVersion {
        var schemaVersion: SchemaVersion = .undefined
        
        let sql = "PRAGMA user_version;"
        
        do {
            try forEachRow(
                statement: sql,
                handleRow: { (statement, index) in
                    if let version = SchemaVersion(rawValue: statement.columnInt(position: 0)) {
                        schemaVersion = version
                    }
                })
        } catch {
            print(error)
        }
        
        return schemaVersion
    }
    
    convenience init(path: String, schema: SchemaVersion = .current) throws {
        try self.init(path)
        try migrateSchema(from: schemaVersion, to: schema)
    }
}

// MARK: - Migration
extension SQLite {
    enum Error: Swift.Error {
        case migration(from: Int, to: Int)
    }
    
    private struct MigrationStep {
        let source: SchemaVersion
        let destination: SchemaVersion
    }
    
    private var tableNames: [String] {
        var names: [String] = []
        
        let sql = "SELECT name FROM sqlite_master WHERE type='table';"
        
        do {
            try forEachRow(statement: sql, handleRow: { (statement, index) in
                names.append(statement.columnText(position: 0))
            })
        } catch {
            print(error)
        }
        
        return names
    }
    
    private func setSchemaVersion(_ version: SchemaVersion) throws {
        let sql = "PRAGMA user_version = \(version.rawValue);"
        try execute(statement: sql)
    }
    
    private func createSchema(_ version: SchemaVersion) throws {
        try doWithTransaction {
            try execute(statement: SQLiteStatement.createProjectEntity.render())
            try execute(statement: SQLiteStatement.createExpressionEntity.render())
            try execute(statement: SQLiteStatement.createTranslationEntity.render())
            try execute(statement: SQLiteStatement.createProjectExpressionEntity.render())
            try setSchemaVersion(version)
        }
    }
    
    func migrateSchema(from: SchemaVersion, to: SchemaVersion) throws {
        guard to.rawValue != from.rawValue else {
            // Migration complete
            return
        }
        
        guard to.rawValue > from.rawValue else {
            // Invalid migration direction
            throw Error.migration(from: from.rawValue, to: to.rawValue)
        }
        
        switch (from) {
        case .undefined:
            let names = tableNames
            if names.contains(ExpressionEntity.schema.name) {
                try setSchemaVersion(.v1)
            } else {
                try createSchema(.current)
                return
            }
        case .v1:
            print("Migrating schema from '\(from.rawValue)' to '\(to.rawValue)'.")
            try doWithTransaction {
                try execute(statement: SQLiteStatement.translationTable_addScriptCode.render())
                try setSchemaVersion(.v2)
            }
        case .v2:
            print("Migrating schema from '\(from.rawValue)' to '\(to.rawValue)'.")
            try doWithTransaction {
                try addSchemaV3Fields()
                try execute(statement: SQLiteStatement.createProjectEntity.render())
                try execute(statement: SQLiteStatement.createProjectExpressionEntity.render())
                try addExpressionKeyUsingName()
                try addUUIDsToMissingExpressions()
                try addUUIDsToMissingTranslations()
                try setSchemaVersion(.v3)
            }
        case .v3:
            return
        }
        
        guard let next = SchemaVersion(rawValue: from.rawValue + 1) else {
            throw Error.migration(from: from.rawValue, to: from.rawValue + 1)
        }
        
        try migrateSchema(from: next, to: to)
    }
    
    private func addSchemaV3Fields() throws {
        try execute(statement: "ALTER TABLE expression RENAME COLUMN comment TO context;")
        try execute(statement: "ALTER TABLE expression ADD COLUMN uuid TEXT;")
        try execute(statement: "ALTER TABLE translation ADD COLUMN uuid TEXT;")
        try execute(statement: "ALTER TABLE expression ADD COLUMN key TEXT;")
    }
    
    private func addExpressionKeyUsingName() throws {
        let entities = try expressionEntities(statement: SQLiteStatement.selectAllFromExpression.render())
        let needsUpdate = entities.filter({ $0.key.isEmpty })
        try needsUpdate.forEach { entity in
            try execute(statement: "UPDATE expression SET key = '\(entity.name)' WHERE id = \(entity.id) LIMIT 1;")
        }
    }
    
    private func addUUIDsToMissingExpressions() throws {
        let entities = try expressionEntities(statement: SQLiteStatement.selectAllFromExpression.render())
        let needsUpdate = entities.filter({ $0.uuid.isEmpty })
        try needsUpdate.forEach { entity in
            try execute(statement: """
            UPDATE expression
            SET uuid = '\(UUID().uuidString)'
            WHERE id = \(entity.id)
            LIMIT 1;
            """)
        }
    }
    
    private func addUUIDsToMissingTranslations() throws {
        let entities = try translationEntities(statement: SQLiteStatement.selectAllFromTranslation.render())
        let needsUpdate = entities.filter({ $0.uuid.isEmpty })
        try needsUpdate.forEach { entity in
            try execute(statement: """
            UPDATE translation
            SET uuid = '\(UUID().uuidString)'
            WHERE id = \(entity.id)
            LIMIT 1;
            """)
        }
    }
}
