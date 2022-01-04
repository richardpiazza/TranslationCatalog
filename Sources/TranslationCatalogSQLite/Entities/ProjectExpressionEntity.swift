import Statement
import TranslationCatalog

struct ProjectExpressionEntity: Entity {
    
    let tableName: String = "project_expression"
    
    @Field("project_id", foreignKey: ForeignKey("project", "id"))
    var projectID: Int = 0
    @Field("expression_id", foreignKey: ForeignKey("expression", "id"))
    var expressionID: Int = 0
}

extension ProjectExpressionEntity {
    static var projectID: Attribute { Self["project_id"]! }
    static var expressionID: Attribute { Self["expression_id"]! }
}
