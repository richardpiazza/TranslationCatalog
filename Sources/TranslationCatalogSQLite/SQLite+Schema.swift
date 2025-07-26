import Foundation
import SQLite
import StatementSQLite
import TranslationCatalog

// MARK: - Schema Version

extension Connection {
    enum SchemaVersion: Int {
        case undefined = 0
        case v1 = 1
        /// Translation - Script Code
        case v2 = 2
        /// UUIDs / Project Entity
        case v3 = 3
        /// Expression Default Value
        case v4 = 4

        static var current: Self { .v4 }
    }

    var schemaVersion: SchemaVersion {
        var schemaVersion: SchemaVersion = .undefined

        let sql = "PRAGMA user_version;"

        do {
            for row in try run(sql) {
                if let version = SchemaVersion(rawValue: row.columnInt(position: 0)) {
                    schemaVersion = version
                }
            }
        } catch {
            print(error)
        }

        return schemaVersion
    }

    convenience init(url: URL, schema: SchemaVersion = .current) throws {
        try self.init(url.path())
        try migrateSchema(from: schemaVersion, to: schema)
    }
}

// MARK: - Migration

extension Connection {
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
            for row in try run(sql) {
                names.append(row.columnText(position: 0))
            }
        } catch {
            print(error)
        }

        return names
    }

    private func setSchemaVersion(_ version: SchemaVersion) throws {
        let sql = "PRAGMA user_version = \(version.rawValue);"
        try run(sql)
    }

    private func createSchema(_ version: SchemaVersion) throws {
        try transaction {
            try run(SQLiteStatement.createProjectEntity.render())
            try run(SQLiteStatement.createExpressionEntity.render())
            try run(SQLiteStatement.createTranslationEntity.render())
            try run(SQLiteStatement.createProjectExpressionEntity.render())
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

        switch from {
        case .undefined:
            let names = tableNames
            if names.contains(ExpressionEntity.identifier) {
                try setSchemaVersion(.v1)
            } else {
                try createSchema(.current)
                return
            }
        case .v1:
            print("Migrating schema from '\(from.rawValue)' to '\(to.rawValue)'.")
            try transaction {
                try run(SQLiteStatement.translationTable_addScriptCode.render())
                try setSchemaVersion(.v2)
            }
        case .v2:
            print("Migrating schema from '\(from.rawValue)' to '\(to.rawValue)'.")
            try transaction {
                try addSchemaV3Fields()
                try run(SQLiteStatement.createProjectEntity.render())
                try run(SQLiteStatement.createProjectExpressionEntity.render())
                try addExpressionKeyUsingName()
                try addUUIDsToMissingExpressions()
                try addUUIDsToMissingTranslations()
                try setSchemaVersion(.v3)
            }
        case .v3:
            print("Migrating schema from '\(from.rawValue)' to '\(to.rawValue)'.")
            try transaction {
                try addSchemeV4Fields()
                try migrateDefaultTranslationsToExpression()
                try setSchemaVersion(.v4)
            }
        case .v4:
            return
        }

        guard let next = SchemaVersion(rawValue: from.rawValue + 1) else {
            throw Error.migration(from: from.rawValue, to: from.rawValue + 1)
        }

        try migrateSchema(from: next, to: to)
    }

    private func addSchemaV3Fields() throws {
        try run("ALTER TABLE expression RENAME COLUMN comment TO context;")
        try run("ALTER TABLE expression ADD COLUMN uuid TEXT;")
        try run("ALTER TABLE translation ADD COLUMN uuid TEXT;")
        try run("ALTER TABLE expression ADD COLUMN key TEXT;")
    }

    private func addExpressionKeyUsingName() throws {
        let entities = try expressionEntities(statement: SQLiteStatement.selectAllFromExpression.render())
        let needsUpdate = entities.filter(\.key.isEmpty)
        try needsUpdate.forEach { entity in
            try run("UPDATE expression SET key = '\(entity.name)' WHERE id = \(entity.id) LIMIT 1;")
        }
    }

    private func addUUIDsToMissingExpressions() throws {
        let entities = try expressionEntities(statement: SQLiteStatement.selectAllFromExpression.render())
        let needsUpdate = entities.filter(\.uuid.isEmpty)
        try needsUpdate.forEach { entity in
            try run("""
            UPDATE expression
            SET uuid = '\(UUID().uuidString)'
            WHERE id = \(entity.id)
            LIMIT 1;
            """)
        }
    }

    private func addUUIDsToMissingTranslations() throws {
        let entities = try translationEntities(statement: SQLiteStatement.selectAllFromTranslation.render())
        let needsUpdate = entities.filter(\.uuid.isEmpty)
        try needsUpdate.forEach { entity in
            try run("""
            UPDATE translation
            SET uuid = '\(UUID().uuidString)'
            WHERE id = \(entity.id)
            LIMIT 1;
            """)
        }
    }
    
    private func addSchemeV4Fields() throws {
        try run("ALTER TABLE expression ADD COLUMN default_value TEXT NOT NULL DEFAULT '';")
    }
    
    private func migrateDefaultTranslationsToExpression() throws {
        let expressionEntities = try expressionEntities(statement: SQLiteStatement.selectAllFromExpression.render())
        for expression in expressionEntities {
            print("Migrate Expression '\(expression.key) (\(expression.id))'")
            let translationStatement = SQLiteStatement.selectTranslationsHavingOnly(expression.id, languageCode: expression.languageCode)
            if let translationEntity = try translationEntity(statement: translationStatement.render()) {
                print("Default Value: \(translationEntity.value)")
                try run ("""
                UPDATE expression
                SET default_value = '\(translationEntity.value)'
                WHERE id = \(expression.id);
                """)
                
                try run ("""
                DELETE FROM translation
                WHERE id = \(translationEntity.id);
                """)
            } else {
                print("FAILED")
            }
        }
    }
}
