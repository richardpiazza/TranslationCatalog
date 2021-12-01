import Statement
import TranslationCatalog

struct ProjectExpressionEntity: Table {
    
    enum CodingKeys: String, CodingKey {
        case projectID = "project_id"
        case expressionID = "expression_id"
    }
    
    static var schema: Schema = { ProjectExpressionEntity().schema }()
    static var projectID: AnyColumn { schema.columns[0] }
    static var expressionID: AnyColumn { schema.columns[1] }
    private var schema: Schema { Schema(name: "project_expression", columns: [_projectID, _expressionID]) }
    
    @Column(table: ProjectExpressionEntity.self, name: CodingKeys.projectID.rawValue, dataType: "INTEGER", notNull: true, foreignKey: ProjectEntity.id)
    var projectID: Int = 0
    @Column(table: ProjectExpressionEntity.self, name: CodingKeys.expressionID.rawValue, dataType: "INTEGER", notNull: true, foreignKey: ExpressionEntity.id)
    var expressionID: Int = 0
}
