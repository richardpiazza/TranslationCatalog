import TranslationCatalog
import StatementSQLite
import PerfectSQLite

// MARK: - `Project` Entity
extension SQLite {
    func projectEntities(statement: String) throws -> [ProjectEntity] {
        var output: [ProjectEntity] = []
        try forEachRow(statement: statement, handleRow: { (stmt, index) in
            output.append(stmt.projectEntity)
        })
        return output
    }
    
    func projectEntity(statement: String) throws -> ProjectEntity? {
        var output: ProjectEntity?
        try forEachRow(statement: statement, handleRow: { (stmt, index) in
            output = stmt.projectEntity
        })
        return output
    }
}

// MARK: - `ProjectExpression` Entity
extension SQLite {
    func projectExpressionEntity(statement: String) throws -> ProjectExpressionEntity? {
        var output: ProjectExpressionEntity?
        try forEachRow(statement: statement) { (stmt, index) in
            output = stmt.projectExpressionEntity
        }
        return output
    }
}

// MARK: - `Expression` Entity
extension SQLite {
    func expressionEntities(statement: String) throws -> [ExpressionEntity] {
        var output: [ExpressionEntity] = []
        try forEachRow(statement: statement, handleRow: { (stmt, index) in
            output.append(stmt.expressionEntity)
        })
        
        return output
    }
    
    func expressionEntity(statement: String) throws -> ExpressionEntity? {
        var output: ExpressionEntity?
        try forEachRow(statement: statement) { (stmt, index) in
            output = stmt.expressionEntity
        }
        return output
    }
}

// MARK: - `Translation` Entity
extension SQLite {
    func translationEntities(statement: String) throws -> [TranslationEntity] {
        var output: [TranslationEntity] = []
        try forEachRow(statement: statement, handleRow: { (stmt, index) in
            output.append(stmt.translationEntity)
        })
        return output
    }
    
    func translationEntity(statement: String) throws -> TranslationEntity? {
        var output: TranslationEntity?
        try forEachRow(statement: statement, handleRow: { (stmt, index) in
            output = stmt.translationEntity
        })
        return output
    }
}
