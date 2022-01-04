import Statement
import StatementSQLite
import TranslationCatalog

// MARK: - ProjectExpression (Schema)
extension SQLiteStatement {
    static var createProjectExpressionEntity: Self {
        .init(
            .CREATE(
                .SCHEMA(ProjectExpressionEntity.self, ifNotExists: true)
            )
        )
    }
}

// MARK: - ProjectExpression (Queries)
extension SQLiteStatement {
    static func selectProjectExpression(projectID: Int, expressionID: Int) -> Self {
        SQLiteStatement(
            .SELECT(
                .column(ProjectExpressionEntity.projectID),
                .column(ProjectExpressionEntity.expressionID)
            ),
            .FROM(
                .TABLE(ProjectExpressionEntity.self)
            ),
            .WHERE(
                .AND(
                    .column(ProjectExpressionEntity.projectID, op: .equal, value: projectID),
                    .column(ProjectExpressionEntity.expressionID, op: .equal, value: expressionID)
                )
            )
        )
    }
    
    static func insertProjectExpression(projectID: Int, expressionID: Int) -> Self {
        SQLiteStatement(
            .INSERT_INTO(
                ProjectExpressionEntity.self,
              .column(ProjectExpressionEntity.projectID),
              .column(ProjectExpressionEntity.expressionID)
            ),
            .VALUES(
                .value(projectID as DataTypeConvertible),
                .value(expressionID as DataTypeConvertible)
            )
        )
    }
    
    static func deleteProjectExpression(projectID: Int, expressionID: Int) -> Self {
        SQLiteStatement(
            .DELETE(
                .FROM(ProjectExpressionEntity.self)
            ),
            .WHERE(
                .AND(
                    .column(ProjectExpressionEntity.projectID, op: .equal, value: projectID),
                    .column(ProjectExpressionEntity.expressionID, op: .equal, value: expressionID)
                )
            ),
            .LIMIT(1)
        )
    }
    
    static func deleteProjectExpressions(projectID: Int) -> Self {
        SQLiteStatement(
            .DELETE(
                .FROM(ProjectExpressionEntity.self)
            ),
            .WHERE(
                .column(ProjectExpressionEntity.projectID, op: .equal, value: projectID)
            )
        )
    }
    
    static func deleteProjectExpressions(expressionID: Int) -> Self {
        SQLiteStatement(
            .DELETE(
                .FROM(ProjectExpressionEntity.self)
            ),
            .WHERE(
                .column(ProjectExpressionEntity.expressionID, op: .equal, value: expressionID)
            )
        )
    }
}
