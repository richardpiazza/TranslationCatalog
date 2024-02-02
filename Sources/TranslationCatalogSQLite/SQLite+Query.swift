import TranslationCatalog
import StatementSQLite
import SQLite

// MARK: - `Project` Entity
extension Connection {
    func projectEntities(statement: String) throws -> [ProjectEntity] {
        var output: [ProjectEntity] = []
        for row in try run(statement) {
            output.append(row.projectEntity)
        }
        return output
    }
    
    func projectEntity(statement: String) throws -> ProjectEntity? {
        var output: ProjectEntity?
        for row in try run(statement) {
            output = row.projectEntity
        }
        return output
    }
}

// MARK: - `ProjectExpression` Entity
extension Connection {
    func projectExpressionEntity(statement: String) throws -> ProjectExpressionEntity? {
        var output: ProjectExpressionEntity?
        for row in try run(statement) {
            output = row.projectExpressionEntity
        }
        return output
    }
}

// MARK: - `Expression` Entity
extension Connection {
    func expressionEntities(statement: String) throws -> [ExpressionEntity] {
        var output: [ExpressionEntity] = []
        for row in try run(statement) {
            output.append(row.expressionEntity)
        }
        
        return output
    }
    
    func expressionEntity(statement: String) throws -> ExpressionEntity? {
        var output: ExpressionEntity?
        for row in try run(statement) {
            output = row.expressionEntity
        }
        return output
    }
}

// MARK: - `Translation` Entity
extension Connection {
    func translationEntities(statement: String) throws -> [TranslationEntity] {
        var output: [TranslationEntity] = []
        for row in try run(statement) {
            output.append(row.translationEntity)
        }
        return output
    }
    
    func translationEntity(statement: String) throws -> TranslationEntity? {
        var output: TranslationEntity?
        for row in try run(statement) {
            output = row.translationEntity
        }
        return output
    }
}
