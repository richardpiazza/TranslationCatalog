import Statement
import TranslationCatalog

struct ProjectExpressionEntity: Entity {
    
    static let identifier: String = "project_expression"
    
    @Field("project_id", foreignKey: ForeignKey(ProjectEntity.self, "id"))
    var projectID: Int = 0
    @Field("expression_id", foreignKey: ForeignKey(ExpressionEntity.self, "id"))
    var expressionID: Int = 0
}

extension ProjectExpressionEntity {
    static let entity = ProjectExpressionEntity()
    static var projectID: Attribute { entity["project_id"]! }
    static var expressionID: Attribute { entity["expression_id"]! }
}
